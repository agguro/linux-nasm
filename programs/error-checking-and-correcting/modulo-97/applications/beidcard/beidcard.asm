; Name:  beidcard.asm
; Description:
;    Modulo 97 check on Belgian ID card Numbers

%define COMMAND          "beid"
%define PURPOSE          "Belgian ID card number check in pure NASM <http://www.nasm.us>."
%define APPLICATIONTITLE "Belgian ID card"
%define NUMBERLENGTH     12
%define NUMBERSTRING     "12"

%macro MODULO97CHECK 0
     mov       rdi, rax
     call      Modulo97.Check
%endm

[list -]
        %include "../../archive/mod97.template"
[list +]