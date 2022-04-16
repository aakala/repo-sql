set lines 500 
set pages 5000
set long 5000


select  sql_text from v$sqlarea where sql_id = '&sql_id';

