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
yum upgrade -y

mkdir -p /u01/download
chmod 777 /u01/download/

yum -y install perl perl-Net-SSLeay openssl perl-IO-Tty perl-Encode-Detect
yum -y install libaio bc nano unzip mc
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

## Install DB

```
chown oracle.oinstall /opt/oracle

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

Internal def password: Pi__31415926!
