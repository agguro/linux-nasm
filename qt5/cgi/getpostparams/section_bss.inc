%ifndef _SECTION_BSS_INC_
%define _SECTION_BSS_INC_

section .bss
	oldbrkaddr:				resq		1
	contentlength:				resq		1
	buffer:					resb		1
	buffer.length:				equ		$-buffer
	stackpointer:				resq		1
	environmentParameterList:	resq		1
	
%endif ; _SECTION_BSS_INC_
