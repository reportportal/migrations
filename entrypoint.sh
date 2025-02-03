#!/bin/sh

# writing this in sh so we don't need to install extra dependencies.
urlencode() {
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    i=0
    while [ $i -lt $length ]; do
        c="$(expr substr "$1" $((i + 1)) 1)"
        case $c in
            [a-zA-Z0-9.~_-]) printf "%s" "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
        i=$((i + 1))
    done

    LC_COLLATE=$old_lc_collate
}


if [ ! -z $POSTGRES_PASSWORD_FILE ]; then
  export POSTGRES_PASSWORD=$(cat $POSTGRES_PASSWORD_FILE)
fi

ENCODED_PASSWORD=$(urlencode $POSTGRES_PASSWORD)
ENCODED_USER=$(urlencode $POSTGRES_USER)

if [ ! -z $OS_HOST ]; then

  /wait-for-it.sh $POSTGRES_SERVER:$POSTGRES_PORT -t 0 -- migrate -path /migrations -database postgres://$ENCODED_USER:$ENCODED_PASSWORD@$POSTGRES_SERVER:$POSTGRES_PORT/$POSTGRES_DB?sslmode=$POSTGRES_SSLMODE "$@" \
  & /wait-for-it.sh $OS_HOST:$OS_PORT -t 0 -- ./index-template-setup.sh \
  ; wait

else

  exec /wait-for-it.sh $POSTGRES_SERVER:$POSTGRES_PORT -t 0 -- migrate -path /migrations -database postgres://$ENCODED_USER:$ENCODED_PASSWORD@$POSTGRES_SERVER:$POSTGRES_PORT/$POSTGRES_DB?sslmode=$POSTGRES_SSLMODE "$@"

fi
