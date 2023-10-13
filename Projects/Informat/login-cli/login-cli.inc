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
	%include 'includes/section_bss.asm'
	
section .rodata
	%include 'includes/section_rodata.asm'
	
section .data
	%include 'includes/section_data.asm'
	
%endif