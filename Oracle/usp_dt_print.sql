BEGIN EXECUTE IMMEDIATE 'DROP PROCEDURE usp_dt_print'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -4043 THEN RAISE; END IF; END;

create procedure usp_dt_print(
    start_time timestamp, description varchar, row_count integer
)
as
    interval_time interval day to second := localtimestamp - start_time;
    output varchar(2000);
begin
    output := to_char(extract(hour from (interval_time)), 'FM09') || ':' ||
        to_char(extract(minute from interval_time), 'FM09') || ':' ||
        to_char(extract(second from interval_time), 'FM09') || ' - ' ||
        description;
    if row_count is not null then
        output := output || ', ' || to_char(row_count) || ' rows';
    end if;
    dbms_output.put_line(output);
end;
/