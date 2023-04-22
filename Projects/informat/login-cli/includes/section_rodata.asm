;project:        Informat
;
;name:           section_rodata.asm
;
;description:    initialized read-only data section for informat.asm
;
;note:           this file may not be assembled, only included in login-cli.asm
;                problems can arise when the IP address of the domain change.

bits 64

section .rodata

    errormsg:       db    "error", EOL
    .len:           equ   $-errormsg

    login_msg:      db    "UserName:"
    .len:           equ   $-login_msg
    password_msg:   db    "Password:"
    .len:           equ   $-password_msg

%ifdef DEBUG
    connected:      db    "Connected", EOL
    .len:           equ   $-connected
    disconnected:   db    10, "Connection closed", EOL
    .len:           equ   $-disconnected
    eol:            db    EOL
    eol.len:        equ   $-eol    
%endif
    ipaddress:      db    52,166,251,248
    port:           db    0,80

request:
    .part1:         db    'GET /wsInfSoft/wsInformat.asmx/AuthenticateUser?sUserName='
    .part1.len:     equ   $-request.part1
    .part2:         db    '&sPassword='
    .part2.len:     equ   $-request.part2                
    .part3:         db    ' HTTP/1.1',EOL,'Host: webservice.informatsoftware.be',EOL,EOL
    .part3.len:     equ   $-request.part3                
    .len:           equ   $-request
    
login_reply:        db    '</boolean>'
.len:               equ   $-login_reply

login_succesfull:   db    'you are logged in',EOL
.len:               equ   $-login_succesfull

access_denied:      db    'access denied',EOL
.len:               equ   $-access_denied
