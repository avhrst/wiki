## Linux Centos 7

```
yum upgrade -y

mkdir -p /u01/download
chmod 777 /u01/download/

yum -y install perl perl-Net-SSLeay openssl perl-IO-Tty perl-Encode-Detect
yum -y install libaio bc nano wget unzip mc
locale
mv /etc/localtime /etc/localtime.bkp
cp /usr/share/zoneinfo/Europe/Kiev /etc/localtime
yum install ntp -y
chkconfig ntpd on
service ntpd restart

yum install mc net-tools.x86_64 htop iotop iftop unzip wget epel-release -y
yum install rlwrap -y
yum install vim -y
systemctl start chronyd
systemctl enable chronyd

mcedit /etc/sysconfig/selinux

setenforce 0
systemctl disable firewalld
systemctl stop firewalld

```

## Disk
```
dd if=/dev/zero of=/swapfile bs=1024 count=2048k
mkswap /swapfile
swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
chown root:root /swapfile
chmod 0600 /swapfile
swapon -s

umount tmpfs
mount -t tmpfs shmfs -o size=2G /dev/shm
echo "tmpfs /dev/shm tmpfs size=2G 0 0" >> /etc/fstab

reboot
```

## Oracle preinstall
```
curl -o oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm
yum -y localinstall oracle-database-preinstall-19c-1.0-1.el7.x86_64.rpm 

```

## Startup

```
mkdir /home/oracle/scripts
```

```
vim /home/oracle/scripts/setEnv.sh
```

```
# Oracle Settings
export TMP=/tmp
export TMPDIR=$TMP

export ORACLE_HOSTNAME=localhost.localdomain
export ORACLE_UNQNAME=ORCLCDB
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/19c/dbhome_1
export ORA_INVENTORY=/opt/oracle/oraInventory
export ORACLE_SID=ORCLCDB
export PDB_NAME=pdb1
export DATA_DIR=\$ORACLE_BASE/oradata

export PATH=/usr/sbin:/usr/local/bin:$PATH
export PATH=$ORACLE_HOME/bin:$PATH

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
```

```
echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile
```

```
vim /home/oracle/scripts/start_all.sh 
```

```
#!/bin/bash
. /home/oracle/scripts/setEnv.sh

export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES

dbstart $ORACLE_HOME
```

```
vim /home/oracle/scripts/stop_all.sh
```

```
#!/bin/bash
. /home/oracle/scripts/setEnv.sh

export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES

dbshut $ORACLE_HOME
```

```
chown -R oracle:oinstall /home/oracle/scripts
chmod u+x /home/oracle/scripts/*.sh
```

## Oracle Install
```
cd /u01/download

yum localinstall oracle-database-ee-19c-1.0-1.x86_64.rpm
/etc/init.d/oracledb_ORCLCDB-19c configure

vim /etc/oratab

reboot
```


## Webmin
```
cd /u01/download
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.999-2.noarch.rpm
yum localinstall webmin-*.rpm 
passwd root
```



# Linux 7 Script

```
vim /lib/systemd/system/dbora.service
```

```
[Unit]
Description=The Oracle Database Service
After=syslog.target network.target

[Service]
# systemd ignores PAM limits, so set any necessary limits in the service.
# Not really a bug, but a feature.
LimitMEMLOCK=infinity
LimitNOFILE=65535

#Type=simple
# idle: similar to simple, the actual execution of the service binary is delayed
#       until all jobs are finished, which avoids mixing the status output with shell output of services.
RemainAfterExit=yes
User=oracle
Group=oinstall
Restart=no
ExecStart=/bin/bash -c '/home/oracle/scripts/start_all.sh'
ExecStop=/bin/bash -c '/home/oracle/scripts/stop_all.sh'

[Install]
WantedBy=multi-user.target
```

```
systemctl daemon-reload
systemctl enable dbora.service
```
### PDB Autostart

```
CREATE OR REPLACE TRIGGER open_pdbs 
  AFTER STARTUP ON DATABASE 
BEGIN 
   EXECUTE IMMEDIATE 'ALTER PLUGGABLE DATABASE ALL OPEN'; 
END open_pdbs;
/
```

## APEX  install
  ```
cd /u01/download
mkdir -p /opt/oracle/apex
unzip apex-latest.zip -d /opt/oracle
chown -R oracle:oinstall /opt/oracle/apex
```

```
su - oracle
cd /opt/oracle/apex
```

```
-- connect to the database
sqlplus / as sysdba
SQL> alter session set container = orclpdb1;

-- for OCI --
SQL> alter profile default limit PASSWORD_VERIFY_FUNCTION null;
SQL> @apxsilentins.sql SYSAUX SYSAUX TEMP /i/ 31415926 31415926 31415926 31415926
-- now disconnect from the database
SQL> exit
```


#### Patch install
```
cd /u01/download
mkdir -p /opt/oracle/apex/patch
unzip p34020981_2210_Generic.zip -d /opt/oracle/patch

chown -R oracle:oinstall /opt/oracle/apex/patch

su - oracle
cd /opt/oracle/patch/34020981

sqlplus / as sysdba
SQL> alter session set container = orclpdb1;
SQL> @catpatch.sql
```
## ORDS Installation

### JDK 17

https://www.oracle.com/java/technologies/downloads/#java17

```
cd /u01/download
yum localinstall 
jdk-17_linux-x64_bin.rpm

mkdir -p /opt/oracle/ords
unzip ords-latest.zip -d /opt/oracle/ords

chown -R oracle:oinstall /opt/oracle/ords
cd /opt/oracle/ords
```

# install ORDS

```
su - oracle
sqlplus / as sysdba

alter user sys identified by AvhrSt__31415926 account unlock;

alter session set container = orclpdb1;
alter user apex_listener identified by 31415926 account unlock;
alter user apex_public_user identified by 31415926 account unlock;
alter user apex_rest_public_user identified by 31415926 account unlock;

-- The next one will fail if you've never installed ORDS before. Ignore errors.
alter user ords_public_user identified by 31415926 account unlock;
```

# 

```
export ORDS_HOME=/opt/oracle/ords
export ORDS_CONFIG=/opt/oracle/ords/config
export ORDS_LOGS=${ORDS_CONFIG}/logs
export DB_PORT=1521
export DB_SERVICE=orclpdb1
export SYSDBA_USER=SYS
export SYSDBA_PASSWORD=AvhrSt__31415926
export ORDS_PASSWORD=31415926


${ORDS_HOME}/bin/ords --config ${ORDS_CONFIG} install \
     --log-folder ${ORDS_LOGS} \
     --admin-user ${SYSDBA_USER} \
     --db-hostname localhost \
     --db-port ${DB_PORT} \
     --db-servicename ${DB_SERVICE} \
     --feature-db-api true \
     --feature-rest-enabled-sql true \
     --feature-sdw true \
     --gateway-mode proxied \
     --gateway-user APEX_PUBLIC_USER \
     --proxy-user \
     --password-stdin <<EOF
${SYSDBA_PASSWORD}
${ORDS_PASSWORD}
EOF
```

## Start and stop script

```
vim /home/oracle/scripts/start_ords.sh
```

```
#!/bin/bash
export PATH=/usr/sbin:/usr/local/bin:/usr/bin:/usr/local/sbin:$PATH
export JAVA_HOME=/usr/java/default
export ORDS_HOME=/opt/oracle/ords
export ORDS_CONFIG=/opt/oracle/ords/config
LOGFILE=/home/oracle/scripts/logs/ords-`date +"%Y""%m""%d"`.log
export _JAVA_OPTIONS="-Xms1126M -Xmx1126M"
nohup ${ORDS_HOME}/bin/ords --config ${ORDS_CONFIG} serve >> $LOGFILE 2>&1 &
echo "View log file with : tail -f $LOGFILE"
```

```
vim /home/oracle/scripts/stop_ords.sh
```

```
#!/bin/bash
export PATH=/usr/sbin:/usr/local/bin:/usr/bin:/usr/local/sbin:$PATH
kill `ps -ef | grep [o]rds.war | awk '{print $2}'`
```

```
mkdir -p /home/oracle/scripts/logs
chown -R oracle:oinstall /home/oracle/scripts
chmod u+x /home/oracle/scripts/*.sh
```

## APEX Static Images

```
su - oracle
cd /opt/oracle/ords

export ORDS_HOME=/opt/oracle/ords
export ORDS_CONFIG=/opt/oracle/ords/config
export APEX_IMAGES=/opt/oracle/apex/images

${ORDS_HOME}/bin/ords --config ${ORDS_CONFIG} config set standalone.static.path ${APEX_IMAGES}
```


```
vim /etc/systemd/system/ords.service
```

```
[Unit]
Description=Oracle REST Data Services
Requires=network.target
After=dbora.service

[Service]
RemainAfterExit=yes
User=oracle
Group=oinstall
Restart=no
ExecStart=/bin/bash -c '/home/oracle/scripts/start_ords.sh'
ExecStop=/bin/bash -c '/home/oracle/scripts/stop_ords.sh'

[Install]
WantedBy=multi-user.target
```

```
systemctl daemon-reload
systemctl start ords
systemctl enable ords

```