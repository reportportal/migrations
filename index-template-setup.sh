#!/bin/bash

## Elasticsearch URL
#ES_HOST="localhost:9200"
#
## Elasticsearch user
#ES_USER="elastic"
#
## Elasticsearch user password
#ES_PASSWORD="elastic1q2w3e"

# Index template name
TEMPLATE_NAME="test"

# JSON data for the index template
TEMPLATE_DATA='
{
  "index_patterns": ["test-*-*"],
  "data_stream": {},
  "priority": 100,
  "template":{
    "settings": {
      "index": {
        "query": {
          "default_field": [
            "message"
          ]
        }
      }
    },
    "mappings": {
      "properties": {
        "timestamp": {
          "type": "date"
        },
        "message": {
          "type": "text"
        }
      }
    }
  }
}
'

# Check if the template exists
response=$(curl -s -o /dev/null -w "%{http_code}" --location --head "$ES_HOST/_index_template/$TEMPLATE_NAME" -u $ES_USER:$ES_PASSWORD)

case $response in
404)
    # Create the template
    curl -X PUT "$ES_HOST/_index_template/$TEMPLATE_NAME" -H "Content-Type: application/json" -d "$TEMPLATE_DATA" -u $ES_USER:$ES_PASSWORD
    echo "Template $TEMPLATE_NAME created."
  ;;
200)
  echo "Template $TEMPLATE_NAME already exists."
  ;;
401)
  echo  "Unable to authenticate user $ELASTICSEARCH_USER for REST request."
  ;;
000)
  echo "Connection error. Host $ELASTICSEARCH_URL"
  ;;
*)
  echo "$response"
  echo "Undefine error."
  ;;
esac
