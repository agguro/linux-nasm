; Name        : image.asm
;
; Build       : nasm -felf64 -o image.o -l image.lst image.asm
;               ld -s -m elf_x86_64 image.o -o image -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
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
     %define   GTK_FILL                  4
     %define   GTK_EXPAND                1
     %define   GTK_SHRINK                2

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
     extern    gtk_label_new
     extern    gtk_table_attach
     extern    gtk_table_new
     extern    gtk_entry_new
     extern		gtk_image_new_from_file
     
[list +]

section .data
	window:			dq	0
	image:			dq	0
	szDestroy:		db	"destroy",0
	szTitle:		db	"Red Rock",0
	szImageFile:	db	"./redrock.jpg",0
	
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
	mov		rsi,GTK_WIN_POS_CENTER
	call	gtk_window_set_position

	mov		rdi,[window]
	mov		rsi,szTitle
	call	gtk_window_set_title

	mov		rdi,szImageFile
	call	gtk_image_new_from_file
	mov		[image],rax 

	mov		rdi,[window]
	mov		rsi,[image]
	call	gtk_container_add
	
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
