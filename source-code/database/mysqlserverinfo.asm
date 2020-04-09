;name:         mysqlserverinfo.asm
;
;build:        nasm "-felf64" mysqlserverinfo.asm -l mysqlserverinfo.lst -o mysqlserverinfo.o 
;               ld -s -melf_x86_64 -o mysqlserverinfo mysqlserverinfo.o -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lmysqlclient
;
;description:  This was my first attempt to use external libaries, the original was a demo with a config file.
;              The file is removed because of an sudden change somewhere that causes a loss of my own created heap but
;              in a next example I will add one again.
; 
;to build: you need libmysqlclient libary. (sudo apt-get install libmysqlclient)

bits 64

[list -]
    extern    mysql_close
    extern    mysql_get_server_info
    extern    mysql_error
    extern    mysql_init
    extern    mysql_real_connect
    extern    mysql_server_end
    extern    mysql_server_init
    extern    exit
    extern    printf
    %include  "unistd.inc"
[list +]

section .bss

    conn:       resq  1
    result:     resq  1
    row:        resq  1

section .rodata:

    host:       db  "agguro.net",0
    port:       dq  3306
    user:       dq  "test",0
    password:   dq  "test",0

section .data

    strserverinfo:  db  "MySQL server info: %s",10,0
    
section .text

global _start
_start:
    ;connect to mysql server
    ;not an embedded MySQL so all arguments must be zero
    xor     rdi, rdi
    xor     rsi, rsi
    xor     rdx, rdx
    call    mysql_server_init
    and     rax, rax
    jnz     done                                ;on error just exit
    ;init mysql
    xor     rdi, rdi
    call    mysql_init
    and     rax, rax
    jz      done                                ;on error exit
    ;no errors, connect and login
    ;when an error occurs we must call mysql_server_end 
    mov     qword[conn], rax                    ;save *mysql
    mov     rdi, rax                            ;value of mysql = pointer to mysql instance of connection
    push    0                                   ;the value of clientflags or NULL if none
    push    0                                   ;the value of socket or NULL if none
    mov     r9d, dword[port]                    ;the value of the port to connect to               
    xor     r8,r8                               ;pointer to zero terminated database string or 0
    mov     rcx, password                       ;pointer to zero terminated password string
    mov     rdx, user                           ;pointer to zero terminated user string
    mov     rsi, host                           ;pointer to zero terminated host string
    call    mysql_real_connect                  ;connect
    pop     rdx                                 ;restore stackpointer
    pop     rdx
    xor     rax, qword[conn]                    ;if conn == pointer to mysql instance then succes
    jnz     endserver                           ;on error end server and exit
    ;get the mysql server info
    mov     rdi,[conn]
    call    mysql_get_server_info
    
    mov     rsi,rax
    mov     rdi,strserverinfo
    xor     rax,rax
    call    printf
    ;close the connection
    mov     rdi, qword[conn]
    call    mysql_close
endserver:        
    call    mysql_server_end
done:
    xor     rdi,rdi
    call    exit
