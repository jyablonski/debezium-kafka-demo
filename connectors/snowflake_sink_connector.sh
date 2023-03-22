#!/usr/bin/env bash

# dumps data into RECORD_CONTENT and RECORD_METADATA variant blobs, fkn useless dude.  requires setting up snowflake streams + tasks after
curl -i -X PUT -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/jyablonski-kafka-snowflake-sink/config \
    -d '
 {
		"connector.class": "com.snowflake.kafka.connector.SnowflakeSinkConnector",
		"tasks.max": "1",
		"topics": "second_movies,movies",
        "snowflake.topic2table.map": "movies:movies,second_movies:second_movies",
        "buffer.count.records":"10000",
        "buffer.flush.time":"60",
        "buffer.size.bytes":"5000000",
        "snowflake.url.name":"xxx.us-east-2.aws.snowflakecomputing.com:443",
        "snowflake.user.name":"kafka_user",
        "snowflake.private.key":"yyy",
        "snowflake.database.name":"kafka_db",
        "snowflake.schema.name":"snowflake_sink",
        "input.data.format": "AVRO",
        "transforms": "AddMetadata",
        "transforms.AddMetadata.type": "org.apache.kafka.connect.transforms.InsertField$Value",
        "transforms.AddMetadata.offset.field": "_offset"
	}
'
