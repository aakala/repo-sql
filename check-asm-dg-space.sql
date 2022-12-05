/* Formatted on 2/11/2014 3:45:15 PM (QP5 v5.163.1008.3004) */
       
set lines 300 
set pages 300
col file_name for a40    
col compatibility for a20
col database_compatibility for a20
SELECT NAME,TYPE,state,compatibility, database_compatibility,voting_files,offline_disks
       ROUND (total_mb / 1024) Total_GB,
       ROUND (free_mb / 1024) Free_GB,
       ROUND (usable_file_mb / 1024) Actual_FREE_GB,
       ROUND ( (total_mb - usable_file_mb) / 1024) occupied_GB,
       ROUND ( (usable_file_mb / total_mb) * 100, 2) " FREE%",
       ROUND (( (total_mb-usable_file_mb )/ total_mb) * 100, 2) " USED%"
  FROM v$asm_diskgroup                   
;



col "DG Name" for a40
col "Disk Name" for a40
col "PATH" for a70
SELECT dg.name "DG Name",
         d.name "Disk Name",
         d.PATH,
         d.header_status
    FROM v$asm_disk d, v$asm_diskgroup_stat dg
   WHERE d.group_number = dg.group_numberr AND dg.name NOT LIKE 'D3%'
ORDER BY 1;

set pages 100 lines 200
set feed on term on



