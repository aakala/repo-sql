set pagesize 200 linesize 200
col begin_interval_time form a30
col avg_runtime_ms form 999,999,990.00
break on plan_hash_value

Accept sql_id    Prompt "Enter SQL_ID:  "
                 Prompt Enter number of days to review (days ago).
Accept days_ago  Prompt "For example: 1 for past 24 hours, 1/2 for past 12 hours, 1/24 for past hour. "

select b.sql_id, a.snap_id, a.begin_interval_time, b.plan_hash_value, b.executions_delta,
       (b.elapsed_time_delta/b.executions_delta)/1000 as avg_runtime_ms
from dba_hist_snapshot a, dba_hist_sqlstat b
  where a.snap_id=b.snap_id and b.sql_id='&sql_id'
    and b.executions_delta > 0
    and a.begin_interval_time > sysdate - &days_ago order by a.snap_id;


