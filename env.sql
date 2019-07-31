alter session set NLS_DATE_FORMAT='DD_MON-YYYY HH24:MI:SS';
set lines 300 pages 5000
set timing on
set sqlprompt "_user'@'_connect_identifier:SQL> "
select name, open_mode, database_role, host_name, instance_name, startup_time from v$database, v$instance;
