select NAME, INSTANCE_NAME, DB_UNIQUE_NAME, STARTUP_TIME, OPEN_MODE, DATABASE_ROLE, FORCE_LOGGING,
 FLASHBACK_ON, HOST_NAME
from gv$database;

select inst_id, PROCESS, STATUS, THREAD#, SEQUENCE#, BLOCK#, BLOCKS
FROM Gv$managed_standby where process<>'ARCH' ;

--Real Time Apply
Prompt "Real Time Apply Lag"

SELECT ( EXTRACT(DAY FROM TO_DSINTERVAL(value)) * 60*24
  + EXTRACT(HOUR FROM TO_DSINTERVAL(value)) * 60
  + EXTRACT(MINUTE FROM TO_DSINTERVAL(value))) "Lag (min)"
  FROM gv$dataguard_stats
  WHERE name = 'apply lag';

Prompt "For dataguard configs not using real time apply" 

select alr.arcr "Date/Time Applied",
al.thrd "Thread",
almax "Last Seq Received", lhmax "Last Seq Applied",
-- lha.arca "ARCH Applied",
  (almax - lhmax) "Difference"
  from (select thread# thrd, max(completion_time) arcr
      from gv$archived_log where applied in ('YES','IN-MEMORY') group by thread#) alr,
       (select thread# thrd, max(sequence#) almax
        from gv$archived_log
           where resetlogs_change#=(select resetlogs_change# from v$database)
             group by thread#) al,
     (select thread# thrd, max(first_time) arca
        from gv$log_history group by thread#) lha,
     (select thread# thrd, max(sequence#) lhmax
        from gv$log_history
           -- where FIRST_CHANGE#=(select max(FIRST_CHANGE#) from gv$log_history)
             group by thread#) lh
where al.thrd = lh.thrd
  and alr.thrd = lha.thrd
  and alr.thrd = lh.thrd;


col "Standby ARCHIVELOG GAP/LAG" format a50

SELECT  floor(((sysdate-max(NEXT_TIME))*24*60*60)/3600)|| ' Hour(s) ' ||
          floor((((sysdate-max(NEXT_TIME))*24*60*60) -
          floor(((sysdate-max(NEXT_TIME))*24*60*60)/3600)*3600)/60) || ' Minute(s) ' ||
          round((((sysdate-max(NEXT_TIME))*24*60*60) -
          floor(((sysdate-max(NEXT_TIME))*24*60*60)/3600)*3600 -
          (floor((((sysdate-max(NEXT_TIME))*24*60*60) -
          floor(((sysdate-max(NEXT_TIME))*24*60*60)/3600)*3600)/60)*60) ))|| ' Second(s) ' "Standby ARCHIVELOG GAP/LAG"
from gv$archived_log where applied ='YES';

