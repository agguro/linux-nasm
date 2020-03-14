%ifndef _SECTION_RODATA_INC_
%define _SECTION_RODATA_INC_

section .data
     httpheader:       db  "Content-type: text/html",10,10
     .length:          equ $-httpheader
     error500:         db  "Error 500: Internal Server Error", 10        ; this message will be returned to the web client
     .length:          equ $-error500
     errorNoMemory:    db  "[cgiroot error] out of memory error", 10     ; this message will be written to the Apache error log
     .length:          equ $-errorNoMemory

%endif ; _SECTION_RODATA_INC_
