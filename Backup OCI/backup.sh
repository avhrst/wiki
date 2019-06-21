#!/bin/bash
source /home/oracle/.bashrc

DATE=`date +"_%Y%m%d_%H%M%S"`

cd /u01/dmp

/bin/rm -f *.dmp
/bin/rm -f *.log

echo "DISTRICT$DATE.dmp"

expdp system/*****@PDB1 schemas=DISTRICT directory=DMP_DIR dumpfile="DISTRICT$DATE.dmp" logfile="DISTRICT$DATE.log"


/bin/chmod 655 *.dmp