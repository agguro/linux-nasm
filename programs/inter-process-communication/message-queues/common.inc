%include "unistd.inc"
%include "sys/stat.inc"
%include "sys/ipc.inc"

%define BUFFER_LENGTH    200

struc MSG_BUF
     .mtype:   resq 1
     .mtext:   resb BUFFER_LENGTH+1
endstruc

section .data
     
     STAT      stat           ; file status structure, STAT64 can also be used
     
     msgbuf istruc MSG_BUF
          at MSG_BUF.mtype,   dq   0
          at MSG_BUF.mtext,   times BUFFER_LENGTH+1 db 0
     iend  
     
     path_to_file:       db   "./kirk", 0
     proj_id:            db   "B"
     msqid:              dq   0
     key:                dq   0
     
     errftok:            db   "something went wrong in function ftok()", 10
     .length:            equ  $-errftok
     errmsgget:          db   "could not acquire a unique key", 10
     .length:            equ  $-errmsgget
     
section .text

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