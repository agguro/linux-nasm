; Name:         setcookie.asm
; Build:        see makefile
; Description:  set 4 cookies
;               Send cookies to web client demo
;               The executable of this file need to be uploaded to your webservers cgi directory
;               from there you can access the application from a webbrowser.

bits 64

[list -]
     %include "unistd.inc"
[list +]

section .data

cookies:
    db "Set-Cookie:UserID=XYZ", 10
    db "Set-Cookie:Password=XYZ123", 10
    db "Set-Cookie:Domain=www.agguro.be", 10
    db "Set-Cookie:Path=/", 10
    db "Content-type: text/html", 10, 10
    db "<pre>Check your browser's cookies for UserID, Password, Domain and Path cookie</pre>"
cookies.length: equ $-cookies

section .text
        global _start
_start:

     mov        rdi, STDOUT
     mov        rsi, cookies
     mov        rdx, cookies.length
     mov        rax, SYS_WRITE
     syscall
     xor        rdi, rdi
     mov        rax, SYS_EXIT
     syscall