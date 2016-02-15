; lockdemo.asm
;
; source: http://beej.us/guide/bgipc/output/html/multipage/flocking.html
;         converted from C
;
; How to use it:
; Assemble and link the program. Open two terminals and run in one terminal until 'got lock' appears (after first RETURN.
; Run this program in the second terminal and hit RETURN. You will see that you don't have a lock immediately. Press RETURN
; in the first terminal to release the lock. In the second terminal you will see the message 'got lock'.
; For more "fun" try this in more terminals.

[list -]
     %include "unistd.inc"
     %include "fcntl.inc"
[list +]

bits 64

section .bss

     fd:       resq      1
     buffer:   resb      1
     .length:  equ       $-buffer
     
section .data

     filename:      db   "lockdemo.c", 0
     
     msgGetLock:    db   "Press <RETURN> to try to get lock: "
     .length:       equ  $-msgGetLock
     
     msgTryLock:    db   "Trying to get lock..."
     .length:       equ  $-msgTryLock
     
     msgGotLock:    db   "got lock", 10
     .length:       equ  $-msgGotLock
     
     msgReleaseLock:    db   "Press <RETURN> to release lock: "
     .length:       equ  $-msgReleaseLock
     
     msgUnlocked:    db   "unlocked", 10
     .length:       equ  $-msgUnlocked
     
     msgOpenError:  db   "::open error", 10
     .length:       equ  $-msgOpenError
     
     msgFcntlError: db   "::fcntl error", 10
     .length:       equ  $-msgFcntlError

     
     FLOCK     fl
     
section .text
     global _start

_start:
     mov       rax, SYS_getpid
     syscall
     ; set PID
     mov       dword[fl.l_pid], eax
     mov       ax, F_WRLCK
     mov       word[fl.l_type], ax
     mov       ax, SEEK_SET
     mov       word[fl.l_whence], SEEK_SET
     
     pop       rax                                          ; get arguments
     dec       rax                                          ; minus 1 for programname
     and       rax, rax
     jz        no_arguments
     mov       ax, F_RDLCK
     mov       WORD[fl.l_type], ax
     
no_arguments:
     mov       rdi, filename
     mov       rsi, O_RDWR
     mov       rax, SYS_open
     syscall
     js        openerror
     
     mov       QWORD[fd], rax
     
     mov       rsi, msgGetLock
     mov       rdx, msgGetLock.length
     mov       rdi, stdout
     mov       rax, SYS_write
     syscall
     
     mov       rsi, buffer
     mov       rdx, buffer.length
     mov       rdi, stdin
     mov       rax, SYS_read
     syscall
     
     mov       rsi, msgTryLock
     mov       rdx, msgTryLock.length
     mov       rdi, stdout
     mov       rax, SYS_write
     syscall
     
     mov       rdi, QWORD[fd]
     mov       rsi, F_SETLKW
     mov       rdx, fl
     mov       rax, SYS_fcntl
     syscall
     js        fcntlerror
     
     mov       rsi, msgGotLock
     mov       rdx, msgGotLock.length
     mov       rdi, stdout
     mov       rax, SYS_write
     syscall
     
     mov       rsi, msgReleaseLock
     mov       rdx, msgReleaseLock.length
     mov       rdi, stdout
     mov       rax, SYS_write
     syscall
     
     mov       rsi, buffer
     mov       rdx, buffer.length
     mov       rdi, stdin
     mov       rax, SYS_read
     syscall
     
     mov       ax, F_UNLCK
     mov       WORD[fl.l_type], ax
     
     mov       rdi, QWORD[fd]
     mov       rsi, F_SETLK
     mov       rdx, fl
     mov       rax, SYS_fcntl
     syscall
     js        fcntlerror
     
     mov       rsi, msgUnlocked
     mov       rdx, msgUnlocked.length
     mov       rdi, stdout
     mov       rax, SYS_write
     syscall
     
     mov       rdi, QWORD[fd]
     mov       rax, SYS_close
     syscall
     
     jmp       exit
     
fcntlerror:
     mov       rsi, msgFcntlError
     mov       rdx, msgFcntlError.length
     jmp       write
     
openerror:
     mov       rsi, msgOpenError
     mov       rdx, msgOpenError.length
write:     
     mov       rdi, stdout
     mov       rax, SYS_write
     syscall
     
exit:

     xor       rdi, rdi
     mov       rax, SYS_exit
     syscall
     
     
     
     
