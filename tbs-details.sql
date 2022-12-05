
Skip to content
Pull requests
Issues
Codespaces
Marketplace
Explore
@aakala
pythian /
team39-oracle
Private

Code
Issues
Pull requests
Actions
Projects
Wiki
Security
Insights

    Settings

team39-oracle/sql-lib/tablespace.sql
@kishanparekh
kishanparekh Create tablespace.sql
Latest commit 2ed98cb Nov 21, 2019
History
1 contributor
29 lines (27 sloc) 1.39 KB
DEFINE tb_space=&tablespace

select
        a.tablespace_name, round(SUM(a.bytes)/(1024*1024*1024)) CURRENT_GB,
        round(SUM(decode(b.maxextend, null, A.BYTES/(1024*1024*1024), b.maxextend*8192/(1024*1024*1024)))) MAX_GB,
        (SUM(a.bytes)/(1024*1024*1024) - round(c.Free/1024/1024/1024)) USED_GB,
        round((SUM(decode(b.maxextend, null, A.BYTES/(1024*1024*1024),
        b.maxextend*8192/(1024*1024*1024))) - (SUM(a.bytes)/(1024*1024*1024) - round(c.Free/1024/1024/1024))),2) FREE_GB,
        round(100*(SUM(a.bytes)/(1024*1024*1024) - round(c.Free/1024/1024/1024))/(SUM(decode(b.maxextend, null, A.BYTES/(1024*1024*1024),
        b.maxextend*8192/(1024*1024*1024))))) USED_PCT
from
        dba_data_files a, sys.filext$ b,
                (SELECT
                        d.tablespace_name ,sum(nvl(c.bytes,0)) Free
                FROM
                        dba_tablespaces d, DBA_FREE_SPACE c
                WHERE
                        d.tablespace_name = c.tablespace_name(+)
                        group by d.tablespace_name) c
WHERE
        a.file_id = b.file#(+)
        and a.tablespace_name = c.tablespace_name
        and a.tablespace_name = '&tb_space'
GROUP BY a.tablespace_name, c.Free/1024
ORDER BY tablespace_name;

col file_name for a60
col tablespace_name for a20
col block_size for a10
col satus for a20
select tablespace_name, block_size, status, contents,logging,extent_managmement, DEF_TAB_COMPRESSION, bigfile from dba_tablespaces where tablespace_name = '&tb_space';

select tablespace_name, file_id, file_name,bytes/1024/1024, autoextensible, maxbytes/1024/1024 from dba_data_files
where tablespace_name='&tb_space';


