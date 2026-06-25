FROM alpine:3.24 AS downloader
ARG TARGETOS
ARG TARGETARCH
ARG GO_MIGRATE_VERSION="v4.19.0"
RUN apk --no-cache add curl bash && \
    curl -L https://github.com/golang-migrate/migrate/releases/download/${GO_MIGRATE_VERSION}/migrate.${TARGETOS}-${TARGETARCH}.tar.gz | tar xvz && \
    curl -Lo /wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh

FROM dhi.io/alpine-base:3.24
ENV POSTGRES_SSLMODE="disable"
COPY --from=downloader /bin/bash /bin/bash
COPY --from=downloader /usr/lib/libreadline.so.8 /usr/lib/
COPY --from=downloader /usr/lib/libncursesw.so.6 /usr/lib/
COPY --chmod=755 --from=downloader /migrate /usr/local/bin/migrate
COPY --chmod=755 --from=downloader /wait-for-it.sh /wait-for-it.sh
COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY migrations/ /migrations/
USER nonroot
ENTRYPOINT ["/entrypoint.sh"]
CMD ["up"]
