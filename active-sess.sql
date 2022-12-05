set pagesize 1000
set linesize 250
col username for a20
col osuser for a20
col machine for a50
col client_info for a12
col SIDSERIAL# for a10
col sql_id for a14

prompt **** Session Count per Machine ****

select machine, osuser, service_name, client_info, count(*) from gv$session where username <> 'ORACLE'
group by machine, osuser, service_name, client_info
order by count(*);

prompt **** Currently Active Sessions ****

set linesize 250
SET PAGES 1000
COLUMN SID FORMAT 99999 HEAD 'SID'
COLUMN SERIAL# FORMAT 99999
COLUMN SPID FORMAT a6 HEAD 'SPID'
COLUMN OSUSER FORMAT a8 truncated
COLUMN USERNAME FORMAT a15 truncated
COLUMN PROGRAM FORMAT a18 truncated
COLUMN MODULE FORMAT a18 truncated
COLUMN MACHINE FORMAT a18 truncated
COLUMN "Program/Machine" FORMAT a18 truncated
COLUMN "LOGIN TIME" FORMAT a11
COLUMN STATUS FORMAT a1 truncated
COLUMN ACTIVE FORMAT a10
COLUMN CLIENT_INFO for a10
COLUMN service_name for a15
COLUMN SIDSERIAL# for a10
SELECT s.inst_id,  s.sid||','||s.serial# SIDSERIAL#, s.sql_id, p.spid, s.osuser, s.username, s.client_info, s.service_name,s.program,s.module,
       to_char(s.logon_time, 'MM.DD HH24:MI') "LOGIN TIME", s.machine, s.status,
       floor(s.last_call_et/3600)||':'||
       floor(mod(s.last_call_et,3600)/60)||':'||
       mod(mod(s.last_call_et,3600),60) "ACTIVE"
  FROM gv$session s, gv$process p
 WHERE s.paddr = p.addr (+)
  AND s.status = 'ACTIVE'
   AND s.type <> 'BACKGROUND'
ORDER BY last_call_et;

