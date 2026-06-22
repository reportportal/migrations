FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS migrate-builder
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG GO_MIGRATE_VERSION="v4.19.1"
ARG LIB_PQ_VERSION="v1.10.9"

RUN tmp="$(mktemp -d)" && \
    cd "${tmp}" && \
    go mod init migrate-build && \
    go mod edit -require=github.com/golang-migrate/migrate/v4@${GO_MIGRATE_VERSION} && \
    go mod edit -require=github.com/lib/pq@${LIB_PQ_VERSION} && \
    go mod download github.com/golang-migrate/migrate/v4 github.com/lib/pq && \
    CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -tags postgres -ldflags="-s -w -X main.Version=${GO_MIGRATE_VERSION}" \
    -o /usr/local/bin/migrate github.com/golang-migrate/migrate/v4/cmd/migrate

FROM alpine:latest
ENV POSTGRES_SSLMODE="disable"
RUN apk --no-cache add bash
COPY --from=migrate-builder /usr/local/bin/migrate /usr/local/bin/migrate
COPY wait-for-it.sh /wait-for-it.sh
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chmod +xr /wait-for-it.sh
COPY migrations/ /migrations/
ENTRYPOINT ["/entrypoint.sh"]
CMD ["up"]
