FROM alpine:latest

RUN apk --no-cache add curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.2.2/migrate.linux-amd64.tar.gz | tar xvz &&  \
    mv migrate.linux-amd64 /usr/local/bin/migrate && \
    chmod +x /usr/local/bin/migrate

ADD "https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh" /wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh
#COPY wait-for-postgres.sh /wait-for-postgres.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x /wait-for-it.sh

COPY migrations/ /migrations/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["up"]
