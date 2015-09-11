; ftpsocket.asm
;
; example of a basic ftp connection to a host:port
; basic error handling is used but can be (and must be) improved
; connect to an ftp server, try to login, login, send messages and quit the session.
; using the STAT and FEAT command will turn out is a disconnection. See more at
; http://superuser.com/questions/302999/ftp-access-stuck-on-feat-command-most-of-the-time
;
; to-do: - implementation for receiving and sending files and directory listing on server
;        - dns support
;        - remove repetitive code
;        - read user and password from file
;
; Running the application like this will result in connection error unless you have a ftp server
; running on 127.0.0.1:21

BITS 64

[list -]
        %include "unistd.inc"
        %include "sys/socket.inc"
[list +]

%define FTPHOST        0x0100007F                        ; host 127.0.0.1
%define FTPPORT        0x1500                            ; port 21
%define USER           "username"                        ; ftp username here
%define PASSWORD       "password"                        ; ftp password here
%define DIRECTORY      ""                                ; directory branches here
%define BUFFERSIZE     256

section .bss
 
        sockfd:           resq 1
        sock_addr:        resq 1
        buffer:           resb BUFFERSIZE

section .data

        socketerror:            db "socket error", 10
        .length:                equ $-socketerror
        connecterror:           db "connection error", 10
        .length:                equ $-connecterror
        connected:              db "Connected", 10
        .length:                equ $-connected
        disconnected:           db "Connection closed", 10
        .length:                equ $-disconnected
        user:                   db "USER ",USER,10
        .length:                equ $-user
        password:               db "PASS ",PASSWORD,10
        .length:                equ $-password
        cwd:                    db "CWD /",DIRECTORY,10
        .length:                equ $-cwd
        syst:                   db "SYST",10
        .length:                equ $-syst
        pasv:                   db "PASV",10
        .length:                equ $-pasv
        pwd:                    db "PWD",10
        .length:                equ $-pwd
        list:                   db "LIST *",10
        .length:                equ $-list
        quit:                   db "QUIT", 10
        .length:                equ $-quit

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
        jl      .socketerror
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
        jl      .connecterror     
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
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, cwd
        mov     rdx, cwd.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
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
; send USER to the server
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, user
        mov     rdx, user.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
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
; send PASS (password) to the server
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, password
        mov     rdx, password.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
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
; send SYST (system) command to the server
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, syst
        mov     rdx, syst.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
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
; send PASV (passive mode) command to the server
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, pasv
        mov     rdx, pasv.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
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
; send PWD command to the server
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, pwd
        mov     rdx, pwd.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
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
; send CWD to the server
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, cwd
        mov     rdx, cwd.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
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
; send PWD command to the server
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, pwd
        mov     rdx, pwd.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
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
; send PWD command to the server
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, quit
        mov     rdx, quit.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
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
.connecterror:
        mov     rsi, connecterror
        mov     rdx, connecterror.length
        jmp     .print
 
.socketerror:
        mov     rsi, socketerror
        mov     rdx, socketerror.length
        jmp     .print
.print:
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
.exit:  
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall