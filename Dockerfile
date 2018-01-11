FROM golang:1.9.2
WORKDIR /go/src/gitlab.com/avarabyeu/migrations

RUN apt-get update && apt-get install -y \
      ca-certificates \
      && rm -fr /var/lib/apt/lists/*

RUN curl https://glide.sh/get | sh && \
    go get -v github.com/alecthomas/gometalinter && \
    gometalinter --install

ARG version

COPY glide.yaml glide.lock ./
RUN glide install

COPY ./ ./
RUN make build version=$version

FROM scratch
WORKDIR /root/
COPY migrations/ ./migrations/
COPY --from=0 /go/src/gitlab.com/avarabyeu/migrations/bin/migrate ./migrate
CMD ["./migrate"]
