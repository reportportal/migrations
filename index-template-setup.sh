#!/bin/bash

# # Elasticsearch URL
# ES_HOST="localhost"

# # Elasticsearch port
# ES_PORT="9200"

# # Elasticsearch user
# ES_USER="elastic"

# # Elasticsearch user password
# ES_PASSWORD="elastic1q2w3e"

# Index template name
TEMPLATE_NAME="logs"

# JSON data for the index template
TEMPLATE_DATA='
{
  "index_patterns": ["logs-*-*"],
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
response=$(curl -s -o /dev/null -w "%{http_code}" --location --head "$ES_HOST:$ES_PORT/_index_template/$TEMPLATE_NAME" -u $ES_USER:$ES_PASSWORD)

case $response in
404)
    # Create the template
    curl -X PUT "$ES_HOST:$ES_PORT/_index_template/$TEMPLATE_NAME" -H "Content-Type: application/json" -d "$TEMPLATE_DATA" -u $ES_USER:$ES_PASSWORD
    echo "Template '$TEMPLATE_NAME' created."
  ;;
200)
  echo "Template '$TEMPLATE_NAME' already exists."
  ;;
401)
  echo  "Unable to authenticate user '$ES_USER' for REST request."
  ;;
000)
  echo "Can't connect to serviver on '$ES_HOST:$ES_PORT'."
  ;;
*)
  echo "$response"
  echo "Something went wrong."
  ;;
esac
