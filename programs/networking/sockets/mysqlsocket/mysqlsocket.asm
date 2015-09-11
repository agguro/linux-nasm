; socket.asm
;
; example of a basic connection to a host:port
; basic error handling is used but can be (and must be) improved
; sudo ngrep -x -q -d lo '' 'port 3306'


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

%define DBHOST        0x100007F         ; host 127.0.0.1
%define DBPORT        0xEA0C            ; port 3306

section .bss
 
sockfd:                 resq 1
sock_addr:              resq 1
buffer:                 resb 1024

section .data

socketerror:            db "socket error", 10
.length:                equ $-socketerror
connecterror:           db "connection error", 10
.length:                equ $-connecterror
connected:              db "Connected", 10
.length:                equ $-connected
disconnected:           db "Connection closed", 10
.length:                equ $-disconnected

crlf:                   db 10

response:               db 54h, 00h, 00h, 01h, 05h, 0a6h, 0fh, 00h, 00h, 00h, 00h, 01h, 21h, 00h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h,  00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
                        db 00h, 00h, 00h, 00h, 74h, 65h, 73h, 74h,    75h, 73h, 65h, 72h, 00h, 14h, 0ffh, 90h
                        db 27h, 6bh, 14h, 46h, 0c6h, 88h, 0f0h, b5h, 0fbh, 0b1h, 0b8h, 32h, 24h, 0c3h, 0c3h, 92h
                        db 59h, 0a3h, 6dh, 79h, 73h, 71h, 6ch, 5fh,    6eh, 61h, 74h, 69h, 76h, 65h, 5fh, 70h
                        db 61h, 73h, 73h, 77h, 6fh, 72h, 64h, 00h
.length:                equ $-response


section .text
 
global _start
 
_start:
 
; create a socket
        mov     rax, SYS_SOCKET          ; call socket(SOCK_STREAM, AF_NET, 0);
        mov     rdi, PF_INET             ; PF_INET = 2
        mov     rsi, SOCK_STREAM         ; SOCK_STREAM = 1
        mov     rdx, IPPROTO_TCP         ; IPPROTO_TCP for mysql server
        syscall
        and     rax, rax
        jl      .socketerror
        mov     QWORD[sockfd], rax       ; save descriptor
 
; fill in sock_addr structure (on stack)
        xor     r8, r8                   ; clear the value of r8
        mov     r8, DBHOST               ; Database host 100007F (IP address : 127.0.0.1)
        push    r8                       ; push r8 to the stack
        push    WORD DBPORT              ; push our port number to the stack
        push    WORD AF_INET             ; push protocol argument to the stack (AF_INET = 2)
        mov     QWORD[sock_addr], rsp    ; Save the sock_addr_in

; connect to the remote host
        mov     rax, SYS_CONNECT         ; 
        mov     rdi, QWORD[sockfd]       ; socket descriptor
        mov     rsi, QWORD[sock_addr]    ; sock_addr structure
        mov     rdx, 16                  ; length of sock_addr structure
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
        mov     rdx, 1024                       ; buffer length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to source address structure
        mov     r9, 0                           ; length of source address structure
        syscall
        and     rax, rax

; write contents of the buffer to stdout, rax has the bytes read
        mov     rdx, rax                        ; bytes read in rdx
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, buffer
        syscall
        
; send the message to the server
        mov     rax, SYS_SENDTO
        mov     rdi, QWORD[sockfd]
        mov     rsi, response
        mov     rdx, response.length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to destination address structure
        mov     r9, 0                           ; length of destination address structure
        syscall
        
; receive a message from the server
        mov     rax, SYS_RECVFROM
        mov     rdi, QWORD[sockfd]
        mov     rsi, buffer
        mov     rdx, 1024                       ; buffer length
        mov     rcx, 0                          ; flags
        mov     r8, 0                           ; pointer to source address structure
        mov     r9, 0                           ; length of source address structure
        syscall
        and     rax, rax
; write contents of the buffer to stdout, rax has the bytes read
        mov     rdx, rax                        ; bytes read in rdx
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, buffer
        syscall
        
; additional CRLF
        mov     rax, SYS_WRITE
        mov     rdi, STDOUT
        mov     rsi, crlf
        mov     rdx, 1
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