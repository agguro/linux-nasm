; Name          : mysqlclientinfo.asm
;
; Build         : nasm "-felf64" mysqlclientinfo.asm -l mysqlclientinfo.lst -o mysqlclientinfo.o
;                 ld -s -melf_x86_64 -o mysqlclientinfo mysqlclientinfo.o -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lmysqlclient
;
; Description   : Gets the mysql client version
;
; Remark:
; Because I need the mysqlclient library and that library the ld-linux-melf_x86_64 (stdlib) I also make
; use of the stdlib functions instead of re-inventing the weel.
; To install libmysqlclient : sudo apt-get install libmysqlclient-dev

bits 64

[list -]
    ; just define the functions we use, to reduce the binary size
    extern      mysql_get_client_info
    extern      printf
    extern      exit
[list +]

section .data

    text:   db  "MySQL Client Version: %s", 10, 0
      
section .text
        global _start

_start:
    ; rax = mysql_get_client_info()
    ;
    call      mysql_get_client_info
    mov       rsi, rax        ; pointer to version info in rsi
    mov       rdi, text       ; pointer to text in rdi
    xor       rax, rax        ; no integers to print
    call      printf
    xor       rdi, rdi        ; no error
    call      exit
