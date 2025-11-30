## Upgrade Centos6

## Iptables
```
sercice iptables stop
service ip6tables stop
chkconfig iptables off
chkconfig ip6tables off
```

## repo
```
cat << 'EOF' > /etc/yum.repos.d/CentOS-Base.repo
[base]
name=CentOS-6.10 - Base
baseurl=http://vault.centos.org/6.10/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[updates]
name=CentOS-6.10 - Updates
baseurl=http://vault.centos.org/6.10/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[extras]
name=CentOS-6.10 - Extras
baseurl=http://vault.centos.org/6.10/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[centosplus]
name=CentOS-6.10 - Plus
baseurl=http://vault.centos.org/6.10/centosplus/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=0
EOF

yum clean all
yum makecache
yum update -y
```


## webmin 
```
yum remove webmin

yum install -y perl perl-Net-SSLeay openssl perl-IO-Tty perl-Encode-Detect
yum install -y perl-Digest-SHA

wget https://prdownloads.sourceforge.net/webadmin/webmin-2.105-1.noarch.rpm
rpm -Uvh webmin-*.rpm
```

## SSH client 
```
vim \.ssh\config

Host ms*.apex.rest
    HostKeyAlgorithms +ssh-rsa
    PubkeyAcceptedAlgorithms +ssh-rsa
```