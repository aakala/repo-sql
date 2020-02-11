set pagesize 400 linesize 200

alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';

Accept sql_id Prompt "Enter SQL ID:  "

SELECT * FROM TABLE(dbms_xplan.display_cursor('&sql_id)',FORMAT=>'ADVANCED'));

