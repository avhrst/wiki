
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
