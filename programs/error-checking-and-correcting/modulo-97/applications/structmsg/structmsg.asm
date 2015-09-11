; Name:  structmsg.asm
; Description:
;    Modulo 97 check on Strutured messages

%define COMMAND          "structmsg"
%define PURPOSE          "Strutured message check in pure NASM <http://www.nasm.us>."
%define APPLICATIONTITLE "Strutured message"
%define NUMBERLENGTH     12
%define NUMBERSTRING     "12"

%macro MODULO97CHECK 0
     mov       rdi, rax
     call      Modulo97.Check
%endm

[list -]
        %include "../../archive/mod97.template"
[list +]