#!/bin/bash
source /home/opc/.bashrc
/usr/local/bin/oci os object bulk-upload -ns fr03l5aat3bq -bn backup --src-dir /u01/dmp/ --overwrite