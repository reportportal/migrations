# Migration scripts for ReportPortal

## Description

In this repository, you will find the migration scripts for ReportPortal.
These scripts are utilized to update the database schema and generate an index
template for OpenSearch.

## Usage

### Enabling OpenSearch support

If you want to use OpenSearch instead of Elasticsearch, you need to set
the OS_HOST, OS_PORT and OS_PROTOCOL environment variables.

### Update to latest revision

```sh
docker-compose run --rm migrations
```

### Downgrade to previous revision

```sh
docker-compose run --rm migrations down
```

### Downgrade to N revisions back

```sh
docker-compose run --rm migrations down N
```

## Environment variables

| Variable | Description |
|----------|-------------|
|POSTGRES_SSLMODE|SSL mode for Postgres connection|
|POSTGRES_USER|Postgres user|
|POSTGRES_PORT|Postgres port|
|POSTGRES_PASSWORD|Postgres password|
|POSTGRES_SERVER|Postgres server|
|POSTGRES_DB|Postgres database|
