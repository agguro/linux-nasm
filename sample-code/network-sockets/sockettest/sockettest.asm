;Name:          sockettest.asm
;Build:         nasm "-felf64" sockettest.asm -l sockettest.lst -o sockettest.o
;               ld -s -melf_x86_64 -o sockettest sockettest.o 
;Description:   This program is a test program to connect and
;               interact with several server examples.
;               (Like HTTP,FTP,... own build servers.)
;               It is hardcoded for localhost:4444.

bits 64
[list -]
    %include "unistd.inc"
    %include "sys/socket.inc"
[list +]

section .bss
 
    sockfd:     resq 1
    sock_addr:  resq 1
    buffer:     resb 1              ;one byte buffer because we get the bytes one at the time
    .length:    equ  $-buffer

section .data
    
    data:           db "Hello internet",10
    ;don't forget the trailing zero to indicate end of message
                    db  0
    .length:        equ $-data
    socketerror:    db  "socket error", 10
    .length:        equ $-socketerror
    connecterror:   db  "connection error", 10
    .length:        equ $-connecterror
    connected:      db  "Connected", 10
    .length:        equ $-connected
    disconnected:   db  "Connection closed", 10
    .length:        equ $-disconnected
    receiveerror:   db  "Receive error",10
    .length:        equ $-receiveerror

    port:           db 17,92            ; port 4444 (256 * 17 + 92)

section .text
    global _start
_start:
 
;create a socket
    syscall socket,PF_INET,SOCK_STREAM,IPPROTO_IP
    and     rax,rax
    jns     .connect
    syscall write,stderr,socketerror,socketerror.length
    syscall exit,1
.connect:    
    mov     qword[sockfd],rax           ;save socket descriptor
;fill in sock_addr structure on stack
;todo: get host or IP and port from commandline
    xor     r8,r8                       ;clear the value of r8
    mov     r8,0x0100007F;              ;100007F (IP address : 127.0.0.1)
    push    r8                          ;push r8 to the stack
    push    word [port]                 ;(Port = 4444) don't use PUSH WORD 4444 (endianess!)
    push    word AF_INET                ;push protocol argument to the stack
    mov     qword [sock_addr],rsp       ;Save the sock_addr_in
;connect to the remote host
;socket_addr structure is 16 bytes long
    syscall connect,qword[sockfd],qword[sock_addr],16
    and     rax,rax
    jns     .connected
    syscall write,stderr,socketerror,socketerror.length
    syscall exit,1
.connected:
    syscall write,stdout,connected,connected.length
;send data to the server
    syscall sendto,qword[sockfd],data,data.length,0,0,0
;receive data from the server, one byte at the time
.receive:
    syscall recvfrom,qword[sockfd],buffer,1,0,0,0
    and     rax, rax
    jns     .checkdata
    syscall write,stderr,receiveerror,receiveerror.length
    ;close the connection
    syscall close,qword[sockfd]
    syscall exit,1
.checkdata:    
;check byte in buffer
;if 0x00 then stop receiving
    cmp     byte[buffer],0
    je      .endreceive
;else we print the byte out
    syscall write,stdout,buffer,rdx
;go to receive next byte    
    jmp     .receive
.endreceive:        
    syscall close,qword[sockfd]       
; disconnected message
    syscall write,stdout,disconnected,disconnected.length    
; exit program        
    syscall exit,0