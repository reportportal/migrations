FROM golang:1.9.3

RUN go get -u -d github.com/mattes/migrate/cli github.com/lib/pq && \
      go build -tags 'postgres' -o /usr/local/bin/migrate github.com/mattes/migrate/cli

ADD "https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh" /wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh
#COPY wait-for-postgres.sh /wait-for-postgres.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x /wait-for-it.sh

COPY migrations/ /migrations/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["up"]
