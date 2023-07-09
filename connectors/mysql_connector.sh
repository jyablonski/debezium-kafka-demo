#!/usr/bin/env bash

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
        "transforms.dropTopicPrefix.replacement":"mysql.$1",
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
        "log.retention.hours": "120",
        "database.allowPublicKeyRetrieval":"true"
    }'
