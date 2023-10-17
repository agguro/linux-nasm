;name:         echos.asm
;
;build:        nasm "-felf64" echos.asm -l echos.lst -o echos.o
;               ld -s -melf_x86_64 -o echos echos.o 
;
;description:  Demonstration on linux sockets based on an example from Beej's Guide to IPC.
;              This is the echo server program which must start before echo client starts(logic)
;              This program receives the input from a echo client and sends it back.
;
;source:       http://beej.us/guide/bgipc/output/html/multipage/unixsock.html

bits 64

[list -]
    %include "unistd.inc"
    %include "signals.inc"
    %include "asm-generic/socket.inc"       
[list +]

section .bss

    s:         resq  1
    t:         resq  1
    len:       resq  1
    s2:        resq  1
    n:         resq  1
    done:      resq  1
    buffer:    resb  100
    .len:      equ   $-buffer

section .rodata

    ;sun socket:
    local:
    .sun_family:    dw    1
    .sun_path:      db    "echo_socket",0
    .len:           equ   $-local
    remote:         
    .sun_family:    dw    1
    .sun_path:      db    "echo_socket",0
    .len:           equ   $-remote
    msg:
    .socket:        db  "error: socket",10
    .socket.len:    equ $-msg.socket
    .bind:          db  "error: bind",10
    .bind.len:      equ $-msg.bind
    .listen:        db  "error: listen",10
    .listen.len:    equ $-msg.listen
    .accept:        db  "error: accept",10
    .accept.len:    equ $-msg.accept
    .send:          db  "error: send",10
    .send.len:      equ $-msg.send
    .receive:       db  "error: receive (client quits)",10
    .receive.len:   equ $-msg.receive
    .waiting:       db  "waiting for connection ...",10
    .waiting.len:   equ $-msg.waiting
    .connected:     db  "connected.",10
    .connected.len: equ $-msg.connected

section .data

    SIGACTION   sigaction

      
section .text
    global _start:
_start:
    ; create socket
    syscall socket,PF_LOCAL,SOCK_STREAM,0           ;AF_UNIX is the posix name, same as PF_LOCAL
    mov     qword[s],rax                            ;save socket
    and     rax,rax
    jns     .@1
    syscall write,stderr,msg.socket,msg.socket.len
    syscall exit,1
.@1:    
    ; if sun_path exists then first delete it
    syscall unlink,local.sun_path,0
    ;copy AF_UNIX to remote.sun_family
    mov     ax,PF_LOCAL
    mov     word[remote.sun_family],ax
    ;bind the sun_path to the socket
    syscall bind,qword[s],local,local.len
    and     rax,rax
    jns     .@2
    syscall write,stderr,msg.bind,msg.bind.len
    syscall exit,1
.@2:    
    ;listen to the socket
    syscall listen,qword[s],5                       ;5 is the nr of connection that can connect
    ; http://veithen.github.io/2014/01/01/how-tcp-backlog-works-in-linux.html
    and     rax,rax
    jns     .@3
    syscall write,stderr,msg.listen,msg.listen.len
    syscall exit,1
.@3:    
    xor     rax,rax
    mov     qword[done],rax

.@4:;while{    
    ;"waiting for connection"
    syscall write,stdout,msg.waiting,msg.waiting.len    
    ;accept incoming connection
    syscall accept,qword[s],remote,t
    mov     qword[s2],rax
    and     rax,rax
    jns     .@5
    syscall write,stderr,msg.accept,msg.accept.len
    syscall exit,1
.@5:    
    ;"connected"
    syscall write,stdout,msg.connected,msg.connected.len
    ;set done flag = 0    
    xor     rax,rax
    mov     qword[done],rax
.@6: ;do{
    ;receive data
    syscall recvfrom,qword[s2],buffer,buffer.len,0,0,0
    mov     qword[n],rax
    mov     eax,dword[buffer]
    cmp     eax,"quit"
    jne     .@7
    ;close socket 2
    syscall close,qword[s2]
.@7:
    mov     rax,qword[n]
    and     rax,rax
    jg      .@8
    jns     .@9
    syscall write,stderr,msg.receive,msg.receive.len
.@9:
    mov     rax,1
    mov     qword[done],rax
.@8:
    mov     rax,qword[done]
    and     rax,rax
    jnz     .@10
    syscall sendto,qword[s2],buffer,qword[n]
    jns     .@10
    syscall write,stderr,msg.send,msg.send.len
    mov     rax,1
    mov     qword[done],rax
.@10:    
    mov     rax,qword[done]
    and     rax,rax
    jz      .@6
    syscall close,qword[s2]
    jmp     .@4
    
    syscall exit,0
