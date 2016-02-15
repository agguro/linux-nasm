; remarks:
; if you do not get a unique key after a while testing the program, you should run
; ipcs   to see all msqid
; if none is seen in the list try to run sudo ipcs

bits 64

%include "./common.inc"

section .data

     msg:                db   "Enter lines of text (max. 200 characters), ^D to quit:", 10
     .length:            equ  $-msg
     errmsgctl:          db   "msgctl error", 10
     .length:            equ  $-errmsgctl
     errmsgsnd:          db   "error msgsnd", 10
     .length:            equ  $-errmsgsnd
     nbytesread:         dq   0
     
section .text
     global _start

_start:

     mov       rdi, path_to_file
     mov       rsi, qword[proj_id]
     call      ftok
     and       rax, rax                           ; if negative we have an error
     js        .error_ftok                        ; we have an error
     mov       qword[key], rax                    ; save the key
     
     syscall   msgget, rax, 0644 | IPC_CREAT
     and       rax, rax
     js        .error_msgget
     mov       qword[msqid], rax
      
     syscall   write, stdout, msg, msg.length
     
     mov       qword[msgbuf + MSG_BUF.mtype], 1              ; we don't really care in this case
     
.repeat:
     syscall   read, stdin, msgbuf+MSG_BUF.mtext, BUFFER_LENGTH
     and       rax, rax                           ; no bytes read
     jz        .endrepeat                         ; then exit
     mov       qword[nbytesread], rax
     cmp       rax, BUFFER_LENGTH
     jl        .lessorequal
     mov       rax, BUFFER_LENGTH                 ; truncate bytes read to max size of buffer-1
.lessorequal: 
     mov       rsi, msgbuf + MSG_BUF.mtext        ; pointer to buf.mtext
     add       rsi, rax                           ; add bytes read to address of .mtext
     dec       rsi                                ; adjust address (we start counting at zero)
     lodsb                                        ; read last byte
     cmp       al, 0x0A                           ; is this LF?
     jne       .skip
     dec       rsi                                ; point again to last byte in .mtext (= 0x0A)
     mov       byte[rsi], 0                       ; replace with EOL
.skip:
     mov       rax, qword[nbytesread]
     add       rax, 8
     syscall   msgsnd, qword[msqid], msgbuf, rax, 0, 0            ; MSG_BUF
     and       rax, rax
     js        .error_msgsnd
     jmp       .repeat

.endrepeat:     
     syscall   msgctl, qword[msqid], IPC_RMID, 0
     and       rax, rax
     js        .error_msgctl

.exit:     
     syscall   exit, 0
     
.error_msgctl:
     syscall   write, stdout, errmsgctl, errmsgctl.length
     jmp       .exit_error
.error_msgget:
     syscall   write, stdout, errmsgget, errmsgget.length
     jmp       .exit_error
.error_msgsnd:
     syscall   write, stdout, errmsgsnd, errmsgsnd.length
     jmp       .exit_error
.error_ftok:
     syscall   write, stdout, errftok, errftok.length
.exit_error:
     syscall   exit, 1
