set lines 200
set pages 200
col CONSTRAINT_NAME for a35
col R_OWNER for a35
col R_CONSTRAINT_NAME for a35
col DELETE_RULE for a35
col DEFERRED for a35

select CONSTRAINT_NAME,CONSTRAINT_TYPE,R_OWNER,R_CONSTRAINT_NAME, DELETE_RULE,DEFERRED from dba_constraints where owner ='&OWNER' and table_name ='&TAB_NAME';

