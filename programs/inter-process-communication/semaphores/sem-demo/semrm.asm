;
; semrm.c -- removes a semaphore
;
; remember ipcs to check the semaphores, ipcrm to remove semaphores
; open a second terminal and type watch -n 1 ipcs to see how the program creates and removes semaphore.
; run the program semdemo, look the semaphore being created.
; run semrm and watch the semaphore being removed.

%include "unistd.inc"
%include "sys/stat.inc"
%include "sys/ipc.inc"
%include "sys/sem.inc"

section .data
     key:           dq        0
     semid:         dq        0
     file:          db        "./semdemo", 0
     STAT           stat
     semgeterror:   db   "cannot get semaphore.", 10
     .length:       equ  $-semgeterror
     semctlerror:   db   "ERROR SEMCTL", 10
     .length:       equ  $-semctlerror
     ftokerror:     db   "cannot get IPC key from ftok function", 10
     .length:       equ  $-ftokerror
     
section .text
global _start
_start:

     mov       rdi, file                                    ; path to file
     mov       rsi, 'J'                                     ; proj_id
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

ftok:
     ; source: http://beej.us/guide/bgipc/output/html/multipage/mq.html
     ; the type key_t is actually just a long, you can use any number you want. But what if you hard-code the number and some other unrelated
     ; program hardcodes the same number but wants another queue? The solution is to use the ftok() function which generates a key from two arguments:
     ; key_t ftok(const char *path, int id);
     ;
     ; RDI has the path/file string to the file
     ; RSI has an 'project id' arbitrary choosen.
     ; on return: RAX has a unique key
     ; on failure: RAX = a negative number containing the error
     ; key = ((st.st_ino & 0xffff) | ((st.st_dev & 0xff) << 16) | ((proj_id & 0xff) << 24));

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