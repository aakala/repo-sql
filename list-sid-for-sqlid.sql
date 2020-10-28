set verify off
set pagesize 999
set pages 1000
col username format a12
col sql_id format a20
col event format a40
col sid for 9999999
col MINS_ACTIVE format 9,999,999.99

select s.inst_id, s.sid,s.serial#, p.spid,s.username, s.sql_id,
substr(s.event,1,40) event,
                round(s.LAST_CALL_ET/60) MINS_ACTIVE
from gv$session s,gv$process p
where s.inst_id=p.inst_id
and s.paddr=p.addr
and sql_id like nvl('&sql_id',sql_id)
/
