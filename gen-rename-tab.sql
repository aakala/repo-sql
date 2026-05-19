/* backs up tables and associated indexes and constraints to _O */
col stmnt for a119 word_wrapped
set pages 0 lines 120 echo off
accept my_own prompt "Owner: "
accept my_tab prompt "Table: "
 
SELECT    'ALTER TABLE '
       || owner
       || '.'
       || table_name
       || ' RENAME TO '
       || SUBSTR (table_name, 1, 28)
       || '_O;' stmnt
  FROM dba_tables
WHERE owner = upper('&my_own') AND table_name = upper('&my_tab');
 
 
SELECT    'ALTER TABLE '
       || owner
       || '.'
       || table_name
       || '_O RENAME CONSTRAINT '
       || constraint_name
       || ' TO '
       || SUBSTR (constraint_name, 1, 28)
       || '_O;' stmnt
  FROM dba_constraints
WHERE owner = upper('&my_own') AND table_name = upper('&my_tab');

SELECT    'ALTER INDEX '
       || owner
       || '.'
       || index_name
       || ' RENAME TO '
       || SUBSTR (index_name, 1, 28)
       || '_O;' stmnt
  FROM dba_indexes
WHERE owner = upper('&my_own') AND table_name = upper('&my_tab');
 
 
 
SELECT    'ALTER TRIGGER '
       || owner
       || '.'
       || SUBSTR (trigger_name, 1, 28)
       || 'RENAME TO '
       || trigger_name
       || '_O ;' stmnt
  FROM dba_trigger
WHERE owner = upper('&my_own') AND table_name = upper('&my_tab');
