create or replace package UTL_WALLET as

function crypto_key (
    p_timewin in number )
    return varchar2;

function crypto_tframe return number;

end;
/

create or replace package body UTL_WALLET as

g_timeframe number default 5;
g_crypto_key varchar(64) default '4E3W4112345677871D727AE06CBF7B65728982392SDFG881235152WEUTYEFB8';

function crypto_key (
    p_timewin in number )
    return varchar2 is
l_curtimewin number;
begin
    select (to_number(extract(day from(sys_extract_utc(systimestamp) - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400000 + to_number(to_char(sys_extract_utc(systimestamp), 'SSSSSFF3')))/(g_timeframe*1000)) into l_curtimewin  from  dual;
    if floor(l_curtimewin)=floor(p_timewin) then
        return g_crypto_key;
    end if;
    return '-1';
exception
    when others then
        dbms_output.put_line(SQLERRM);
end crypto_key;

function crypto_tframe return number is
begin
    return g_timeframe;
end crypto_tframe;

end UTL_WALLET;
/