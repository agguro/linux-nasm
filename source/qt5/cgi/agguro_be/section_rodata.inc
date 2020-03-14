%ifndef _SECTION_RODATA_INC_
%define _SECTION_RODATA_INC_

section .rodata
page:	db 'Content-type: text/html', 0x0A, 0x0A
    incbin "index.html"
.end:	equ $-page

%endif ; _SECTION_RODATA_INC_
