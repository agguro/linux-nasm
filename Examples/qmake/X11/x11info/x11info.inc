%ifndef _X11INFO_INC_
%define _X11INFO_INC_

%include "unistd.inc"


; external functions from X11 library
    extern XOpenDisplay
    extern XDisplayName
    extern XCloseDisplay
; external functions from stdio library
    extern printf
    extern exit
    extern puts

%endif
