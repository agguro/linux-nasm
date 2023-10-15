bits 64

%include "include/webservices/webservices.inc"

global _start

;BSS section
section .bss
%include "include/ssl/sslsocket.bss.inc"

;DATA section
section .data
%include "definitions/definitions.data.inc"

;RODATA section
section .rodata
%include "include/ssl/sslsocket.rodata.inc"
%include "definitions/definitions.rodata.inc"

