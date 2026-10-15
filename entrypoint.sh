#!/bin/sh

# writing this in sh so we don't need to install extra dependencies.
urlencode() {
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    _ue_str="$1"
    while [ -n "$_ue_str" ]; do
        _ue_c="${_ue_str%"${_ue_str#?}"}"
        _ue_str="${_ue_str#?}"
        case $_ue_c in
            [a-zA-Z0-9.~_-]) printf "%s" "$_ue_c" ;;
            *) printf '%%%02X' "'$_ue_c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

if [ -n "$POSTGRES_PASSWORD_FILE" ]; then
  export POSTGRES_PASSWORD=$(cat "$POSTGRES_PASSWORD_FILE")
fi

ENCODED_PASSWORD=$(urlencode "$POSTGRES_PASSWORD")
ENCODED_USER=$(urlencode "$POSTGRES_USER")

if [ -n "$OS_HOST" ]; then

  /wait-for-it.sh $POSTGRES_SERVER:$POSTGRES_PORT -t 0 -- migrate -path /migrations -database postgres://$ENCODED_USER:$ENCODED_PASSWORD@$POSTGRES_SERVER:$POSTGRES_PORT/$POSTGRES_DB?sslmode=$POSTGRES_SSLMODE "$@" \
  & /wait-for-it.sh $OS_HOST:$OS_PORT -t 0 -- ./index-template-setup.sh \
  ; wait

else

  exec /wait-for-it.sh $POSTGRES_SERVER:$POSTGRES_PORT -t 0 -- migrate -path /migrations -database postgres://$ENCODED_USER:$ENCODED_PASSWORD@$POSTGRES_SERVER:$POSTGRES_PORT/$POSTGRES_DB?sslmode=$POSTGRES_SSLMODE "$@"

fi
