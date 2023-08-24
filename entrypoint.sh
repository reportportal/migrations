#!/bin/sh

if [ ! -z $OS_HOST ]; then

  if [ ! -z $POSTGRES_PASSWORD_FILE ]; then
    export POSTGRES_PASSWORD=$(cat $POSTGRES_PASSWORD_FILE)
  fi

  exec /wait-for-it.sh $POSTGRES_SERVER:$POSTGRES_PORT -t 0 -- migrate -path /migrations -database postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_SERVER:$POSTGRES_PORT/$POSTGRES_DB?sslmode=$POSTGRES_SSLMODE "$@" \
    & exec /wait-for-it.sh $OS_HOST:$OS_PORT -t 0 -- ./index-template-setup.sh

else

  if [ ! -z $POSTGRES_PASSWORD_FILE ]; then
    export POSTGRES_PASSWORD=$(cat $POSTGRES_PASSWORD_FILE)
  fi

  exec /wait-for-it.sh $POSTGRES_SERVER:$POSTGRES_PORT -t 0 -- migrate -path /migrations -database postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_SERVER:$POSTGRES_PORT/$POSTGRES_DB?sslmode=$POSTGRES_SSLMODE "$@"

fi
