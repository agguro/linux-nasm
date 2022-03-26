;name          : semrm.asm
;
;build         : nasm "-felf64" semrm.asm -l semrm.lst -o semrm.o
;                ld -s -melf_x86_64 -o semrm semrm.o 
;
;description   : removes a semaphore
;
;remark        : Before running this program you must start semdemo.
;                semrm removes the semaphore created by semdemo.
;                remember: ipcs to check the semaphores
;                          ipcrm removes semaphores
;                open a second terminal and type watch -n 1 ipcs to see
;                how the program creates and removes semaphore.
;
;source        : http://beej.us/guide/bgipc/output/html/multipage/semaphores.html#semsamp

bits 64

[list -]
    %include "unistd.inc"
    %include "sys/stat.inc"
    %include "sys/ipc.inc"
    %include "sys/sem.inc"
[list +]

    %define PROJ_ID     'J'

section .rodata
     file:          db   "./semdemo", 0
     semgeterror:   db   "cannot get semaphore.", 10
     .length:       equ  $-semgeterror
     semctlerror:   db   "ERROR SEMCTL", 10
     .length:       equ  $-semctlerror
     ftokerror:     db   "cannot get IPC key from ftok function", 10
     .length:       equ  $-ftokerror

section .rodata

     STAT           stat
     key:           dq   0
     semid:         dq   0

section .text

global _start
_start:

     mov       rdi, file                                    ; path to file
     mov       rsi, PROJ_ID                                 ; proj_id
     call      ftok
     mov       qword[key], rax                              ; save the retrieved key
     test      rax, rax
     js        error.ftok                                   ; on error just exit, just because we are lazy in this example
     
     ; grab the semaphore set created by seminit.c
     syscall   semget, qword[key], 1, 0                     ; just get the semid, don't create one
     mov       qword[semid], rax                            ; save the semid
     test      rax, rax
     js        error.semget                                 ; on error just exit, just because we are lazy in this example
     
     ; remove it
     syscall   semctl, qword[semid], 0, IPC_RMID            ; no union semun because op IPC_RMID (see man page)
     ; don't test rax, we just leave the program error or not
     test      rax, rax
     js        error.semctl
     
exit:
     syscall   exit, 0

error:
.semget:
     syscall   write, stderr, semgeterror, semgeterror.length
     syscall   exit, 1
.ftok:
     syscall   write, stderr, ftokerror, ftokerror.length
     syscall   exit, 1
.semctl:
     syscall   write, stderr, semctlerror, semctlerror.length
     syscall   exit, 1

; key = ((st.st_ino & 0xffff) | ((st.st_dev & 0xff) << 16) | ((proj_id & 0xff) << 24));
; source: http://beej.us/guide/bgipc/output/html/multipage/mq.html

ftok:
     ; rdi has the path/file string to the file
     ; rsi has an 'project id' arbitrary choosen.
     ; on return: RAX has a unique key
     ; on failure: RAX = a negative number containing the error

     ; save the project id in R8 (will remain after syscalls)
     mov       r8, rsi
     ; open the file
     syscall   open, rdi, O_RDONLY
     and       rax, rax
     js        .done
     syscall   fstat, rax, stat
     and       rax, rax
     js        .done
     mov       rax, QWORD [stat.st_ino]                ; get the file size
     and       rax, 0xFFFF
     mov       rbx, QWORD [stat.st_dev]
     and       rbx, 0xFF
     shl       rbx, 16
     or        rax, rbx
     and       r8, 0xFF                                ; R8 = proj_id
     shl       r8, 24
     or        rax, r8
     ; rax now contains a key which uniquely identifies the file.
.done:     
     ret
