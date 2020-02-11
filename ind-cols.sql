-- -----------------------------------------------------------------------------------
-- File Name    - https://github.com/aakala/repo-sql/blob/master/ind-cols.sql
--               
-- Description  - Displays the list of indexes on a particular column
--               
-- Usage        - @ind-cols tab col filtering_clause
--
--               e.g 1. Filtering by table & column name only
--                 @ind-cols table_name col_name 1=1
--               
--                    e.g. @ind EMP EMP_PK 1=1
--                    
--              -e.g.  2. Filtering by table, column name & owner
--                  @:1,$d
ind-cols  table_name col_name index_owner='owner-name'
--                  
--                    e.g. @ind  EMP EMP_PK  index_owner='SCOTT'
--               
-- -----------------------------------------------------------------------------------




set pagesize 200 linesize 400
col index_owner form a30
col table_name form a30
col table_owner form a30
col index_name form a30
col column_name form a30
set feedback off
alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';

break on table_owner on table_name on index_owner on index_name skip 1


select table_owner, table_name, index_owner, index_name,COLUMN_NAME, COLUMN_POSITION, COLUMN_LENGTH, DESCEND 
 from dba_ind_columns i 
 where index_name  in 
 ( select index_name  from dba_ind_columns
   where
         regexp_like(table_name, '&1', 'i')
    and  regexp_like(COLUMN_NAME, '&2', 'i')
    and i.index_owner=index_owner 
	and &3) 
 order by 1,2,3,4,COLUMN_POSITION;


