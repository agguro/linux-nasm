; Name:     downloaddata.asm
; Build:    see makefile
; Description:
; Demonstration of a simple downloadable file, the contents of the file are in the program.
; (It could be the binary of this program too.)
; If you should see errors instead of a download window check if fastcgi is enabled on your apache server.
; appearantle mod-cgi alone isn't enough to serve this program
; sudo apt-get install libapache2-mod-fastcgi
; sudo a2enmod fastcgi
; sudo service apache2 restart

bits 64

[list -]
     %include 'unistd.inc'
[list +]

section .bss

section .data

httpheader:
     db   'Content-type: application/octet-stream', 10
     db   'Content-Disposition: attachment; filename="data.bin"', 10, 10
.length: equ $-httpheader

section .text
    global _start
    
_start:

     ; we send the reply in two pieces, to download the binary of this program
     ; This doesn't send the entire program, only the assembled code of the .text section.
data:

     mov       rax, SYS_WRITE
     mov       rsi, httpheader
     mov       rdx, httpheader.length
     mov       rdi, STDOUT
     syscall
     
     mov       rax, SYS_WRITE
     mov       rsi, data
     mov       rdx, data.length
     mov       rdi, STDOUT
     syscall
     
     xor       rdi, rdi
     mov       rax, SYS_EXIT
     syscall
     
.length: equ $-data     