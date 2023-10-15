;name        : lockdemo.asm
;
;build       : nasm -f elf64 -o lockdemo.o -l lockdemo.lst lockdemo.asm
;            : ld -s -m elf_x86_64 lockdemo.o -o lockdemo
;
;description : Demonstration of file locking mechanism.
;
;source      : Beej's guide to IPC
;              http://beej.us/guide/bgipc/output/html/multipage/flocking.html

[list -]
    %include "unistd.inc"
    %include "sys/fcntl.inc"
[list +]

bits 64

section .bss

    fd:        resq     1
    buffer:    resb     1
    .length:   equ      $-buffer
    
section .rodata

    filename:          db   "lockdemo.asm", 0
    msgGetLock:        db   "Press <RETURN> to try to get lock: "
        .length:       equ  $-msgGetLock
    msgTryLock:        db   "Trying to get lock..."
        .length:       equ  $-msgTryLock
    msgGotLock:        db   "got lock", 10
        .length:       equ  $-msgGotLock
    msgReleaseLock:    db   "Press <RETURN> to release lock: "
        .length:       equ  $-msgReleaseLock
    msgUnlocked:       db   "unlocked", 10
        .length:       equ  $-msgUnlocked
    msgOpenError:      db   "::open error", 10
        .length:       equ  $-msgOpenError
    msgFcntlError:     db   "::fcntl error", 10
        .length:       equ  $-msgFcntlError

section .data
    
    FLOCK   fl
    
section .text

global _start
_start:
    syscall getpid
    ; set PID
    mov     dword[fl.l_pid], eax
    mov     ax, F_WRLCK
    mov     word[fl.l_type], ax
    mov     ax, SEEK_SET
    mov     word[fl.l_whence], SEEK_SET
    pop     rax                                  ; get arguments
    dec     rax                                  ; minus 1 for programname
    and     rax, rax
    jz      no_arguments
    mov     ax, F_RDLCK
    mov     word[fl.l_type], ax   
no_arguments:
    syscall open, filename, O_RDWR
    js      openerror
    mov     qword[fd], rax
    syscall write, stdout, msgGetLock, msgGetLock.length    
    syscall read, stdin, buffer, buffer.length
    syscall write, stdout, msgTryLock, msgTryLock.length
    syscall fcntl, qword[fd], F_SETLKW, fl
    js      fcntlerror
    syscall write, stdout, msgGotLock, msgGotLock.length
    syscall write, stdout, msgReleaseLock, msgReleaseLock.length
    syscall read, stdin, buffer, buffer.length
    mov     ax, F_UNLCK
    mov     word[fl.l_type], ax
    syscall fcntl, qword[fd], F_SETLK, fl
    js      fcntlerror
    syscall write, stdout, msgUnlocked, msgUnlocked.length
    syscall close, qword[fd]
    jmp     exit
    
fcntlerror:
    mov     rsi, msgFcntlError
    mov     rdx, msgFcntlError.length
    jmp     write
    
openerror:
    mov     rsi, msgOpenError
    mov     rdx, msgOpenError.length
    
write:    
    syscall write, stdout
    
exit:
    syscall exit, 0
