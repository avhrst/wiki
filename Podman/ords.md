

## Setup ORDS
```
podman volume create ords_config_vol

podman run -d \
  --name apex-ords \
  -p 8080:8080 \
  -e DBHOST=host.containers.internal \
  -e DBPORT=1521 \
  -e DBSERVICENAME=freepdb1 \
  -e ORACLE_PWD=oracle \
  -v ords_config_vol:/etc/ords/config:Z \
  -v /home/oleksii/Oracle/apex/images:/etc/ords/static_files:Z \
  container-registry.oracle.com/database/ords:latest


podman exec -it apex-ords ords --config /etc/ords/config config set standalone.static.path /etc/ords/static_files

podman exec -it apex-ords ords --config /etc/ords/config config set standalone.doc.root /etc/ords/static_files

```

## Set the Context Path (Optional)
By default, ORDS is served at /ords. If you want to change this or ensure it is correctly set, use:
```
podman exec -it apex-ords ords --config /etc/ords/config config set standalone.context.path /ords
```

## Restart the Container
```
podman restart apex-ords
```

## Verification
```
podman exec -it apex-ords ords --config /etc/ords/config config list
```