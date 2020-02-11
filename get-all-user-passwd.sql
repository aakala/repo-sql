set feedback  off heading off
set lines 300 pages 0
 with t as
 ( select TO_CHAR(dbms_metadata.get_ddl('USER',username)) ddl from dba_users where account_status ='OPEN' )
  select replace(ddl,'CREATE','ALTER')||';'
  from t;
