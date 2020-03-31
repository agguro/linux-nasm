; Name:        shmdemo.asm
;
; Build:       nasm "-felf64" shmdemo.asm -l shmdemo.lst -o shmdemo.o
;              ld -s -melf_x86_64 -o shmdemo shmdemo.o 
;
; Description: Demonstration on shared memory segments based on an example from Beej's Guide to IPC.
;
; Remark:      The C code only use shmget to "get and create" a shared emory segment.  In assembly language
;              we must take care of this.  That's why the syscall shmget appears twice.  Once to get and
;              create a shared memory segment, the second time if the shared memory segment already exists
;              and we want to attach to it.
;
; Source:      http://beej.us/guide/bgipc/output/html/multipage/shm.html

bits 64

[list -]
    %include "unistd.inc"
    %include "sys/ipc.inc"
    %include "sys/stat.inc"
[list +]

    %define SHM_SIZE 1024  ; make it a 1K shared memory segment

section .bss
    key:        resq    1
    shmid:      resq    1
    data:       resq    1
    datalength: resq    1
    mode:       resq    1
    argc:       resq    1
    arg:        resq    1

section .rodata

    msgUsage:       db  "Usage: shmdemo [data_to_write]",10
    .length:        equ $-msgUsage
    errFtok:        db  "Cannot get IPC key from ftok function.",10
    .length:        equ $-errFtok
    errShmGet:      db  "Cannot create shared memory segment.",10
    .length:        equ $-errShmGet
    errShmAt:       db  "Cannot attach to shared memory segment.",10
    .length:        equ $-errShmAt
    errShmDet:      db  "Cannot detach from shared memory segment.",10
    .length:        equ $-errShmDet
    errRemShm:      db  "Shared Memory Segment cannot be removed.",10
    .length:        equ $-errRemShm
    msgShmRem:      db  "Shared Memory Segment is removed, check with ipcs -m",10
                    db  "eventually kill it with ipcrm -m [id]",10
    .length:        equ $-msgShmRem
    msgWriteTo:     db  "writing to segment : "
    .length:        equ $-msgWriteTo    
    msgReadFrom:    db  "segment contains   : "
    .length:        equ $-msgReadFrom
    eol:            db  10
    filename:       db  "shmdemo",0

section .data

    STAT        stat     

section .text
    global _start:
_start:
    
    pop     rax                                             ;get argc
    cmp     rax,2
    jg      error.usage                                     ;if to much arguments
	pop		rdi												;get programname
	
    ; if two or less arguments, save the argument count for later use
    mov     qword[argc], rax    

    ; make the key, we pop the pointer to this binary from stack to create a key
    mov		rdi,filename                                             ;path to file
    mov     rsi, 'R'                                        ;proj_id
    call    ftok                                            
    mov     qword[key], rax                                 ;save the retrieved key
    and     rax,rax
    js      error.ftok                                      ;on error just exit
    
    ; create and connect to the shared memory segment
    ;permissions are in octal notation
    syscall shmget, qword[key], SHM_SIZE, 0o644 | IPC_CREAT
    ; if no errors then the segment created, then we attach to it
    and     rax, rax
    jns     attach
    ; if an error occured, check if the segment already exist and attach
    syscall shmget, qword[key], SHM_SIZE
    ; if still an error then we cannot connect -> other problem
    and     rax, rax                                    ;there is an error
    js      error.shmget
    ; attach to the shared memory segment
attach:
    ; first save our id
    mov     qword[shmid], rax
    ; attach to the segment to get a pointer to it
    syscall shmat, qword[shmid], 0, 0
    and     rax, rax    
    js      error.shmat                                 ;there is an error
    ; save pointer to shared memory segment
    mov     qword[data], rax
  
    ; read or modify the segment, based on the commandline
    mov     rax, qword[argc]
    cmp     rax, 2
    jne     printSegment                                ;no second argument
    ; this code is additional to kill a shared memory segment
    pop     rdi
    mov     eax,dword[rdi]
    xor     eax,"kill"                                  ;in fact remove but kill is 4 bytes
    jz      killShm
    push    rdi
    
    ; if two argments where on the commandline and it isn't 'kill', the second is the data we want to write
    ; to our segment
    ; first write what we're gonna do
    syscall     write, stdout, msgWriteTo, msgWriteTo.length
    
    pop     rdi                                         ;get pointer to the data
    mov     qword[arg], rdi                             ;save for later use    
    call    dataLength                                  ;calculate length of data
    cmp     rax,1024                                    ;check length
    jle     storeLength                                 ;length is less then segment size
    mov     rax,1024                                    ;if more than 1024 bytes, just take first 1024 bytes
storeLength:    
    mov     qword[datalength],rax                       ;store length of data
    ; write to stdout
    dec     rax                                         ;ignore trailing zero
    syscall write, stdout,qword[arg],qword[datalength]
    syscall write, stdout,eol,1
    
    ; copy data into shared memory segment
    mov     rsi,qword[arg]                              ;pointer to new data
    mov     rcx,qword[datalength]                       ;length of new data
    mov     rdi,qword[data]                             ;pointer to shared memory segment
repeat:    
    lodsb                                                   ;load byte from new data
    stosb                                                   ;and store in shared memory segment
    loopnz  repeat                                      ;and so on for entire new data size
    
    ; we print the content of the shared memory segment
    ; it's here we continue the program when only one argument is given
printSegment:
    ; print what we will show on screen
    syscall write, stdout, msgReadFrom, msgReadFrom.length
    ; check if rdi doesn't point to NULL, should not happen but in less controlled software
    ; it can happen.  Just to be sure...
    mov     rdi,qword[data]
    and     rdi, rdi
    jz      error.usage                                 ;if data doesn't points to a zero address
    call    dataLength                                  ;calculate length of it, that's why we keep
                                                            ;the trailing zero
    ; print the data in our shared memory segment on screen, remember rax has the length of it
    dec     rax                                         ;ignore trailing zero
    syscall write, stdout, qword[data], rax
    syscall write, stdout, eol,1                        ;and terminate the line

detach:
    ; detach from segment
    syscall shmdt,qword[data]
    js      error.detach
exit:
    syscall exit,0
    
    ; this is optional code to demonstrate how to remove a shared memory segment
killShm:
    syscall shmctl,qword[shmid],IPC_RMID,0
    and     rax,rax
    js      error.remove
    syscall write,stdout,msgShmRem,msgShmRem.length
    syscall exit,0

; messages to print when something isn't what it's supposed to be    
error:
.remove:
    syscall write, stderr, errRemShm, errRemShm.length
    syscall exit,1
.usage:
    syscall write, stderr, msgUsage, msgUsage.length
    syscall exit,1
.ftok:
    syscall write, stderr, errFtok, errFtok.length
    syscall exit,1     
.shmget:
    syscall write, stderr, errShmGet, errShmGet.length
    syscall exit,1
.shmat:     
    syscall write, stderr, errShmAt, errShmAt.length
    syscall exit,1
.detach:
    syscall write, stderr, errShmDet, errShmDet.length
    syscall exit,1

dataLength:
    ; in : rdi is pointer to zero terminated list of bytes
    push    rcx                         ;save rcx
    xor     rcx,rcx                     ;make the biggest number possible
    dec     rcx
    xor     al,al                       ;the zero we will scan for
    repne   scasb                       ;scan byte sequence until zero found
    not     rcx                         ;invert all and pass length
    mov     rax,rcx                     ;via rax to caller
    pop     rcx                         ;restore rcx
    ret
    
ftok:
    ; key = ((st.st_ino & 0xffff) | ((st.st_dev & 0xff) << 16) | ((proj_id & 0xff) << 24));
    ; save the project id in r8 (will remain after syscalls)

    mov     r8,rsi
    ; open the file
    syscall open,rdi, O_RDONLY
    and     rax,rax
    js      .done
    syscall fstat,rax, stat
    and     rax,rax
    js      .done
    mov     rax,qword [stat.st_ino]     ;get the file size
    and     rax,0xFFFF
    mov     rbx,qword [stat.st_dev]
    and     rbx,0xFF
    shl     rbx,16
    or      rax,rbx
    and     r8,0xFF                                ; R8 = proj_id
    shl     r8,24
    or      rax,r8
    ; rax now contains a key which uniquely identifies the file.
.done:     
    ret
