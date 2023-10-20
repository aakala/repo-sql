set lines 300
set pages 500
col SQL_ID from a20

select nvl(SQL_ID, 'NULL') as SQL_ID, count(*) as DBTIME_Secs
from v$active_Session_history
where 
    session_type = 'FOREGROUND'
group by SQLID
order by 2 desc
/
  
Prompt "View waits for a sql" 
  
col event for a50
select event, count(*) as DBTIME_Secs
from v$active_Session_history
where 
    session_type = 'FOREGROUND'
  and SQL_ID = &v_sql_id
group by event
order by 2 desc
/

