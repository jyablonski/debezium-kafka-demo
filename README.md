# Debezium
Practice Repo with Debezium which spins up MySQL, Postgres, Kafka, Kafka Connect, Kafka UI, and a Python Producer to test CDC Implementations with Debezium.

The Example connects to 2 separate Tables, builds 2 separate Kafka Topics, and writes out all changes to 2 separate Kafka S3 Sinks using 1 Source Connector + 1 Sink Connector.  The Python Producer writes SQL Records to the `second_movies` table in Postgres every 5 seconds to test a real-time CDC use case. You can adapt the connectors to include more tables as needed for either MySQL or Postgres.

## Steps
1. Run `docker-compose up`.
2. Run `docker-compose logs -f kafka-connect` to follow logs for debugging purposes as well as to see if Debezium is sending CDC Messages.
3. Run the PUT S3 Sink Connector script in your local terminal.
4. Run the PUT Debezium Connector script in your local terminal.
5. Connect to ksql in another terminal via `docker exec -it ksqldb ksql http://ksqldb:8088`.
   1. Run `show connectors;` and `show topics;` to see if your stuff is running.
6. Login to MySQL Workbench & start screwing around with records in the `movies` table to see if CDC works & stores to S3.

## Articles
[Debugging](https://levelup.gitconnected.com/fixing-debezium-connectors-when-they-break-on-production-49fb52d6ac4e)
[S3 Sink](https://docs.confluent.io/kafka-connectors/s3-sink/current/overview.html)
[Original Debezium Repo](https://github.com/confluentinc/demo-scene/blob/master/livestreams/july-15/data/queries.sql)
[Kafka Sink Repo](https://github.com/confluentinc/demo-scene/blob/master/kafka-to-s3/docker-compose.yml)

## S3 IAM User
Create an IAM User and attach policy that looks like below, then create access/secret credentials and paste into aws_credentials

```
[default]
aws_access_key_id = xxx
aws_secret_access_key = yyy
```

S3 Policy
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::jyablonski-kafka-s3-sink"
            ]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object*",
            "Resource": [
                "arn:aws:s3:::jyablonski-kafka-s3-sink/*"
            ]
        }
    ]
}
```


S3 Sink Connector
```
curl -i -X PUT -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/jyablonski-kafka-s3-sink/config \
    -d '
 {
		"connector.class": "io.confluent.connect.s3.S3SinkConnector",
		"key.converter":"org.apache.kafka.connect.storage.StringConverter",
		"tasks.max": "1",
		"topics": "movies",
		"s3.region": "us-east-1",
		"s3.bucket.name": "jyablonski-kafka-s3-sink",
        "rotate.schedule.interval.ms": "60000",
        "timezone": "UTC",
		"flush.size": "65536",
		"storage.class": "io.confluent.connect.s3.storage.S3Storage",
		"format.class": "io.confluent.connect.s3.format.json.JsonFormat",
		"schema.generator.class": "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator",
		"schema.compatibility": "NONE",
        "partitioner.class": "io.confluent.connect.storage.partitioner.DefaultPartitioner",
        "transforms": "AddMetadata",
        "transforms.AddMetadata.type": "org.apache.kafka.connect.transforms.InsertField$Value",
        "transforms.AddMetadata.offset.field": "_offset",
        "transforms.AddMetadata.partition.field": "_partition"
	}
'
```


ksqldb Source Connector to create dummy data
`confluent-hub install --no-prompt mdrogalis/voluble:0.1.0` add to docker-compose if you want.

```
CREATE SOURCE CONNECTOR s WITH (
  'connector.class' = 'io.mdrogalis.voluble.VolubleSourceConnector',

  'genkp.owners.with' = '#{Internet.uuid}',
  'genv.owners.name.with' = '#{Name.full_name}',
  'genv.owners.creditCardNumber.with' = '#{Finance.credit_card}',

  'genk.cats.name.with' = '#{FunnyName.name}',
  'genv.cats.owner.matching' = 'owners.key',

  'genk.diets.catName.matching' = 'cats.key.name',
  'genv.diets.dish.with' = '#{Food.vegetables}',
  'genv.diets.measurement.with' = '#{Food.measurements}',
  'genv.diets.size.with' = '#{Food.measurement_sizes}',

  'genk.adopters.name.sometimes.with' = '#{Name.full_name}',
  'genk.adopters.name.sometimes.matching' = 'adopters.key.name',
  'genv.adopters.jobTitle.with' = '#{Job.title}',
  'attrk.adopters.name.matching.rate' = '0.05',
  'topic.adopters.tombstone.rate' = '0.10',

  'global.history.records.max' = '100000'
);

```

1. Single message transforms
   1. changes the data as it passes through
   2. you can add additional columns or metadata onto the messages.


Storage Class Formats:
    1. `io.confluent.connect.s3.format.parquet.ParquetFormat`
    2. `io.confluent.connect.s3.format.json.JsonFormat`
    3. `io.confluent.connect.s3.format.avro.AvroFormat`


# Debezium Config Options
`connector.class` - The Installed Connector to use

`tasks.max` - Max number of tasks for this connector. Defaults to 1, only use 1 for MySQL + Postgres

`database.hostname` - IP Address or Hostname for the Postgres Database.

`database.dbname` - The Database to connect to on the Server.

`database.server.name` - A separate, internal name for Debezium to identify the Database.

`schema.include.list` - Comma separated list of schemas you want to capture.  By default it captures every schema.

`table.include.list` - If specified, it will only capture data for these tables.  Format is `schemaName.tableName`.

`table.exclude.list` - Can alternatively exclude tables instead.  `table.include.list` and `table.exclude.list` cant both be set at the same time.

`plugin.name` - Basically just put it to `pgoutput` at all times.

`include.schema.changes` - Boolean which dictates whether to send DDL changes and send them to the a Kafka Topic w/ the same name as the database server ID.  Probably fine to set to false unless you actually plan to have a consumer read from this topic.

`snapshot.mode` - Whether to do a `select *` from all records currently in the table.  It will incrementally grab these in chunks if there's a lot.

`io.debezium.transforms.ExtractNewRecordState` - Flattens the message to only include the record after the NEW changes.  By default, Debezium will capture both the Old + New record state, but we only want the new one for CDC.

`transforms.unwrap.drop.tombstones` - When a record is deleted, 2 changes are captured by Debezium: 1 for the record as it was before the delete, and 1 that sets all the columns to null.  This parameter drops this record that has everything set to null before it sends it to Kafka.

`transforms.unwrap.delete.handling.mode: rewrite` - Creates a new column called `__deleted`.  When a record is deleted, Debezium will capture the record as it was before the delete & set the `__deleted` field to `true`.

`transforms.dropTopicPrefix.type: org.apache.kafka.connect.transforms.RegexRouter` - Used to update a Topic's name.

`transforms.dropTopicPrefix.regex` - Used to specify the structure for a Topic's name that you want to change.
- `asgard_postgres.dbz_schema.(.*)` means it will remove `asgard_postgres.dbz_schema.` in the topic name and only keep the actual topic name (`.*`)

`transforms.dropTopicPrefix.replacement` - Used to specify what to replace the filtered Regex with.  
- `$1` means it captures the first part.  `$2` would capture the second part, if you were filtering 2 different parts of a regex out or something.

# Debugging
Make sure aws credentials are in the container
`docker exec kafka-connect cat /root/.aws/credentials`

Follow logs to see if errors are happening and if Debezium CDC messages are getting sent to Kafka.
`docker-compose logs -f kafka-connect`

Show connectors to see if they're running or failing w/ a warning.
`show connectors;`


# Schema Registry
Used to capture schema information from connectors.


# Converters
Avro, Protobuf, and JsonSchemaConverter all exist to convert data from internal data types used in Kafka into data types we can store in remote storage like S3.

Sink Connectors receive schema information in addition to the data for the actual message.  Allows the sink connector to know the strucutre of the data to provide additional capabilities like maintaining a database table structure or creating/updating a search index.

JSON is easiest to debug while getting started (can download to s3 and see it), parquet might be best long term for snowflake + storage?

# Debezium Quirks
[Article](https://groups.google.com/g/debezium/c/wIByhyNN9bQ)
[Debez Article](https://debezium.io/documentation/reference/stable/connectors/mysql.html)

These 2 fkn database properties have nothing to do with the MySQL Database apparently.  They're supposed to have something to do with schema changes + the Kafka Topic. There's also some additional properties, which seems like they're writing stuff as asgard.{table_name} and the transform are to drop that prefix and the asgard.demo.(.*) is to drop the ACTUAL MySQL DB name (demo) as well.

If you have 2+ Debezium Connectors, you *CANNOT* use the same `database.server.id` or `database.server.name` for each table to do CDC on or it'll yell at you and the worker will ,,, die.

```
"database.server.id": "42",
"database.server.name": "asgard",

"include.schema.changes": "true",
"transforms": "unwrap,dropTopicPrefix",
"transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
"transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
"transforms.dropTopicPrefix.regex":"asgard.demo.(.*)",
"transforms.dropTopicPrefix.replacement":"$1",
```

## Docker Port Stuff
`-p 8080:80`	Maps TCP port 80 in the container to port 8080 on the Docker host.

## Workflow Diagram
Each MySQL/Postgres Database you have would need its own Debezium Connector, but they can all write to the same Kafka Cluster.

![image](https://user-images.githubusercontent.com/16946556/191134280-5db8097f-3130-48d1-a564-096e64748be3.png)

# Tombstones
- A tombstone record is created after a record is deleted, and it keeps the primary key and sets all other columns to null.
- You can set `delete.handling.mode = rewrite` which adds a `__deleted` column to the tables, and when that record gets deleted an "update" event happens which sets this _deleted column to true so you can filter it out downstream later on.
- If you leave tombstones on it breaks shit because certain columns aren't supposed to be null or maybe it's the schema registry that breaks it, i dont know.  so i have to set drop tombstones to true.

Adding the following properties allows you to track deletes - it will add a `__deleted` column to every record which is set to true or false depending on whether the event represents a delete operation or not.

```
"transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
"transforms.unwrap.delete.handling.mode": "rewrite",
"drop.tombstones": "true"
```
`drop.tombstones` - keeps records for DELETE operations in the event stream.  I had to default to true otherwise errors yeet.


# Redshift Sink
deletes work as-is.

adding a new column automatically works

DELETING a column fucked shit up bc it sets everything to null and that's how it defines a "deleted" column or something, but in redshift if it's a data type of like int - that can't be null so it errored out.
    - this likely doesnt matter bc when would be deleting a lot of cols?

It adds a Primary key index into the schema as well for each table.

![image](https://user-images.githubusercontent.com/16946556/197405330-a97f80a0-85e8-4f58-ae15-17a431a5460e.png)


![image](https://user-images.githubusercontent.com/16946556/197406047-5d09728a-5af6-4999-8c5f-a12264cdf868.png)
    - i can get inserts working, and deletes working, but updates on exisitng records show up as new records.
    - can distinguish based on _offset but this is still not ideal.
    - `insert.mode=update` worked, but then you cant do inserts.
    - i saw some ppl creating 3 redshift sinks for insert, update, and insert with delete.enabled=true but that's sounds meh

adding a new column doesn't get reflected in redshift until a new insert operation is executed.

you'd have to do something like below on every single table to get the most recent record.

```
with latest_records as (
    select
        id,
        max(_offset) as _offset
    from table
    group by id
)

select *
from table
inner join latest_records using (id, _offset)
```

# Snowflake Kafka Sink
Worked but shit shows up as 2 JSON metadata columns instead of the normal table data columns.  this involves additional transformations to do anything with the data.  Snowflake offers features for this like Streams + Tasks but you're also paying for those compute resources and it introduces more complexity.

S3 sink with Snowpipe set up is just about the same thing except the data actually gets loaded directly into the source tables which is the only reason we're streaming in the first place.

have to set default role + default warehouse for this kafka_user.  also, you have to use 
```
 {
		"connector.class": "com.snowflake.kafka.connector.SnowflakeSinkConnector",
		"tasks.max": "1",
		"topics": "second_movies,movies",
        "snowflake.topic2table.map": "movies:movies,second_movies:second_movies",
        "buffer.count.records":"10000",
        "buffer.flush.time":"60",
        "buffer.size.bytes":"5000000",
        "snowflake.url.name":"yyy",
        "snowflake.user.name":"aaa",
        "snowflake.private.key":"zz",
        "snowflake.private.key.passphrase":"yyyy",
        "snowflake.database.name":"kafka_db",
        "snowflake.schema.name":"kafka_schema",
        "transforms": "AddMetadata",
        "transforms.AddMetadata.type": "org.apache.kafka.connect.transforms.InsertField$Value",
        "transforms.AddMetadata.offset.field": "_offset"
	}
```
![image](https://user-images.githubusercontent.com/16946556/200147474-fd5ed40e-deb0-4038-80d0-123e00720e53.png)

# Snowflake JDBC Sink
- [Stackoverflow 1](https://stackoverflow.com/questions/69890973/kafka-jdbc-sink-connector-cant-find-tables-in-snowflake)
- [Classpath Link](https://github.com/confluentinc/demo-scene/blob/ab824ce9f97952125518487a779753cb2549bac7/ibm-demo/docker-compose.yml)
- [Classpath link 2](https://github.com/confluentinc/demo-scene/blob/master/connect-jdbc/docker-compose.yml)

## IM SO CLOSE
[Article 1](https://github.com/confluentinc/demo-scene/blob/master/oracle-and-kafka/jdbc-driver.adoc)
[Vid](https://www.youtube.com/watch?v=vI_L9irU9Pc)
[Stackoverflow of Connector](https://stackoverflow.com/questions/69890973/kafka-jdbc-sink-connector-cant-find-tables-in-snowflake)

![image](https://user-images.githubusercontent.com/16946556/208001421-c09fa05a-ffe0-42c9-bbfa-12ccb4cecf52.png)

![image](https://user-images.githubusercontent.com/16946556/208002405-26b11e92-3b8a-4f1a-95af-e2951f829baf.png)

JDBC Sink works but it's painfully slow bc it's doing a million fkn merges at once, had to give ALL PRIVILEGES bc select + insert wasn't enough.  Still have to use OracleDatabaseDialect bc it's the only one that's compatible.  Things also got fkd up if there were 2 different tables with the same name but in different databses - it didnt care what schema + db you throw in the JDBC parameters.  

Don't think it's a realistic solution.

## JDBC Errors
`Caused by: io.confluent.connect.jdbc.sink.TableAlterOrCreateException: Table "second_movies" is missing and auto-creation is disabled`
`INFO Using Generic dialect TABLE "second_movies" absent (io.confluent.connect.jdbc.dialect.GenericDatabaseDialect)`
`Caused by: io.confluent.connect.jdbc.sink.TableAlterOrCreateException: Table "kafka_db"."kafka_schema"."second_movies" is missing and auto-creation is disabl`

basically auto.create fails bc this sink doesnt have official snowflake compatibility.
insert only w/ no auto.create doesnt work either because of quote issue that i couldnt figure out.


`Cannot ALTER TABLE "SECOND_MOVIES" to add missing field SinkRecordField{schema=Schema{STRING}, name='title', isPrimaryKey=false}, as the field is not optional and does not have a default value`

# Tombstones
- A tombstone record is created after a record is deleted, and it keeps the primary key and sets all other columns to null.
- You can set `delete.handling.mode = rewrite` which adds a _deleted column to the tables, and when that record gets deleted an "update" event happens which sets this _deleted column to true so you can filter it out downstream later on.
- If you leave tombstones on it breaks shit because certain columns aren't supposed to be null or maybe it's the schema registry that breaks it, i dont know.  so i have to set drop tombstones to true.

Version: 0.0.4
