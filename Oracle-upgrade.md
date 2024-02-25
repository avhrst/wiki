
https://oracle-base.com/articles/19c/multitenant-upgrading-to-19c

## Preinstall step
```
yum install -y oracle-database-preinstall-19c
yum update -y
```

## Install 19c
```
su - oracle
```

```
export ORACLE_HOME=$ORACLE_BASE/product/19.0.0/dbhome_1
export SOFTWARE_DIR=/u01/download
export ORA_INVENTORY=/u01/app/oraInventory
mkdir -p ${ORACLE_HOME}
cd $ORACLE_HOME
/bin/unzip -oq ${SOFTWARE_DIR}/LINUX.X64_193000_db_home.zip
```

Install DB
```
./runInstaller -ignorePrereq -waitforcompletion -silent                        \
    -responseFile ${ORACLE_HOME}/install/response/db_install.rsp               \
    oracle.install.option=INSTALL_DB_SWONLY                                    \
    ORACLE_HOSTNAME=${ORACLE_HOSTNAME}                                         \
    UNIX_GROUP_NAME=oinstall                                                   \
    INVENTORY_LOCATION=${ORA_INVENTORY}                                        \
    SELECTED_LANGUAGES=en,en_GB                                                \
    ORACLE_HOME=${ORACLE_HOME}                                                 \
    ORACLE_BASE=${ORACLE_BASE}                                                 \
    oracle.install.db.InstallEdition=EE                                        \
    oracle.install.db.OSDBA_GROUP=dba                                          \
    oracle.install.db.OSBACKUPDBA_GROUP=dba                                    \
    oracle.install.db.OSDGDBA_GROUP=dba                                        \
    oracle.install.db.OSKMDBA_GROUP=dba                                        \
    oracle.install.db.OSRACDBA_GROUP=dba                                       \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false                                 \
    DECLINE_SECURITY_UPDATES=true
```

run as root
```
/u01/app/oracle/product/19.0.0/dbhome_1/root.sh
```

## Upgrade

```
su - oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.0.0/dbhome_1
unzip -o /u01/download/preupgrade_19_cbuild_13_lf.zip 

export ORACLE_SID=cdb1
export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES
export ORACLE_HOME=$ORACLE_BASE/product/12.2.0.1/db_1

$ORACLE_BASE/product/19.0.0/dbhome_1/jdk/bin/java -jar $ORACLE_BASE/product/19.0.0/dbhome_1/rdbms/admin/preupgrade.jar TERMINAL TEXT
```
## Perform Pre-Upgrade Actions

```
$ORACLE_HOME/perl/bin/perl \
    -I$ORACLE_HOME/perl/lib \
    -I$ORACLE_HOME/rdbms/admin \
    $ORACLE_HOME/rdbms/admin/catcon.pl \
    -l /u01/app/oracle/cfgtoollogs/cdb1/preupgrade/ \
    -b preup_${ORACLE_SID} \
    /u01/app/oracle/cfgtoollogs/${ORACLE_SID}/preupgrade/preupgrade_fixups.sql
```

```
$ORACLE_HOME/perl/bin/perl \
    -I$ORACLE_HOME/perl/lib \
    -I$ORACLE_HOME/rdbms/admin \
    $ORACLE_HOME/rdbms/admin/catcon.pl \
    -l /u01/app/oracle/cfgtoollogs/${ORACLE_SID}/preupgrade/ \
    -b preup_${ORACLE_SID}_recompile \
    -C 'PDB$SEED' \
    $ORACLE_HOME/rdbms/admin/utlrp.sql
```

## Upgrade the Database

```
sqlplus / as sysdba <<EOF
shutdown immediate;
exit;
EOF
```

```
cp $ORACLE_HOME/network/admin/*.ora $ORACLE_BASE/product/19.0.0/dbhome_1/network/admin

# Add this to $ORACLE_BASE/product/19.0.0/dbhome_1/network/admin/sqlnet.ora
# Need to correct password versions and remove this.
cat >> $ORACLE_BASE/product/19.0.0/dbhome_1/network/admin/sqlnet.ora <<EOF
# This should be temporary while you deal with old passwords.
SQLNET.ALLOWED_LOGON_VERSION_SERVER=11
EOF

cp $ORACLE_HOME/dbs/orapw${ORACLE_SID} $ORACLE_BASE/product/19.0.0/dbhome_1/dbs/
cp $ORACLE_HOME/dbs/spfile${ORACLE_SID}.ora $ORACLE_BASE/product/19.0.0/dbhome_1/dbs/
```

```
lsnrctl stop
export ORACLE_HOME=$ORACLE_BASE/product/19.0.0/dbhome_1
export PATH=${ORACLE_HOME}/bin:$PATH
lsnrctl start
```

```
sqlplus / as sysdba <<EOF
startup upgrade;
alter pluggable database all open upgrade force;
exit;
EOF
```

```
# Regular upgrade command.
cd $ORACLE_HOME/rdbms/admin
$ORACLE_HOME/perl/bin/perl catctl.pl catupgrd.sql

# Shorthand command.
$ORACLE_HOME/bin/dbupgrade
```

```
sqlplus / as sysdba <<EOF
shutdown immediate;
startup;

column name format A30
select name, open_mode from v\$pdbs;

exit;
EOF
```

```
$ORACLE_HOME/perl/bin/perl \
    -I$ORACLE_HOME/perl/lib \
    -I$ORACLE_HOME/rdbms/admin \
    $ORACLE_HOME/rdbms/admin/catcon.pl \
    -l /u01/app/oracle/cfgtoollogs/${ORACLE_SID}/preupgrade/ \
    -b postup_cdb1 \
    /u01/app/oracle/cfgtoollogs/${ORACLE_SID}/preupgrade/postupgrade_fixups.sql
```

## Final Steps

```
vim /etc/oratab

cdb1:/u01/app/oracle/product/19.0.0/dbhome_1:Y
```

```
sqlplus / as sysdba <<EOF
alter system set compatible='19.0.0' scope=spfile;
shutdown immediate;
startup;
EXIT;
EOF
```

```
sqlplus / as sysdba <<EOF
shutdown immediate;
startup upgrade;

alter database local undo on;

shutdown immediate;
startup;
EXIT;
EOF
```

```
vim /home/oracle/scripts/setEnv.sh

export ORACLE_HOME=$ORACLE_BASE/product/19.0.0/dbhome_1
```
APEX validate
```
sqlplus / as sysdba <<EOF
ALTER SESSION SET CONTAINER=pdb1;
SET SERVEROUTPUT ON;
EXEC SYS.validate_apex;
exit;
EOF
```

Change SYS password
```
sqlplus / as sysdba
ALTER USER sys IDENTIFIED BY "new_password";
```

## APEX Upgrade

```
cd /u02
cd /u01/download
mkdir -p /u01/apex
unzip apex-latest.zip -d /u01
chown -R oracle:oinstall /u01/apex
```

```
su - oracle
cd /u01/apex
```

```
sqlplus / as sysdba

alter session set container = pdb1;
alter profile default limit PASSWORD_VERIFY_FUNCTION null;
@apxsilentins.sql SYSAUX SYSAUX TEMP /i/ 31415926 31415926 31415926 31415926
@apex_rest_config.sql
exit;
```

## ORDS config

install Java 11

```
cd /u01/download
rpm -ihv jdk-11.0.21_linux-x64_bin.rpm
chown -R ords:ords /u02 
```

```
su - ords
cd /u02
unzip /u01/download/ords-latest.zip
mkdir -p /u02/config/logs
```

```
export ORDS_HOME=/u02
export ORDS_CONFIG=/u02/config
export ORDS_LOGS=${ORDS_CONFIG}/logs
export DB_PORT=1521
export DB_SERVICE=pdb1
export SYSDBA_USER=SYS
export SYSDBA_PASSWORD=AvhrSt31415926
export ORDS_PASSWORD=31415926


${ORDS_HOME}/bin/ords --config ${ORDS_CONFIG} install \
     --log-folder ${ORDS_LOGS} \
     --admin-user ${SYSDBA_USER} \
     --db-hostname ${HOSTNAME} \
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

exit
```

root
```

vim /etc/tomcat/tomcat.conf
JAVA_OPTS="-Dconfig.url=/u02/config -Xms1024M -Xmx1024M"

mkdir /usr/share/tomcat/webapps/i/
cp -R /u01/apex/images/* /usr/share/tomcat/webapps/i/
cp /u02/ords.war /usr/share/tomcat/webapps/
chown -R tomcat:tomcat /u02/config
chown -R tomcat:tomcat /usr/share/tomcat/webapps/ords.war
chown -R tomcat:tomcat /usr/share/tomcat/webapps/i/

```