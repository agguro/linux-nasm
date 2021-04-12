%ifndef _MT1993732_INC_
%define _MT1993732_INC_

%include "unistd.inc"
%include "sys/time.inc"

;number of numbers to generate
%define NUMBER   1000000

;macro to generate buffers in several parts in the code
;use with: BUFFER name,type,number
%macro BUFFER 3
  %1:
    %if %2=="BYTE"
        %assign n 1
    %elif %2=="WORD"
        %assign n 2
    %elif %2=="DWORD"
        %assign n 4
    %elif %2=="QWORD"
        %assign n 8
    %endif
    .start:  resb %3*n
    .end:
    .len: equ %1.end-%1.start
%endmacro

;macro to build strings
%macro STRING 2
  %1:
    .start:  db %2
    .end:
    .len: equ %1.end-%1.start
%endmacro

%endif
