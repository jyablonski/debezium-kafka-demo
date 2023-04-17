#!/usr/bin/env bash

# postgres
# mysql
# "snapshot.mode": "never" IS DIFFERENT THAN IN POSTGRES.  in mysql it will still read from as much of the binlog as it can. 
# there change it to schema only so it wont read anything until brand new cdc updates get captured
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
        "table.whitelist": "demo.movies,demo.second_movies,demo.test_table1,demo.test_table2,demo.test_table3,demo.test_table4,demo.test_table5,demo.test_table6,demo.test_table7,demo.test_table8,demo.test_table9,demo.test_table10",
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
