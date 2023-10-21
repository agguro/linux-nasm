TODO: second example

https://asm.sourceforge.net/articles/smc.html

;****************************************************************************
;****************************************************************************
;*
;* USING SELF MODIFYING CODE UNDER LINUX
;*
;* written by Karsten Scheibler, 2004-AUG-09
;*
;****************************************************************************
;****************************************************************************





global _start



;****************************************************************************
;* some assign's
;****************************************************************************
%assign SYS_WRITE			4
%assign SYS_MPROTECT		125

%assign PROT_READ			1
%assign PROT_WRITE			2
%assign PROT_EXEC			4



;****************************************************************************
;* data
;****************************************************************************
section .bss
					alignb	4
modified_code:				resb	0x2000



;****************************************************************************
;* smc_start
;****************************************************************************
section .text
_start:
smc_start:

	;calculate the address in section .bss, it must lie on a page
	;boundary (x86: 4KB = 0x1000)
	;NOTE: In this example obsolete because each segment is page
	;      aligned and we use it only once, so we know that it is
	;      aligned to a page boundary, but if you have more than
	;      one section .bss in your code (or link several objects
	;      together) you can't be sure about that

	mov	dword ebp, (modified_code + 0x1000)
	and	dword ebp, 0xfffff000

	;change flags of this page to read + write + executable,
	;NOTE: On x86 Architecture this call is obsolete, because for
	;      section .bss PROT_READ and PROT_WRITE are already set.
	;      PROT_EXEC is on x86 also set if PROT_READ is set, this
	;      results in rwx for this segment, but this behavior may
	;      change with appearance of the NX-flag in modern processors

	mov	dword eax, SYS_MPROTECT
	mov	dword ebx, ebp
	mov	dword ecx, 0x1000
	mov	dword edx, (PROT_READ | PROT_WRITE | PROT_EXEC)
	int	byte  0x80
	test	dword eax, eax
	js	near  smc_error

	;execute unmodified code first

code1_start:
	mov	dword eax, SYS_WRITE
	mov	dword ebx, 1
	mov	dword ecx, hello_world_1
code1_mark_1:
	mov	dword edx, (hello_world_2 - hello_world_1)
code1_mark_2:
	int	byte  0x80
code1_end:

	;copy code snippet from above to our page (address is still in ebp)

	mov	dword ecx, (code1_end - code1_start)
	mov	dword esi, code1_start
	mov	dword edi, ebp
	cld
	rep movsb

	;append 'ret' opcode to it, so that we can do a call to it

	mov	byte  al, [return]
	stosb

	;change some values in the copied code: start address of the text
	;and its length

	mov	dword eax, hello_world_2
	mov	dword ebx, (code1_mark_1 - code1_start)
	mov	dword [ebx + ebp - 4], eax
	mov	dword eax, (hello_world_3 - hello_world_2)
	mov	dword ebx, (code1_mark_2 - code1_start)
	mov	dword [ebx + ebp - 4], eax

	;finally call it

	call	dword ebp

	;copy second example

	mov	dword ecx, (code2_end - code2_start)
	mov	dword esi, code2_start
	mov	dword edi, ebp
	rep movsb

	;do something real nasty: edi points right after the 'rep stosb'
	;instruction, so this will really modify itself

	mov	dword edi, ebp
	add	dword edi, (code2_mark - code2_start)
	call	dword ebp

	;modify code in section .text itself

endless:
	;allow us to write to section .text

	mov	dword eax, SYS_MPROTECT
	mov	dword ebx, smc_start
	and	dword ebx, 0xfffff000
	mov	dword ecx, 0x2000
	mov	dword edx, (PROT_READ | PROT_WRITE | PROT_EXEC)
	int	byte  0x80
	test	dword eax, eax
	js	near  smc_error

	;write message to screen

	mov	dword eax, SYS_WRITE
	mov	dword ebx, 1
	mov	dword ecx, endless_loop
	mov	dword edx, (hello_world_1 - endless_loop)
	int	byte  0x80

	;here comes the magic, which prevents endless execution

	mov	dword ecx, (smc_end_1 - smc_end)
	mov	dword esi, smc_end
	mov	dword edi, endless
	rep movsb

	;do it again

	jmp	short endless



;****************************************************************************
;* code2
;****************************************************************************

	;this is the ret opcode we copy above
	;and the nop opcode needed by code2

return:
	ret
no_operation:
	nop

	;here some real selfmodifying code, if copied
	;to .bss and edi correctly loaded ebx should contain 0x4 instead
	;of 0x8

code2_start:
	mov	byte  al, [no_operation]
	xor	dword ebx, ebx
	mov	dword ecx, 0x04
	rep stosb
code2_mark:
	inc	dword ebx
	inc	dword ebx
	inc	dword ebx
	inc	dword ebx
	inc	dword ebx
	inc	dword ebx
	inc	dword ebx
	inc	dword ebx
	call	dword [function_pointer]
	ret
code2_end:
					align 4
function_pointer:			dd	write_hex



;****************************************************************************
;* write_hex
;****************************************************************************
write_hex:
	mov	byte  bh, bl
	shr	byte  bl, 4
	add	byte  bl, 0x30
	cmp	byte  bl, 0x3a
	jb	short .number_1
	add	byte  bl, 0x07
.number_1:
	mov	byte  [hex_number], bl
	and	byte  bh, 0x0f
	add	byte  bh, 0x30
	cmp	byte  bh, 0x3a
	jb	short .number_2
	add	byte  bh, 0x07
.number_2:
	mov	byte  [hex_number + 1], bh
	mov	dword eax, SYS_WRITE
	mov	dword ebx, 1
	mov	dword ecx, hex_text
	mov	dword edx, 9
	int	byte  0x80
	ret

section .data
hex_text:		db	"ebx: "
hex_number:		db	"00h", 10



;****************************************************************************
;* some text
;****************************************************************************
endless_loop:		db	"No endless loop here!", 10
hello_world_1:		db	"Hello World!", 10
hello_world_2:		db	"This code was modified!", 10
hello_world_3:



;****************************************************************************
;* smc_error
;****************************************************************************
section .text
smc_error:
	xor	dword eax, eax
	inc	dword eax
	mov	dword ebx, eax
	int	byte  0x80



;****************************************************************************
;* smc_end
;****************************************************************************
section .text
smc_end:
	xor	dword eax, eax
	xor	dword ebx, ebx
	inc	dword eax
	int	byte  0x80
smc_end_1:
;*********************************************** linuxassembly@unusedino.de *
