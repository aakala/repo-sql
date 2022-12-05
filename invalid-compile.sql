select count(*) from dba_objects where status!='VALID';
col owner for a30
col object_name for a30
col object_type for a30
set lines 100
set pages 200
select owner,object_name,object_type from dba_objects where status!='VALID';
select owner,object_type,count(*) from dba_objects where status!='VALID' group by owner, object_type;
select owner,object_name,object_type from dba_objects where status!='VALID';

-- Schema level.
EXEC UTL_RECOMP.recomp_serial('&Schema');
EXEC UTL_RECOMP.recomp_parallel(4, '&Schema');

-- Database level.
--EXEC UTL_RECOMP.recomp_serial();
--EXEC UTL_RECOMP.recomp_parallel(4);

select count(*) from dba_objects where status!='VALID';
select owner,object_type,count(*) from dba_objects where status!='VALID' group by owner, object_type order by 1,2;
select owner,object_name,object_type from dba_objects where status!='VALID';
