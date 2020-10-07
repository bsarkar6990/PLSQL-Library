create or replace package UTL_TOTP as

function calc_otp (
    p_secret in raw,
    p_timewin   in number)
    return number;

function check_otp(
    p_secret in raw,
    p_otp in number)
    return boolean;

function new_secret
    return raw;

function create_cred(
    p_username varchar2,
    p_save number default 0)
    return varchar2;

function fetch_cred(
    p_username varchar2)
    return varchar2;

function authorize(
    p_username varchar2,
    p_otp number)
    return boolean;
    
end UTL_TOTP;
/

create or replace package body UTL_TOTP as

g_timeframe number default 30; --in seconds
g_window number default 5;

function calc_otp (
    p_secret in raw,
    p_timewin   in number)
    return number is
l_timewin raw(160);
l_offset number;
l_hash RAW(2048);
l_off24 RAW(2048);
l_off16 RAW(2048);
l_off8 RAW(2048);
l_off0 RAW(2048);
l_otp number;
begin
    l_timewin := UTL_RAW.CAST_FROM_BINARY_INTEGER(p_timewin);
    l_hash := dbms_crypto.mac(utl_math.mlpad((l_timewin),16), dbms_crypto.HMAC_SH1, p_secret);
    l_offset:=utl_raw.cast_to_binary_integer(LTRIM(UTL_RAW.BIT_AND(l_hash,HEXTORAW(utl_math.mlpad('F',length(RAWTOHEX(l_hash))))),'0'));
    l_off24:=utl_math.rawshift(UTL_RAW.BIT_AND(UTL_RAW.SUBSTR(l_hash,l_offset+1,1),HEXTORAW('7f')),-24);
    l_off16:=utl_math.rawshift(UTL_RAW.BIT_AND(UTL_RAW.SUBSTR(l_hash,l_offset+2,1),HEXTORAW('ff')),-16);
    l_off8:=utl_math.rawshift(UTL_RAW.BIT_AND(UTL_RAW.SUBSTR(l_hash,l_offset+3,1),HEXTORAW('ff')),-8);
    l_off0:=UTL_RAW.BIT_AND(UTL_RAW.SUBSTR(l_hash,l_offset+4,1),HEXTORAW('ff'));
    l_otp:=mod(UTL_RAW.cast_to_binary_integer(UTL_RAW.BIT_OR(l_off24,utl_math.mlpad(UTL_RAW.BIT_OR(l_off16,utl_math.mlpad(UTL_RAW.BIT_OR(l_off8,utl_math.mlpad(l_off0,4)),6)),8))),power(10,6));
    return l_otp;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end calc_otp;

function check_otp(
    p_secret in raw,
    p_otp in number)
    return boolean is
l_curtimewin number;
l_min number;
l_max number;
l_otp number;
begin
    select (to_number(extract(day from(sys_extract_utc(systimestamp) - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400000 + to_number(to_char(sys_extract_utc(systimestamp), 'SSSSSFF3')))/(g_timeframe*1000)) into l_curtimewin  from  dual;
    l_min:=-((g_window - 1) / 2);
    l_max:=(g_window / 2);
    for l_cur in l_min..l_max loop
        l_otp:=calc_otp(p_secret,(l_curtimewin+l_cur));
        if l_otp=p_otp then
            return true;
        end if;
    end loop;
    return false;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end check_otp;

function new_secret
    return raw is
begin
    return DBMS_CRYPTO.RANDOMBYTES (20);
exception
    when others then
        dbms_output.put_line(SQLERRM);
end new_secret;

function create_cred(
    p_username varchar2,
    p_save number)
    return varchar2 is
PRAGMA AUTONOMOUS_TRANSACTION;
l_secret raw(160);
l_secret_base32 varchar2(256);
l_encrypted_secret varchar2(2048);
l_updated number:=0;
begin
    l_secret:=new_secret;
    l_secret_base32:=utl_math.base32_rencode(l_secret);
    if p_save<>0 then   
        l_encrypted_secret:=utl_algo.encrypt(RAWTOHEX(l_secret));
        update HWM_USERS
        set    SECRET_KEY_ENCRYPT=l_encrypted_secret
        where  upper(user_name)=upper(p_username);
        commit;
    end if;
    return l_secret_base32;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end create_cred;

function fetch_cred(
    p_username varchar2)
    return varchar2 is
l_secret varchar2(2048);
l_secret_base32 varchar2(256);
l_encrypted_secret varchar2(2048);
l_updated number:=0;
begin
    select SECRET_KEY_ENCRYPT into l_encrypted_secret
    from    HWM_USERS
    where    upper(user_name)=upper(p_username);
    l_secret:=utl_algo.decrypt(l_encrypted_secret);
    l_secret_base32:=utl_math.base32_xencode(l_secret);
    return l_secret_base32;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end fetch_cred;

function authorize(
    p_username varchar2,
    p_otp number)
    return boolean is
l_secret varchar2(2048);
l_secret_base32 varchar2(256);
l_encrypted_secret varchar2(2048);
l_updated number:=0;
begin
    select SECRET_KEY_ENCRYPT into l_encrypted_secret
    from    HWM_USERS
    where    upper(user_name)=upper(p_username);
    l_secret:=utl_algo.decrypt(l_encrypted_secret);
    return check_otp(HEXTORAW(l_secret),p_otp);
exception
    when others then
        dbms_output.put_line(SQLERRM);
end authorize;
    
end UTL_TOTP;
/