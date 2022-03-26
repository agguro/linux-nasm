;name        : list.asm
;
;build       : nasm -felf64 -o list.o -l list.lst list.asm
;              ld -m elf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lgtk-3 -lglib-2.0 list.o -o list
;
;description : an example of glib 2.0 single linked lists
;
;source	: https://github.com/steshaw/gtk-examples	

bits 64

[list -]
	extern	g_slist_append
	extern	g_slist_free
	extern	g_slist_insert
	extern	g_slist_insert_sorted
	extern	g_slist_prepend
	extern 	g_slist_reverse
	extern 	g_slist_sort
	extern	g_slist_nth
	extern	g_slist_find
	extern 	g_print
	extern 	strcmp
	extern  exit
[list +]

section .rodata
	names:
	.fred:		db	"Fred",0
	.susie:		db	"Susie",0
	.frank:		db	"Frank",0
	.wilma:		db	"Wilma",0
	.mary:		db	"Mary",0
	.joe:		db	"Joe",0
	.mike:		db	"Mike",0
	.tyler:		db	"Tyler",0
	.amy:		db	"Amy",0
	.zoe:		db	"Zoe",0

	messages:
	.original:			db	"original list",10,"-------------",10,0
	.reversinglist:		db	10,"reversing list",10,"--------------",10,0
	.reversesorting:	db	10,"reverse sorted list",10,"-------------------",10,0
	.sorting:			db	10,"sorted list",10,"-----------",10,0
	.notfound:			db	"not found.",10,0
	.found:				db	"found at %d.",10,0
	.item:				db	"%s "						;don't separate this line with the next
	.crlf:				db	10,0
	.lookup:			db	"looking up %s : ",0
	
section .data
		list:	dq	0			;start of the list
		
section .text
global _start

_start:
	;add Fred, Susie, Frank and Wilma to the list
	mov		rdi,[list]
	mov 	rsi,names.fred
	call	g_slist_append
	mov 	[list],rax
	mov		rdi,[list]
	mov 	rsi,names.susie
	call	g_slist_append
	mov 	[list],rax
	mov		rdi,[list]
	mov 	rsi,names.frank
	call	g_slist_append
	mov 	[list],rax
	mov		rdi,[list]
	mov 	rsi,names.wilma
	call	g_slist_append
	mov 	[list],rax
	;insert Joe at the front of the list
	mov		rdi,[list]
	mov 	rsi,names.joe
	call	g_slist_prepend
	mov 	[list],rax
	;insert Mary after the second position
	mov		rdi,[list]
	mov 	rsi,names.mary
	mov 	rdx,2
	call	g_slist_insert
	mov 	[list],rax

	;add names but sorted
	mov		rdi,[list]
	mov 	rsi,names.amy
	mov 	rdx,List.Sort
	call	g_slist_insert_sorted
	mov 	[list],rax
	mov		rdi,[list]
	mov 	rsi,names.zoe
	mov 	rdx,List.Sort
	call	g_slist_insert_sorted
	mov 	[list],rax

	;Show the list so far
	mov 	rdi,messages.original
	xor		rax,rax
	call	g_print
	mov 	rdi,[list]
	call 	List.Display
	mov 	rdi,messages.crlf
	xor		rax,rax
	call	g_print
	
	;lookup some names in the list
	mov		rdi,[list]
	mov 	rsi,names.mike
	call 	List.Lookup
	mov		rdi,[list]
	mov 	rsi,names.mary
	call 	List.Lookup
	mov		rdi,[list]
	mov 	rsi,names.fred
	call 	List.Lookup
	mov		rdi,[list]
	mov 	rsi,names.tyler
	call 	List.Lookup
	;reverse the list
	mov 	rdi,messages.reversinglist
	call 	g_print
	mov 	rdi,[list]
	call 	g_slist_reverse
	mov		[list],rax
	;show revered list
	mov 	rdi,[list]
	call 	List.Display
	;sort the list alphabetically
	mov 	rdi,messages.sorting
	call 	g_print
	mov 	rdi,[list]
	mov 	rsi,List.Sort
	call	g_slist_sort
	mov		[list],rax
	;show sorted list
	mov 	rdi,[list]
	call 	List.Display
	;reversesort the list
	mov 	rdi,messages.reversesorting
	call 	g_print
	mov 	rdi,[list]
	mov 	rsi,List.ReverseSort
	call	g_slist_sort
	mov		[list],rax
	;show sorted list
	mov 	rdi,[list]
	call 	List.Display

	;free the data
	mov 	rdi,[list]
	call 	g_slist_free
	;exit the program
    xor     rdi,rdi
    call	exit

List:
.Lookup:
	;int 3
	;rdi has pointer to list
	;rsi has pointer to name which we're looking for
	push	rbp
	mov		rbp,rsp
	push	rdi
	push	rsi
	mov		rdi,messages.lookup
	xor 	rax,rax
	call	g_print
	pop		rsi
	pop		rdi
	;int		3
	call	g_slist_find
	mov		rdi,messages.notfound
	;rax has either zero or the item pointer
	and		rax,rax
	jz		.print
	mov		rsi,rax
	mov		rdi,messages.found
	xor		rax,rax
.print:	
	call	g_print
	mov 	rsp,rbp
	pop		rbp
	ret
	
.Display:
	push 	rbp
	mov 	rbp,rsp
	sub 	rsp,0x0
	mov 	r15,rdi
	xor 	rsi,rsi					;index = 0
.repeat:
	xor 	rax,rax
	mov 	rdi,r15
	call	g_slist_nth				;get nth item in the list
	and 	rax,rax
	jz		.done
	push	rdi
	push	rsi
	mov 	rsi,[rax]
	mov		rdi,messages.item
	xor 	rax,rax
	call	g_print
	pop		rsi
	pop		rdi
	inc 	esi
	jmp 	.repeat
.done:
	mov 	rsp,rbp
	pop		rbp
	ret
	
.ReverseSort:
	;reverse sorting is fairly easy now, just swap rdi and rsi
	xor 	rdi,rsi
	xor 	rsi,rdi
	xor 	rdi,rsi
	;and compare after the swap
.Sort:
	;compare strings in rdi and rsi, returning
	;-1 when string rdi comes before string rsi
	; 0 when both strings are equal
	; 1 when string in rsi comes after string rdi
	call	strcmp
	ret
