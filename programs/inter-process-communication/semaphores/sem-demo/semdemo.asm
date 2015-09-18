bits 64

[list -]
%include "unistd.inc"
%include "sys/ipc.inc"
%include "sys/sem.inc"
%include "sys/termios.inc"
%include "sys/stat.inc"
[list +]

STRUC SEM_UNION_STRUC
    .val:       resq    1
    .buf:       resq    1
    .array:     resq    1
ENDSTRUC

%macro SEM_UNION 1
          %1: 
          ISTRUC SEM_UNION_STRUC
          at    SEM_UNION_STRUC.val,       dq  0
          at    SEM_UNION_STRUC.buf,       dq  0
          at    SEM_UNION_STRUC.array,     dq  0
          IEND
%endmacro


%define MAX_RETRIES 10

section .bss
     keybuffer:     resb     1

section .data

     STAT       stat
     TERMIOS    termios
     SEMBUF     sb
     SEMID      buf
     SEM_UNION  semun
     
     
     key:           dq        0
     semid:         dq        0
     file:          db        "./semdemo", 0
     
     semgeterror:   db   "cannot get semaphore.", 10
     .length:       equ  $-semgeterror
     semctlerror:   db   "ERROR SEMCTL", 10
     .length:       equ  $-semctlerror
     ftokerror:     db   "cannot get IPC key from ftok function", 10
     .length:       equ  $-ftokerror
     initsemerror:  db   "semaphore could not be initialized", 10
     .length:       equ  $-initsemerror
     semoperror:    db   "sem operation error", 10
     .length:       equ  $-semoperror
     msglock:       db   "Press return to lock: ", 10
     .length:       equ  $-msglock
     msgtrylock:    db   "Trying to lock...", 10
     .length:       equ  $-msgtrylock
     msglocked:     db   "Locked.", 10
     .length:       equ  $-msglocked
     msgunlock:     db   "Press return to unlock: ", 10
     .length:       equ  $-msgunlock
     msgunlocked:   db   "Unlocked.", 10
     .length:       equ  $-msgunlocked
     
section .text
global _start:
_start:

     ;sb.sem_num = 0;
     ;sb.sem_op = -1;  /* set to allocate resource */
     ;sb.sem_flg = SEM_UNDO;

     mov       qword[sb.sem_num], 0
     mov       qword[sb.sem_op], -1               ; set to allocate resource
     mov       qword[sb.sem_flg], SEM_UNDO
    
     ;if ((key = ftok("semdemo.c", 'J')) == -1) {
     ;   perror("ftok");
     ;   exit(1);
     ;}

     mov       rdi, file                                    ; path to file
     mov       rsi, 'J'                                     ; proj_id
     call      ftok
     mov       qword[key], rax                              ; save the retrieved key
     test      rax, rax
     js        error.ftok                                   ; on error just exit, just because we are lazy in this example
     
     
    ;/* grab the semaphore set created by seminit.c: */
    ;if ((semid = initsem(key, 1)) == -1) {
    ;    perror("initsem");
    ;    exit(1);
    ;}

    mov        rdi, qword[key]                                             ; key
    mov        rsi, 1                                                      ; nsems
    call       initsem
    ; rax holds the semid or a negative value when an error occured
    mov        qword[semid], rax
    test       rax, rax
    js         error.initsem
    
    ;printf("Press return to lock: ");
    ;getchar();
    ;printf("Trying to lock...\n");

    syscall write, stdout, msglock, msglock.length
    call        waitforkeypress
    syscall     write, stdout, msgtrylock, msgtrylock.length
    
    ;if (semop(semid, &sb, 1) == -1) {
    ;    perror("semop");
    ;    exit(1);
    ;}
    
    syscall   semop, qword[semid], sb, 1
    test      rax, rax
    js        error.semop

    ;printf("Locked.\n");
    ;printf("Press return to unlock: ");
    ;getchar();

    syscall    write, stdout, msglocked, msglocked.length
    syscall    write, stdout, msgunlock, msgunlock.length
    call       waitforkeypress
    
    ;sb.sem_op = 1; /* free resource */
    
    mov   qword[sb.sem_op], 1                ; free resource
    
    ;if (semop(semid, &sb, 1) == -1) {
    ;    perror("semop");
    ;    exit(1);
    ;}

    syscall   semop, qword[semid], sb, 1
    test       rax, rax
    js         error.semop

    ; printf("Unlocked\n");
    syscall    write, stdout, msgunlocked, msgunlocked.length

    syscall    exit, 0
    
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
.initsem:
     syscall   write, stderr, initsemerror, initsemerror.length
     syscall   exit, 1
.semop:     
     syscall   write, stderr, semoperror, semoperror.length
     syscall   exit, 1


initsem:
  ; rdi = key (from ftok)
  ; rsi = nsems
  
  
    ret
    
%ifdef REMARK    



; initsem() -- more-than-inspired by W. Richard Stevens' UNIX Network
; Programming 2nd edition, volume 2, lockvsem.c, page 295.

int initsem(key_t key, int nsems)  /* key from ftok() */
{
    int i;
    union semun arg;
    struct semid_ds buf;
    struct sembuf sb;
    int semid;

    semid = semget(key, nsems, IPC_CREAT | IPC_EXCL | 0666);

    if (semid >= 0) { /* we got it first */
        sb.sem_op = 1; sb.sem_flg = 0;
        arg.val = 1;

        printf("press return\n"); getchar();

        for(sb.sem_num = 0; sb.sem_num < nsems; sb.sem_num++) { 
            /* do a semop() to "free" the semaphores. */
            /* this sets the sem_otime field, as needed below. */
            if (semop(semid, &sb, 1) == -1) {
                int e = errno;
                semctl(semid, 0, IPC_RMID); /* clean up */
                errno = e;
                return -1; /* error, check errno */
            }
        }

    } else if (errno == EEXIST) { /* someone else got it first */
        int ready = 0;

        semid = semget(key, nsems, 0); /* get the id */
        if (semid < 0) return semid; /* error, check errno */

        /* wait for other process to initialize the semaphore: */
        arg.buf = &buf;
        for(i = 0; i < MAX_RETRIES && !ready; i++) {
            semctl(semid, nsems-1, IPC_STAT, arg);
            if (arg.buf->sem_otime != 0) {
                ready = 1;
            } else {
                sleep(1);
            }
        }
        if (!ready) {
            errno = ETIME;
            return -1;
        }
    } else {
        return semid; /* error, check errno */
    }

    return semid;
}     

%endif

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

     
; Name:         waitforkeypress

waitforkeypress:

    call    TermIOS.Canonical.OFF      ; switch canonical mode off
    call    TermIOS.Echo.OFF           ; no echo

.readKey:
    syscall read, STDIN, keybuffer, 1
    mov     al, byte[keybuffer]
    cmp     al, 10
    jne     .readKey
    
    ; clear the buffer
    mov     QWORD[rsi], 10

    ; Don't forget to switch canonical mode on
    call    TermIOS.Canonical.ON       ; switch canonical mode back on
    call    TermIOS.Echo.ON            ; restore echo
    ret
    
TermIOS.Canonical:
.ON:
    mov     rax, ICANON
    jmp     TermIOS.LocalModeFlag.SET

.OFF:
    mov     rax,ICANON
    jmp     TermIOS.LocalModeFlag.CLEAR

TermIOS.Echo:
.ON:
    mov     rax,ECHO
    jmp     TermIOS.LocalModeFlag.SET

.OFF:
    mov     rax,ECHO
    jmp     TermIOS.LocalModeFlag.CLEAR

TermIOS.LocalModeFlag:
.SET:
    call    TermIOS.STDIN.READ
    or      dword [termios.c_lflag], eax
    call    TermIOS.STDIN.WRITE
    ret

.CLEAR:
    call    TermIOS.STDIN.READ
    not     eax
    and     [termios.c_lflag], eax
    call    TermIOS.STDIN.WRITE
    ret

; subroutine for all TCGETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
TermIOS.STDIN:
.READ:
    mov     rsi, TCGETS
    jmp     TermIOS.IOCTL

; subroutine for all TCSETS operation on the syscall IOCTL
; the original value of RCX is restored on exit
.WRITE:
    mov     rsi, TCSETS

; subroutine for operations on the syscall IOCTL for STDIN
; all registers are restored to their original values on exit of the subroutine
TermIOS.IOCTL:
    push    rax             ; we need to store RAX or TermIOS.LocalFlag functions fail
    syscall ioctl, STDIN, rsi, termios
    pop     rax
    ret     