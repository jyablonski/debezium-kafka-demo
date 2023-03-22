# Steps to get an EC2 Small Instance up & running with docker-compose and a Schema Registry for MSK
open port 8081 in security group of ec2 instance cluster

```
sudo mkdir -p /usr/share/java/aws
sudo wget -P /usr/share/java/aws https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.1/aws-msk-iam-auth-1.1.1-all.jar
sudo chmod -R 444 /usr/share/java/aws

sudo amazon-linux-extras install docker
sudo yum install docker 
sudo service docker start 
sudo groupadd docker
sudo usermod -a -G docker ec2-user 
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

reboot instance and then run `sudo service docker start`
docker-compuse up
```

# Debezium Configs
```
# OLD 
"key.converter": "io.confluent.connect.avro.AvroConverter",
"key.converter.schema.registry.url": "http://schema-registry:8081",
"value.converter": "io.confluent.connect.avro.AvroConverter",
"value.converter.schema.registry.url": "http://schema-registry:8081"


# NEW
"key.converter": "io.confluent.connect.avro.AvroConverter",
"key.converter.schema.registry.url": "http://10-0-0-84.ec2.internal:8081",
"value.converter": "io.confluent.connect.avro.AvroConverter",
"value.converter.schema.registry.url": "http://10-0-0-84.ec2.internal:8081"
```

# Docker-compose file
make sure you fill in the docker-compose.yml env vars properly to the msk cluster that's built

```
version: '2'
services:
  schema-registry:
      image: confluentinc/cp-schema-registry:5.4.6-1-ubi8
      hostname: schema-registry
      container_name: schema-registry
      ports:
        - "8081:8081"
      volumes:
        - /usr/share/java/aws/aws-msk-iam-auth-1.1.1-all.jar:/usr/share/java/cp-base-new/aws-msk-iam-auth-1.1.1-all.jar
        - /usr/share/java/aws/aws-msk-iam-auth-1.1.1-all.jar:/usr/share/java/rest-utils/aws-msk-iam-auth-1.1.1-all.jar
      environment: # https://docs.confluent.io/platform/current/schema-registry/installation/config.html#schemaregistry-config
        SCHEMA_REGISTRY_LISTENERS: http://0.0.0.0:8081
        SCHEMA_REGISTRY_HOST_NAME: "${HOSTNAME}" # 
        SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS: "${BOOTSTRAP_BROKERS_SASL_IAM}"
        SCHEMA_REGISTRY_KAFKASTORE_SECURITY_PROTOCOL: "SASL_SSL"
        SCHEMA_REGISTRY_KAFKASTORE_SASL_MECHANISM: "AWS_MSK_IAM"
        SCHEMA_REGISTRY_KAFKASTORE_SASL_JAAS_CONFIG: "software.amazon.msk.auth.iam.IAMLoginModule required awsDebugCreds=true;"
        SCHEMA_REGISTRY_KAFKASTORE_SASL_CLIENT_CALLBACK_HANDLER_CLASS: "software.amazon.msk.auth.iam.IAMClientCallbackHandler"
```
