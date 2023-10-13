;project:       Informat.asm
;
;name:          section_data.asm
;
;date:          17 aug 2020
;
;description:   initialized global variables and static local variables section for informat.asm

bits 64

section .data

SOCKETADDR_IN   sockaddr_in
TIMEVAL         time_out,5          ;5 second time out

;strange things happens when moved to .bss section, need to check it
login_buf:          times   256 db 0
.len:               equ     $-login_buf
password_buf:       times   256 db 0
.len:               equ     $-password_buf
login_length:       dq      0
password_length:    dq      0
server:             dq      0                       ;pointer to server structure
