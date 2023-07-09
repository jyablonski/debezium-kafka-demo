# Debezium
Practice Repo with Debezium which spins up MySQL, Postgres, Kafka, Kafka Connect, Kafka UI (`http://localhost:8080`), and an optional Python Producer to test CDC Implementations with Debezium as well as other Data Engineering use cases.

This Repo is setup to test Debezium for both MySQL & Postgres.  Debezium Connector Configs + S3 Sinks can be found in the `connectors/` directory. The Python Producer can be used to write out SQL Records to the `second_movies` table in Postgres every 5 seconds to test a real-time CDC use case. You can adapt the connectors to include more tables as needed.

## Steps
1. Run `make up`
2. Submit one of the Debezium Connectors for either Postgres or MySQL found in the `connectors/` directory
3. Submit one of the S3 Sinks (make sure the `topics` parameter matches your Kafka Topic names) found in the `connectors/s3_sink.sh` file
   1. You'll need to setup an `aws_credentials` file at the root of the directory in order to pass credentials for any S3 Sink to work
4. Spin up the Kafka UI at `http://localhost:8080` to view the Topics, Messages in the Topics, and the status of the Connectors
5. Spin up your DB tool of choice and make record changes in the tables connected to your connectors to see the changes be captured by Debezium & sent off to the Kafka Topics
6. When finished, run `make down`

## Workflow Diagram
Each MySQL/Postgres Database you have would need its own Debezium Connector, but they can all write to the same Kafka Cluster.

![image](https://user-images.githubusercontent.com/16946556/191134280-5db8097f-3130-48d1-a564-096e64748be3.png)

## Articles
- [Debugging](https://levelup.gitconnected.com/fixing-debezium-connectors-when-they-break-on-production-49fb52d6ac4e)
- [S3 Sink](https://docs.confluent.io/kafka-connectors/s3-sink/current/overview.html)
- [Original Debezium Repo](https://github.com/confluentinc/demo-scene/blob/master/livestreams/july-15/data/queries.sql)
- [Kafka Sink Repo](https://github.com/confluentinc/demo-scene/blob/master/kafka-to-s3/docker-compose.yml)

## S3 Sink - IAM User
To use the S3 Sink, create an IAM User in your AWS Account and attach policy that looks like below, then create access/secret credentials and paste into a `aws_credentials` file at the root of the directory

`aws_credentials`
```
[default]
aws_access_key_id = xxx
aws_secret_access_key = yyy
```

Example S3 Policy to write to an S3 Bucket called `jyablonski-kafka-s3-sink`
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


Example S3 Sink Connector
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

Storage Class Formats:
 1. `io.confluent.connect.s3.format.parquet.ParquetFormat`
 2. `io.confluent.connect.s3.format.avro.AvroFormat`
 3. `io.confluent.connect.s3.format.json.JsonFormat`
    1. JSON is the only one that will work out of the box; Parquet + Avro require a Schema Registry Container + additional Config Parameters to be setup to point at the Schema Registry in order for them to work.


## Debezium Config Options Explanations
`connector.class` - The Installed Connector to use

`tasks.max` - Max number of tasks for this connector. Defaults to 1, only use 1 for MySQL + Postgres

`database.server.id` (MySQL only) - Must be a **UNIQUE** value if multiple Debezium Connectors are hooked up to that specific Database.  If they're the same database server ID then you will encounter errors.

`database.hostname` - IP Address or Hostname for the Postgres Database.

`database.dbname` - The Database to connect to on the Server.

`database.server.name` - A separate, internal name for Debezium to identify the Database.

`schema.include.list` - Comma separated list of schemas you want to capture.  By default it captures every schema.

`table.include.list` - If specified, it will only capture data for these tables.  Format is `schemaName.tableName`.

`table.exclude.list` - Can alternatively exclude tables instead.  `table.include.list` and `table.exclude.list` cant both be set at the same time.

`plugin.name` (Postgres only) - Basically just put it to `pgoutput` at all times.

`include.schema.changes` - Boolean which dictates whether to send DDL changes and send them to the a Kafka Topic w/ the same name as the database server ID.  Probably fine to set to false unless you actually plan to have a consumer read from this topic.

`snapshot.mode` - Whether to do a `select *` from all records currently in the table.  It will incrementally grab these in chunks if there's a lot.
  - *NOTE* Values for this parameter mean different things in MySQL + Postgres.  If you don't want to re-capture 100% of data when the Connectors boots up, for Postgres it can be set to `never`, while in MySQL it has to be set to `schema_only`.

`io.debezium.transforms.ExtractNewRecordState` - Flattens the message to only include the record after the NEW changes.  By default, Debezium will capture both the Old + New record state, but we only want the new one for CDC + Data Engineering use cases.

`transforms.unwrap.drop.tombstones` - When a record is deleted, 2 changes are captured by Debezium: 1 for the record as it was before the delete, and 1 that sets all the columns to null.  If set to true, this parameter drops this record that has everything set to null before it sends it to Kafka which is what we want for DE use cases.

`transforms.unwrap.delete.handling.mode: rewrite` - Creates a new column called `__deleted`.  When a record is deleted, Debezium will capture the record as it was before the delete & set the `__deleted` field to `true`.

`transforms.dropTopicPrefix.type: org.apache.kafka.connect.transforms.RegexRouter` - Used to update a Topic's name.

`transforms.dropTopicPrefix.regex` - Used to specify the structure for a Topic's name that you want to change.
- `asgard_postgres.dbz_schema.(.*)` means it will remove `asgard_postgres.dbz_schema.` in the topic name and only keep the actual topic name (`.*`)

`transforms.dropTopicPrefix.replacement` - Used to specify what to replace the filtered Regex with.  
- `$1` means it captures the first part.  `$2` would capture the second part, if you were filtering 2 different parts of a regex out or something.

## Schema Registry
Used to capture schema information from connectors.

If you want to use a Parquet or Avro Sink Format for the Sink files, then you must use a Schema Registry.  The following key + value converter parameters must be set on the *Debezium* Connector so the records are initially written with the appropriate Schema Metadata in the system.

```
"key.converter": "io.confluent.connect.avro.AvroConverter",
"key.converter.enhanced.avro.schema.support": "true",
"key.converter.schema.registry.url": "http://schema-registry:8081",
"value.converter": "io.confluent.connect.avro.AvroConverter",
"value.converter.enhanced.avro.schema.support": "true",
"value.converter.schema.registry.url": "http://schema-registry:8081"
```

And the S3 Sink would subsequently need these parameters to write out to Parquet

```
"storage.class": "io.confluent.connect.s3.storage.S3Storage",
"format.class": "io.confluent.connect.s3.format.parquet.ParquetFormat",
"schema.generator.class": "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator",
"schema.compatibility": "NONE",
"partitioner.class": "io.confluent.connect.storage.partitioner.DefaultPartitioner"
```

## Mutliple Debezium Connectors on 1 Database
[Article](https://groups.google.com/g/debezium/c/wIByhyNN9bQ)
[Debez Article](https://debezium.io/documentation/reference/stable/connectors/mysql.html)

These 2 database properties have nothing to do with the MySQL Database apparently.  They're supposed to have something to do with schema changes + the Kafka Topic. There's also some additional properties, which seems like they're writing stuff as asgard.{table_name} and the transform are to drop that prefix and the asgard.demo.(.*) is to drop the ACTUAL MySQL DB name (demo) as well.

If you have 2+ Debezium Connectors, you *CANNOT* use the same `database.server.id` or `database.server.name` for each table to do CDC on or it'll yell at you and the worker will die.

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

## What are Tombstones
- A tombstone record is created after a record is deleted, and it keeps the primary key and sets all other columns to null.
- You can set `delete.handling.mode = rewrite` which adds a `__deleted` column to the tables, and when that record gets deleted an "update" event happens which sets this _deleted column to true so you can filter it out downstream later on.
- If you set ` "transforms.unwrap.drop.tombstones": "false",` it breaks shit because it leaves the deleted records in there with all columns set to NULL, but certain columns aren't supposed to be null or maybe it's the schema registry that sees them and freaks out and causes errors, i dont know.  This parameter should always be set to `true`

Adding the following properties allows you to track deletes - it will add a `__deleted` column to every record which is set to true or false depending on whether the event represents a delete operation or not.

```
"transforms": "unwrap",
"transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
"transforms.unwrap.delete.handling.mode": "rewrite",
"transforms.unwrap.drop.tombstones": "true"
```