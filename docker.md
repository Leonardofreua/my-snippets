### Delete all containers created from specific image:

```bash
docker ps -a --filter ancestor=postgres:14 --format "{{.ID}}" | xargs -r docker rm -f
```

### Stops and cleans up everything (containers, volumes, images, network) related to docker-compose.yml setup

```bash
docker compose down -v --rmi all && docker compose up --build -d
```
