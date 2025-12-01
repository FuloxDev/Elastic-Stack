#!/bin/bash
# Load the .env file
source ./.env
# or alternatively
# . ./.env

# Now use the variables

curl -k -X GET "https://localhost:9200/_cat/indices?v&s=store.size:desc" -u "elastic:$ELASTIC_PASSWORD"