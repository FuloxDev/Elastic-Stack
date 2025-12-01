#!/bin/bash
# Load the .env file
source ./.env
# or alternatively
# . ./.env

# Now use the variables

curl -k -X PUT "https://localhost:9200/_ilm/policy/data_cleanup_policy" \
  -H "Content-Type: application/json" \
  -u "elastic:$ELASTIC_PASSWORD" \
  -d '{
    "policy": {
      "phases": {
        "hot": {
          "min_age": "0ms",
          "actions": {}
        },
        "warm": {
          "min_age": "7d",
          "actions": {
            "shrink": {
              "number_of_shards": 1
            },
            "forcemerge": {
              "max_num_segments": 1
            }
          }
        },
        "delete": {
          "min_age": "30d",
          "actions": {
            "delete": {
              "delete_searchable_snapshot": true
            }
          }
        }
      }
    }
  }'



  curl -k -X PUT "https://localhost:9200/_index_template/template_with_cleanup" \
  -H "Content-Type: application/json" \
  -u "elastic:$ELASTIC_PASSWORD" \
  -d '{
    "index_patterns": ["filebeat-*", "metricbeat-*", "logstash-*"],
    "template": {
      "settings": {
        "index.lifecycle.name": "data_cleanup_policy",
        "index.lifecycle.rollover_alias": "logs"
      }
    }
  }'