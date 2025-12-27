# Oracle Database Knowledge Base

A comprehensive knowledge base and documentation repository for Oracle Database administration, installation, configuration, and operational procedures across multiple versions.

## Repository Structure

### [Backup OCI/](Backup OCI/)
Cloud backup automation for Oracle Database using OCI Object Storage
- [backup.sh](Backup OCI/backup.sh) - Data Pump export automation script
- [upload.sh](Backup OCI/upload.sh) - OCI Object Storage bulk upload script
- [expdb Object store.md](Backup OCI/expdb Object store.md) - Export to object storage procedures

### [Blob to files/](Blob to files/)
PL/SQL utilities for converting database BLOBs to filesystem files
- [upload img.sql](Blob to files/upload img.sql) - Extract BLOBs from database to filesystem using UTL_FILE
- [rest img.sql](Blob to files/rest img.sql) - REST API endpoints for serving files with proper MIME types

### [Install Oracle/](Install Oracle/)
Installation guides for different Oracle Database versions
- [Oracle 19c.md](Install Oracle/Oracle 19c.md) - Oracle Database 19c Enterprise Edition installation on CentOS 7
- [Oracle 21c.md](Install Oracle/Oracle 21c.md) - Oracle Database 21c installation guide
- [XE21.md](Install Oracle/XE21.md) - Oracle Database XE 21c Express Edition installation
- [free-23ai.md](Install Oracle/free-23ai.md) - Oracle Database 23ai Free (AI-capable) on Rocky Linux 9

### [Podman/](Podman/)
Container deployment configurations for Oracle Database and ORDS
- [oracle-db.md](Podman/oracle-db.md) - Oracle Database containerized deployment with Podman
- [ords.md](Podman/ords.md) - Oracle REST Data Services (ORDS) container configuration

### [RMAN/](RMAN/)
Recovery Manager configuration and backup strategies
- [config.md](RMAN/config.md) - RMAN backup configuration and recovery procedures

### [Tools/](Tools/)
Database development and debugging utilities
- [unwrap.md](Tools/unwrap.md) - PL/SQL unwrapper tool installation and usage

### [Upgrade Oracle/](Upgrade Oracle/)
Database upgrade procedures and migration guides
- [Oracle-upgrade.md](Upgrade Oracle/Oracle-upgrade.md) - Complete upgrade guide from Oracle 12c to 19c, including APEX and ORDS

### [ms/](ms/)
Microsoft SQL Server related documentation
- [upgrade_tt.md](ms/upgrade_tt.md) - SQL Server upgrade procedures

## Key Technologies

- **Oracle Database**: 12c, 19c, 21c, 23ai, XE 21c
- **APEX** (Oracle Application Express): Low-code web application platform
- **ORDS** (Oracle REST Data Services): RESTful API layer for Oracle Database
- **RMAN**: Oracle Recovery Manager for backup and recovery
- **Infrastructure**: Linux (CentOS 7, Rocky Linux 9), Apache httpd, Tomcat, Java 11/17
- **Cloud**: Oracle Cloud Infrastructure (OCI) Object Storage
- **Containers**: Podman for containerized Oracle deployments

## Common Operations

### Database Export with Data Pump
```bash
expdp system/password@PDB1 schemas=DISTRICT \
  directory=DMP_DIR \
  dumpfile="DISTRICT_$(date +%Y%m%d_%H%M%S).dmp" \
  logfile="DISTRICT_$(date +%Y%m%d_%H%M%S).log"
```

### Upload to OCI Object Storage
```bash
oci os object bulk-upload \
  -ns <namespace> \
  -bn backup \
  --src-dir /u01/dmp/ \
  --overwrite
```

### Oracle Environment Setup
```bash
export ORACLE_HOME=$ORACLE_BASE/product/19.0.0/dbhome_1
export ORACLE_SID=cdb1
export ORAENV_ASK=NO
. oraenv
```

## Architecture

The repository documents a typical multi-tier Oracle deployment:

1. **Database Layer**: Oracle Database (Container/Pluggable Database architecture)
2. **Application Layer**: APEX for web applications
3. **API Layer**: ORDS for REST services
4. **Web Layer**: Apache httpd as reverse proxy
5. **Backup Layer**: RMAN + OCI Object Storage for cloud backups

## Getting Started

1. Choose your Oracle Database version from the [Install Oracle/](Install Oracle/) directory
2. Follow the installation guide for your target platform
3. Configure automated backups using scripts in [Backup OCI/](Backup OCI/)
4. Set up RMAN backup policies from [RMAN/](RMAN/)
5. For upgrades, refer to [Upgrade Oracle/](Upgrade Oracle/)

## Important Notes

- Backup scripts contain placeholder credentials - use Oracle Wallet or secure credential storage for production
- Pre-upgrade validation is critical - always run preupgrade.jar before database upgrades
- BLOB file operations require proper directory permissions via CREATE DIRECTORY
- Systemd service files are provided for automatic database and middleware startup

## Contributing

This is a living documentation repository. When adding new procedures:
- Use clear, step-by-step instructions
- Include version-specific information
- Provide example commands with expected output
- Document any prerequisites or dependencies

## License

Internal documentation for Oracle Database administration.
