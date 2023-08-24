#!/bin/bash

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

# Create the template
function create_template() {

  response=$(curl -k -s -o /dev/null -w "%{http_code}" --location --head "$OS_PROTOCOL://$OS_HOST:$OS_PORT/_index_template/$TEMPLATE_NAME" -u $OS_USER:$OS_PASSWORD)

  case $response in
  404)
    result=$(curl -k -s -o /dev/null -w "%{http_code}" -X PUT "$OS_PROTOCOL://$OS_HOST:$OS_PORT/_index_template/$TEMPLATE_NAME" -H "Content-Type: application/json" -d "$TEMPLATE_DATA" -u $OS_USER:$OS_PASSWORD)
    case "$result" in 
    200)
      echo "Template '$TEMPLATE_NAME' created."
      ;;
    *)
      echo "$result Something went wrong."
      ;;
    esac ;;
  200)
    echo "Template '$TEMPLATE_NAME' already exists."
    ;;
  401)
    echo "$response Unable to authenticate user '$OS_USER' for REST request."
    ;;
  503)
    echo "$response Service Unavailable. Retrying in 3 seconds..."
    sleep 3
    create_template
    ;;
  000)
    echo "Connection error to '$OS_PROTOCOL://$OS_HOST:$OS_PORT'."
    ;;
  *)
    echo "$response Something went wrong."
    ;;
  esac
}

create_template
