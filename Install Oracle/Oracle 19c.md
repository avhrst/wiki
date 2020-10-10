## Instalation script

### Startup

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

export ORACLE_HOSTNAME=district.localdomain
export ORACLE_UNQNAME=ORCLCDB
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19c/dbhome_1
export ORA_INVENTORY=/opt/oracle/oraInventory
export ORACLE_SID=ORCLCDB
export PDB_NAME=orclpdb1
export DATA_DIR=/opt/oracle/oradata

export PATH=/usr/sbin:/usr/local/bin:\$PATH
export PATH=$ORACLE_HOME/bin:\$PATH

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
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
# https://bugzilla.redhat.com/show_bug.cgi?id=754285
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


