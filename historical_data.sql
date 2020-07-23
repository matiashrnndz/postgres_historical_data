DO $$

DECLARE
    jid integer;
    scid integer;

BEGIN

    -- JOBS --
    -- Create a new job
    INSERT INTO pgagent.pga_job(
        jobjclid, jobname, jobdesc, jobhostagent, jobenabled
    ) VALUES (
        1::integer, 'cleanup'::text, ''::text, ''::text, true
    ) RETURNING jobid INTO jid;

    -- STEPS --
    -- Instert a step (jobid: NULL)
    INSERT INTO pgagent.pga_jobstep (
        jstjobid, jstname, jstenabled, jstkind,
        jstconnstr, jstdbname, jstonerror,
        jstcode, jstdesc
    ) VALUES (
        jid, 'run_cleanup'::text, true, 's'::character(1),
        ''::text, 'DatabaseName'::name, 'f'::character(1),
        '-- CODE --
        --
        -- If historical table does not exist, you must create the table without data
        --
        CREATE TABLE IF NOT EXISTS table_name_history
        AS TABLE table_name
        WITH NO DATA;
        --
        -- Clean up the records that you want to delete
        -- Insert more records than the ones you are going to delete
        --
        INSERT INTO table_name_history
        SELECT * FROM table_name WHERE 
        table_name.timestamp_inserted < (''now''::text::date - 20)
        ON CONFLICT DO NOTHING;
        --
        -- Delete the old records to free space from the main table
        --
        DELETE FROM table_name WHERE 
        table_name.timestamp_inserted < (''now''::text::date - 30);
        '::text, ''::text
    );

    -- SCHEDULES --
    -- Insert a schedule
    INSERT INTO pgagent.pga_schedule(
        jscjobid, jscname, jscdesc, jscenabled,
        jscstart, jscend,    jscminutes, jschours, jscweekdays, jscmonthdays, jscmonths
    ) VALUES (
        jid, 'weekly'::text, ''::text, true,
        '2019-05-26 15:46:16-03'::timestamp with time zone, '2029-05-21 16:32:29-03'::timestamp with time zone,
        -- Minutes
        ARRAY[true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]::boolean[],
        -- Hours
        ARRAY[false,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]::boolean[],
        -- Week days
        ARRAY[true,false,false,false,false,false,false]::boolean[],
        -- Month days
        ARRAY[false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]::boolean[],
        -- Months
        ARRAY[false,false,false,false,false,false,false,false,false,false,false,false]::boolean[]
    ) RETURNING jscid INTO scid;

END
$$;
