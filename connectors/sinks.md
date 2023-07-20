### Redshift Sink
Adding new columns + deleting records worked fine out of the box. Deleting a column fucked shit up because it sets everything to NULL

It adds a Primary key index into the schema as well for each table.

![image](https://user-images.githubusercontent.com/16946556/197405330-a97f80a0-85e8-4f58-ae15-17a431a5460e.png)


![image](https://user-images.githubusercontent.com/16946556/197406047-5d09728a-5af6-4999-8c5f-a12264cdf868.png)
  - I can get inserts working, and deletes working, but updates on exisitng records show up as new records.
  - `insert.mode=update` worked, but then you cant do inserts.
  - I saw some ppl creating 3 redshift sinks for insert, update, and insert with `delete.enabled=true` but that's sounds meh
  - Adding a new column doesn't get reflected in redshift until a new insert operation is executed.

TLDR you'll have to do extensive testing when using the Redshift Sink to figure out what it can/can't do out of the box.  More than likely you'll need 3 separate Redshift Sinks each capturing Insert, Update, and Delete Events respectively.


You'd have to do de-dupe the records and order by offset to find the most recent record if updated records in the OLTP Tables kept showing up as new inserts in Redshift.

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

### Snowflake Kafka Sink (Official)
Worked but records shows up as 2 JSON metadata columns instead of the normal table data columns.  This requires additional transformations to do anything with the data.  Snowflake offers features for this like Streams + Tasks but you're also paying for those compute resources and it introduces more complexity.

S3 Sink with Snowpipe set up is just about the same thing except the data actually gets loaded directly into the source tables which is the only reason we're streaming in the first place.

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
- They're just JSON Blobs.  
- Each table would need specific SQL Code to unnest that JSON data; it's easy but it's tedious as fuck

### Snowflake JDBC Sink
- [Stackoverflow 1](https://stackoverflow.com/questions/69890973/kafka-jdbc-sink-connector-cant-find-tables-in-snowflake)
- [Classpath Link](https://github.com/confluentinc/demo-scene/blob/ab824ce9f97952125518487a779753cb2549bac7/ibm-demo/docker-compose.yml)
- [Classpath link 2](https://github.com/confluentinc/demo-scene/blob/master/connect-jdbc/docker-compose.yml)
- [Article 1](https://github.com/confluentinc/demo-scene/blob/master/oracle-and-kafka/jdbc-driver.adoc)
- [Vid](https://www.youtube.com/watch?v=vI_L9irU9Pc)
- [Stackoverflow of Connector](https://stackoverflow.com/questions/69890973/kafka-jdbc-sink-connector-cant-find-tables-in-snowflake)

![image](https://user-images.githubusercontent.com/16946556/208001421-c09fa05a-ffe0-42c9-bbfa-12ccb4cecf52.png)

![image](https://user-images.githubusercontent.com/16946556/208002405-26b11e92-3b8a-4f1a-95af-e2951f829baf.png)

Using the Generic JDBC Sink in Snowflake works but it's painfully slow bc it's doing a million fkn merges at once, had to give ALL PRIVILEGES bc select + insert wasn't enough.  Still have to use `OracleDatabaseDialect`` bc it's the only one that's compatible.  Things also got fkd up if there were 2 different tables with the same name but in different databses - it didnt care what schema + db you throw in the JDBC parameters.
- Snowflake Dialect likely will never be a thing because the Devs didn't want to be responsible for continuously paying Snowflake to run Integration Tests, which would be required in order to support the Sink which is reasonable.

Don't think it'll ever a realistic solution.

#### fin