#!/bin/bash

# Load environment variables
source ./.env

# Variables
ES_URL="https://localhost:9200"
ES_USER="elastic"
ES_PASS="$ELASTIC_PASSWORD"
DAYS_TO_KEEP=30

# Get current date in epoch seconds
NOW=$(date +%s)
# Calculate cutoff date in milliseconds (Elasticsearch uses ms)
CUTOFF=$((($NOW - ($DAYS_TO_KEEP * 86400)) * 1000))

echo "Deleting indices older than $DAYS_TO_KEEP days..."

# Get list of indices with creation dates
INDICES=$(curl -k -s -u "$ES_USER:$ES_PASS" "$ES_URL/_cat/indices?h=index,creation.date.string,creation.date&s=creation.date:asc")

# Loop through indices and delete old ones
echo "$INDICES" | while read -r INDEX CREATE_DATE CREATE_TIMESTAMP; do
  if [ -n "$CREATE_TIMESTAMP" ] && [ "$CREATE_TIMESTAMP" -lt "$CUTOFF" ]; then
    echo "Deleting old index: $INDEX (created on $CREATE_DATE)"
    curl -k -s -X DELETE -u "$ES_USER:$ES_PASS" "$ES_URL/$INDEX"
    echo ""
  fi
done

echo "Cleanup complete"