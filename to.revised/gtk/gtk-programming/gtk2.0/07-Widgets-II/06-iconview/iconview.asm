; Name        : gtkiconview.asm
;
; Build       : nasm -felf64 -o gtkiconview.o -l gtkiconview.lst gtkiconview.asm
;               ld -s -m elf_x86_64 gtkiconview.o -o gtkiconview -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : Gtk widgets examples
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/


bits 64

[list -]
    
     extern    exit
     extern    gtk_init
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
     extern    gtk_box_new
     extern    gtk_box_pack_start
     extern    gtk_button_new_with_label
     extern    gtk_fixed_new
     extern    gtk_fixed_put
     extern    gtk_widget_set_size_request
     extern    gtk_scrolled_window_new
     extern    gtk_scrolled_window_set_policy
     extern    gtk_scrolled_window_set_shadow_type
     extern    gtk_icon_view_new_with_model
     extern    gtk_icon_view_set_text_column
     extern    gtk_icon_view_set_pixbuf_column
     extern    gtk_icon_view_set_selection_mode
     extern    gdk_pixbuf_get_type
     extern    gtk_list_store_new
     extern    gtk_list_store_append
     extern    gtk_list_store_set
     extern    g_object_unref

	%define		GTK_WINDOW_TOPLEVEL		0
	%define		GTK_WIN_POS_CENTER		1
	%define		TRUE					1
	%define		FALSE					0
	%define		COL_DISPLAY_NAME		0
	%define		COL_PIXBUF				1
	%define		NUM_COLS				2
	%define		GTK_POLICY_AUTOMATIC	0
	%define		GTK_SHADOW_IN			1
	%define		GTK_SELECTION_MULTIPLE	2
[list +]

section .data
	window:				dq	0
	icon_view:			dq	0
	sw:					dq	0
	list_store:			dq	0
	p1:					dq	0
	p2:					dq	0
	p3:					dq	0
	p4:					dq	0
	iter:				dq	0
	err:				dq	0
	szIconView:			db "IconView",0
	szDestroy:			db "destroy",0
	szFileUbuntu:		db	"ubuntu.png",0
	szFileGnumeric:		db	"gnumeric.png",0
	szFileBlender:		db	"blender.png",0
	szFileInkscape:		db	"inkscape.png",0
	szDispNameUbuntu:	db	"Ubuntu",0
	szDispNameGnumeric:	db	"Gnumeric",0
	szDispNameBlender:	db	"Blender",0
	szDispNameInkscape:	db	"Inkscape",0

section .text
     global _start

_start:
	xor		rdi,rdi
	xor		rsi,rsi
	call	gtk_init

	mov		rdi,GTK_WINDOW_TOPLEVEL
	call	gtk_window_new
	mov		[window],rax
	
	mov		rdi,[window]
	mov		rsi,szIconView
	call	gtk_window_set_title

	mov		rdi,[window]
	mov		rsi,GTK_WIN_POS_CENTER
	call	gtk_window_set_position
	
	mov		rdi,[window]
	mov		rsi,10
	call	gtk_container_set_border_width
	
	mov		rdi,[window]
	mov		rsi,350
	mov		rdx,300
	call	gtk_window_set_default_size

	xor		rdi,rdi
	xor		rsi,rsi
	call	gtk_scrolled_window_new
	mov		[sw],rax 
	  
	mov		rdi,[window]
	mov		rsi,[sw]
	call	gtk_container_add
	
	mov		rdi,[sw]
	mov		rsi,GTK_POLICY_AUTOMATIC
	mov		rdx,GTK_POLICY_AUTOMATIC
	call	gtk_scrolled_window_set_policy
	
	mov		rdi,[sw]
	mov		rsi,GTK_SHADOW_IN
	call	gtk_scrolled_window_set_shadow_type

	call	init_model
	mov		rdi,rax
	call	gtk_icon_view_new_with_model
	mov		[icon_view],rax 
	
	mov		rdi,[sw]
	mov		rsi,[icon_view]
	call	gtk_container_add

	mov		rdi,[icon_view]
	mov		rsi,COL_DISPLAY_NAME
	call	gtk_icon_view_set_text_column
	
	mov		rdi,[icon_view]
	mov		rsi,COL_PIXBUF
	call	gtk_icon_view_set_pixbuf_column
	
	mov		rdi,[icon_view]
	mov		rsi,GTK_SELECTION_MULTIPLE
	call	gtk_icon_view_set_selection_mode

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

	xor		rdi,rdi
	call	exit


init_model:
	push rbp
	mov	rbp, rsp

	mov	QWORD [err], 0

	mov	rsi, err
	mov	rdi, szFileBlender
	call gdk_pixbuf_new_from_file
	mov	QWORD [p1],rax

	mov	rsi, err
	mov	rdi, szFileGnumeric
	call gdk_pixbuf_new_from_file
	mov	QWORD [p2],rax

	mov	rsi, err
	mov	rdi, szFileInkscape
	call gdk_pixbuf_new_from_file
	mov	QWORD [p3],rax

	mov	rsi, err
	mov	rdi, szFileUbuntu
	call gdk_pixbuf_new_from_file
	mov	QWORD [p4],rax

	call gdk_pixbuf_get_type
	mov	rdx, rax
	mov	esi, 64
	mov	edi, 2
	mov	eax, 0
	call gtk_list_store_new
	mov	QWORD [list_store], rax
	
	mov	rsi, iter
	mov	rdi, QWORD [list_store]
	call gtk_list_store_append

	sub	rsp, 8
	push	-1
	mov	r9, QWORD [p1]
	mov	r8d, 1
	mov	rcx, szDispNameBlender
	mov	edx, 0
	mov	rsi, iter
	mov	rdi, QWORD [list_store]
	mov	eax, 0
	call	gtk_list_store_set
	add	rsp, 16

	mov	rdi, QWORD [p1]
	call	g_object_unref
	
	mov	rsi, iter
	mov	rdi, QWORD [list_store]
	call gtk_list_store_append

	sub	rsp, 8
	push	-1
	mov	r9, QWORD [p2]
	mov	r8d, 1
	mov	rcx, szDispNameGnumeric
	mov	edx, 0
	mov	rsi, iter
	mov	rdi, QWORD [list_store]
	mov	eax, 0
	call	gtk_list_store_set
	add	rsp, 16

	mov	rdi, QWORD [p2]
	call	g_object_unref

	mov	rsi, iter
	mov	rdi, QWORD [list_store]
	call gtk_list_store_append

	sub	rsp, 8
	push	-1
	mov	r9, QWORD [p3]
	mov	r8d, 1
	mov	rcx, szDispNameInkscape
	mov	edx, 0
	mov	rsi, iter
	mov	rdi, QWORD [list_store]
	mov	eax, 0
	call	gtk_list_store_set
	add	rsp, 16

	mov	rdi, QWORD [p3]
	call	g_object_unref

	mov	rsi, iter
	mov	rdi, QWORD [list_store]
	call gtk_list_store_append

	sub	rsp, 8
	push	-1
	mov	r9, QWORD [p4]
	mov	r8d, 1
	mov	rcx, szDispNameUbuntu
	mov	edx, 0
	mov	rsi, iter
	mov	rdi, QWORD [list_store]
	mov	eax, 0
	call	gtk_list_store_set
	add	rsp, 16

	mov	rdi, QWORD [p4]
	call	g_object_unref
	
	mov		rax,[list_store]
	leave
	ret
