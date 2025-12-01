#!/bin/bash

# Prereqs: docker-compose
#          curl

generate_post_data()
{
  cat <<EOF
{
  "name": "elasticsearch-sink",
  "config": {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
    "tasks.max": "1",
    "topics": "example-topic",
    "key.ignore": "true",
    "schema.ignore": "true",
    "connection.url": "http://localhost:9200",
    "type.name": "_doc",
    "name": "elasticsearch-sink",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable": "false",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "false",
    "transforms": "insertTS,formatTS",
    "transforms.insertTS.type": "org.apache.kafka.connect.transforms.InsertField\$Value",
    "transforms.insertTS.timestamp.field": "messageTS",
    "transforms.formatTS.type": "org.apache.kafka.connect.transforms.TimestampConverter\$Value",
    "transforms.formatTS.format": "yyyy-MM-dd'T'HH:mm:ss",
    "transforms.formatTS.field": "messageTS",
    "transforms.formatTS.target.type": "string",
    # SSL Below
    "ssl.keystore.location": "/path/to/your/keystore.jks",  # Adjust the keystore location
    "ssl.keystore.password": "your-keystore-password",     # Adjust the keystore password
    "ssl.truststore.location": "/path/to/your/truststore.jks",  # Adjust the truststore location
    "ssl.truststore.password": "your-truststore-password",     # Adjust the truststore password
    "security.protocol": "SSL",
    "basic.auth.credentials.source": "USER_INFO",
    "connection.user": "your-elasticsearch-username",         # Adjust the Elasticsearch username
    "connection.password": "your-elasticsearch-password"       # Adjust the Elasticsearch password
  }
}
EOF
}

# Restart everything from empty. The yaml file defining the
# containers has no persistent volumes.
# docker compose down
# docker compose up -d

# Give it a chance to start
echo "Waiting for 20 seconds..."
# sleep 20

# Configure kafka connect
curl -i \
-H "Content-Type:application/json" \
-X POST --data "$(generate_post_data)" "http://localhost:8083/connectors"

# Wait a little to give everything chance to stabilise
echo "Waiting for 15 seconds..."
sleep 15


exit $rc