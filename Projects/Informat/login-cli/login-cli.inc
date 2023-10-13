%ifndef _INFORMAT_INC_
%define _INFORMAT_INC_

%include "unistd.inc"
%include "asm-generic/errno.inc"
%include "asm-generic/socket.inc"
%include "sys/time.inc"

extern stringsearch

%define BUFFERSIZE	4096		; buffersize in bytes for the reply
%define EOL		    10

section .bss
	%include 'section.bss.inc'
	
section .rodata
	%include 'section.rodata.inc'
	
section .data
	%include 'section.data.inc'
	
%endif
