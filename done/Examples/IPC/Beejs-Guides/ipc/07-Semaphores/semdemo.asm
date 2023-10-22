;name         :  semdemo.asm
;
;build        : nasm "-felf64" semdemo.asm -l semdemo.lst -o semdemo.o
;               ld -s -melf_x86_64 -o semdemo semdemo.o 
;
;description  : A demonstration on semphores based on an example from
;               Beej's Guide to IPC.
;
;remark       : remember! ipcs to check the semaphores, ipcrm removes semaphores
;               Open a second terminal and type watch -n 1 ipcs to see how the 
;               program creates and removes semaphores.
;               The goal is to open several terminals and run ./semdemo in it.
;
;source       : http://beej.us/guide/bgipc/output/html/multipage/semaphores.html#semsamp

bits 64

[list -]

    %include    "unistd.inc"
    %include    "sys/ipc.inc"
    %include    "sys/sem.inc"
    %include    "sys/termios.inc"
    %include    "sys/stat.inc"
    %include    "sys/time.inc"
    %include    "asm-generic/errno.inc"

[list +]

    %define MAX_RETRIES 10
    %define PROJ_ID     'J'

section .bss

    i:             resq     1
    ready:         resq     1
    semidi:        resq     1
    e:             resq     1
    keyi:          resq     1
    nsemsi:        resq     1
    buffer:        resb     5            ; one byte isn't enough on my system ...
    .length:       equ      $-buffer     ; (reason are often the hotkey sequences)
    key:           resq     1
    semid:         resq     1

section .rodata

    msgWefirst:    db    "We got the semaphore first...",10
    .len:          equ   $-msgWefirst
    msgOther:      db    "Waiting for other process to initialize semaphore...",10
    .len:          equ   $-msgOther
    file:          db    "semdemo", 0
    semgeterror:   db    "cannot get semaphore.", 10
    .length:       equ   $-semgeterror
    semctlerror:   db    "ERROR SEMCTL", 10
    .length:       equ   $-semctlerror
    ftokerror:     db    "cannot get IPC key from ftok function", 10
    .length:       equ   $-ftokerror
    initsemerror:  db    "semaphore could not be initialized", 10
    .length:       equ   $-initsemerror
    semoperror:    db    "sem operation error", 10
    .length:       equ   $-semoperror
    msglock:       db    "Press return to lock: ", 10
    .length:       equ   $-msglock
    msgtrylock:    db    "Trying to lock...", 10
    .length:       equ   $-msgtrylock
    msglocked:     db    "Locked.", 10
    .length:       equ   $-msglocked
    msgunlock:     db    "Press return to unlock: ", 10
    .length:       equ   $-msgunlock
    msgunlocked:   db    "Unlocked.", 10
    .length:       equ   $-msgunlocked

section .data

    STAT        stat
    TERMIOS     termios
    SEM_BUF     sb
    SEMID_DS    buf
    SEM_UNION   semun
    SEM_BUF     sbi
    SEM_UNION   arg
    TIMESPEC    timer
      
section .text

global _start:
_start:

    ;get key from ftok
    mov     rdi, file                       ;path to file
    mov     rsi, PROJ_ID                    ;proj_id
    call    ftok
    mov     qword [key], rax                ;save the retrieved key
    test    rax, rax
    js      error.ftok                      ;on error, exit
    ;get a semaphore id from initsem
    mov     rdi, qword [key]                ;key
    mov     rsi, 1                          ;nsems
    call    initsem                         ;semid = initsem(key, 1)
    ;if semid < 0 an error occured
    mov     qword [semid], rax
    test    rax, rax
    js      error.initsem
    ;printf("Press return to lock: ")
    syscall write, stdout, msglock, msglock.length
    ;getchar()
    call    waitforreturnkey
    ;printf("Trying to lock...\n");
    syscall write, stdout, msgtrylock, msgtrylock.length

    ;set semaphore operation structure
    mov     qword [sb.sem_num], 0           ;sb.sem_num = 0;
    mov     qword [sb.sem_op], -1           ;sb.sem_op = -1; set to allocate resource
    mov     qword [sb.sem_flg], SEM_UNDO    ;sb.sem_flg = SEM_UNDO;
    syscall semop, qword [semid], sb, 1
    ;if semop < 0 then error
    test    rax, rax
    js      error.semop
    ;printf("Locked.\n");
    syscall write, stdout, msglocked, msglocked.length   
    ;printf("Press return to unlock: ");
    syscall write, stdout, msgunlock, msgunlock.length    
    ;getchar();
    call    waitforreturnkey
    ;free the semaphore
    mov     qword [sb.sem_op], 1                ; free resource
    syscall semop, qword [semid], sb, 1
    ;if semop < o then error
    test    rax, rax
    js      error.semop
    ;printf("Unlocked\n");
    syscall write, stdout, msgunlocked, msgunlocked.length
    syscall exit, 0
;error handling
error:
.semget:
    mov     rdi,semgeterror
    mov     rsi,semgeterror.length
    jmp     .tostderr
.ftok:
    mov     rdi, ftokerror
    mov     rsi, ftokerror.length
    jmp     .tostderr
.semctl:
    mov     rdi,semctlerror
    mov     rsi,semctlerror.length
    jmp     .tostderr
.initsem:
    mov     rdi,initsemerror
    mov     rsi,initsemerror.length
    jmp     .tostderr
.semop:     
    mov     rdi,semoperror
    mov     rsi,semoperror.length
.tostderr:
    syscall write,stderr
    syscall exit
    
sleep:
    ;halts the system for n seconds
    ;the seconds must be in rdi
    push    rbp
    mov     rbp,rsp
    mov     qword [timer.tv_sec],rdi
    mov     qword [timer.tv_nsec],0    
    syscall nanosleep,timer,0
    mov     rsp,rbp 
    pop     rbp 
    ret

waitforreturnkey:
    ;wait until the return key is pressed
    call    termios.canonical.off      ; switch canonical mode off
    call    termios.echo.off           ; no echo
    ; read from stdin (usually the keyboard)
.repeat:    
    syscall read, stdin, buffer, buffer.length
    mov     al,byte[rsi]
    cmp     al,0x0A
    jne     .repeat
    ; clear the buffer
    ;syscall write, stdout, buffer, buffer.length
    ; Don't forget to switch canonical mode on
    call    termios.canonical.on       ; switch canonical mode back on
    call    termios.echo.on            ; restore echo
    ret
    
; Auxiliary functions to switch echo and canonical mode on and off.
termios.canonical:
.on:
    mov     rax,ICANON
    jmp     termios.localmodeflag.set
.off:
    mov     rax,ICANON
    jmp     termios.localmodeflag.clear
termios.echo:
.on:
    mov     rax,ECHO
    jmp     termios.localmodeflag.set
.off:
    mov     rax,ECHO
    jmp     termios.localmodeflag.clear
termios.localmodeflag:
.set:
    call    termios.stdin.read
    or      dword [termios.c_lflag], eax
    call    termios.stdin.write
    ret
.clear:
    call    termios.stdin.read
    not     eax
    and     [termios.c_lflag], eax
    call    termios.stdin.write
    ret
; subroutine for all TCGETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
termios.stdin:
.read:
    mov     rsi, TCGETS
    jmp     termios.ioctl
; subroutine for all TCSETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
.write:
    mov     rsi, TCSETS
; subroutine for operations on the syscall IOCTL for STDIN
; all registers are restored to their original values on exit of the subroutine
termios.ioctl:
    push    rax             ; we need to store RAX or TermIOS.LocalFlag functions fail
    mov     rdx, termios
    syscall ioctl, stdin
    pop     rax
    ret

; Convert a pathname and a project identifier to a System V IPC key
; the ftok function is defined in c/c++ as follows:
; key = ((st.st_ino & 0xffff) | ((st.st_dev & 0xff) << 16) | ((proj_id & 0xff) << 24));
ftok:
    ; rdi has the path/file string to the file
    ; rsi has an 'project id' arbitrary choosen.
    ; rax has a unique key or, on failure, a negative number containing the error
    ; save used registers
    push    rbx
    push    rdi
    push    rsi
    push    r8
    ; save the project id in R8 (will remain after syscalls)
    mov     r8, rsi
    ; open the file
    syscall open, rdi, O_RDONLY
    and     rax, rax
    js      .done                                ; something wrong, errno in rax and return
    syscall fstat, rax, stat                     ; get filestatus
    and     rax, rax
    js      .done                                ; something wrong, errno in rax and return
    mov     rax, qword [stat.st_ino]             ; get the file size
    and     rax, 0xFFFF
    mov     rbx, qword [stat.st_dev]             ; ID of device containing file
    and     rbx, 0xFF
    shl     rbx, 16
    or      rax, rbx
    and     r8, 0xFF                             ; R8 = proj_id
    shl     r8, 24
    or      rax, r8
.done:     
    ; rax now contains a key which uniquely identifies the file.
    ; restore used registers
    pop     r8
    pop     rsi
    pop     rdi
    pop     rbx  
    ret

; initsem()
; -- more-than-inspired by W. Richard Stevens' UNIX Network
; Programming 2nd edition, volume 2, lockvsem.c, page 295.
; and thanks to Beejs Guide to IPC
; it's quite a dificult implementation from my part, need to
; recheck it in the future.
initsem:
    mov     qword[nsemsi],rsi
    mov     qword[keyi],rdi
    syscall semget,qword[keyi],qword[nsemsi],IPC_CREAT | IPC_EXCL | 0o666
    mov     qword[semidi],rax
    cmp     rax,0
    jge     wefirst
    cmp     rax,EEXIST
    je      someoneelse
    mov     rax,qword[semidi]            ;return error
    ret                
wefirst:
    syscall write,stdout,msgWefirst,msgWefirst.len
    mov     word[sbi.sem_num],0
    mov     word[sbi.sem_op],1
    mov     word[sbi.sem_flg],0
    jmp     .@1
.@2:
    ;do a semop to free the semaphores
    ;this sets the sem_otime as needed below
    syscall semop,qword[semidi],sbi,1
    cmp     rax,0
    jns     .@3
    mov     qword[e],rax
    syscall semctl,qword[semidi],0,IPC_RMID        ;clean up
    mov     rax,qword[e]
    ret                        ;return error
.@3:
    inc     word[sbi.sem_num]
.@1:
    movsx   rax,word[sbi.sem_num]
    cmp     rax,qword[nsemsi]
    jl      .@2
    mov     rax,qword[semidi]
    ret     ;return semid
someoneelse:    
    ;someone else got it first
    syscall write,stdout,msgOther,msgOther.len
    syscall semget,qword[keyi],qword[nsemsi],0    ;get semid
    mov     qword[semidi],rax
    cmp     rax,0
    jge     .waitforotherprocess
    mov     rax,qword[semidi]
    ret     ;return error
.waitforotherprocess:
    ;wait for other process to initialize the semaphore
    mov     qword[ready],0
    mov     qword[i],0
    jmp     .@1
.@3:
    syscall semctl,qword[semidi],qword[nsemsi-1],IPC_STAT,arg
    cmp     qword[arg.buf+SEMID_DS_STRUC.sem_otime],0
    je      .sleep
    mov     qword[ready],1
    jmp     .@4
.sleep:
    mov     rdi,1
    call    sleep
.@4:    
    inc     qword[i]
.@1:
    cmp     qword[ready],1
    je      .@2
    cmp     qword[i],MAX_RETRIES
    jl      .@3
    jmp     .@5
.@2:
    mov     rax,ETIME                ;return ETIME error
    ret
.@5:
    mov     rax,qword[semidi]
    ret
