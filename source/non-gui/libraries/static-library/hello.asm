; Name:         hello.asm
;
; Build:        nasm "-felf64" hello.asm -o hello.o -l hello.lst
;               nasm "-felf64" libhello.asm -l libhello.lst -o libhello.o
;               ar rcs libhello.a libhello.o
;               ld -s -melf_x86_64 -o hello hello.o libhello.a
;
; Description:  Shows the hello world program with the use of a static library
;               The purpose of a static library is to collect commonly used procedures
;               and store them in one archive file so we can use the archive file to
;               link other programs who use the same procedures. An archive file is not
;               a shared libary, each program assembled and linked with an archive file
;               will have the procedures in their listing.

bits 64

; define the archive functions
[list -]
    %include "libhello.def"
[list +]  
        
section .data
    message: db  "Hello world!", 10
    .length: equ $-message

section .text
    global _start
    
_start:
    mov     rsi, message
    mov     rdx, message.length
    call    WriteString
    xor     rdi, rdi
    call    Exit
