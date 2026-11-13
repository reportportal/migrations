FROM alpine:3.24 AS downloader
ARG TARGETOS
ARG TARGETARCH
ARG GO_MIGRATE_VERSION="v4.19.0"
RUN apk --no-cache add --upgrade curl bash openssl libcrypto3 libssl3 && \
    curl -L https://github.com/golang-migrate/migrate/releases/download/${GO_MIGRATE_VERSION}/migrate.${TARGETOS}-${TARGETARCH}.tar.gz | tar xvz && \
    curl -Lo /wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh

FROM dhi.io/alpine-base:3.24@sha256:c83afceb9027a70719ea5ed916754a94ecdbe33a64cb8bcbb4da9fbffaefe7b0
ENV POSTGRES_SSLMODE="disable"
COPY --from=downloader /bin/bash /bin/bash
COPY --from=downloader /usr/lib/libreadline.so.8 /usr/lib/
COPY --from=downloader /usr/lib/libncursesw.so.6 /usr/lib/
COPY --chmod=755 --from=downloader /migrate /usr/local/bin/migrate
COPY --chmod=755 --from=downloader /wait-for-it.sh /wait-for-it.sh
COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 index-template-setup.sh /index-template-setup.sh
COPY migrations/ /migrations/
USER nonroot
ENTRYPOINT ["/entrypoint.sh"]
CMD ["up"]
