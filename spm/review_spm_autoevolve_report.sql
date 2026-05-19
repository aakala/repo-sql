
--------------------------------------------------------------------------------
-- Name:        review_spm_autoevolve_report.sql
-- Purpose:     Parse DBMS_SPM.REPORT_AUTO_EVOLVE_TASK output and classify
--              findings into:
--                A - Failed benefit / rejected
--                B - Adaptive / duplicate / no real change
--                C - Unclassified / review required
--                D - Real accepted improvements
--
-- Author:      A.Kala
-- Version:     1.0
--
-- License:     MIT License
-- Notes:
-- This script was developed with assistance from AI tooling and refined through
-- practical testing and review. Final validation, interpretation, and use are
-- the responsibility of the operator.
--------------------------------------------------------------------------------

set serveroutput on size unlimited format wrapped
set linesize 500
set pagesize 1000
set long 1000000
set longchunksize 32767

declare
    l_report        clob;
    l_pos           pls_integer;
    l_next_pos      pls_integer;
    l_report_len    pls_integer;
    l_step          varchar2(200) := 'INITIALIZATION';

    l_cnt_a         pls_integer := 0; -- failed benefit / rejected
    l_cnt_b         pls_integer := 0; -- adaptive / duplicate / no real change
    l_cnt_c         pls_integer := 0; -- review required / errors / unclassified
    l_cnt_d         pls_integer := 0; -- real accepted improvements

    procedure print_line(
        p_text in varchar2
    ) is
    begin
        dbms_output.put_line(p_text);
    end;

    procedure print_fatal_error(
        p_step in varchar2,
        p_err  in varchar2
    ) is
    begin
        dbms_output.put_line(chr(10) || '==============================================================');
        dbms_output.put_line('SCRIPT STATUS: FAILED');
        dbms_output.put_line('STEP          : ' || p_step);
        dbms_output.put_line('ERROR         : ' || substr(p_err, 1, 3500));
        dbms_output.put_line('==============================================================');
    exception
        when others then
            null;
    end;

    function get_chunk(
        p_start in pls_integer,
        p_len   in pls_integer,
        p_max   in pls_integer
    ) return varchar2
    is
    begin
        return dbms_lob.substr(l_report, least(p_len, p_max), p_start);
    exception
        when others then
            return null;
    end;

    function normalize(
        p_txt in varchar2
    ) return varchar2
    is
    begin
        return regexp_replace(nvl(p_txt, ' '), '\s+', ' ');
    end;

    function get_section_text(
        p_start in pls_integer,
        p_len   in pls_integer
    ) return varchar2
    is
    begin
        return normalize(get_chunk(p_start, p_len, 32000));
    end;

    function extract_val(
        p_start   in pls_integer,
        p_len     in pls_integer,
        p_pattern in varchar2
    ) return varchar2
    is
        l_val varchar2(4000);
    begin
        l_val := regexp_substr(
                   get_chunk(p_start, p_len, 12000),
                   p_pattern,
                   1,
                   1,
                   'in',
                   1
                 );
        return trim(l_val);
    exception
        when others then
            return null;
    end;

    function classify_section(
        p_start in pls_integer,
        p_len   in pls_integer
    ) return varchar2
    is
        l_txt varchar2(32767);
    begin
        l_txt := get_section_text(p_start, p_len);

        if l_txt is null then
            return 'C';
        elsif instr(l_txt, ' ERRORS SECTION ') > 0
           or instr(l_txt, ' ORA-') > 0
        then
            return 'C';
        elsif instr(l_txt, 'failed the benefit criterion') > 0 then
            return 'A';
        elsif instr(l_txt, 'adaptive and different from the final executed plan') > 0
           or instr(l_txt, 'final executed plan already exists in the plan history as an accepted plan') > 0
           or instr(l_txt, 'implementing the recommendation will drop the adaptive plan') > 0
           or instr(l_txt, 'the baseline plan matches the non-accepted plan being verified') > 0
        then
            return 'B';
        elsif instr(l_txt, 'passed the benefit criterion') > 0 then
            return 'D';
        else
            return 'C';
        end if;
    end;

    function get_reason(
        p_start in pls_integer,
        p_len   in pls_integer
    ) return varchar2
    is
        l_txt varchar2(32767);
    begin
        l_txt := get_section_text(p_start, p_len);

        if l_txt is null then
            return 'SECTION_READ_FAILURE';
        elsif instr(l_txt, ' ERRORS SECTION ') > 0 and instr(l_txt, ' ORA-') > 0 then
            return 'ERRORS_SECTION_WITH_ORA';
        elsif instr(l_txt, ' ERRORS SECTION ') > 0 then
            return 'ERRORS_SECTION_PRESENT';
        elsif instr(l_txt, ' ORA-') > 0 then
            return 'ORA_ERROR_FOUND';
        elsif instr(l_txt, 'Recommendation:') > 0
          and instr(l_txt, 'benefit criterion') = 0 then
            return 'UNRECOGNIZED_RECOMMENDATION_PATTERN';
        elsif instr(l_txt, 'automatically accepted') > 0 then
            return 'UNRECOGNIZED_ACCEPTED_PATTERN';
        elsif instr(l_txt, 'verified') > 0
          and instr(l_txt, 'passed the benefit criterion') = 0
          and instr(l_txt, 'failed the benefit criterion') = 0 then
            return 'VERIFIED_WITHOUT_KNOWN_BENEFIT_RESULT';
        else
            return 'UNCLASSIFIED';
        end if;
    end;

    function get_benefit(
        p_start in pls_integer,
        p_len   in pls_integer
    ) return number
    is
        l_val varchar2(100);
    begin
        l_val := regexp_substr(
                   get_section_text(p_start, p_len),
                   '([0-9]+(\.[0-9]+)?) times better',
                   1,
                   1,
                   'in',
                   1
                 );
        return to_number(l_val);
    exception
        when others then
            return null;
    end;

    function get_benefit_pct(
        p_factor in number
    ) return number
    is
    begin
        if p_factor is null then
            return null;
        else
            return round((p_factor - 1) * 100, 2);
        end if;
    end;

    function get_base_elapsed_s(
        p_start in pls_integer,
        p_len   in pls_integer
    ) return varchar2
    is
        l_txt varchar2(32767);
        l_val varchar2(100);
    begin
        l_txt := get_section_text(p_start, p_len);

        l_val := regexp_substr(
                   l_txt,
                   'Elapsed Time \(s\):\s*([0-9\.]+)\s+([0-9\.]+)',
                   1,
                   1,
                   'in',
                   1
                 );

        return trim(l_val);
    exception
        when others then
            return null;
    end;

    function get_test_elapsed_s(
        p_start in pls_integer,
        p_len   in pls_integer
    ) return varchar2
    is
        l_txt varchar2(32767);
        l_val varchar2(100);
    begin
        l_txt := get_section_text(p_start, p_len);

        l_val := regexp_substr(
                   l_txt,
                   'Elapsed Time \(s\):\s*([0-9\.]+)\s+([0-9\.]+)',
                   1,
                   1,
                   'in',
                   2
                 );

        return trim(l_val);
    exception
        when others then
            return null;
    end;

    function get_sql_id(
        p_sql_handle in varchar2,
        p_plan_name  in varchar2
    ) return varchar2
    is
        l_sql_id varchar2(13);
    begin
        /*
          1) Best match: live cursor using this exact baseline plan
        */
        begin
            select min(s.sql_id)
            into   l_sql_id
            from   dba_sql_plan_baselines b
                   join v$sql s
                     on s.exact_matching_signature = b.signature
                    and s.sql_plan_baseline        = b.plan_name
            where  b.sql_handle = p_sql_handle
            and    b.plan_name  = p_plan_name;

            if l_sql_id is not null then
                return l_sql_id;
            end if;
        exception
            when no_data_found then
                null;
            when others then
                null;
        end;

        /*
          2) Next best: shared pool parent cursor by signature
        */
        begin
            select min(s.sql_id)
            into   l_sql_id
            from   dba_sql_plan_baselines b
                   join v$sqlarea s
                     on s.exact_matching_signature = b.signature
            where  b.sql_handle = p_sql_handle
            and    b.plan_name  = p_plan_name;

            if l_sql_id is not null then
                return l_sql_id;
            end if;
        exception
            when no_data_found then
                null;
            when others then
                null;
        end;

        /*
          3) Fallback: derive SQL_ID from baseline SQL text
        */
        begin
            select min(dbms_sqltune_util0.sqltext_to_sqlid(b.sql_text || chr(0)))
            into   l_sql_id
            from   dba_sql_plan_baselines b
            where  b.sql_handle = p_sql_handle
            and    b.plan_name  = p_plan_name;

            return l_sql_id;
        exception
            when no_data_found then
                return null;
            when others then
                return null;
        end;
    end;

    function get_plan_hash_from_baseline(
        p_sql_handle in varchar2,
        p_plan_name  in varchar2
    ) return varchar2
    is
        l_hash varchar2(100);
    begin
        select min(to_char(to_number(regexp_replace(plan_table_output, '^[^0-9]*'))))
        into   l_hash
        from   table(dbms_xplan.display_sql_plan_baseline(p_sql_handle, p_plan_name))
        where  plan_table_output like 'Plan hash value: %';

        return l_hash;
    exception
        when no_data_found then
            return null;
        when others then
            return null;
    end;

    function get_last_verified(
        p_sql_handle in varchar2,
        p_plan       in varchar2
    ) return varchar2
    is
        l_val varchar2(40);
    begin
        select to_char(max(last_verified), 'DD-MON-YYYY HH24:MI:SS')
        into   l_val
        from   dba_sql_plan_baselines
        where  sql_handle = p_sql_handle
        and    plan_name  = p_plan;

        return l_val;
    exception
        when others then
            return null;
    end;

    procedure process_section(
        p_start in pls_integer,
        p_len   in pls_integer,
        p_cat   in varchar2
    ) is
        l_cat             varchar2(1);
        l_obj             varchar2(30);
        l_sql_handle      varchar2(50);
        l_test_plan       varchar2(128);
        l_base_plan       varchar2(128);
        l_sql_id          varchar2(13);
        l_reason          varchar2(60);
        l_benefit         number;
        l_benefit_pct     number;
        l_base_hash       varchar2(30);
        l_test_hash       varchar2(30);
        l_last_verified   varchar2(40);
        l_base_elapsed_s  varchar2(30);
        l_test_elapsed_s  varchar2(30);
    begin
        l_cat := classify_section(p_start, p_len);

        if l_cat <> p_cat then
            return;
        end if;

        l_obj        := extract_val(p_start, p_len, 'Object ID\s*:\s*([0-9]+)');
        l_sql_handle := extract_val(p_start, p_len, 'SQL Handle\s*:\s*(\S+)');
        l_test_plan  := extract_val(p_start, p_len, 'Test Plan Name\s*:\s*(\S+)');
        l_base_plan  := extract_val(p_start, p_len, 'Base Plan Name\s*:\s*(\S+)');
        l_sql_id     := get_sql_id(l_sql_handle, l_test_plan);

        if l_cat = 'A' then
            l_cnt_a := l_cnt_a + 1;

            print_line(
                rpad(nvl(l_obj, '-'), 8)              || ' | ' ||
                rpad(nvl(l_sql_id, 'N/A'), 13)       || ' | ' ||
                rpad(nvl(l_sql_handle, '-'), 20)     || ' | ' ||
                rpad(nvl(l_test_plan, '-'), 31)      || ' | ' ||
                rpad(nvl(l_base_plan, '-'), 31)
            );

        elsif l_cat = 'B' then
            l_cnt_b := l_cnt_b + 1;

            print_line(
                rpad(nvl(l_obj, '-'), 8)              || ' | ' ||
                rpad(nvl(l_sql_id, 'N/A'), 13)       || ' | ' ||
                rpad(nvl(l_sql_handle, '-'), 20)     || ' | ' ||
                rpad(nvl(l_test_plan, '-'), 31)      || ' | ' ||
                rpad(nvl(l_base_plan, '-'), 31)
            );

        elsif l_cat = 'C' then
            l_cnt_c := l_cnt_c + 1;
            l_reason := get_reason(p_start, p_len);

            print_line(
                rpad(nvl(l_obj, '-'), 8)              || ' | ' ||
                rpad(nvl(l_sql_id, 'N/A'), 13)       || ' | ' ||
                rpad(nvl(l_sql_handle, '-'), 20)     || ' | ' ||
                rpad(nvl(l_test_plan, '-'), 31)      || ' | ' ||
                rpad(nvl(l_base_plan, '-'), 31)      || ' | ' ||
                nvl(l_reason, 'UNCLASSIFIED')
            );

        elsif l_cat = 'D' then
            l_cnt_d := l_cnt_d + 1;
            l_benefit       := get_benefit(p_start, p_len);
            l_benefit_pct   := get_benefit_pct(l_benefit);
            l_base_hash     := get_plan_hash_from_baseline(l_sql_handle, l_base_plan);
            l_test_hash     := get_plan_hash_from_baseline(l_sql_handle, l_test_plan);
            l_last_verified := get_last_verified(l_sql_handle, l_test_plan);
            l_base_elapsed_s := get_base_elapsed_s(p_start, p_len);
            l_test_elapsed_s := get_test_elapsed_s(p_start, p_len);

            print_line(
                rpad(nvl(l_obj, '-'), 8)                    || ' | ' ||
                rpad(nvl(l_sql_id, 'N/A'), 13)             || ' | ' ||
                rpad(nvl(l_sql_handle, '-'), 20)           || ' | ' ||
                rpad(nvl(l_base_hash, '-'), 15)            || ' | ' ||
                rpad(nvl(l_test_hash, '-'), 15)            || ' | ' ||
                rpad(nvl(l_last_verified, 'N/A'), 20)      || ' | ' ||
                lpad(nvl(l_base_elapsed_s, 'N/A'), 14)     || ' | ' ||
                lpad(nvl(l_test_elapsed_s, 'N/A'), 14)     || ' | ' ||
                lpad(nvl(to_char(l_benefit_pct, '999990.99'), 'N/A'), 10) || ' | ' ||
                lpad(nvl(to_char(l_benefit, '999990.99999'), 'N/A'), 12)
            );
        end if;
    end;

    procedure run_cat(
        p_cat in varchar2
    ) is
        l_len pls_integer;
    begin
        l_pos := dbms_lob.instr(l_report, 'Object ID', 1, 1);

        while l_pos > 0 loop
            l_next_pos := dbms_lob.instr(l_report, 'Object ID', l_pos + 1, 1);

            if l_next_pos = 0 then
                l_len := l_report_len - l_pos + 1;
            else
                l_len := l_next_pos - l_pos;
            end if;

            process_section(l_pos, l_len, p_cat);

            exit when l_next_pos = 0;
            l_pos := l_next_pos;
        end loop;
    end;

begin
    l_step := 'GENERATE REPORT';
    l_report := dbms_spm.report_auto_evolve_task(
                  type           => 'TEXT',
                  level          => 'ALL',
                  section        => 'ALL',
                  object_id      => null,
                  execution_name => null
                );

    if l_report is null then
        raise_application_error(-20001, 'DBMS_SPM.REPORT_AUTO_EVOLVE_TASK returned NULL');
    end if;

    l_step := 'GET REPORT LENGTH';
    l_report_len := dbms_lob.getlength(l_report);

    if l_report_len = 0 then
        raise_application_error(-20002, 'Auto evolve report is empty');
    end if;

    l_step := 'PRINT CATEGORY A';
    print_line('==============================================================');
    print_line('CATEGORY A: FAILED BENEFIT / REJECTED');
    print_line('==============================================================');
    print_line('OBJ_ID   | SQL_ID        | SQL_HANDLE           | TEST_PLAN_NAME                  | BASE_PLAN_NAME');
    print_line('-------- | ------------- | -------------------- | ------------------------------- | -------------------------------');
    run_cat('A');
    if l_cnt_a = 0 then
        print_line('No rows');
    end if;

    l_step := 'PRINT CATEGORY B';
    print_line(chr(10) || '==============================================================');
    print_line('CATEGORY B: ADAPTIVE / DUPLICATE / NO REAL CHANGE');
    print_line('==============================================================');
    print_line('NOTE:');
    print_line('Category B contains adaptive/duplicate plan cases. These are separated from');
    print_line('Category A because they are not true failed-benefit cases.');
    print_line('');
    print_line('In these entries, the report may say "The plan was automatically accepted", but');
    print_line('this usually does not mean a meaningful new execution plan was added. The final');
    print_line('executed plan already exists as an accepted baseline, so this category is best');
    print_line('treated as informational/cleanup rather than a real improvement.');
    print_line('');
    print_line('OBJ_ID   | SQL_ID        | SQL_HANDLE           | TEST_PLAN_NAME                  | BASE_PLAN_NAME');
    print_line('-------- | ------------- | -------------------- | ------------------------------- | -------------------------------');
    run_cat('B');
    if l_cnt_b = 0 then
        print_line('No rows');
    end if;

    l_step := 'PRINT CATEGORY C';
    print_line(chr(10) || '================================================================================================================================================');
    print_line('CATEGORY C: UNCLASSIFIED / REVIEW REQUIRED');
    print_line('================================================================================================================================================');
    print_line('NOTE:');
    print_line('Category C contains findings that did not match the standard classification');
    print_line('patterns for Categories A, B, or D, or contain report error sections.');
    print_line('');
    print_line('This may include verification errors, skipped/ineligible plans, unexpected');
    print_line('report wording, ORA errors, or new report patterns that should be reviewed manually.');
    print_line('');
    print_line('OBJ_ID   | SQL_ID        | SQL_HANDLE           | TEST_PLAN_NAME                  | BASE_PLAN_NAME                  | REVIEW_REASON');
    print_line('-------- | ------------- | -------------------- | ------------------------------- | ------------------------------- | ------------------------------');
    run_cat('C');
    if l_cnt_c = 0 then
        print_line('No rows');
    end if;

    l_step := 'PRINT CATEGORY D';
    print_line(chr(10) || '====================================================================================================================================================================');
    print_line('CATEGORY D: REAL ACCEPTED IMPROVEMENTS');
    print_line('====================================================================================================================================================================');
    print_line('COLUMN DESCRIPTION:');
    print_line('OBJ_ID          = Report object identifier for the specific auto evolve finding');
    print_line('SQL_ID          = SQL ID derived from live/shared SQL when available, else from baseline SQL_TEXT');
    print_line('SQL_HANDLE      = SQL Plan Management handle');
    print_line('BASE_PLAN_HASH  = Plan hash value from DBMS_XPLAN for the baseline plan');
    print_line('TEST_PLAN_HASH  = Plan hash value from DBMS_XPLAN for the accepted test plan');
    print_line('LAST_VERIFIED   = Verification timestamp for the accepted test plan');
    print_line('BASE_ELAPSED_S  = Base plan elapsed time from report execution statistics');
    print_line('TEST_ELAPSED_S  = Test plan elapsed time from report execution statistics');
    print_line('BEN_PCT         = Percent benefit derived from IMPROV_FACT');
    print_line('IMPROV_FACT     = Exact "times better than baseline" value from the report');
    print_line('');
    print_line('OBJ_ID   | SQL_ID        | SQL_HANDLE           | BASE_PLAN_HASH  | TEST_PLAN_HASH  | LAST_VERIFIED        | BASE_ELAPSED_S | TEST_ELAPSED_S | BEN_PCT    | IMPROV_FACT');
    print_line('-------- | ------------- | -------------------- | --------------- | --------------- | -------------------- | -------------- | -------------- | ---------- | ------------');
    run_cat('D');
    if l_cnt_d = 0 then
        print_line('No rows');
    end if;

    l_step := 'PRINT SUMMARY';
    print_line(chr(10) || '==============================================================');
    print_line('SUMMARY');
    print_line('==============================================================');
    print_line('SQLs reviewed   = ' || (l_cnt_a + l_cnt_b + l_cnt_c + l_cnt_d));
    print_line('Plans accepted  = ' || l_cnt_d);

    print_line(chr(10) || '==============================================================');
    print_line('SCRIPT STATUS: SUCCESS');
    print_line('==============================================================');

exception
    when others then
        print_fatal_error(l_step, sqlerrm);
end;
/
