; Name:         echoc.asm
;
; Build:        nasm "-felf64" echoc.asm -l echoc.lst -o echoc.o
;               ld -s -melf_x86_64 -o echoc echoc.o 
;
; Description:  Demonstration on linux sockets based on an example from Beej's Guide to IPC.
;               This is the echo client program, first run echos, the echo server
;               program.  This program sends the input to an echoserver which in turn returns
;               the message.
;
; Source:       http://beej.us/guide/bgipc/output/html/multipage/unixsock.html

bits 64

[list -]
    %include "unistd.inc"
    %include "signals.inc"
    %include "sys/socket.inc"
[list +]

section .bss

    s:         resq  1
    t:         resq  1
    len:       resq  1
    n:         resq  1
    buffer:    resb  100
    .len:      equ   $-buffer

section .rodata

    ;sun socket:
    remote:
    .sun_family:        dw    0
    .sun_path:          db    "echo_socket",0
    .len:               equ   $-remote
    msg:
    .socket:            db  "error: socket",10
    .socket.len:        equ $-msg.socket
    .connect:           db  "error: connect",10
    .connect.len:       equ $-msg.connect
    .send:              db  "error: send",10
    .send.len:          equ $-msg.send
    .receive:           db  "error: receive",10
    .receive.len:       equ $-msg.receive
    .closed:            db  "server closed connection",10
    .closed.len:        equ $-msg.closed
    .close:             db  "error: close",10
    .close.len:         equ $-msg.close
    .echo:              db  "echo"
    .prompt:            db  "> "
    .prompt.len:        equ $-msg.prompt
    .echo.len:          equ $-msg.echo    
    .tryconnect:        db  "trying to connect ...",10
    .tryconnect.len:    equ $-msg.tryconnect
    .connected:         db  "connected.",10
    .connected.len:     equ $-msg.connected
    .disconnected:      db  10,"connection closed",10
    .disconnected.len:  equ $-msg.disconnected
    
section .data

    SIGACTION   sigaction

section .text

global _start:
_start:
       
    ; create socket
    syscall socket,PF_LOCAL,SOCK_STREAM,0               ;AF_UNIX is the posix name, same as PF_LOCAL
    mov     qword[s],rax                                ;save socket
    and     rax,rax
    jns     .@1                                         ;if rax<0 then msg
    syscall write,stderr,msg.socket,msg.socket.len
    syscall exit,1
.@1:  
    ;print try to connect
    syscall write,stdout,msg.tryconnect,msg.tryconnect.len  
    ;copy AF_UNIX to remote.sun_family
    mov     ax,PF_LOCAL
    mov     word[remote.sun_family],ax
    ;connect to the socket
    syscall connect,qword[s],remote,remote.len
    and     rax,rax
    jns     .@2
    syscall write,stderr,msg.connect,msg.connect.len
    syscall exit,1
.@2:
    ;write connected
    syscall write,stdout,msg.connected,msg.connected.len
    ;write prompt
    syscall write,stdout,msg.prompt,msg.prompt.len
    ;read from stdin
    syscall read,stdin,buffer,buffer.len
    ;check and save the bytes read from stdin, if more than 100
    ;just send the first 100
    cmp     rax,100
    jle     .@3
    mov     rax,100
.@3:
    mov     qword[n],rax
    syscall sendto,qword[s],buffer,qword[n],0,0,0
    and     rax,rax
    jns     .@4
    syscall write,stderr,msg.send,msg.send.len
    syscall exit,1
.@4:    
    ;now receive echo from server
    syscall recvfrom,qword[s],buffer,buffer.len,0,0,0
    mov     qword[t],rax
    cmp     rax,0
    jle     .@5
    syscall write,stdout,msg.echo,msg.echo.len
    syscall write,stdout,buffer,qword[t]
    jmp     .@2
.@5:    
    jz      .@6
    syscall write,stderr,msg.receive,msg.receive.len
    syscall exit,1
.@6:
    syscall write,stdout,msg.closed,msg.closed.len
    syscall exit,1
