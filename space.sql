/* Formatted on 2/11/2014 3:45:15 PM (QP5 v5.163.1008.3004) */
       
set lines 300 
set pages 300
col file_name for a40                      
SELECT NAME,TYPE,state,
       ROUND (total_mb / 1024) Total_GB,
       ROUND (free_mb / 1024) Free_GB,
       ROUND (usable_file_mb / 1024) Actual_FREE_GB,
       ROUND ( (total_mb - usable_file_mb) / 1024) occupied_GB,
       ROUND ( (usable_file_mb / total_mb) * 100, 2) " FREE%",
       ROUND (( (total_mb-usable_file_mb )/ total_mb) * 100, 2) " USED%"
  FROM v$asm_diskgroup                   
;


SELECT dg.name "DG Name",
         d.name "Disk Name",
         d.PATH,
         d.header_status
    FROM v$asm_disk d, v$asm_diskgroup_stat dg
   WHERE d.group_number = dg.group_numberr AND dg.name NOT LIKE 'D3%'
ORDER BY 1;


select * from v$parameter where name like 'db_create%';

set lines 200
set pages 300
col file_name for a40
select file_name, bytes/1024/1024/1024, autoextensible, maxbytes/1024/1024/1024 from dba_Data_files where tablespace_name ='&tbs_name';
