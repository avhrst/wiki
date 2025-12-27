# Install Oracle DB in podman


Create volume
```
podman volume create ai-db-data
```

Setup DB
```
podman run -d \
    --name ai-db \
    --mount=type=volume,source=ai-db-data,destination=/opt/oracle/oradata \
    -p 1521:1521 \
    -e ORACLE_PWD=oracle \
    container-registry.oracle.com/database/free:latest
```