; Name:  besiscard.asm
; Description:
;    Modulo 97 check on Belgian SIS card Numbers

%define COMMAND          "besiscard"
%define PURPOSE          "Belgian SIS card Number check in pure NASM <http://www.nasm.us>."
%define APPLICATIONTITLE "Belgian SIS card Number"
%define NUMBERLENGTH     10
%define NUMBERSTRING     "10"

%macro MODULO97CHECK 0
     mov       rdi, rax
     call      Modulo97.Check
%endm

[list -]
        %include "../../archive/mod97.template"
[list +]