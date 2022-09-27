FROM migrate/migrate:v4.15.2 AS migrate

ENV POSTGRES_SSLMODE="disable"

RUN apk --no-cache add bash && \
    chmod +x /usr/bin/migrate

ADD "https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh" /wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chmod +xr /wait-for-it.sh

COPY migrations/ /migrations/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["up"]