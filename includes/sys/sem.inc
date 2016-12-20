%ifndef _ASM_SYS_SEM_INC_
%define _ASM_SYS_SEM_INC_  1

%include "sys/ipc.inc"
%include "sys/time.inc"
; Get system dependent definition of `struct semid_ds' and more.
%define SEM_UNDO    0x1000    ; undo the operation on exit

; Commands for `semctl'.
%define GETPID      11        ; get sempid
%define GETVAL      12        ; get semval
%define GETALL      13        ; get all semval's
%define GETNCNT     14        ; get semncnt
%define GETZCNT     15        ; get semzcnt
%define SETVAL      16        ; set semval
%define SETALL      17        ; set all semval's


; Data structure describing a set of semaphores.

STRUC SEM_ID_STRUC
     .sem_perm:           resq      1 ; operation permission struct, must be filled in as pointer to the structure by the calling program
     .sem_otime:          resq      1 ; last semop() time
     .__glibc_reserved1:  resq      1
     .sem_ctime:          resq      1 ; last time changed by semctl()
     .__glibc_reserved2:  resq      1 ;
     .sem_nsems:          resq      1 ; number of semaphores in set
     .__glibc_reserved3:  resq      1
     .__glibc_reserved4:  resq      1
ENDSTRUC

     %macro SEM_ID 1
          %1: 
          ISTRUC SEM_ID_STRUC
               at SEM_ID_STRUC.sem_perm,               dq 0           ; IPC_PERM_STRUC
               at SEM_ID_STRUC.sem_otime,              dq 0
               at SEM_ID_STRUC.__glibc_reserved1,      dq 0
               at SEM_ID_STRUC.sem_ctime,              dq 0
               at SEM_ID_STRUC.__glibc_reserved2,      dq 0
               at SEM_ID_STRUC.sem_nsems,              dd 0
               at SEM_ID_STRUC.__glibc_reserved3,      dq 0
               at SEM_ID_STRUC.__glibc_reserved4,      dq 0
          IEND  

          ; definition macro's for SEM_ID structure
          ; !! warn: Leave commented lines commented, they are here to be complete. If in the future some of these fields will be used.
          
          %define %1.perm                  %1+SEM_ID_STRUC.sem_perm
          %define %1.perm.uid              %1+SEM_ID_STRUC.sem_perm+IPC_PERM_STRUC.uid
          %define %1.perm.gid              %1+SEM_ID_STRUC.sem_perm+IPC_PERM_STRUC.gid
          %define %1.perm.cuid             %1+SEM_ID_STRUC.sem_perm+IPC_PERM_STRUC.cuid
          %define %1.perm.cgid             %1+SEM_ID_STRUC.sem_perm+IPC_PERM_STRUC.cgid
          %define %1.perm.mode             %1+SEM_ID_STRUC.sem_perm+IPC_PERM_STRUC.mode
          %define %1.perm.__seq            %1+SEM_ID_STRUC.sem_perm+IPC_PERM_STRUC.__seq

          %define %1.sem_otime                    %1+SEM_ID_STRUC.sem_otime
          ; %define %1.sem_id__glibc_reserved1    %1+SEM_ID_STRUC.sem_id__glibc_reserved1
          %define %1.sem_ctime                    %1+SEM_ID_STRUC.sem_ctime
          ; %define %1.sem_id__glibc_reserved2    %1+SEM_ID_STRUC.sem_id__glibc_reserved2
          %define %1.sem_nsems                    %1+SEM_ID_STRUC.sem_nsems
          ; %define %1.sem_id__glibc_reserved3    %1+SEM_ID_STRUC.sem_id__glibc_reserved3
          ; %define %1.sem_id__glibc_reserved4    %1+SEM_ID_STRUC.sem_id__glibc_reserved4
          
     %endmacro

     ; ipcs ctl cmds
     %define SEM_STAT                       18
     %define SEM_INFO                       19

     STRUC SEMINFO_STRUC
          semmap:        resq      1
          semmni:        resq      1
          semmns:        resq      1
          semmnu:        resq      1
          semmsl:        resq      1
          semopm:        resq      1
          semume:        resq      1
          semusz:        resq      1
          semvmx:        resq      1
          semaem:        resq      1
     ENDSTRUC

     %macro SEM_INFO 1
          %1: 
          ISTRUC SEMINFO_STRUC
               at   SEMINFO_STRUC.semmap,         dq   0
               at   SEMINFO_STRUC.semmni,         dq   0
               at   SEMINFO_STRUC.semmns,         dq   0
               at   SEMINFO_STRUC.semmnu,         dq   0
               at   SEMINFO_STRUC.semmls,         dq   0
               at   SEMINFO_STRUC.semopm,         dq   0
               at   SEMINFO_STRUC.semume,         dq   0
               at   SEMINFO_STRUC.semusz,         dq   0
               at   SEMINFO_STRUC.semvmx,         dq   0
               at   SEMINFO_STRUC.semaem,         dq   0
          IEND

          %define %1.semmap.      %1+SEMINFO_STRUC.semmap
          %define %1.semmni.      %1+SEMINFO_STRUC.semmni
          %define %1.semmns.      %1+SEMINFO_STRUC.semmns
          %define %1.semmnu.      %1+SEMINFO_STRUC.semmnu
          %define %1.semmls.      %1+SEMINFO_STRUC.semmls
          %define %1.semopm.      %1+SEMINFO_STRUC.semopm
          %define %1.semume.      %1+SEMINFO_STRUC.semume
          %define %1.semusz.      %1+SEMINFO_STRUC.semusz
          %define %1.semvmx.      %1+SEMINFO_STRUC.semvmx
          %define %1.semaem.      %1+SEMINFO_STRUC.semaem

     %endmacro

     ; Structure used for argument to `semop' to describe operations.

     STRUC SEMBUF_STRUC
          .sem_num:      resq      1
          .sem_op:       resq      1
          .sem_flg:      resq      1
     ENDSTRUC

     %macro SEM_BUF 1
          %1:
          ISTRUC SEMBUF_STRUC
               at   SEMBUF_STRUC.sem_num,         dq   0
               at   SEMBUF_STRUC.sem_op,          dq   0
               at   SEMBUF_STRUC.sem_flg,         dq   0
          IEND

          %define %1.sem_num        %1+SEMBUF_STRUC.sem_num
          %define %1.sem_op        %1+SEMBUF_STRUC.sem_op
          %define %1.sem_flg       %1+SEMBUF_STRUC.sem_flg
     %endmacro
%endif
