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


