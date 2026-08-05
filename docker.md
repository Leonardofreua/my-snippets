### Delete all containers created from specific image:

```bash
docker ps -a --filter ancestor=postgres:14 --format "{{.ID}}" | xargs -r docker rm -f
```

### Stops and cleans up everything (containers, volumes, images, network) related to docker-compose.yml setup

```bash
docker compose down -v --rmi all && docker compose up --build -d
```

### List all container and their IP address

```bash
docker ps --format "{{.Names}}: {{.ID}}" | while read line; do name=$(echo $line | cut -d: -f1); id=$(echo $line | cut -d: -f2 | xargs); ip=$(docker inspect $id --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2v/dev/null); echo "$ip -> $name"; done 2>/dev/null | sort
```

### List the number os PostgreSQL connections used by each container

```bash
docker exec postgres psql -U postgres -d db_name -c "SELECT client_addr, count(*) FROM pg_stat_activity WHERE usename = 'name' GROUP BY client_addr ORDER BY count DESC;" 2>&1
```