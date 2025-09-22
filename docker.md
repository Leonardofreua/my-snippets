### Delete all containers created from specific image:

```bash
docker ps -a --filter ancestor=postgres:14 --format "{{.ID}}" | xargs -r docker rm -f
```