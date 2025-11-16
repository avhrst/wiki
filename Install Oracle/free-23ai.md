# Install Oracle 23ai/26ai APEX 24.2

## Rocky Linux 9 

Convert to Oracle Linux 9

```
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