Implementation of Time-Based OTP Authentication algorithm (TOTP, RFC 6238) which is a multi-factor authentication using pure PL/SQL in Oracle Database 11g Enterprise Edition Release 11.2.0.4.0.

The TOTP based authentication is very cost effective as compared to SMS based authentication. PL/SQL implementation can be done on any SQL database where Java version can't be implemented.

Why TOTP?
Becasue SMS-based Authentication has a huge initial cost associated with it for implementation as well as for ongoing support and maintenance, whereas there is only one-time implementation cost with TOTP and Google/Microsoft authenticator app are free of cost available on Play Store.

Please note that if in case DBMS_CRYPTO standard package is not available then alternatively FND_CRYPTO can be used or complex SQL query can be written for HMAC with SHA1/SHA256/SHA512 hash algorithm.

Complexity: You would see there is a bit effort and complexity in UTL_Math package development where I have to write algorithm for hex/raw to binary string or vice-versa. Conversion is done using pure SQL queries with no use of any procedure/function to increase performance.