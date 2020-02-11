set pages 0
set feedback off
set lines 300
column cmd format a300 word_wrapped
column file_name format a80 word_wrapped
set lines 300
set verify off

SELECT    'alter database datafile '''
       || file_name
       || ''' resize '
       || CEIL ( (NVL (hwm, 1) * c.block_size) / 1024 / 1024 + 10)
       || 'm;'
          cmd
  FROM dba_data_files a,
       (  SELECT file_id, MAX (block_id + blocks - 1) hwm
            FROM dba_extents
        GROUP BY file_id) b,
       dba_tablespaces c
 WHERE     a.file_id = b.file_id(+)
       AND   CEIL (blocks * c.block_size / 1024 / 1024)
           - CEIL ( (NVL (hwm, 1) * c.block_size) / 1024 / 1024) > 0
       AND a.tablespace_name = c.tablespace_name
       AND c.block_size IN (2048, 4096, 8192, 16384, 32768)
--       AND a.tablespace_name LIKE 'DATA'
       AND c.status != 'READ ONLY'
       AND c.contents != 'TEMPORARY';
