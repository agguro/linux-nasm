;name        : spock.asm
;
;build       : nasm -felf64 -o spock.o -l spock.lst spock.asm
;              ld -s -m elf_x86_64 spock.o -o spock
;
;description : demonstration of message queuing.
;
;remark      : run kirk first
;
;source      : Beej's guide to Interprocess communication
;              http://beej.us/guide/bgipc/output/html/multipage/mq.html#mqsamp

bits 64

[list -]
    %include "unistd.inc"
    %include "sys/stat.inc"
    %include "sys/ipc.inc"
[list +]

	%define BUFFER_LENGTH    200
    %define DOUBLE_QUOTES    34

struc MSG_BUF
     .mtype:   resq 1
     .mtext:   resb BUFFER_LENGTH+1
endstruc

section .rodata
     path_to_file:       db   "../demofile", 0
     proj_id:            db   "B"
     msg:                db   "Spock: Ready to receive messages, captain.", 10
     .length:            equ  $-msg
     errmsgrcv:          db   "Identifier removed", 10
     .length:            equ  $-errmsgrcv
     spock:
     .begin:             db   "Spock: ", DOUBLE_QUOTES
     .begin.length:      equ  $-spock.begin
     .end:               db   DOUBLE_QUOTES, 10
     .end.length:        equ  $-spock.end
     errftok:            db   "something went wrong in function ftok()", 10
     .length:            equ  $-errftok
     errmsgget:          db   "could not acquire a unique key", 10
     .length:            equ  $-errmsgget

section .data

    STAT    stat           ; file status structure
 
    msgbuf istruc MSG_BUF
        at MSG_BUF.mtype,   dq   0
        at MSG_BUF.mtext,   times BUFFER_LENGTH+1 db 0
    iend  

    bytesreceived:    dq   0
    msqid:            dq   0
    key:              dq   0

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
     
ftok:
; key = ((st.st_ino & 0xffff) | ((st.st_dev & 0xff) << 16) | ((proj_id & 0xff) << 24));
; source: http://beej.us/guide/bgipc/output/html/multipage/mq.html
; rdi: path/file string to the file
; rsi has an 'project id' arbitrary choosen.
; on return:
; rax a unique key or a negative number containing the error when ftok fails

    ; save the project id in R8 (will remain after syscalls)
    mov     r8, rsi
    ; open the file
    syscall open, rdi, O_RDONLY
    and     rax, rax
    js      .done
    syscall fstat, rax, stat
    and     rax, rax
    js      .done
    mov     rax, qword [stat.st_ino]     ; get the file size
    and     rax, 0xFFFF
    mov     rbx, qword [stat.st_dev]
    and     rbx, 0xFF
    shl     rbx, 16
    or      rax, rbx
    and     r8, 0xFF                     ; R8 = proj_id
    shl     r8, 24
    or      rax, r8
    ; rax now contains a key which uniquely identifies the file.
.done:     
    ret
