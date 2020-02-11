-- -----------------------------------------------------------------------------------
-- File Name    - https://github.com/aakala/repo-sql/blob/master/ind.sql
--               
-- Description  - Displays brief Index details
--               
-- Usage        - @ind ind_name filtering_clause 
--              
--              e.g. 1. Filtering by index name only
--                 @ind ind_name 1=1
--               
--                    e.g. @ind EMP_PK 1=1
--                    
--              e.g. 2. Filtering by both index_name & index_owner 
--                  @ind  ind_name owner='ind_owner'
--                  
--                    e.g. @ind EMP_PK owner='SCOTT'
--               
-- -----------------------------------------------------------------------------------




set pagesize 200 linesize 400
col owner form a30
col table_name form a30
col table_owner form a30
col index_name form a30
col UNIQUENES form a10
col column_name form a30
set feedback off
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';


break on owner on index_name on uniqueness on last_analyzed on table_owner on table_name skip 1



select i.owner, i.index_name, i.UNIQUENESS, i.LAST_ANALYZED,ic.table_owner, ic.TABLE_NAME, ic.column_name, ic.column_position, ic.DESCEND
from dba_indexes i, dba_ind_columns ic
where i.index_name=ic.index_name
and i.owner= ic.INDEX_OWNER
and regexp_like(ic.index_name, '&1', 'i') 
and &2
;

