/*<TOAD_FILE_CHUNK>*/
set lines 160
set pages 1000
col username format a12
col sql format a65
col event format a40

select event,count(*) from v$session_wait group by event order by 2
/


select /*+ rule */ distinct w.sid,s.username,substr(w.event,1,40) event,
substr(q.sql_text,1,30)||'.....'||substr(q.sql_text,instr(q.sql_text,'FROM',1),30) "SQL",
round(s.LAST_CALL_ET/60) MINS_ACTIVE
from v$session_wait w,v$session s,v$sql q where w.event like '%&event%'
and w.sid=s.sid
and s.SQL_HASH_VALUE=q.HASH_VALUE
and s.status='ACTIVE'
and s.username is not null
order by s.username,round(s.LAST_CALL_ET/60)
/
