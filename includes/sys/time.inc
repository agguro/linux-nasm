%ifndef _ASM_TIME_INC_
%define _ASM_TIME_INC_   1

%define CLOCK_REALTIME 0

STRUC TIMESPEC_STRUC
  .tv_sec:      resq    1
  .tv_nsec:     resq    1
ENDSTRUC

STRUC TIMEVAL_STRUC
  .tv_sec:      resq    1               ; seconds
  .tv_usec:     resq    1               ; microseconds
ENDSTRUC

STRUC TIMEZONE_STRUC
  .tz_minuteswest:      resq    1               ; minutes west of Greenwich
  .tz_dsttime:          resq    1               ; type of DST correction
ENDSTRUC


; TIMESPEC takes one mandatory parameter %1 which is the name of the data structure.
; The second and third refers to secs and nanosecs respectively and aren't mandatory.
; When no value is given for seconds and/or nanoseconds they defaults to zero.
%macro TIMESPEC 1-3 0,0
    %1:  ISTRUC TIMESPEC_STRUC
        at  TIMESPEC_STRUC.tv_sec,     dq %2
        at  TIMESPEC_STRUC.tv_nsec,    dq %3
    IEND

    %define %1.tv_sec   %1+TIMESPEC_STRUC.tv_sec
    %define %1.tv_nsec  %1+TIMESPEC_STRUC.tv_nsec
%endmacro

; TIMEVAL takes one mandatory parameter %1 which is the name of the data structure.
; The second and third refers to secs and microsecs respectively and aren't mandatory.
; When no value is given for seconds and/or nanoseconds they defaults to zero.
%macro TIMEVAL 1-3 0,0
    %1:  ISTRUC TIMEVAL_STRUC
        at  TIMEVAL_STRUC.tv_sec,     dq %2
        at  TIMEVAL_STRUC.tv_usec,    dq %3
    IEND

    %define %1.tv_sec   %1+TIMEVAL_STRUC.tv_sec
    %define %1.tv_usec  %1+TIMEVAL_STRUC.tv_usec
%endmacro

; TIMEZONE takes one mandatory parameter %1 which is the name of the data structure.
; The second and third refers to minuteswest and dsttime respectively and aren't mandatory.
; When no value is given for minuteswest and/or dsttime they defaults to zero.
%macro TIMEZONE 1-3 0,0
    %1:  ISTRUC TIMEZONE_STRUC
        at  TIMEZONE_STRUC.tz_minuteswest,     dq %2
        at  TIMEZONE_STRUC.tz_dsttime,         dq %3
    IEND

    %define %1.tz_minuteswest   %1+TIMEZONE_STRUC.tz_minuteswest
    %define %1.tz_dsttime       %1+TIMEZONE_STRUC.tz_dsttime
%endmacro

%endif