;project:       Informat.asm
;
;name:          section_data.asm
;
;description:   initialized global variables and static local variables section for informat.asm
;
;note:          this file may not be assembled, only included in informat.asm

bits 64

section .data

SOCKETADDR_IN   sockaddr_in
TIMEVAL         time_out,5          ;5 second time out


;strange things happens when moved to .bss section
login_buf:          times   256 db 0
.len:               equ     $-login_buf
password_buf:       times   256 db 0
.len:               equ     $-password_buf
login_length:       dq      0
password_length:    dq      0
