; ftpsocket.asm
;
; example of a basic ftp connection to a host:port
; basic error handling is used but can be (and must be) improved
; connect to an ftp server, try to login, login, send messages and quit the session.
; using the STAT and FEAT command will turn out is a disconnection. See more at
; http://superuser.com/questions/302999/ftp-access-stuck-on-feat-command-most-of-the-time
;
; to-do: implementation for receiving and sending files and directory listing on server
;        dns support
;        remove repetitive code

BITS 64

[list -]
        %include "syscalls.inc"
        %include "termio.inc"
[list +]

%define AF_INET       2
%define AF_LOCAL      1
%define SOCK_STREAM   1
%define PF_INET       2
%define PF_LOCAL      1
%define IPPROTO_IP    0
%define IPPROTO_TCP   6
%define IPPROTO_UDP   17
%define INADDR_ANY    0

%define FTPHOST        0xFD00A8C0 ;                      ; host 192.168.0.253
%define FTPPORT        0xB80B                                        ; port 3000
%define LOGINUSER      "agguro"                        ; ftp username here
%define LOGINPASSWORD       "66102644933"                        ; ftp password here
%define DIRECTORY      ""                                ; directory branches here
%define BUFFERSIZE     256

%macro _process 3                               ; use: send socketfd, command
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[%1]
        mov     rsi, %2
        mov     rdx, %3
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
        syscall
        mov     rax, SYS_RECVFROM
        mov     rdi, QWORD[%1]
        mov     rsi, buffer
        mov     rdx, BUFFERSIZE                 ; buffer size
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to source address structure
        mov     r9, 0                           ; length of source address structure
        syscall
        mov     rdx, rax                        ; bytes read in rdx
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, buffer
        syscall
%endmacro

; macro USER "username"
%macro USER 1
section .data
      %%cmd:       db     "USER ",%1,10
      %%length:     equ    $-%%cmd
section .text
      _process  sockfd, %%cmd, %%length
%endmacro

; macro PASS "password"
%macro PASS 1
section .data
      %%cmd:         db     "PASS ",%1,10
      %%length:       equ    $-%%cmd
section .text
      _process  sockfd, %%cmd, %%length
%endmacro

; macro CDW "directory" 
%macro CWD 1
section .data
      %%cmd:        db     "CWD ",%1,10
      %%length:     equ    $-%%cmd
section .text
      _process  sockfd, %%cmd, %%length
%endmacro

; macro PWD
%macro PWD 0
section .data
      %%cmd:        db     "PWD",10
      %%length:     equ    $-%%cmd
section .text
      _process  sockfd, %%cmd, %%length
%endmacro

; macro SYST
%macro SYST 0
section .data
      %%cmd:        db     "SYST",10
      %%length:     equ    $-%%cmd
section .text
      _process  sockfd, %%cmd, %%length
%endmacro

; macro PASV
%macro PASV 0
section .data
      %%cmd:        db     "PASV",10
      %%length:     equ    $-%%cmd
section .text
      _process  sockfd, %%cmd, %%length
%endmacro

; macro TYPE
%macro TYPE 1
section .data
      %%cmd:        db     "TYPE ",%1,10
      %%length:     equ    $-%%cmd
section .text
      _process  sockfd, %%cmd, %%length
%endmacro

; macro PORT "x,x,x,x,p,p" 
%macro PORT 1
section .data
      %%cmd:        db     "PORT ",%1,10
      %%length:     equ    $-%%cmd
section .text
      _process  sockfd, %%cmd, %%length
%endmacro

; macro QUIT
%macro QUIT 0
section .data
      %%cmd:        db     "QUIT",10
      %%length:     equ    $-%%cmd
section .text
      _process  sockfd, %%cmd, %%length
%endmacro

; macro LIST "*"
%macro LIST 1
section .data
      %%cmd:        db     "LIST ",%1,10
      %%length:     equ    $-%%cmd
section .text
      _process  sockfd, %%cmd, %%length
%endmacro



section .bss
 
        sockfd:           resq 1
        sock_addr:        resq 1
        buffer:           resb BUFFERSIZE

section .data

        errorsocket:            db "socket error", 10
        .length:                equ $-errorsocket
        errorconnect:           db "connection error", 10
        .length:                equ $-errorconnect
        connected:              db "Connected", 10
        .length:                equ $-connected
        disconnected:           db "Connection closed", 10
        .length:                equ $-disconnected
        
        

        crlf:                   db 10

section .text
 
        global _start
 
_start:
 
; create a socket
        mov     rax, SYS_SOCKET                 ; call socket(SOCK_STREAM, AF_NET, 0);
        mov     rdi, PF_INET                    ; PF_INET = 2
        mov     rsi, SOCK_STREAM                ; SOCK_STREAM = 1
        mov     rdx, IPPROTO_IP                 ; IPPROTO_TCP for mysql server
        syscall
        and     rax, rax
        jl      socketerror
        mov     QWORD[sockfd], rax              ; save descriptor      
; fill in sock_addr structure (on stack)
        xor     r8, r8                          ; clear the value of r8
        mov     r8, FTPHOST                     ; FTP host 100007F (IP address : 127.0.0.1)
        push    r8                              ; push r8 to the stack
        push    WORD FTPPORT                    ; push our port number to the stack
        push    WORD AF_INET                    ; push protocol argument to the stack (AF_INET = 2)
        mov     QWORD[sock_addr], rsp           ; Save the sock_addr_in
; connect to the remote host
        mov     rax, SYS_CONNECT
        mov     rdi, QWORD[sockfd]              ; socket descriptor
        mov     rsi, QWORD[sock_addr]           ; sock_addr structure
        mov     rdx, 16                         ; length of sock_addr structure
        syscall
        and     rax, rax
        jl      connecterror     
        mov     rsi, connected
        mov     rdx, connected.length
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
; receive a message from the server
        mov     rax, SYS_RECVFROM
        mov     rdi, QWORD[sockfd]
        mov     rsi, buffer
        mov     rdx, BUFFERSIZE                 ; buffer size
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to source address structure
        mov     r9, 0                           ; length of source address structure
        syscall
; write contents of the buffer to stdout, rax has the bytes read
        mov     rdx, rax                        ; bytes read in rdx
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, buffer
        syscall
        
        
; make an attempt to access server without login
; send CWD to the server
        CWD "/"
; LOGIN        
; send USER to the server
        USER "agguro"
        PASS "66102644933"
        SYST
        PASV
        TYPE "I"
        PORT "(192,168,0,253,141,7)"
        PWD
        CWD "/www"
        PWD
        QUIT
        
        
; close connection
        mov     rax, SYS_CLOSE
        mov     rdi, QWORD[sockfd]
        syscall
; disconnected message
        mov     rsi, disconnected
        mov     rdx, disconnected.length
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
; exit program        
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall
; the errors
connecterror:
        mov     rsi, errorconnect
        mov     rdx, errorconnect.length
        jmp     print
 
socketerror:
        mov     rsi, errorsocket
        mov     rdx, errorsocket.length
        jmp     print
print:
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
exit:  
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall