

## Setup ORDS Linux
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

## Setup ORDS Windows 
PowerShell commands (with correct line continuation and quoting)
```
podman volume create ords_config_vol

$APEX_IMAGES = "C:\Users\oleksii\Code\oracle\apex\images"

podman run -d `
  --name apex-ords `
  -p 8080:8080 `
  -e DBHOST=host.containers.internal `
  -e DBPORT=1521 `
  -e DBSERVICENAME=freepdb1 `
  -e ORACLE_PWD=oracle `
  -v ords_config_vol:/etc/ords/config `
  --mount type=bind,src="$APEX_IMAGES",dst=/etc/ords/static_files `
  container-registry.oracle.com/database/ords:latest

podman exec -it apex-ords ords --config /etc/ords/config config set standalone.static.path /etc/ords/static_files
podman exec -it apex-ords ords --config /etc/ords/config config set standalone.doc.root /etc/ords/static_files

```
Why --mount instead of -v here: it avoids edge cases with Windows path parsing and is generally clearer on Windows.

## Restart the Container
```
podman restart apex-ords
```

## Verification
```
podman exec -it apex-ords ords --config /etc/ords/config config list
```
