# Migration scripts for ReportPortal

### Usage

#### Update to latest revision
```sh
docker-compose run --rm migrations
```

#### Downgrade to previous revision
```sh
docker-compose run --rm migrations down
```

#### Downgrade to N revisions back
```sh
docker-compose run --rm migrations down N
```
