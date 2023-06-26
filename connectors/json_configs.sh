#!/usr/bin/env bash

# postgres
curl -i -X PUT -H "Content-Type:application/json" \
  http://localhost:8083/connectors/source-debezium-postgres/config \
  -d '{
        "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
        "tasks.max": "1",
        "database.hostname": "postgres",
        "database.port": "5432",
        "database.user": "postgres",
        "database.password": "postgres",
        "database.dbname" : "postgres",
        "database.server.name": "asgard_postgres",
        "schema.include.list": "dbz_schema",
        "table.whitelist": "dbz_schema.second_movies",
        "plugin.name": "pgoutput",
        "include.schema.changes": "false",
        "snapshot.mode": "never",
        "transforms": "unwrap,dropTopicPrefix",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.drop.tombstones": "true",
        "transforms.unwrap.delete.handling.mode":"rewrite",
        "transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.dropTopicPrefix.regex":"asgard_postgres.dbz_schema.(.*)",
        "transforms.dropTopicPrefix.replacement":"postgres.$1",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "false",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable": "false",
        "log.retention.hours": "120",
        "poll.interval.ms": "30000"
    }'

# mysql
# "snapshot.mode": "never" IS DIFFERENT THAN IN POSTGRES.  in mysql it will still read from as much of the binlog as it can. 
# change to schema only
curl -i -X PUT -H "Content-Type:application/json" \
  http://localhost:8083/connectors/mysql-debezium/config \
  -d '{
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "database.hostname": "mysql",
        "database.port": "3306",
        "database.user": "debezium",
        "database.password": "dbz",
        "database.server.id": "43",
        "database.server.name": "asgard",
        "table.whitelist": "demo.movies,demo.second_movies",
        "database.history.kafka.bootstrap.servers": "broker:29092",
        "database.history.kafka.topic": "dbhistory.demo" ,
        "decimal.handling.mode": "double",
        "include.schema.changes": "false",
        "snapshot.mode": "schema_only",
        "transforms": "unwrap,dropTopicPrefix",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.drop.tombstones": "true",
        "transforms.unwrap.delete.handling.mode":"rewrite",
        "transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.dropTopicPrefix.regex":"asgard.demo.(.*)",
        "transforms.dropTopicPrefix.replacement":"mysql.$1",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "false",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable": "false",
        "log.retention.hours": "120",
        "poll.interval.ms": "30000"
    }'

# optional 2nd mysql debezium connector to see if both can run at same time.
# `mysql-debezium-test2`, `database.server.name`, `database.server.id`, `transforms.dropTopicPrefix.regex`, and `transforms.dropTopicPrefix.replacement`
# must all be differnt than the first one
# https://stackoverflow.com/questions/70504021/can-2-debezium-connectors-read-from-same-source-at-the-same-time#:~:text=Yes%2C%20you%20can%20run%20multiple,sharing%20state%20with%20one%20another.
curl -i -X PUT -H "Content-Type:application/json" \
  http://localhost:8083/connectors/mysql-debezium-test/config \
  -d '{
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "database.hostname": "mysql",
        "database.port": "3306",
        "database.user": "debezium",
        "database.password": "dbz",
        "database.server.id": "44",
        "database.server.name": "asgard2",
        "table.whitelist": "demo.movies,demo.second_movies",
        "database.history.kafka.bootstrap.servers": "broker:29092",
        "database.history.kafka.topic": "dbhistory.demo" ,
        "decimal.handling.mode": "double",
        "include.schema.changes": "false",
        "snapshot.mode": "schema_only",
        "transforms": "unwrap,dropTopicPrefix",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.drop.tombstones": "true",
        "transforms.unwrap.delete.handling.mode":"rewrite",
        "transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.dropTopicPrefix.regex":"asgard2.demo.(.*)",
        "transforms.dropTopicPrefix.replacement":"mysql2.$1",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "false",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable": "false",
        "log.retention.hours": "120",
        "poll.interval.ms": "30000"
    }'

# TIMESTAMP TRANSFORMS
# yeet fucking baby this is so stupid
# https://stackoverflow.com/questions/59328370/how-to-transform-more-than-1-field-in-kafka-connect
# "transforms.TimestampConverter1.format": "yyyy-MM-dd HH:mm:ssZ" = "2023-06-25 17:45:11+0000",
# "transforms.TimestampConverter1.format": "yyyy-MM-dd HH:mm:ssX" = "2023-06-25 17:45:11Z",
curl -i -X PUT -H "Content-Type:application/json" \
  http://localhost:8083/connectors/mysql-debezium-test2/config \
  -d '{
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "database.hostname": "mysql",
        "database.port": "3306",
        "database.user": "debezium",
        "database.password": "dbz",
        "database.server.id": "44",
        "database.server.name": "asgard2",
        "table.whitelist": "demo.movies,demo.second_movies",
        "database.history.kafka.bootstrap.servers": "broker:29092",
        "database.history.kafka.topic": "dbhistory.demo" ,
        "decimal.handling.mode": "double",
        "include.schema.changes": "false",
        "snapshot.mode": "schema_only",
        "transforms": "unwrap,dropTopicPrefix,TimestampConverter1,TimestampConverter2,TimestampConverter3",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.drop.tombstones": "true",
        "transforms.unwrap.delete.handling.mode":"rewrite",
        "transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.dropTopicPrefix.regex":"asgard2.demo.(.*)",
        "transforms.dropTopicPrefix.replacement":"mysql2.$1",
        "transforms.TimestampConverter1.type": "org.apache.kafka.connect.transforms.TimestampConverter$Value",
        "transforms.TimestampConverter1.field": "created_at_datetime",
        "transforms.TimestampConverter1.format": "yyyy-MM-dd HH:mm:ssX",
        "transforms.TimestampConverter1.target.type": "string",
        "transforms.TimestampConverter2.type": "org.apache.kafka.connect.transforms.TimestampConverter$Value",
        "transforms.TimestampConverter2.field": "created_at_wtf",
        "transforms.TimestampConverter2.format": "yyyy-MM-dd HH:mm:ssX",
        "transforms.TimestampConverter2.target.type": "string",
        "transforms.TimestampConverter3.type": "org.apache.kafka.connect.transforms.TimestampConverter$Value",
        "transforms.TimestampConverter3.field": "this_doesnt_exist",
        "transforms.TimestampConverter3.format": "yyyy-MM-dd HH:mm:ssX",
        "transforms.TimestampConverter3.target.type": "string",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "false",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable": "false",
        "log.retention.hours": "120"
    }'

# ORYAN JAR
curl -i -X PUT -H "Content-Type:application/json" \
  http://localhost:8083/connectors/mysql-debezium-test/config \
  -d '{
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "database.hostname": "mysql",
        "database.port": "3306",
        "database.user": "debezium",
        "database.password": "dbz",
        "database.server.id": "44",
        "database.server.name": "asgard2",
        "table.whitelist": "demo.movies,demo.second_movies",
        "database.history.kafka.bootstrap.servers": "broker:29092",
        "database.history.kafka.topic": "dbhistory.demo" ,
        "decimal.handling.mode": "double",
        "include.schema.changes": "false",
        "snapshot.mode": "schema_only",
        "transforms": "unwrap,dropTopicPrefix",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.drop.tombstones": "true",
        "transforms.unwrap.delete.handling.mode":"rewrite",
        "transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.dropTopicPrefix.regex":"asgard2.demo.(.*)",
        "transforms.dropTopicPrefix.replacement":"mysql2.$1",
        "converters": "timestampConverter",
        "timestampConverter.type": "oryanmoshe.kafka.connect.util.TimestampConverter",
        "timestampConverter.format.time": "HH:mm:ss.SSS",
        "timestampConverter.format.date": "YYYY-MM-dd",
        "timestampConverter.format.datetime": "YYYY-MM-dd'T'HH:mm:ss.SSS'Z'",
        "timestampConverter.debug": "false",
        "key.converter": "org.apache.kafka.connect.json.JsonConverter",
        "key.converter.schemas.enable": "false",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable": "false",
        "log.retention.hours": "120",
        "poll.interval.ms": "30000"
    }'

curl -i -X PUT -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/jyablonski-kafka-s3-sink-postgres/config \
    -d '
 {
		"connector.class": "io.confluent.connect.s3.S3SinkConnector",
		"key.converter":"org.apache.kafka.connect.json.JsonConverter",
		"key.converter.schemas.enable": "false",
		"value.converter.schemas.enable": "false",
		"value.converter": "org.apache.kafka.connect.json.JsonConverter",
		"tasks.max": "1",
		"topics": "mysql.movies",
		"s3.region": "us-east-1",
		"s3.bucket.name": "jyablonski-kafka-s3-sink",
        "rotate.schedule.interval.ms": "300000",
        "timezone": "UTC",
		"flush.size": "65536",
		"storage.class": "io.confluent.connect.s3.storage.S3Storage",
		"format.class": "io.confluent.connect.s3.format.json.JsonFormat",
		"schema.generator.class": "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator",
		"schema.compatibility": "NONE",
        "partitioner.class": "io.confluent.connect.storage.partitioner.DefaultPartitioner",
        "transforms": "AddMetadata",
        "transforms.AddMetadata.type": "org.apache.kafka.connect.transforms.InsertField$Value",
        "transforms.AddMetadata.offset.field": "_offset"
	}
'