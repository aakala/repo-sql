-------------------------------------------------------------------------------
--
--
--
-- File name:   
-- Purpose:     An easy to use Oracle session-level performance measurement tool
--              which does NOT require any database changes nor creation of any
--              database objects!
--
-- Usage:       This script uses 
--
--
--
-- Disclaimer:  This script is provided "as is", so no warranties or guarantees are
--              made about its correctness, reliability and safety. Use it at your
--              own risk!
--
--
--------------------------------------------------------------------------------
--

set feedback  off heading off
set lines 300 pages 0

Prompt Username accept username 
 with t as
 ( select TO_CHAR(dbms_metadata.get_ddl('USER','&username')) ddl from dual )
  select replace(ddl,'CREATE','ALTER')||';'
  from t;
