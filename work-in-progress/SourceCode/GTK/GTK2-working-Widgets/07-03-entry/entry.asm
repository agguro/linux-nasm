; Name        : gtkentry.asm
;
; Build       : nasm -felf64 -o gtkentry.o -l gtkentry.lst gtkentry.asm
;               ld -s -m elf_x86_64 gtkentry.o -o gtkentry -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
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
[list +]

section .data
	window:			dq	0
	table:			dq	0
	label1:			dq	0
	label2:			dq	0
	label3:			dq	0
	entry1:			dq	0
	entry2:			dq	0
	entry3:			dq	0
	szDestroy:		db	"destroy",0
	szGtkEntry:		db	"GtkEntry",0
	szName:			db	"Name",0
	szAge:			db	"Age",0
	szOccupation:	db	"Occupation",0

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
	mov		rsi,szGtkEntry
	call	gtk_window_set_title
  
	mov		rdi,[window]
	mov		rsi,10
	call	gtk_container_set_border_width

	mov		rdi,3
	mov		rsi,2
	mov		rdx,FALSE
	call	gtk_table_new
	mov		[table],rax
  
	mov		rdi,[window]
	mov		rsi,[table]
	call	gtk_container_add

	mov		rdi,szName
	call	gtk_label_new
	mov		[label1],rax
	mov		rdi,szAge
	call	gtk_label_new
	mov		[label2],rax
	mov		rdi,szOccupation
	call	gtk_label_new
	mov		[label3],rax

	mov		rdi,[table]
	mov		rsi,[label1]
	mov		rdx,0
	mov		rcx,1
	mov		r8,0
	mov		r9,1
	push	5
	push	5
	push	GTK_FILL | GTK_SHRINK
	push	GTK_FILL | GTK_SHRINK
	call	gtk_table_attach
	
	mov		rdi,[table]
	mov		rsi,[label2]
	mov		rdx,0
	mov		rcx,1
	mov		r8,1
	mov		r9,2
	push	5
	push	5
	push	GTK_FILL | GTK_SHRINK
	push	GTK_FILL | GTK_SHRINK
	call	gtk_table_attach

	mov		rdi,[table]
	mov		rsi,[label3]
	mov		rdx,0
	mov		rcx,1
	mov		r8,2
	mov		r9,3
	push	5
	push	5
	push	GTK_FILL | GTK_SHRINK
	push	GTK_FILL | GTK_SHRINK
	call	gtk_table_attach

	call	gtk_entry_new
	mov		[entry1],rax
	call	gtk_entry_new
	mov		[entry2],rax
	call	gtk_entry_new
	mov		[entry3],rax

	mov		rdi,[table]
	mov		rsi,[entry1]
	mov		rdx,1
	mov		rcx,2
	mov		r8,0
	mov		r9,1
	push	5
	push	5
	push	GTK_FILL | GTK_SHRINK
	push	GTK_FILL | GTK_SHRINK
	call	gtk_table_attach
  
	mov		rdi,[table]
	mov		rsi,[entry2]
	mov		rdx,1
	mov		rcx,2
	mov		r8,1
	mov		r9,2
	push	5
	push	5
	push	GTK_FILL | GTK_SHRINK
	push	GTK_FILL | GTK_SHRINK
	call	gtk_table_attach

	mov		rdi,[table]
	mov		rsi,[entry3]
	mov		rdx,1
	mov		rcx,2
	mov		r8,2
	mov		r9,3
	push	5
	push	5
	push	GTK_FILL | GTK_SHRINK
	push	GTK_FILL | GTK_SHRINK
	call	gtk_table_attach

	mov		rdi,[window]
	call	gtk_widget_show_all

	mov		rdi,[window]
	mov		rsi,szDestroy
	mov		rdx,gtk_main_quit
	xor		rcx,rcx
	xor		r8,r8
	xor		r9,r9
	call	g_signal_connect_data

	call	gtk_main

	xor		rdi,rdi
	call	exit
