set lines 100
col name format a60
Prompt " Checking usage of recovery_file_dest " 
select
   name,
  floor(space_limit / 1024 / 1024/1024) "Size GB",
  ceil(space_used / 1024 / 1024/1024) "Used GB"
from v$recovery_file_dest;

Prompt " Details of Flash Recovery Area Usage"

SELECT * FROM V$FLASH_RECOVERY_AREA_USAGE;
 
Prompt "Location and size of the FRA"

show parameter db_recovery_file_dest
 
Prompt "Usage and space consumption"
SELECT
  ROUND((A.SPACE_LIMIT / 1024 / 1024 / 1024), 2) AS FLASH_IN_GB, 
  ROUND((A.SPACE_USED / 1024 / 1024 / 1024), 2) AS FLASH_USED_IN_GB, 
  ROUND((A.SPACE_RECLAIMABLE / 1024 / 1024 / 1024), 2) AS FLASH_RECLAIMABLE_GB,
  SUM(B.PERCENT_SPACE_USED)  AS PERCENT_OF_SPACE_USED
FROM
  V$RECOVERY_FILE_DEST A,
  V$FLASH_RECOVERY_AREA_USAGE B
GROUP BY
  SPACE_LIMIT, 
  SPACE_USED , 
  SPACE_RECLAIMABLE ;

Prompt " Size of ASM Diskgroup .. if ASM is being used"
  
set lines 200
set pages 300
col NAMEfor a40                          
SELECT NAME,TYPE,
       ROUND (total_mb / 1024) Total_GB,
       ROUND (free_mb / 1024) Free_GB,
       ROUND (usable_file_mb / 1024) Actual_FREE_GB,
       ROUND ( (total_mb - usable_file_mb) / 1024) occupied_GB,
       ROUND ( (usable_file_mb / total_mb) * 100, 2) " FREE%",
       ROUND (( (total_mb-usable_file_mb )/ total_mb) * 100, 2) " USED%"
  FROM v$asm_diskgroup_stat;

Prompt " Review of restore points.. if any " 

select name,SCN,GUARANTEE_FLASHBACK_DATABASE,round(STORAGE_SIZE/1024/1024,0) STORAGE_SIZE_MB, time from V$RESTORE_POINT order by time;