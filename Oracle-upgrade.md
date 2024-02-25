
Preinstall step
```
yum install -y oracle-database-preinstall-19c
yum update -y
```

Install 19c
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
