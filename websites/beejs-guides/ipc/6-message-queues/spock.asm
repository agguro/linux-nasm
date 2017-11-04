; Name        : spock.asm
;
; Build       : nasm -felf64 -o spock.o -l spock.lst spock.asm
;               ld -s -m elf_x86_64 spock.o -o spock
;
; Description : demonstration of message queuing.
;
; Remark      : run kirk first
;
; Source      : Beej's guide to Interprocess communication
;               http://beej.us/guide/bgipc/output/html/multipage/mq.html#mqsamp

bits 64

     %include "./common.inc"
     %define DOUBLE_QUOTES    34

section .data

     msg:                db   "Spock: Ready to receive messages, captain.", 10
     .length:            equ  $-msg
     errmsgrcv:          db   "Identifier removed", 10
     .length:            equ  $-errmsgrcv
     spock:
     .begin:             db   "Spock: ", DOUBLE_QUOTES
     .begin.length:      equ  $-spock.begin
     .end:               db   DOUBLE_QUOTES, 10
     .end.length:        equ  $-spock.end
     bytesreceived:      dq   0
     
section .text
     global _start

_start:
     
     mov       rdi, path_to_file
     mov       rsi, qword[proj_id]
     call      ftok
     and       rax, rax                           ; if negative we have an error
     js        .error_ftok                        ; we have an error
     mov       qword[key], rax                    ; save the key
     
     syscall   msgget, rax, 666o                            
     and       rax, rax
     js        .error_msgget
     mov       qword[msqid], rax
      
     syscall   write, stdout, msg, msg.length
         
.repeat:
     syscall   msgrcv, qword[msqid], msgbuf, BUFFER_LENGTH, 0, 0
     and       rax, rax
     js        .error_msgrcv
     ; subtract size of .mtype to get the actual length of the message
     sub       rax, 8
     mov       qword[bytesreceived], rax
     syscall   write, stdout, spock.begin, spock.begin.length
     syscall   write, stdout, msgbuf+MSG_BUF.mtext, qword[bytesreceived]
     syscall   write, stdout, spock.end, spock.end.length
     jmp       .repeat
     
     ; this program never exits on his own

.error_msgget:
     syscall   write, stdout, errmsgget, errmsgget.length
     jmp       .exit_error     
.error_msgrcv:
     syscall   write, stderr, errmsgrcv, errmsgrcv.length     
     jmp       .exit_error
.error_ftok:
     syscall   write, stdout, errftok, errftok.length
.exit_error:
     syscall   exit, 1
     
