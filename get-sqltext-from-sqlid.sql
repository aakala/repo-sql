set long 100000
select SQL_TEXT fulltext
from v$sqltext
where sql_id='&sql_id'
;
