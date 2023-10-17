;name        : kirk.asm
;
;build       : nasm -felf64 -o kirk.o -l kirk.lst kirk.asm
;              ld -s -m elf_x86_64 kirk.o -o kirk
;
;description : demonstration of message queuing.
;
;remark      : run this program, open a second terminal and run spock in that terminal.
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

struc MSG_BUF
    .mtype:    resq    1
    .mtext:    resb    BUFFER_LENGTH+1
endstruc

section .rodata
    path_to_file:    db   "../kirk", 0
    proj_id:         db   "B"
    errftok:         db   "something went wrong in function ftok()", 10
    .length:         equ  $-errftok
    errmsgget:       db   "could not acquire a unique key", 10
    .length:         equ  $-errmsgget
    msg:             db   "Enter lines of text (max. 200 characters), ^D to quit:", 10
    .length:         equ  $-msg
    errmsgctl:       db   "msgctl error", 10
    .length:         equ  $-errmsgctl
    errmsgsnd:       db   "error msgsnd", 10
    .length:         equ  $-errmsgsnd

section .data
     
    STAT    stat           ; file status structure, STAT64 can also be used
    msgbuf istruc MSG_BUF
        at MSG_BUF.mtype,   dq   0
        at MSG_BUF.mtext,   times BUFFER_LENGTH+1 db 0
    iend  
    msqid:        dq   0
    key:          dq   0
    nbytesread:   dq   0
     
section .text

global _start
_start:

    mov       rdi, path_to_file
    mov       rsi, qword[proj_id]
    call      ftok
    and       rax, rax                           ; if negative we have an error
    js        .error_ftok                        ; we have an error
    mov       qword[key], rax                    ; save the key
     
    syscall   msgget, rax, 666o | IPC_CREAT
    and       rax, rax
    js        .error_msgget
    mov       qword[msqid], rax
      
    syscall   write, stdout, msg, msg.length
     
    mov       qword[msgbuf + MSG_BUF.mtype], 1                 ; we don't really care in this case
     
.repeat:
    syscall   read, stdin, msgbuf+MSG_BUF.mtext, BUFFER_LENGTH
    and       rax, rax                                         ; no bytes read
    jz        .endrepeat                                       ; then exit
    mov       qword[nbytesread], rax
    cmp       rax, BUFFER_LENGTH
    jl        .lessorequal
    mov       rax, BUFFER_LENGTH                               ; truncate bytes read to max size of buffer-1
.lessorequal: 
    mov       rsi, msgbuf + MSG_BUF.mtext                      ; pointer to buf.mtext
    add       rsi, rax                                         ; add bytes read to address of .mtext
    dec       rsi                                              ; adjust address (we start counting at zero)
    lodsb                                                      ; read last byte
    cmp       al, 0x0A                                         ; is this LF?
    jne       .skip
    dec       rsi                                              ; point again to last byte in .mtext (= 0x0A)
    mov       byte[rsi], 0                                     ; replace with EOL
.skip:
    mov       rax, qword[nbytesread]
    add       rax, 8
    syscall   msgsnd, qword[msqid], msgbuf, rax, 0, 0          ; MSG_BUF
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
