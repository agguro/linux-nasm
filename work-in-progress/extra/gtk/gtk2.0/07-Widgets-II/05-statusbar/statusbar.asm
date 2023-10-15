; Name        : statusbar.asù
;
; Build       : nasm -f elf64 -F dwarf -g ../statusbar.asm -o statusbar.o
;				ld -m elf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lc -lgtk-x11-2.0 -lgdk-x11-2.0 -lpangocairo-1.0 -latk-1.0 -lcairo -lgdk_pixbuf-2.0 -lgio-2.0
;				-lpangoft2-1.0 -lpango-1.0 -lgobject-2.0 -lglib-2.0 -lfontconfig -lfreetype statusbar.o -o statusbar
;
; Description : Gtk widgets examples
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/


bits 64

[list -]
     
     %define   GTK_WINDOW_TOPLEVEL           0
     %define   GTK_WIN_POS_CENTER            1
     %define   GTK_JUSTIFY_CENTER            2
     %define   TRUE                          1
     %define   FALSE                         0
     %define   GTK_ORIENTATION_HORIZONTAL    0
     %define   GTK_ORIENTATION_VERTICAL      1
     %define   FLOAT1				0x3F800000
     
     extern    exit
     extern    gtk_init
     extern		g_free
     extern    gtk_window_new
     extern    gtk_window_set_title
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_window_set_icon
     extern    gtk_widget_show_all
     extern    gtk_main
     extern    gtk_main_quit
     extern    g_signal_connect_data
     extern    gdk_pixbuf_new_from_file
     extern    gdk_pixbuf_loader_new
     extern    gdk_pixbuf_loader_write
     extern    gdk_pixbuf_loader_get_pixbuf
     extern    gtk_container_add    
     extern    gtk_container_set_border_width
     extern    gtk_vbox_new
     extern    gtk_hbox_new
     extern    gtk_box_pack_start
     extern    gtk_button_new_with_label
     extern    gtk_fixed_new
     extern    gtk_fixed_put
     extern    gtk_widget_set_size_request
     extern    gtk_statusbar_new
     extern    gtk_button_get_label
     extern    g_strdup_printf
     extern    gtk_statusbar_get_context_id
     extern    gtk_statusbar_push
     extern		gtk_alignment_new
[list +]

section .data
  window:	dq	0
  hbox:	dq	0
  vbox:	dq	0
  halign:	dq	0
  balign:	dq	0
  button1:	dq	0
  button2:	dq	0
  statusbar:	dq	0
  win:	dq	0
  widget:	dq	0
  str:	dq	0
  
szGtkStatusbar:	db "GtkStatusbar",0
szOK:	db	"OK",0
szApply:	db "Apply",0
szClicked:	db	"clicked",0
szDestroy:	db	"destroy",0
szMask:		db "%s button clicked",0

section .text
     global _start

_start:

	xor		rsi, rsi                  ; argv
	xor		rdi, rdi                  ; argc
	call	gtk_init

	mov		rdi,GTK_WINDOW_TOPLEVEL
	call	gtk_window_new
	mov[window],rax
	
	mov		rdi,[window]
	mov		rsi,GTK_WIN_POS_CENTER
	call	gtk_window_set_position
	
	mov		rdi,[window]
	mov		rsi,300
	mov		rdx,200
	call	gtk_window_set_default_size
	
	mov		rdi,[window]
	mov		rsi,szGtkStatusbar
	call	gtk_window_set_title

	mov		rdi,FALSE
	xor		rsi,rsi
	call	gtk_vbox_new
	mov		[vbox],rax

	mov		rdi,FALSE
	xor		rsi,rsi
	call	gtk_hbox_new
	mov		[hbox],rax

	mov		rdi,[window]
	mov		rsi,[vbox]
	call	gtk_container_add

	pxor	xmm0,xmm0
	pxor	xmm1,xmm1
	pxor	xmm2,xmm2
	pxor	xmm3,xmm3	
	call	gtk_alignment_new
	mov		[halign],rax
	
	mov		rdi,[halign]
	mov		rsi,[hbox]
	call	gtk_container_add
	
	mov		rdi,[vbox]
	mov		rsi,[halign]
	mov		rdx,TRUE
	mov		rcx,TRUE 
	mov		r8,5
	call	gtk_box_pack_start

	mov		rdi,szOK
	call	gtk_button_new_with_label
	mov		[button1],rax

	mov		rdi,[button1]
	mov		rsi,70
	mov		rdx,30	
	call	gtk_widget_set_size_request

	mov		rdi,szApply
	call	gtk_button_new_with_label
	mov		[button2],rax
	
	mov		rdi,[button2]
	mov		rsi,70
	mov		rdx,30	
	call	gtk_widget_set_size_request

	mov		rdi,[hbox]
	mov		rsi,[button1]
	mov		rdx,FALSE
	mov		rcx,FALSE
	mov		r8,5
	call	gtk_box_pack_start

	mov		rdi,[hbox]
	mov		rsi,[button2]
	mov		rdx,FALSE
	mov		rcx,FALSE
	mov		r8,0
	call	gtk_box_pack_start
		
	pxor	xmm0,xmm0
	mov		r14,FLOAT1
	movq	xmm1,r14
	movq	xmm2,r14
	pxor	xmm3,xmm3
	call	gtk_alignment_new
	mov		[balign],rax
	
	call	gtk_statusbar_new
	mov		[statusbar],rax
	
	mov		rdi,[balign]
	mov		rsi,[statusbar]
	call	gtk_container_add

	mov		rdi,[vbox]
	mov		rsi,[balign]
	mov		rdx,FALSE
	mov		rcx,FALSE
	mov		r8,0
	call	gtk_box_pack_start

	mov		rdi,[button1]
	mov		rsi,szClicked
	mov		rdx,button_pressed
	mov		rcx,[statusbar]
	xor		r8,r8
	xor		r9,r9
	call	g_signal_connect_data

	mov		rdi,[button2]
	mov		rsi,szClicked
	mov		rdx,button_pressed
	mov		rcx,[statusbar]
	xor		r8,r8
	xor		r9,r9
	call	g_signal_connect_data

	mov		rdi,[window]
	mov		rsi,szDestroy
	mov		rdx,gtk_main_quit
	xor		rcx,rcx
	xor		r8,r8
	xor		r9,r9
	call	g_signal_connect_data

	mov		rdi,[window]
	call	gtk_widget_show_all

	call	gtk_main

	xor		rdi, rdi
	call    exit
     
button_pressed:
	push	rbp
	mov		rbp,rsp
	
	mov		[widget],rdi
	mov		[win],rsi
	mov		rdi,[widget]
	call	gtk_button_get_label
	mov		rsi,rax
	mov		rdi,szMask
	call	g_strdup_printf
	mov		[str],rax

	mov		rdi,[win]
	mov		rsi,[str]
	call	gtk_statusbar_get_context_id
	mov		rsi,rax
	mov 	rdi,[win]
	mov		rdx,[str]
	call	gtk_statusbar_push
	mov		rdi,[str]
	call	g_free
	
	mov		rsp,rbp
	pop		rbp
	ret
