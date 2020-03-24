; Name        : version.asm
;
; Build       : nasm -felf64 -o version.o -l version.lst version.asm
;               ld -s -m elf_x86_64 version.o -o version -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 \
;               -lgtk-x11-2.0 -lglib-2.0
;               or with automake
;               aclocal && autoconf && automake --add-missing --foreign
;               mkdir build
;               cd build
;               ../configure
;               make
;
; Description : The program is restricted to show some data stored in the glib and gtk shared
;				libraries.
;               these strings can be obtained with 
;				objdump -t -T /usr/lib/x86_64-linux-gnu/libglib-2.0.so | grep .rodata
;               objdump -t -T /usr/lib/x86_64-linux-gnu/libgtk-x11-2.0.so | grep .rodata
;				and so on for other libraries.
;
; C - source  : http://zetcode.com/gui/gtk2/introduction/

bits 64

[list -]
	;glib parameters
	extern	glib_minor_version
	extern	glib_micro_version
	extern	glib_major_version
	;gtk params
	extern	gtk_micro_version
	extern	gtk_major_version
	extern	gtk_minor_version
	;stdio
	extern	printf
    extern  exit
[list +]

section .rodata
	;to have the possibility to extend this program I prefer to work with lists

	params:	dq	glib_major_version, glib_minor_version,	glib_micro_version	
			dq	gtk_major_version, gtk_minor_version, gtk_micro_version
			dq	0

	msgs:	dq	szglib_major_version,szglib_minor_version,szglib_micro_version
			dq	szgtk_major_version, szgtk_minor_version, szgtk_micro_version
	
	;messages:
	messages:
	szglib_major_version:	db	"Glib version: %d",0
	szglib_minor_version:	db	".%d",0
	szglib_micro_version:	db	".%d",10,0

	szgtk_major_version:	db	"Gtk version: %d",0
	szgtk_minor_version:	db	".%d",0
	szgtk_micro_version:	db	".%d",10,0

section .text
global _start

_start:
	;r14 isn't changed by printf and holds the pointer in the message list
	mov 	r14,msgs
	;r15 isn't changed by printf holds the pointer in the param list
	mov		r15,params
	;we're gonna loop through the parameters in params list until we got the nul pointer
	;at the end and we exit the program
.repeat:
	mov 	rax,[r15]
	test	rax,rax
	jz		.exit
	mov 	esi,dword[rax]		;read value in esi
	mov 	rdi,qword[r14]		;read pointer to message in rdi
	xor		rax,rax				;rax =  indicating no extra parameters
	call 	printf
	add 	r14,8				;next pointer in msgs list
	add 	r15,8				;next pointer in params list
	jmp		.repeat
.exit:    
    ;exit program
    xor     rdi,rdi
    call    exit
