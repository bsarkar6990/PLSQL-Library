create or replace package UTL_ALGO as

function encrypt(
    p_hex varchar2)
    return varchar2;
    
function decrypt(
    p_hex varchar2)
    return varchar2;

end;
/
create or replace package body UTL_ALGO as

g_encryption_type PLS_INTEGER :=
                            DBMS_CRYPTO.ENCRYPT_AES256
                          + DBMS_CRYPTO.CHAIN_CBC
                          + DBMS_CRYPTO.PAD_PKCS5;
                          
function encrypt(
    p_hex varchar2)
    return varchar2 is
l_encrypted RAW(2048);
l_crypto_key varchar(64);
l_curtimewin number;
begin
    select (to_number(extract(day from(sys_extract_utc(systimestamp) - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400000 + to_number(to_char(sys_extract_utc(systimestamp), 'SSSSSFF3')))/(utl_wallet.crypto_tframe*1000)) into l_curtimewin  from  dual;
   l_crypto_key:=utl_wallet.crypto_key(l_curtimewin);
    l_encrypted:= DBMS_CRYPTO.ENCRYPT(
        src => HEXTORAW(p_hex),
        typ => g_encryption_type,
        key => l_crypto_key
     );
    return RAWTOHEX(l_encrypted);
exception
    when others then
        dbms_output.put_line(SQLERRM);
end encrypt;

function decrypt(
    p_hex varchar2)
    return varchar2 is
l_decrypted RAW (2048);
l_crypto_key varchar(64);
l_curtimewin number;
begin
    select (to_number(extract(day from(sys_extract_utc(systimestamp) - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400000 + to_number(to_char(sys_extract_utc(systimestamp), 'SSSSSFF3')))/(utl_wallet.crypto_tframe*1000)) into l_curtimewin  from  dual;
    l_crypto_key:=utl_wallet.crypto_key(l_curtimewin);
    l_decrypted := DBMS_CRYPTO.DECRYPT(
         src => HEXTORAW(p_hex),
         typ => g_encryption_type,
         key => l_crypto_key
      );
    return RAWTOHEX(l_decrypted);
exception
    when others then
        dbms_output.put_line(SQLERRM);
end decrypt;

end UTL_ALGO;
/