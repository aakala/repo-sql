
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';



SET LINE 200 PAGES 200
COL PROGRAM FORMAT A20
COL MACHINE FORMAT A30
COL MODULE FORMAT A20
  
select sql_id,PGA_ALLOCATED,SAMPLE_TIME,max(TEMP_SPACE_ALLOCATED)/(1024*1024*1024) TEMP_USED(GB) ,SESSION_ID, SESSION_SERIAL#,MODULE,PROGRAM,MACHINE
from DBA_HIST_ACTIVE_SESS_HISTORY 
where 
sample_time between '14-AUG-24 01.00.00.000 AM' and '14-AUG-24 02.00.00.00 AM'
group by sql_id,SESSION_ID, PGA_ALLOCATED,SAMPLE_TIME,SESSION_SERIAL#,MODULE,PROGRAM,MACHINE order by sql_id;
