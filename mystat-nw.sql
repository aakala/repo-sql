set lines 200
set pages 500
col  value for 999999999999999999
select stat.sid "SID" , s.name "STATISTIC",  stat.value from v$mystat stat right join v$statname s on s.statistic#=stat.statistic#  where s.name like '%SQL*Net%' ;

