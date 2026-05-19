# repo-sql

SQL and PL/SQL helper scripts for troubleshooting, performance tuning, operational analysis, and day-to-day Oracle database administration.

## Overview

This repository is a growing collection of reusable Oracle DBA scripts.

The goal of this repository is to provide:

- practical Oracle DBA utilities
- readable and reusable SQL scripts
- operational troubleshooting helpers
- SQL performance investigation tools

Most scripts are designed to be:

- lightweight
- directly runnable from SQL*Plus or SQLcl
- dependency-free
- easy to modify for local environments
- Scripts will require access to the Oracle dictionary and performance views



# Download the scripts or entire repository

### Clone the repository:

```bash
git clone https://github.com/aakala/repo-sql.git
cd repo-sql
```
### Download the entire repository

```
curl -L -o repo-sql.zip https://github.com/aakala/repo-sql/archive/refs/heads/master.zip
unzip repo-sql.zip

or
wget -O repo-sql.zip https://github.com/aakala/repo-sql/archive/refs/heads/master.zip
unzip repo-sql.zip
```
## Download a single script

```
curl -L -O https://raw.githubusercontent.com/aakala/repo-sql/master/active-sessions.sql
wget https://raw.githubusercontent.com/aakala/repo-sql/master/active-sessions.sql
```

## Disclaimer

These scripts are provided for community and educational use.
Always:
  Review scripts before executing in production
  Validate logic in non-production environments
  test performance impact for large data sets or historical views
  No warranty is provided.

## License
MIT License
