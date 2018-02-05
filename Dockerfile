FROM golang:1.9.3

RUN go get -u -d github.com/mattes/migrate/cli github.com/lib/pq && \
      go build -tags 'postgres' -o /usr/local/bin/migrate github.com/mattes/migrate/cli

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY migrations/ /migrations/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["up"]
