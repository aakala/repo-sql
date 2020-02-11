SELECT s.inst_id,
        r.name                   rbs,
        nvl(s.username, 'None')  oracle_user,
        s.osuser                 client_user,
        p.username               unix_user,
        p.spid                   unix_pid,
        TO_CHAR(s.logon_time, 'mm/dd/yy hh24:mi:ss') as login_time,
        t.used_ublk * 32768/1024/1024/102  as undo_GB,
                st.sql_text as sql_text
   FROM gv$process     p,
        v$rollname     r,
        gv$session     s,
        gv$transaction t,
        gv$sqlarea     st
  WHERE p.inst_id=s.inst_id
    AND p.inst_id=t.inst_id
    AND s.inst_id=st.inst_id
    AND s.taddr = t.addr
    AND s.paddr = p.addr(+)
    AND r.usn   = t.xidusn(+)
    AND s.sql_address = st.address
  AND t.used_ublk * 32768 > 1073741824
/
