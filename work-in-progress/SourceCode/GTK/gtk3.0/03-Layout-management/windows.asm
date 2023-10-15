;name:	windows.asm
;
;build:	nasm -f elf64 -F dwarf -g ../windows.asm -o windows.o
;		ld -m elf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lgtk-x11-2.0 -lglib-2.0 -lgobject-2.0 windows.o -o windows
;description : 
;		a more advanced window
;
;C-source  : http://zetcode.com/tutorials/gtktutorial/gtklayoutmanagement/

bits 64

[list -]
	%define	GTK_WINDOW_TOPLEVEL	0
	%define	GTK_WIN_POS_CENTER	1
	%define	FALSE				0
	%define	TRUE				1
	%define	FLOAT1				0x3F800000     
	%define	GTK_EXPAND			1
	%define	GTK_SHRINK			2
	%define	GTK_FILL			4
	extern	exit
	extern	g_signal_connect_data
	extern	gtk_alignment_new
	extern	gtk_button_new_with_label
	extern	gtk_container_add
	extern	gtk_container_set_border_width
	extern	gtk_init
	extern	gtk_label_new
	extern	gtk_main
	extern	gtk_main_quit
	extern	gtk_table_attach
	extern	gtk_table_new
	extern	gtk_table_set_col_spacings
	extern	gtk_table_set_row_spacings
	extern	gtk_text_view_new
	extern	gtk_text_view_set_cursor_visible
	extern	gtk_text_view_set_editable
	extern	gtk_window_new
	extern	gtk_window_set_position
	extern	gtk_widget_set_size_request
	extern	gtk_window_set_title
	extern	gtk_widget_show_all
[list +]

section .data
	window:			dq	0
		.title:		db	"Windows",0
	table:			dq	0
	signal:
		.destroy:	db	"destroy",0
	label:			dq  0
	halign:			dq	0
	halign2:		dq	0
	valign:			dq	0
	wins:			dq	0
	actBtn:			dq	0
		.text:		db	"Activate",0
	clsBtn:			dq	0
		.text:		db	"Close",0
	hlpBtn:			dQ	0
		.text:		db	"Help",0
	okBtn:			dq	0
		.text:		db	"Ok",0
	
section .text
	global _start

_start:
	xor		rsi, rsi					;argv
	xor		rdi, rdi					;argc
	call	gtk_init

;create all widgets
	;mainwindow
	mov		rdi,GTK_WINDOW_TOPLEVEL
	call	gtk_window_new
	mov		[window], rax

	;table widget
	mov		rdi,6						;rows
	mov		rsi,4						;columns
	mov		rdx,FALSE					;homogenious
	call	gtk_table_new
	mov		[table], rax

	;alignments
	xorps	xmm0,xmm0					;xalign
	xorps	xmm1,xmm1					;yalign
	xorps	xmm2,xmm2					;xscale
	xorps	xmm3,xmm3					;yscale
	call	gtk_alignment_new
	mov		[halign],rax
	call	gtk_alignment_new
	mov		[valign],rax
	mov		r14,FLOAT1					;xscale
	movq	xmm1,r14
	xorps	xmm0,xmm0
	call	gtk_alignment_new
	mov		[halign2],rax

	;label
	mov 	rdi,window.title
	call	gtk_label_new
	mov		[label],rax

	;textview
	call	gtk_text_view_new
	mov		[wins],rax

	;buttons
	mov		rdi,actBtn.text 
	call	gtk_button_new_with_label
	mov		[actBtn],rax
	mov		rdi,clsBtn.text 
	call	gtk_button_new_with_label
	mov		[clsBtn],rax
	mov 	rdi,hlpBtn.text
	call	gtk_button_new_with_label
	mov 	[hlpBtn],rax
	mov		rdi,okBtn.text
	call	gtk_button_new_with_label
	mov 	[okBtn], rax
;end of creation of widgets
	
;initialization of the widgets
	;window
	mov		rdi,[window]
	mov		rsi,GTK_WIN_POS_CENTER
	call	gtk_window_set_position
	mov		rdi,[window]
	mov		rsi,300
	mov		rdx,250
	call	gtk_widget_set_size_request
	mov		rdi,[window]
	mov		rsi,window.title
	call	gtk_window_set_title
	mov		rdi,[window]
	mov		rsi,15
	call	gtk_container_set_border_width

    ;textview
	mov		rdi,[wins]
	mov		rsi,FALSE
	call	gtk_text_view_set_editable
	mov		rdi,[wins]
	mov		rsi,FALSE
	call	gtk_text_view_set_cursor_visible
	
	;buttons
	mov		rdi,[actBtn]
	mov		rsi,70
	mov		rdx,30
	call	gtk_widget_set_size_request
	mov		rdi,[clsBtn]
	mov		rsi,70
	mov		rdx,30
	call	gtk_widget_set_size_request
	mov		rdi,[okBtn]
	mov		rsi,70
	mov		rdx,30
	call	gtk_widget_set_size_request
	mov 	rdi,[hlpBtn]
	mov		rsi,70
	mov		rdx,30
	call	gtk_widget_set_size_request

;the layout
	mov		rdi,[table]
	mov		rsi,3
	call	gtk_table_set_col_spacings
	mov 	rdi,[table]
	mov 	rsi,3
	call	gtk_table_set_row_spacings

;add widgets to their containers
	mov		rdi,[halign]
	mov		rsi,[label]
	call	gtk_container_add

	mov		rdi,[valign]
	mov		rsi,[clsBtn]
	call	gtk_container_add

	mov 	rdi,[halign2]
	mov 	rsi,[hlpBtn]
	call	gtk_container_add

	mov		rdi,[window]
	mov		rsi,[table]
	call	gtk_container_add
	
;attach the widgets to the table
	push	0						;ypadding
	push	0						;xpadding
	push	GTK_FILL				;yoptions
	push	GTK_FILL				;xoptions
	mov		r9,1					;bottom_attach
	mov		r8,0					;top_attach
	mov		rcx,1					;right_attach
	mov		rdx,0					;left_attach
	mov		rsi,[halign]			;child widget
	mov		rdi,[table]				;table widget
	call	gtk_table_attach		;attach widget to table

	push	0						;ypadding
	push	0						;xpadding
	push	GTK_FILL				;yoptions
	push	GTK_FILL				;xoptions
	mov		r9,5					;bottom_attach
	mov		r8,4					;top_attach
	mov		rcx,1					;right_attach
	mov		rdx,0					;left_attach
	mov		rsi,[halign2]			;child widget
	mov		rdi,[table]				;table widget
	call	gtk_table_attach		;attach widget to table

	push	1						;ypadding
	push	1						;xpadding
	push	GTK_FILL | GTK_EXPAND	;yoptions
	push	GTK_FILL				;xoptions
	mov		r9,3					;bottom_attach
	mov		r8,2					;top_attach
	mov		rcx,4					;right_attach
	mov		rdx,3					;left_attach
	mov		rsi,[valign]			;child widget
	mov		rdi,[table]				;table widget
	call	gtk_table_attach		;attach widget to table

	push	1						;ypadding
	push	1						;xpadding
	push	GTK_FILL | GTK_EXPAND	;yoptions
	push	GTK_FILL | GTK_EXPAND	;xoptions
	mov		r9,3					;bottom_attach
	mov		r8,1					;top_attach
	mov		rcx,2					;right_attach
	mov		rdx,0					;left_attach
	mov		rsi,[wins]				;child widget
	mov		rdi,[table]				;parent table widget
	call	gtk_table_attach		;attach child to parent table

	push	1						;ypadding
	push	1						;xpadding
	push	GTK_SHRINK				;yoptions
	push	GTK_FILL				;xoptions
	mov		r9,2					;bottom_attach
	mov		r8,1					;top_attach
	mov		rcx,4					;right_attach
	mov		rdx,3					;left_attach
	mov		rsi,[actBtn]			;child widget
	mov		rdi,[table]				;parent table widget
	call	gtk_table_attach		;attach child to parent table

	push	0						;ypadding
	push	0						;xpadding
	push	GTK_FILL				;yoptions
	push	GTK_FILL				;xoptions
	mov		r9,5					;bottom_attach
	mov		r8,4					;top_attach
	mov		rcx,4					;right_attach
	mov		rdx,3					;left_attach
	mov		rsi,[okBtn]				;child widget
	mov		rdi,[table]				;parent table widget
	call	gtk_table_attach		;attach child to parent table
	
;connect the signals to their slots
	xor		r9d,r9d					;combination of GConnectFlags 
	xor		r8d,r8d					;a GClosureNotify for data
	xor		rcx,rcx					;pointer to the data to pass
	mov		rdx,gtk_main_quit		;pointer to the handler
	mov		rsi,signal.destroy		;pointer to the signal
	mov		rdi,[window]			;pointer to the widget instance
	call	g_signal_connect_data	;the value in RAX is the handler, but we don't store it now
;show the window
	mov		rdi,[window]
	call	gtk_widget_show_all
;main program loop
	call	gtk_main
;exit program
	xor		rdi,rdi
	call	exit
