#!/usr/bin/env bash

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
        "table.whitelist": "dbz_schema.movies",
        "plugin.name": "pgoutput",
        "include.schema.changes": "true",
        "snapshot.mode": "never",
        "transforms": "unwrap,dropTopicPrefix",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.drop.tombstones": "true",
        "transforms.unwrap.delete.handling.mode":"rewrite",
        "transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
        "transforms.dropTopicPrefix.regex":"asgard_postgres.dbz_schema.(.*)",
        "transforms.dropTopicPrefix.replacement":"$1",
        "key.converter": "io.confluent.connect.avro.AvroConverter",
        "key.converter.enhanced.avro.schema.support": "true",
        "key.converter.schema.registry.url": "http://schema-registry:8081",
        "value.converter": "io.confluent.connect.avro.AvroConverter",
        "value.converter.enhanced.avro.schema.support": "true",
        "value.converter.schema.registry.url": "http://schema-registry:8081"
    }'