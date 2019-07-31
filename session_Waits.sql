 
SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300
 
COLUMN username FORMAT A20
COLUMN sid FORMAT 9999
COLUMN serial# FORMAT 9999
COLUMN event FORMAT A40

SET LINESIZE 200
SET PAGESIZE 1000

COLUMN username FORMAT A20
COLUMN event FORMAT A30
COLUMN wait_class FORMAT A15

SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       sw.event,
       sw.wait_class,
       sw.wait_time,
       sw.seconds_in_wait,
       sw.state
FROM   v$session_wait sw,
       v$session s
WHERE  s.sid = sw.sid
ORDER BY sw.seconds_in_wait DESC;

 
SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       se.event,
       se.total_waits,
       se.total_timeouts,
       se.time_waited,
       se.average_wait,
       se.max_wait,
       se.time_waited_micro
FROM   v$session_event se,
       v$session s
WHERE  s.sid = se.sid
AND    s.sid=&sid
ORDER BY se.time_waited DESC
/


select session_id, event, max(SAMPLE_TIME) - min(SAMPLE_TIME) "TIME"  
from v$active_session_history where sql_id = &sql_id 
group by session_id, event order by 1,2;