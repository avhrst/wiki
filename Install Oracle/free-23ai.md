# Install Oracle 23ai/26ai APEX 24.2

## Rocky Linux 9 

Convert to Oracle Linux 9

```
yum install wget
wget https://raw.githubusercontent.com/oracle/centos2ol/main/centos2ol.sh
bash centos2ol.sh -k

dnf install -y oracle-ai-database-preinstall-26ai

```

Install packages
```
vim /etc/sysconfig/selinux
SELINUX=permissive

systemctl disable firewalld
systemctl stop firewalld

```

## Install DB

```
 wget https://download.oracle.com/otn-pub/otn_software/db-free/oracle-ai-database-free-26ai-23.26.0-1.el9.x86_64.rpm

  dnf -y localinstall oracle-ai-database-free-26ai-23.26.0-1.el9.x86_64.rpm
```

## Configure DB 

```
vim /etc/sysconfig/oracle-free-26ai.conf
vim /etc/hosts
```

```
export DB_PASSWORD=SysPassword31415926

(echo "${DB_PASSWORD}"; echo "${DB_PASSWORD}";) | /etc/init.d/oracle-free-26ai configure

systemctl enable oracle-free-26ai
```

vim ~/.bash_profile
```
export ORACLE_SID=FREE 
export ORAENV_ASK=NO 
. /opt/oracle/product/26ai/dbhomeFree/bin/oraenv
```

## APEX install

```
su - oracle

cd /opt/oracle
wget https://download.oracle.com/otn_software/apex/apex_24.2.zip
unzip apex_24.2.zip

cd apex
```

```
sqlplus / as sysdba

ALTER SESSION SET CONTAINER = freepdb1;
@apexins.sql SYSAUX SYSAUX TEMP /i/
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
@apxchpwd.sql
```

# ORDS instalation

## root user
```
wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.rpm
dnf localinstall jdk-21_linux-x64_bin.rpm

mkdir -p /opt/oracle/ords

groupadd ords
useradd -M -s /bin/bash -g ords -d /opt/oracle/ords ords

wget https://download.oracle.com/otn_software/java/ords/ords-latest.zip

unzip ords-*.zip -d /opt/oracle/ords
chown ords -R /opt/oracle/ords

cp -a /opt/oracle/apex/images/  /opt/oracle/ords
chown -R ords:ords /opt/oracle/ords/images
```

## ords user
```
vim ~/.bash_profile

export ORDS_CONFIG=/opt/oracle/ords
PATH="$PATH:/opt/oracle/ords/bin"
export PATH

```

```
ords install
```

###  ORDS Services

```
vim /etc/systemd/system/ords.service
```

```
[Unit]
Description=Oracle REST Data Services
Requires=network.target
After=oracle-xe-21c.service

[Service]
Type=simple
ExecStart=/opt/oracle/ords/bin/ords --config /opt/oracle/ords serve
ExecStop=/bin/kill -HUP ${MAINPID}
User=ords

[Install]
WantedBy=multi-user.target
```

```
systemctl daemon-reload
systemctl start ords
systemctl enable ords

```



### ORDS -https
```
openssl pkcs8 -topk8 -inform PEM -outform DER -in yourdomain.key -out yourdomain.der -nocrypt
```

```
export ORDS_CONFIG=/opt/oracle/ords/config   # adjust to your config dir

# HTTPS port (equivalent to jetty.secure.port)
ords --config "$ORDS_CONFIG" config set standalone.https.port 8443

# Cert + key (equivalent to ssl.cert / ssl.cert.key)
ords --config "$ORDS_CONFIG" config set standalone.https.cert     /opt/oracle/ords/config/ords/ssl/yourdomain.crt
ords --config "$ORDS_CONFIG" config set standalone.https.cert.key /opt/oracle/ords/config/ords/ssl/yourdomain.key

# HTTPS host (equivalent to ssl.host)
ords --config "$ORDS_CONFIG" config set standalone.https.host yourdomain

```



