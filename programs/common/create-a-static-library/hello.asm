; Name:         hello.asm
; Build:        see makefile
; Run:          ./hello
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
