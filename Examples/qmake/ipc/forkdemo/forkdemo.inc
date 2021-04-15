%ifndef _FORKDEMO_INC_
%define _FORKDEMO_INC_

%include "unistd.inc"
%include "sys/time.inc"

;structure with process 'properties'
STRUC PROCESS_STRUC
    .address:     resq    1
    .PID:         resq    1
    .pidok:       resb    1
    .timer:       resq    1
    .iterations:  resq    1
ENDSTRUC

;a macro to easy the coding a bit
%macro PROCESS 5
    %define %1.address       %1+PROCESS_STRUC.address
    %define %1.PID           %1+PROCESS_STRUC.PID
    %define %1.pidok         %1+PROCESS_STRUC.pidok
    %define %1.timer         %1+PROCESS_STRUC.timer
    %define %1.iterations    %1+PROCESS_STRUC.iterations

    TIMESPEC timer%1,%4,%5

    %1: ISTRUC PROCESS_STRUC
    at    PROCESS_STRUC.address,    dq %2
    at    PROCESS_STRUC.PID,        dq 0
    at    PROCESS_STRUC.pidok,      db 0
    at    PROCESS_STRUC.timer,      dq timer%1
    at    PROCESS_STRUC.iterations, dq %3
    IEND
%endmacro


%endif
