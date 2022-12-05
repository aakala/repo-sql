REM  blocking_info.sql

clear columns
clear breaks
clear computes

set pagesize 500
set linesize 200


SELECT s1.username || '@' || s1.machine
    || ' ( SID=' || s1.sid || ' )  is blocking '
    || s2.username || '@' || s2.machine || ' ( SID=' || s2.sid || ' ) ' AS blocking_status
FROM v$lock l1, v$session s1, v$lock l2, v$session s2
WHERE s1.sid=l1.sid AND s2.sid=l2.sid
  AND l1.block=1 AND l2.request > 0
  AND l1.id1 = l2.id1
  AND l1.id2 = l2.id2
;


column object_name form a35
column object_type form a30
column lock_description form a20

SELECT l1.sid,
       o.object_name,
       o.object_type,
       l1.type as lock_type,
       l1.lmode as lock_mode,
       case l1.lmode
           when 0 then 'None'
           when 1 then 'Null'
           when 2 then 'Row Share'
           when 3 then 'Row Exclusive'
           when 4 then 'Share'
           when 5 then 'Share Sub Exclusive'
           when 6 then 'Table Exclusive'
         end as lock_description
FROM v$lock l1, dba_objects o
WHERE l1.block = 1
  AND (l1.id1 = o.object_id OR l1.id2 = o.object_id)
;

