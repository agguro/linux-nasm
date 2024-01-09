; Name        : hscale.asm
;
; Build       : nasm -felf64 -Fdwarf -g -o hscale.o hscale.asm
;               ld --dynamic-linker /lib64/ld-linux-x86-64.so.2 -melf_x86_64 -g -o hscale hscale.o -lc `pkg-config --libs gtk+-2.0`
;
; Description : Gtk widgets examples
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/


bits 64

[list -]
     
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     %define   TRUE                               1
     %define   FALSE                              0
     %define   FLOAT1		              0x3F80000000000000
     %define   FLOAT100					  0x4059000000000000
     
extern exit
extern gtk_alignment_new
extern gtk_box_pack_start
extern gtk_container_add
extern gtk_container_set_border_width
extern gtk_hbox_new
extern gtk_hscale_new_with_range
extern gtk_init
extern gtk_label_new
extern gtk_main
extern gtk_main_quit
extern gtk_misc_set_alignment
extern gtk_scale_set_draw_value
extern gtk_widget_set_size_request
extern gtk_widget_show_all
extern gtk_window_new
extern gtk_window_set_default_size
extern gtk_window_set_position
extern gtk_window_set_title
extern g_signal_connect_data
extern gtk_range_get_value
extern g_strdup_printf
extern gtk_label_set_text
extern g_free

[list +]

section .data
	window:		dq	0
	halign:		dq	0
	hbox:		dq	0
	hscale:		dq	0
	label:		dq	0
	range:		dq	0
	win:		dq	0
	val:		dq	0
	str:		dq	0
	
	szGtkHScale:	db	"HScale",0
	szDots:			db	"...",0
	szDestroy:		db	"destroy",0
	szValueChanged:	db	"value-changed",0
	szFloatMask:	db	"%.f",0

section .text
     global _start

_start:

	xor		rsi,rsi
	xor		rdi,rdi
	call	gtk_init
	
	mov		rdi,GTK_WINDOW_TOPLEVEL
	call	gtk_window_new
	mov		[window],rax
	
	mov		rdi,[window]
	mov		rsi,GTK_WIN_POS_CENTER
	call	gtk_window_set_position
	
	mov		rdi,[window]
	mov		rsi,300
	mov		rdx,250
	call	gtk_window_set_default_size
	
	mov		rdi,[window]
	mov		rsi,10
	call	gtk_container_set_border_width
	
	mov		rdi,[window]
	mov		rsi,szGtkHScale
	call	gtk_window_set_title
	
	mov		rdi,FALSE
	mov		rsi,20
	call	gtk_hbox_new
	mov		[hbox],rax
	
	pxor	xmm0,xmm0
	mov		r14,FLOAT100
	movq	xmm1,r14
	mov		r14,FLOAT1
	movq	xmm2,r14
	call	gtk_hscale_new_with_range
	mov		[hscale],rax

	mov		rdi,[hscale]
	mov		rsi,FALSE
	call	gtk_scale_set_draw_value
	
	mov		rdi,[hscale]
	mov		rsi,150
	mov		edx,-1
	call	gtk_widget_set_size_request
	
	mov		rdi,szDots
	call	gtk_label_new
	mov		[label],rax
	
	mov		rdi,[label]
	pxor	xmm0,xmm0
	mov     r14, FLOAT1
    movq    xmm1, r14
	call	gtk_misc_set_alignment
	
	mov		rdi,[hbox]
	mov		rsi,[hscale]
	mov		rdx,FALSE
	mov		rcx,FALSE
	mov		r8,0
	call	gtk_box_pack_start
	mov		rdi,[hbox]
	mov		rsi,[label]
	mov		rdx,FALSE
	mov		rcx,FALSE
	mov		r8,0
	call	gtk_box_pack_start
	
	pxor	xmm0,xmm0
	pxor	xmm1,xmm1
	pxor	xmm2,xmm2
	pxor	xmm3,xmm3
	call	gtk_alignment_new
	mov		[halign],rax
	
	mov		rdi,[halign]
	mov		rsi,[hbox]
	call	gtk_container_add
	
	mov		rdi,[window]
	mov		rsi,[halign]
	call	gtk_container_add

	xor		r9, r9                                       ; combination of GConnectFlags
	xor		r8, r8                                       ; a GClosureNotify for data
	xor		rcx, rcx                                     ; pointer to window instance in RCX
	mov		rdx, gtk_main_quit                            ; pointer to the handler
	mov		rsi, szDestroy                               ; pointer to the signal
	mov		rdi, [window]                                     ; pointer to checkbutton in RDI
	call	g_signal_connect_data                          ; GtkCheckButton example

	xor		r9, r9                                       ; combination of GConnectFlags
	xor		r8, r8                                       ; a GClosureNotify for data
	mov		rcx, [label]                                     ; pointer to window instance in RCX
	mov		rdx, value_changed                            ; pointer to the handler
	mov		rsi, szValueChanged                               ; pointer to the signal
	mov		rdi, [hscale]                                     ; pointer to checkbutton in RDI
	call	g_signal_connect_data                          ; GtkCheckButton example

	mov		rdi,[window]
	call	gtk_widget_show_all
	call	gtk_main
	xor		rdi, rdi
	call	exit



     
;void value_changed(GtkRange *range, gpointer win)

;	gdouble val = gtk_range_get_value(range);
;   gchar *str = g_strdup_printf("%.f", val);
;   gtk_label_set_text(GTK_LABEL(win), str);

;   g_free(str);
value_changed:
	push	rbp
	mov		rbp,rsp
	;rdi has the pointer to the range
	;rsi has the pointer to our label
	mov 	[range],rdi
	mov		[win],rsi

	mov 	rdi,[range]
	call	gtk_range_get_value
	
	;xmm0 contains the value of the range
	movq	[val],xmm0
	;print the label text to set into a string in memory
	mov		rdi,szFloatMask
	mov 	rax,1
	call 	g_strdup_printf
	mov		[str],rax
	
	;rax has the pointer to the string
	mov		rdi,[win]
	mov		rsi,[str]
	call	gtk_label_set_text
	
	mov		rdi,[str]
	call	g_free
	mov		qword[str],0
	
	mov		rsp,rbp
	pop		rbp
	ret
