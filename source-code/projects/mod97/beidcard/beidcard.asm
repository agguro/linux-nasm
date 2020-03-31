; Name:         beidcard.asm
;
; Build:        nasm "-felf64" beidcard.asm -l beidcard.lst -o beidcard.o
;               ld -s -melf_x86_64 -o beidcard beidcard.o ../libmodulo97/libmodulo97.a
;
; Description:  Modulo 97 check on Belgian ID card Numbers

%define COMMAND          "beid"
%define PURPOSE          "Belgian ID card number check in pure NASM <http://www.nasm.us>."
%define APPLICATIONTITLE "Belgian ID card"
%define NUMBERLENGTH     12
%define NUMBERSTRING     "12"

%macro MODULO97CHECK 0
    mov     rdi, rax
    call    Modulo97.Check
%endm

[list -]
    %include "../template/mod97.template"
[list +]
