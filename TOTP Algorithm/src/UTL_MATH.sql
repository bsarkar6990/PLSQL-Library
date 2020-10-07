create or replace package UTL_MATH as

function num2bin (
    p_num in number )
    return varchar2;

function bin2num (
    p_bin in varchar2)
    return number;
    
function bin2hex (
    p_bin in varchar2)
    return varchar2;

function var2bin(
    p_var in varchar2)
    return varchar2;
    
function hex2bin(
    p_var in varchar2)
    return varchar2;    

function raw2bin(
    p_raw in raw)
    return varchar2;

function bin2raw (
    p_bin in varchar2)
    return raw;
    
/*mod right pad*/    
function mrpad(
    p_bin in varchar2,
    p_mod in number)
    return varchar2;
    
/*mod left pad*/    
function mlpad(
    p_bin in varchar2,
    p_mod in number)
    return varchar2;
    
function binshift (
    p_bin in varchar2,
    p_bit in number)
    return varchar2;
    
function numshift (
    p_num in number,
    p_bit in number)
    return number;

function hexshift (
    p_hex in varchar2,
    p_bit in number)
    return varchar2;

function rawshift (
    p_raw in raw,
    p_bit in number)
    return raw;
    
function base32_rencode(
    p_raw in raw)
    return varchar2;
    
function base32_xencode(
    p_var in varchar2)
    return varchar2;
    
function base32_encode(
    p_var in varchar2)
    return varchar2;
end;
/

create or replace package body UTL_MATH as

function num2bin (
    p_num in number )
    return varchar2 is
v_bin varchar2(256);
begin
    SELECT LISTAGG(SIGN(BITAND(n, POWER(2,LEVEL-1))),'') 
       WITHIN GROUP(ORDER BY LEVEL DESC) bin
    into v_bin
    FROM (select p_num n from dual)
    CONNECT BY POWER(2, LEVEL-1)<=255;
    return v_bin;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end num2bin;

function bin2num (
    p_bin in varchar2 )
    return number is
v_num number;
begin
    select sum(to_number(substr(n,level,1))*power(2,length(n)-level)) c into v_num from(
        select p_bin n from dual)
    connect by level <=length(n);
    return v_num;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end bin2num;

function bin2hex (
    p_bin in varchar2)
    return varchar2 is
v_hex varchar2(4000);
begin
    select ltrim(listagg(trim(to_char(bin2num(substr(n,(level-1)*4+1,4)),'XX'))) within group(order by level),'0') into v_hex
    from(
        select mlpad(p_bin,4) n from dual)
    connect by level<=ceil(length(n)/4);
    return v_hex;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end bin2hex;

function var2bin(
    p_var in varchar2)
    return varchar2 is
v_var varchar2(4000);
begin
    select listagg(num2bin(ASCII(substr(n,level,1)))) within group(order by level) into v_var
    from (
    select p_var n from dual)
    connect by level<=length(n);
    return v_var;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end var2bin;

function hex2bin(
    p_var in varchar2)
    return varchar2 is
v_var varchar2(4000);
begin
    select listagg(num2bin(to_number(substr(n,(level-1)*2+1,2),'XX'))) within group(order by level) into v_var
    from (
    select mlpad(p_var,2) n from dual)
    connect by level<=round(length(n)/2);
    return v_var;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end hex2bin;

function raw2bin(
    p_raw in raw)
    return varchar2 is
v_var varchar2(4000);
begin
    select listagg(num2bin(UTL_RAW.CAST_TO_BINARY_INTEGER(UTL_RAW.SUBSTR(n,level,1)))) within group(order by level) into v_var
    from (
    select p_raw n from dual)
    connect by level<=UTL_RAW.LENGTH(n);
    return v_var;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end raw2bin;

function bin2raw (
    p_bin in varchar2)
    return raw is
v_raw raw(32767);
begin
    select HEXTORAW(bin2hex(p_bin)) into v_raw from dual;
    return v_raw;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end bin2raw;

function mrpad(
    p_bin in varchar2,
    p_mod in number)
    return varchar2 is 
v_bin varchar2(4000);
begin
    select rpad(n,p_mod*ceil(length(n)/p_mod),'0') into v_bin from(
        select nvl(p_bin,'0') n from dual);
    return v_bin;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end mrpad;

function mlpad(
    p_bin in varchar2,
    p_mod in number)
    return varchar2 is 
v_bin varchar2(4000);
begin
    select lpad(n,p_mod*ceil(length(n)/p_mod),'0') into v_bin from(
        select nvl(p_bin,'0') n from dual);
    return v_bin;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end mlpad;

function binshift (
    p_bin in varchar2,
    p_bit in number)
    return varchar2 is
v_bin varchar2(4000);
begin
    select listagg(nvl(substr(n,(-level*sign(p_bit))-decode(sign(p_bit),-1,0,p_bit),1),0)) within group(order by level*sign(p_bit) desc) into v_bin
    from (select 1 c1, rpad(n,length(n)-decode(sign(p_bit),-1,p_bit,0),'0') n from (
        select p_bin n from dual))
    connect by level <=length(n);
    return v_bin;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end binshift;
       
function numshift (
    p_num in number,
    p_bit in number)
    return number is
v_num number;
begin
    SELECT bin2num(binshift(num2bin(p_num),p_bit)) into v_num
    FROM dual;
    return v_num;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end numshift;

function hexshift (
    p_hex in varchar2,
    p_bit in number)
    return varchar2 is
v_hex varchar2(4000);
begin
    SELECT bin2hex(binshift(hex2bin(p_hex),p_bit)) into v_hex
    FROM dual;
    return v_hex;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end hexshift;

function rawshift (
    p_raw in raw,
    p_bit in number)
    return raw is
v_raw raw(32767);
begin
    SELECT bin2raw(binshift(raw2bin(p_raw),p_bit)) into v_raw
    FROM dual;
    return v_raw;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end rawshift;

function base32_xencode(
    p_var in varchar2)
    return varchar2 is
v_var varchar2(4000);
begin
    select listagg(case when c1>6 then t2.encoding when c1<=6 then case when c3=1 or (c3=2 and c1<=4) or (c3=3 and c1<=3) or (c3=4 and c1=1) then '=' else encoding  end end) within group(order by c1 desc) c4 into v_var from (
        select round(length(n)/5)+1-level c1,bin2num(substr(n,(level-1)*5+1,5)) c2,ceil(length(trim(TRAILING '0' from substr(n,length(n)-40,40)))/8) c3
        from (
            select mrpad(hex2bin(p_var),40) n from dual)
        connect by level<=length(n)/5) t1,RFC3548_CHARACTER_SETS t2
     where t1.c2=t2.value;
     return v_var;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end base32_xencode;

function base32_rencode(
    p_raw in raw)
    return varchar2 is
v_var varchar2(4000);
begin
    select listagg(case when c1>6 then t2.encoding when c1<=6 then case when c3=1 or (c3=2 and c1<=4) or (c3=3 and c1<=3) or (c3=4 and c1=1) then '=' else encoding  end end) within group(order by c1 desc) c4 into v_var from (
        select round(length(n)/5)+1-level c1,bin2num(substr(n,(level-1)*5+1,5)) c2,ceil(length(trim(TRAILING '0' from substr(n,length(n)-40,40)))/8) c3
        from (
            select mrpad(raw2bin(p_raw),40) n from dual)
        connect by level<=length(n)/5) t1,RFC3548_CHARACTER_SETS t2
     where t1.c2=t2.value;
     return v_var;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end base32_rencode;

function base32_encode(
    p_var in varchar2)
    return varchar2 is
v_var varchar2(4000);
begin
    select listagg(case when c1>6 then t2.encoding when c1<=6 then case when c3=1 or (c3=2 and c1<=4) or (c3=3 and c1<=3) or (c3=4 and c1=1) then '=' else encoding  end end) within group(order by c1 desc) c4 into v_var from (
        select round(length(n)/5)+1-level c1,bin2num(substr(n,(level-1)*5+1,5)) c2,ceil(length(trim(TRAILING '0' from substr(n,length(n)-40,40)))/8) c3
        from (
            select mrpad(var2bin(p_var),40) n from dual)
        connect by level<=length(n)/5) t1,RFC3548_CHARACTER_SETS t2
     where t1.c2=t2.value;
     return v_var;
exception
    when others then
        dbms_output.put_line(SQLERRM);
end base32_encode;
end UTL_MATH;
/