FROM alpine:latest
ARG TARGETOS
ARG TARGETARCH
ARG GO_MIGRATE_VERSION="v4.18.1"
ENV POSTGRES_SSLMODE="disable"
RUN apk --no-cache add curl bash && \
    curl -L https://github.com/golang-migrate/migrate/releases/download/${GO_MIGRATE_VERSION}/migrate.${TARGETOS}-${TARGETARCH}.tar.gz | tar xvz &&  \
    mv migrate /usr/local/bin/migrate && \
    chmod +x /usr/local/bin/migrate
ADD "https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh" /wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh
COPY index-template-setup.sh /index-template-setup.sh
RUN chmod +x /entrypoint.sh && chmod +xr /wait-for-it.sh && chmod +x /index-template-setup.sh
COPY migrations/ /migrations/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["up"]
