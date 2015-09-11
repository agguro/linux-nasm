; Name:        getclientinfo
; Build:       see makefile
; Run:         ./getclientinfo
;
; Here I make life a bit easier and use printf and exit from stdlib (/lib64/ld-linux-x86-64.so.2 in the make file)

bits 64

[list -]
    ; to reduce the binary size do not include the entire mysqlclient.inc file or stdio.inc
    extern      mysql_get_client_info
    extern      printf
    extern      exit
[list +]

section .data

      text:
%ifdef CGI
      db  "Content-type: text/html", 10, 10
%endif      
      db  "MySQL Client Version: %s"
%ifndef CGI
      db  10
%endif
      db  0
section .text
    global _start

_start:

     call      mysql_get_client_info
 
     mov       rsi, rax        ; pointer to version info in rsi
     mov       rdi, text       ; pointer to text in rdi
     xor       rax, rax        ; no integers to print
     call      printf
     
     xor       rdi, rdi        ; no error
     call      exit