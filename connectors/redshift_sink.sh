#!/usr/bin/env bash

curl -i -X PUT -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/jyablonski-kafka-redshift-sink-postgres/config \
    -d '
 {
        "confluent.topic.bootstrap.servers": "broker:29092",
        "confluent.license.topic.replication.factor": "1",
        "confluent.topic.replication.factor": "1",
		"connector.class": "io.confluent.connect.aws.redshift.RedshiftSinkConnector",
		"tasks.max": "1",
		"topics": "second_movies,movies",
        "aws.redshift.domain": "jyablonski-test-cluster.c0d1rid7802w.us-east-1.redshift.amazonaws.com",
        "aws.redshift.port": "5439",
        "aws.redshift.database": "dev",
        "aws.redshift.user": "jacob",
        "aws.redshift.password": "zzz",
        "auto.create": "true",
        "auto.evolve": "true",
        "pk.mode": "record_key",
        "delete.enabled": "true",
        "table.name.format": "dbz.${topic}",
        "insert.mode": "insert",
        "transforms": "AddMetadata",
        "transforms.AddMetadata.type": "org.apache.kafka.connect.transforms.InsertField$Value",
        "transforms.AddMetadata.offset.field": "_offset"
	}
'