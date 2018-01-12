# Migration scripts for ReportPortal

### Usage

#### Update to latest revision
```sh
docker-compose run --rm migrations
```

#### Downgrade to previous revision
```sh
docker-compose exec --rm migrations down
```

#### Downgrade to N revisions back
```sh
docker-compose exec --rm migrations down N
```
