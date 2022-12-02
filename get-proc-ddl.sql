set lines 200
set pages 200

set long 50000
col ddl for a5000

SELECT DBMS_METADATA.get_ddl ('PROCEDURE','&PROC_NAME','&OWNER')"DDL"  from dual;
