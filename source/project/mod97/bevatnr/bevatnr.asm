; Name:         bevatnr.asm
;
; Build:        nasm "-felf64" bevatnr.asm -l bevatnr.lst -o bevatnr.o
;               ld -s -melf_x86_64 -o bevatnr bevatnr.o ../libmodulo97/libmodulo97.a
;
; Description:  Modulo 97 check on Belgian VAT Numbers

%define COMMAND          "bevatnr"
%define PURPOSE          "Belgian VAT Number check in pure NASM <http://www.nasm.us>."
%define APPLICATIONTITLE "Belgian VAT Number"
%define NUMBERLENGTH     10
%define NUMBERSTRING     "10"

%macro MODULO97CHECK 0
    ; RAX has the converted number, we need to extract the last two decimal digits
    xor     rdx, rdx
    mov     rbx, 100
    div     rbx                      ; RDX = checkdigits, RAX = number
    mov     rcx, 97
    sub     rcx, rdx                 ; RCX = 97 - modulo97(number)
    xor     rdx, rdx
    mul     rbx                      ; RAX = number * 100
    add     rax, rcx                 ; new number to check
    mov     rdi, rax
    call    Modulo97.Check
%endm

[list -]
    %include "../template/mod97.template"
[list +]
