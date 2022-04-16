set linesize 500
set pagesize 5000

select * from TABLE(dbms_xplan.display_awr('&sql_id'));

