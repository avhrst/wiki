

## Convert to Oracle Linux 8

```
yum install wget
wget https://raw.githubusercontent.com/oracle/centos2ol/main/centos2ol.sh
bash centos2ol.sh -k
```

## /etc/hosts

```
yum install vim
vim /etc/hosts
```

## DB Install

```
dnf install -y oracle-database-preinstall-21c

vim /etc/selinux/config
SELINUX=permissive



mkdir /u01
mkdir /u02

dnf -y localinstall oracle-database-ee-21c-1.0-1.ol8.x86_64.rpm

```

## DB Configure
```
mkdir -p /u01/app/oracle/product/21.0.0/dbhome_1
mkdir -p /u02/oradata
chown -R oracle:oinstall /u01 /u02
chmod -R 775 /u01 /u02

vim /etc/sysconfig/oracledb_ORCLCDB-21c.conf
ORACLE_DATA_LOCATION=/u02/oradata

/etc/init.d/oracledb_ORCLCDB-21c configure
```

# Oracle env

```
vim /etc/oratab
```

```
mkdir -p /u01/oracle/scripts

cat > /u01/oracle/scripts/setEnv.sh <<EOF
# Oracle Settings
export TMP=/tmp
export TMPDIR=\$TMP

export ORACLE_HOSTNAME=msboard
export ORACLE_UNQNAME=ORCLCDB
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/21c/dbhome_1
export ORA_INVENTORY=/opt/oracle/oraInventory
export ORACLE_SID=ORCLCDB
export PDB_NAME=orclpdb1
export DATA_DIR=/u02/oradata

export PATH=/usr/sbin:/usr/local/bin:\$PATH
export PATH=\$ORACLE_HOME/bin:\$PATH

export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
EOF

echo ". /u01/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile
```