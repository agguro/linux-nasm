%ifndef _ASM_TIME_INC_
%define _ASM_TIME_INC_

%define CLOCK_REALTIME 0

STRUC TIMESPEC_STRUC
  .tv_sec:      resq    1
  .tv_nsec:     resq    1
ENDSTRUC

; TIMESPEC takes one mandatory parameter %1 which is the name of the data structure.
; The second and third refers to secs and nanosecs respectively and aren't mandatory.
; When no value is given for seconds and/or nanoseconds they defaults to zero.
%macro TIMESPEC 1-3
    %1:  ISTRUC TIMESPEC_STRUC
        at  TIMESPEC_STRUC.tv_sec,     dq %2
        at  TIMESPEC_STRUC.tv_nsec,    dq %3
    IEND

    %define %1.tv_sec   %1+TIMESPEC_STRUC.tv_sec
    %define %1.tv_nsec  %1+TIMESPEC_STRUC.tv_nsec
%endmacro

%elif
  %warning "time.inc already included"
%endif
