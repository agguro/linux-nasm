; Name:         bebankacc.asm
;
; Build:        nasm "-felf64" bebankacc.asm -l bebankacc.lst -o bebankacc.o
;               ld -s -melf_x86_64 -o bebankacc bebankacc.o ../libmodulo97/libmodulo97.a
;
; Description:  Modulo 97 check on Belgian Bankaccount Numbers

%define COMMAND          "bebankacc"
%define PURPOSE          "Belgian bank account number check in pure NASM <http://www.nasm.us>."
%define APPLICATIONTITLE "Belgian bank account number"
%define NUMBERLENGTH     12
%define NUMBERSTRING     "12"

%macro MODULO97CHECK 0
    mov     rdi, rax
    call    Modulo97.Check
%endm

[list -]
    %include "../template/mod97.template"
[list +]
