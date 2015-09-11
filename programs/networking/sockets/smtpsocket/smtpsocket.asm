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

%define HOST        0x10887D4A ;                      ; host 74.125.136.16  smtp.googlemail.com
%define PORT        0x4B02                                        ; port 587
%define BUFFERSIZE  2048

section .bss
 
        sockfd:           resq 1
        sock_addr:        resq 1
        ;buffer:           resb BUFFERSIZE

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
        hello:                  db "EHLO",10
        .length:                equ $-hello
        starttls:               db "STARTTLS",10
        .length:                equ $-starttls
        authenticate:           db "AUTH LOGIN",10,10
        .length:                equ $-authenticate
        login:                  db "YWd1YXNndWVycmVpcm9yb2JlcnRvQGdtYWlsLmNvbQ==", 10
        .length:                equ $-login
        password:               db "ZXNwYXJ0YW5vNjYxMDI2NDQ5MzM=", 10
        .length:                equ $-password
        
        buffer:                 times BUFFERSIZE db 0
        
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
        mov     r8, HOST                     ; FTP host 100007F (IP address : 127.0.0.1)
        push    r8                              ; push r8 to the stack
        push    WORD PORT                    ; push our port number to the stack
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

; smtp here HELO

        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, hello
        mov     rdx, hello.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
        syscall
       
        
        mov     rax, SYS_RECVFROM
        mov     rdi, QWORD[sockfd]
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

; smtp here STARTTLS

        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, starttls
        mov     rdx, starttls.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
        syscall
       
        
        mov     rax, SYS_RECVFROM
        mov     rdi, QWORD[sockfd]
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

; smtp here authenticate

        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, authenticate
        mov     rdx, authenticate.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
        syscall
       
        
        mov     rax, SYS_RECVFROM
        mov     rdi, QWORD[sockfd]
        mov     rsi, buffer
        mov     rdx, BUFFERSIZE                 ; buffer size
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to source address structure
        mov     r9, 0                           ; length of source address structure
        syscall
       int 3
        mov     rdx, rax                        ; bytes read in rdx
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, buffer
        syscall
        
        ; smtp here authenticate

        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, login
        mov     rdx, login.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
        syscall
       
        
        mov     rax, SYS_RECVFROM
        mov     rdi, QWORD[sockfd]
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
        
        ; smtp here authenticate

        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, password
        mov     rdx, password.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
        syscall
       
        
        mov     rax, SYS_RECVFROM
        mov     rdi, QWORD[sockfd]
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
        
Disconnect:        
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