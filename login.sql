alter session set NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS';
set lines 300 pages 5000
col host_name for a30
col db_unique_name for a10
col instance_number for 9999 head "INST|#"
set sqlprompt "_user'@'_connect_identifier:SQL> "
col uptime for a17 head "Days Hrs Min Sec"


select name, open_mode, database_role, host_name, instance_name,db_unique_name,log_mode, startup_time from v$database, v$instance;
Prompt 
Prompt  Product components and versions 
Prompt ==================================

col product for a50
col version for a15
col status for a30
  select *
    from product_component_version;


Prompt 
Prompt Database components and versions
Prompt ================================


col comp_id for a20
col comp_name for a45
select comp_id, comp_name, status, version from dba_registry;

Prompt 
Prompt  RAC node information 
Prompt ======================


  select inst_id, instance_number, host_name, startup_time, status, database_status, active_state, instance_role, status
,        floor(sysdate - startup_time) || 'D ' || trunc( 24*((sysdate-startup_time) - trunc(sysdate-startup_time))) || 'H ' ||
               mod(trunc(1440*((sysdate-startup_time) - trunc(sysdate-startup_time))), 60) ||'M ' || mod(trunc(86400*((sysdate-startup_time) -
               trunc(sysdate-startup_time))), 60) ||'S' uptime
    from gv$instance
order by 1;


set timing on