bits 64

%include "include/webservices/webservices.inc"

global _start

;BSS section
section .bss
%include "include/ssl/sslsocket.bss.inc"

;DATA section
section .data
%include "getallaccountsextended/getallaccountsextended.data.inc"

;RODATA section
section .rodata
%include "include/ssl/sslsocket.rodata.inc"
%include "getallaccountsextended/getallaccountsextended.rodata.inc"

