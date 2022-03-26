;name        : spair.asm
;
;build       : nasm "-felf64" spair.asm -l spair.lst -o spair.o
;              ld -s -melf_x86_64 -o spair spair.o
;
;description : A demonstration on spair syscall based on an example from Beej's Guide to IPC.
;              No user interaction in this example, parent process writes a letter, the child
;              reads it, convert to uppercase and sends it back to the parent, who writes it
;              to the terminal/console
;
;source      : Beejs guide to IPC - http://beej.us/guide/bgipc/output/html/multipage/fork.html
;
;august 24, 2014 : assembler 64 bits version

bits 64
align 16

[list -]
    %include "unistd.inc"
    %include "sys/socket.inc"
    %include "sys/wait.inc"
[list +]

section .bss

    sv:
    .0:    resd    1    ;sv[0]
    .1:    resd    1    ;sv[1]

section .rodata

    msg:
    .fork:          db     "Fork error", 10
    .fork.len:      equ    $-msg.fork
    .socket:        db     "error: socketpair", 10
    .socket.len:    equ    $-msg.socket
    parent:
    .send:          db     "parent send "
    .send.len:      equ    $-parent.send
    .read:          db     "parent read "
    .read.len:      equ    $-parent.read
    child:
    .send:          db     "child send "
    .send.len:      equ    $-child.send
    .read:          db     "child read "
    .read.len:      equ    $-child.read
    eol:            db     10

section .data
    
    buf:            db     "b"

section .text

global  _start
_start:
 ; create socket
    syscall socketpair, PF_LOCAL, SOCK_STREAM, 0, sv           ;AF_UNIX is the posix name, same as PF_LOCAL
    and     rax, rax
    jns     .@1
    syscall write, stderr, msg.socket, msg.socket.len
    syscall exit, 1
.@1:    
    syscall fork
    and     rax, rax                        ; rax contains the PID
    jns     .@2
    syscall write, stderr, msg.fork, msg.fork.len
    syscall exit, 1
.@2:     
    jnz     .@4                              ; childs pid returned, go to parent

; The child process
.@3:
    syscall read, qword[sv.1], buf, 1
    syscall write, stdout, child.read, child.read.len
    syscall write, stdout, buf, 1
    syscall write, stdout, eol, 1
    ;toupper
    mov     al, byte[buf]
    and     al, 0b11011111
    mov     byte[buf], al
    syscall write, qword[sv.1], buf, 1
    syscall write, stdout, child.send, child.send.len
    syscall write, stdout, buf, 1
    syscall write, stdout, eol, 1
    syscall exit, 0
        
; The parent process
.@4:
    syscall write, qword[sv.0], buf, 1
    syscall write, stdout, parent.send, parent.send.len
    syscall write, stdout, buf, 1
    syscall write, stdout, eol, 1
    syscall read, qword[sv.0], buf, 1
    syscall write, stdout, parent.read, parent.read.len
    syscall write, stdout, buf, 1
    syscall write, stdout, eol, 1
    ; wait for child to terminate
    syscall wait4, 0, 0, 0, 0       ; wait for child to terminate
    syscall exit, 0
