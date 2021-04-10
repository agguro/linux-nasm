%ifndef _SOCKETTEST_INC_
%define _SOCKETTEST_INC_

%include "unistd.inc"
%include "sys/socket.inc"
%include "sys/time.inc"

%DEFINE BUFFERSIZE 4096						;buffersize in bytes for the reply
%define DEBUG=1

struc STRUC_SOCKETADDR_IN
   .sin_family: 	resw 1
   .sin_port:		resw 1
   .sin_addr:		resd 1
   .sin_pad:		resb 8
endstruc

%endif
