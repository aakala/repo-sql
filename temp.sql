SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 50
SET LINESIZE 300
SET COLSEP '|'
 
COLUMN tablespace FORMAT A20
COLUMN temp_size FORMAT A20
COLUMN sid_serial FORMAT A20
COLUMN username FORMAT A20
COLUMN program FORMAT A50
 
SELECT b.tablespace,
       ROUND(((b.blocks*p.value)/1024/1024),2)||'M' AS temp_size,
       a.inst_id as Instance,
       a.sid||','||a.serial# AS sid_serial,
       NVL(a.username, '(oracle)') AS username,
       a.program,
       a.status,
       a.sql_id
FROM   gv$session a,
       gv$sort_usage b,
       gv$parameter p
WHERE  p.name  = 'db_block_size'
AND    a.saddr = b.session_addr
AND    a.inst_id=b.inst_id
AND    a.inst_id=p.inst_id
ORDER BY b.tablespace, b.blocks desc
/

SELECT A.tablespace_name tablespace, D.mb_total,
    SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
    D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
   FROM v$sort_segment A,
    (
   SELECT B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
    FROM v$tablespace B, v$tempfile C
     WHERE B.ts#= C.ts#
      GROUP BY B.name, C.block_size) D
    WHERE A.tablespace_name = D.name
    GROUP by A.tablespace_name, D.mb_total;
