#!/usr/bin/env bash

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
        "snowflake.url.name":"yk63760.us-east-2.aws.snowflakecomputing.com:443",
        "snowflake.user.name":"kafka_user",
        "snowflake.private.key":"MIIFHDBOBgkqhkiG9w0BBQ0wQTApBgkqhkiG9w0BBQwwHAQIVT6cH+kkV8ECAggAMAwGCCqGSIb3DQIJBQAwFAYIKoZIhvcNAwcECBxMk4+XFlfdBIIEyDV7P/ccwd8D43NCUqbEBr6/brh1Gn+F7lwJt86JMV0Lg9FDcoQA802hj3gwwJ4xVWXuuKWnogR0auLpuxl5dilWgAlQe8/7ESx4lwOx4Qy+t/+Mc56RiwC6ymLRzHahDpAg9LJZaNF4t1tQ+lFBD1bdxPGgjLj10L7VEv5ejspCH+kBIpcdrpc5G9c/qz/iBhI7fWzMneSEt5+0+pYQTbjPN7RdYblJ3Dza/jk7hTpCcgFUg6EvvJM2GFcBmt+fJNWzj9zqw9maU0AqwyL6JQW/mYfueNO1zqztzCujmMETHkBAwMFDxkmVv13xeT9CA9i8+aCxasuvKy9cn4n+kUsTg/hQ/SMHi2lWlcC+44BxWi+W4Q8yq32sU4BJxCAFsDoaMkMsOL6GVYA0XfFoLmRBqQ04LsPTnaUY64DmPl/RnrV8ZgO011NP3FaqvJTwhk20cZGApWxjLMexg3771Kc3kp+jgWfkdA/VNgOQMeFEGXqix6RZOQU06MGhApDbuIvMCiuld+d2EyiqUNwvK9V6/TUyzZQ3Gn6aVKKRrqBTbXTsxoju7cxc82gPUe1/4ip2uZ5EnmTyajmXc4gpBaJE1IBFlI+wCz0ees+C0LPKhnJvd8eszzzwkWnqUNh0eTlsokplogYaS4VKA7N+QNAj59cMUhT5FTPEP3x1b2xNrKhdKBRrsZg1dp/aGUoQ/j/+OP79qCz9fzn1QtMUjCSsmSmQBcyiaBoSCOUuNuyE3FjHy0GNh6tAcW11HCRueqzdGOAKgQpT0TaYKpxX7CJ8RUGSxvjgDYDpFWbFSW8BGLqsNg2yYPLmf4ZRizAFi7gcdaA2mJ3URBRmInG7BTSkROtEjv/nRIw5/3K8V7KSWeRKXZBNo5Al+0urK7ugnkx3rHS7HNBOmqOgdOCqIa38qYaL2f6iBnJ0rauQ8dT7VmNn9JqW8ytu/NEr7wwk6ebkRmJ9bvz7LhXOqI1tapBLhDv4ZzXQ/7XBXeH9BTpqmEkOybu5b2QqRkUm+l7cHictQ2timh72IOAPfrSCdzi9f9RQpMDkmyJB35z453CSJwbBitpxSef28T9Ky0nzJ4bK/Gv7uRmPvT+gl95FQ2miLs8FufsPKggDff88rHaQJq0JjdgpiFHMqMey5oph8AxRuOQHmFD9OhywQ8+2mQZGsSEFk5yBiwv4TrLwoLPtSvZPMfDRA259VFiRcSU6FU3G3SMItoSn6VDjcP1RAMwxHF/v94prDn1er8UffYARGWr3enJtMZPmOpEv/72zjsm/90bNax3dhK8gvnUlNvwjaN+d03Vy9/IvRMgX9mQHGWsn7iyrN4XkkjJX7ngnDPE7f4wB6dTUQUAyxbFkYnG0fNDopwtdc3LrW86YpMcSFov96oZE5D2PUsHVdOl/O0ineufkhiROVs0nuNcifCAxnRzHpSV/6ki6sY+3sAO9ZFO0WOXOjzt7+mygQzzKU4gsgGES6oq0Q9EvEonkp7fm+hP3koleKYkjk8iR0JAa+Gx2M6/zE+vcWGvTd3iVNf6KJgsVrRt1SRgOQo9pbTxJgNqKw1nDBzyFls1j7/KrJk/7wA44+ODcukGJ3+fgWtpkk2uEKnntp/Ih/TCJXruZrmfQVS++JA==",
        "snowflake.private.key.passphrase":"bugger",
        "snowflake.database.name":"kafka_db",
        "snowflake.schema.name":"kafka_schema",
        "input.data.format": "AVRO",
        "transforms": "AddMetadata",
        "transforms.AddMetadata.type": "org.apache.kafka.connect.transforms.InsertField$Value",
        "transforms.AddMetadata.offset.field": "_offset"
	}
'
# "connection.url":"jdbc:snowflake://yk63760.snowflakecomputing.com/?user=kafka_user&password=testpassword123&db=kafka_db&schema=kafka_schema",


##### jdbc sink
#!/usr/bin/env bash

curl -i -X PUT -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/jyablonski-kafka-snowflake-sink4/config \
    -d '
 {
		"connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
		"tasks.max": "1",
		"topics": "second_movies,movies",
        "poll.interval.ms": 300000,
        "batch.max.rows": 1000,
        "connection.url":"jdbc:snowflake://yk63760.us-east-2.aws.snowflakecomputing.com:443/?db=kafka_db&warehouse=test_warehouse&schema=kafka_schema&role=KAFKA_CONNECTOR_ROLE_1",
        "connection.user": "kafka_user",
        "connection.password": "testpassword123",
        "auto.create": "false",
        "auto.evolve": "false",
        "delete.enabled": "true",
        "pk.mode": "record_key",
        "table.name.format": "${topic}",
        "quote.sql.identifiers": "never",
        "insert.mode": "upsert",
        "transforms": "unwrap,AddMetadata",
        "transforms.AddMetadata.type": "org.apache.kafka.connect.transforms.InsertField$Value",
        "transforms.unwrap.drop.tombstones": "true",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.delete.handling.mode": "rewrite",
        "transforms.AddMetadata.offset.field": "_offset",
        "value.converter": "io.confluent.connect.avro.AvroConverter",
        "value.converter.schema.registry.url": "http://schema-registry:8081",
        "key.converter": "io.confluent.connect.avro.AvroConverter",
        "key.converter.schema.registry.url": "http://schema-registry:8081"
	}
'


## SNOWFLAKE SINK
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
        "snowflake.url.name":"yk63760.us-east-2.aws.snowflakecomputing.com:443",
        "snowflake.user.name":"kafka_user",
        "snowflake.private.key":"MIIEpAIBAAKCAQEAtlW43VWU3KMbXSlKAzlWwr+Nt1qNGo0BC6K/HmzXTs2EwTTPGSZUxLQ7LL0BYP4eFt+xd3F66QAxJJLkZ4BlL2FwMtvZwjjX1v2Xe42YIvgyWzNxJH3pw5W6TCW/n43ELx+xDspDsg5V6OE+RLUJK6K/qukK+tapqmywgVQhl8tmGQbe5R6rRmq3oxgpT0eijK+qRRZB+3zEkVZ+3GSlXclnXTxchB71dDn3O6i6XJGqVrKXckCHz8uu5S4FDnxRUSKPXUNaIFkWnmjVzWRE0Zsyw/TKLFNCusdgFWelK110bmUKpW8RQkpu8rjs1U2nVVT/aA2t4ts3pJPehBEc8QIDAQABAoIBAQCPcWTcC4XvBgpzAhaN7sAIufXdd0lmx+M4qjI811eTUS/NZ6Q9nuA1V6zuB0tcaM53JEhTNV2CjHoc0csKegIggkFoYXkwyNNU+XAA7WXwrN3AzfmGwd/z1IkZeuEDvt3GTOJYRlt3aru/V+RK3Tl3sLOk222d5N7ZimRZejxrU267cwkOEr98lLWuNHQuwfRQAz4cSLNrYie3GhkxoQV4Uo3YEs59rhS3X7w8jxioNtUH/VXmkfyqFSTOp2/ODqJjZxqSmIAwWew1PPiVedA7MgIXISrg1Q2TlPhKrASwdFVRznt7yC9cw+pp7T8U0vbXQkeq/pXba27+bTfx/rwBAoGBAN+6gP2tFA03CiMGXYzH7CQnq6BRzjF2yG736TZyx4CagQZIeYfd5PRYUKbpb/5sJO8XubBWw60Wvc7l9Yy52I8bgCzsjeyUdj/XfTTpaH9gkVRFW344B7kfMXRWBztaYgCBYbFxA59d1O+UfjfFD8LQnwelFV/jIglsZIMiQUPRAoGBANCisouAscfhiWxyz7ZDQ0miOFUlmwajFYoJUMLEtLGFmpfxwKm6HVpJx0YSRahek7uFHCqvcZjQOSDLfbatXflu5X7SxIdFtMxQe5AdmUBoHqW8Vz+cT4SFKOJJF5X0kXwjQTq06bTR176i8MoBtASzxq+wbaZhg11hYsaL9C8hAoGBAIOcem9AlvAjNbJe9z9vCGpIb/0SwqJ0hvpImoeuQ9BSk543mk6j6SEYpvFZl8lqotuH8HNcxyWWoDgLLUUIuu2Mtv02d1L6DwoFYSF0QUXVcAjL+EOrAFgVkokmZoCy7b3wXqD8o63ni/EYQJvcMCZhhXwA0C8lNYunmQVPbGdRAoGAHyJoapEF9sIdc+WeQaDABdkDdxFplQ/5QuQo/SfFn0hEza/yBGIVx0eDSV2or3uNqEow7d3IoflQzSgQ1pYAlByMeuSRF267kFHiXptMJ2RiTnFQw9lbtHb6puopbuNUYqYQMeaVibpW68f9Dug6KQl6+PTnKBEdPW4vA1oXUoECgYA+tewfU8PY0fJ21TntDn/xszHEZ0ENHnQT34aCY958ArHgzzzH6P4RWw8sclP3kZP7tqD1JsAKVcf/Chx7tFzK9iaiuVgTNWh2KO6i7dCGB273iUxosWJQ4R7n1NB4Z5fKMgqdA5gC7FDGR4HSPXgi7EdYmE8Pu5wkxMFaNb6CVw==",
        "snowflake.database.name":"kafka_db",
        "snowflake.schema.name":"snowflake_sink",
        "input.data.format": "AVRO",
        "transforms": "AddMetadata",
        "transforms.AddMetadata.type": "org.apache.kafka.connect.transforms.InsertField$Value",
        "transforms.AddMetadata.offset.field": "_offset"
	}
'