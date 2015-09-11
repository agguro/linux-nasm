; Name:     hello
; Build:    see makefile
; Run:      ./hello
; Description: Writes 'Hello world!" to STDOUT with the use of a shared library

[list -]
     %include "unistd.inc"
     %include "libhello.def"
[list +]

BITS 64
align 16

section .data

     message:                  db   "hello from mainprogram!",10
     .length:                  equ  $-message
     messageagain:             db   "hello again from mainprogram!",10
     .length:                  equ  $-messageagain
     messageend:               db   "end program", 10
     .length:                  equ  $-messageend
     addressmessageend:        dq   messageend
     .length:                  dq   messageend.length
        
section .text
     global _start
_start:

     ; write the programs message
     mov       rsi, message
     mov       rdx, message.length
     call      WriteExternalString

     ; write the string from library directly
     mov       rsi, hellostring wrt ..sym
     mov       rdx, QWORD[hellostring.length wrt ..sym]
     call      WriteExternalString

     ; get the string and his length and write to stdout
     call      GetString
     mov       rdi, STDOUT
     mov       rax, SYS_WRITE
     syscall
     
     ; write library string
     call      WriteInternalString

     ; overwrite library string pointer and length
     mov       rax, messageagain
     mov       QWORD[hellostring.pointer wrt ..sym], rax
     mov       QWORD[hellostring.length wrt ..sym], messageagain.length
     
     ; and recall libary WriteInternalString
     call      WriteInternalString

     ; overwrite library string again but with library function
     mov       rsi, message
     mov       rdx, message.length
     call      SetString
     
     ; and recall library WriteInternalString again
     call      WriteInternalString

     ; get the string pointer and length in RSI, RDX, same as GetString
     call      GetStringPointer
     mov       rax, rsi            ; load address to stringpointer in RAX
     mov       rsi, [rax]          ; load stringpointer in RSI
     mov       rax, rdx            ; load address to stringlength in RAX
     mov       rdx, [rax]          ; load stringlength in RDX
     
     call      WriteExternalString
     
     mov       rsi, addressmessageend
     mov       rdx, addressmessageend.length
     call      SetStringPointer
     
     call      WriteInternalString
     
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall