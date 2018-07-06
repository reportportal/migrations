#!/bin/sh
exec /wait-for-it.sh $POSTGRES_SERVER:$POSTGRES_PORT -- migrate -path /migrations -database postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_SERVER/$POSTGRES_DB?sslmode=disable "$@"
