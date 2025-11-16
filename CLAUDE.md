# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a knowledge base and documentation repository for Oracle Database administration, installation, and configuration. It contains procedural guides, configuration examples, and operational scripts for managing Oracle Database environments across different versions (12c, 19c, 23ai, 26ai, XE 21c).

## Repository Structure

- **Oracle-upgrade.md** - Main upgrade guide from Oracle 12c to 19c, including APEX and ORDS configuration
- **Install Oracle/** - Installation guides for different Oracle versions:
  - `Oracle 19c.md` - Enterprise Edition installation on CentOS 7
  - `XE21.md` - Express Edition installation
  - `free-23ai.md` - Latest AI-capable database installation on Rocky Linux 9
- **Backup OCI/** - Cloud backup automation scripts and procedures
- **Blob to files/** - PL/SQL scripts for converting database BLOBs to filesystem files
- **RMAN/** - Recovery Manager configuration and backup strategies

## Key Technologies

- **Oracle Database**: 12c, 19c, 23ai, 26ai, XE 21c
- **APEX** (Oracle Application Express): Web application platform
- **ORDS** (Oracle REST Data Services): REST API layer
- **RMAN**: Native backup and recovery tool
- **Infrastructure**: Linux (CentOS 7, Rocky Linux 9), Apache httpd, Tomcat, Java 11/17
- **Cloud**: Oracle Cloud Infrastructure (OCI) for backups

## Common Operations

### Database Export (Data Pump)

Located in `Backup OCI/backup.sh`:
```bash
expdp system/password@PDB1 schemas=DISTRICT directory=DMP_DIR dumpfile="DISTRICT_DATE.dmp" logfile="DISTRICT_DATE.log"
```

### Cloud Upload to OCI Object Storage

Located in `Backup OCI/upload.sh`:
```bash
oci os object bulk-upload -ns <namespace> -bn backup --src-dir /u01/dmp/ --overwrite
```

### Oracle Environment Setup

Standard environment variables used throughout:
```bash
export ORACLE_HOME=$ORACLE_BASE/product/19.0.0/dbhome_1
export ORACLE_SID=cdb1
export ORAENV_ASK=NO
. oraenv
```

## Architecture Patterns

### Multi-tier Oracle Stack

The typical deployment architecture documented here:
1. **Database Layer**: Oracle Database (CDB/PDB architecture)
2. **Application Layer**: APEX (web apps)
3. **API Layer**: ORDS (REST services)
4. **Web Layer**: Apache httpd (reverse proxy)
5. **Backup Layer**: RMAN + OCI Object Storage

### Database File Handling

The `Blob to files/` directory demonstrates a pattern for:
- Extracting BLOBs from database tables to filesystem using `UTL_FILE`
- Serving files via REST API with proper MIME types
- Managing a CDN-like file storage structure

Key tables:
- `load_img` - Source table with BLOB data
- `CDN_FILES` - Metadata table tracking extracted files

### Systemd Service Management

Database and middleware are managed via systemd services:
- `dbora.service` - Database auto-start/stop
- `ords.service` - ORDS REST service
- `tomcat.service` - Tomcat container

## Installation Commands

### Silent Database Installation

From `Install Oracle/Oracle 19c.md`:
```bash
./runInstaller -ignorePrereq -waitforcompletion -silent \
    -responseFile ${ORACLE_HOME}/install/response/db_install.rsp \
    oracle.install.option=INSTALL_DB_SWONLY \
    ORACLE_HOSTNAME=${ORACLE_HOSTNAME} \
    ORACLE_HOME=${ORACLE_HOME} \
    ORACLE_BASE=${ORACLE_BASE} \
    oracle.install.db.InstallEdition=EE
```

### ORDS Configuration

Standard ORDS setup pattern:
```bash
ords --config ${ORDS_CONFIG} install \
    --admin-user SYS \
    --db-hostname localhost \
    --db-port 1521 \
    --db-servicename PDB1 \
    --feature-db-api true \
    --feature-rest-enabled-sql true \
    --feature-sdw true \
    --gateway-mode proxied \
    --gateway-user APEX_PUBLIC_USER \
    --proxy-user
```

## Important Notes

### Security Considerations

- The backup scripts contain database credentials - these should be updated to use wallet or secure credential storage
- Default passwords in documentation should be changed for production use

### Pre-upgrade Validation

Before any Oracle upgrade, the documented pattern is:
1. Run preupgrade.jar to generate fixup scripts
2. Execute preupgrade_fixups.sql
3. Recompile invalid objects with utlrp.sql
4. Shutdown and perform upgrade
5. Run postupgrade_fixups.sql

### BLOB File Operations

When working with the BLOB-to-file scripts:
- Files are written to directories configured via `CREATE DIRECTORY` SQL commands
- The `UTL_FILE` package requires proper directory permissions
- REST endpoints in `rest img.sql` handle HTTP status codes (200, 404, 500)

## File Naming Conventions

- Markdown files use spaces in names (e.g., `Oracle 19c.md`)
- Shell scripts use .sh extension
- SQL scripts use .sql extension
- Dump files follow pattern: `SCHEMA_YYYYMMDD_HHMMSS.dmp`
