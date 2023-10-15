; Name        : gtkframe.asm
;
; Build       : nasm -felf64 -o gtkframe.o -l gtkframe.lst gtkframe.asm
;               ld -s -m elf_x86_64 gtkframe.o -o gtkframe -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : Gtk widgets examples
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/


bits 64

[list -]
     
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
     %define   TRUE                               1
     %define   GTK_SHADOW_IN                      0
     %define   GTK_SHADOW_OUT                     2
     %define   GTK_SHADOW_ETCHED_IN               3
     %define   GTK_SHADOW_ETCHED_OUT              4
          
     extern    exit
     extern	gtk_container_set_border_width
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
     extern    gtk_fixed_new
     extern    gtk_fixed_put
     extern    gtk_frame_new
     extern    gtk_frame_set_shadow_type
     extern    gtk_table_new
     extern    gtk_table_attach_defaults
     extern    gtk_table_set_col_spacings
     extern    gtk_table_set_row_spacings
	extern	gtk_label_set_justify
	extern	gtk_label_new
%define GTK_JUSTIFY_CENTER	2
[list +]

section .data
	label:	dq	0
	window:	dq	0
	title:	db	"no sleep",0
	text:	incbin	"poem.txt"
			db	0
	szDestroy:	db	"destroy",0
	
section .text
     global _start

_start:
     ; Folowing code generates a window, shows it and can be closed. It has an application icon set
     ; and will be used for all GtkWidget demonstrations
     xor       rsi, rsi                  ; argv
     xor       rdi, rdi                  ; argc
     call      gtk_init

     ; the main window
     xor       rdi, rdi                                  ; GTK_WINDOW_TOPLEVEL = 0 in RDI
     call      gtk_window_new
     mov       r13, rax                                  ; pointer to window in R15
	 
	 mov       rdi, r13                                  ; pointer to window in RDI
     mov       rsi, GTK_WIN_POS_CENTER
     call      gtk_window_set_position

     mov       rdi, r13                                  ; pointer to window in RDI
     mov       rsi, title
     call      gtk_window_set_title
     
	mov		rdi,r13
	mov		rsi,15
	call	gtk_container_set_border_width
  
	mov		rdi,text
	call	gtk_label_new
	mov		r14,rax
	
	mov		rdi,r14
	mov		rsi,GTK_JUSTIFY_CENTER
	call	gtk_label_set_justify
	
	mov		rdi,r13
	mov		rsi,r14
	call	gtk_container_add

	
     xor       r9d, r9d                        ; combination of GConnectFlags
     xor       r8d, r8d                        ; a GClosureNotify for data
     mov       rcx, r13                        ; pointer to window instance in RCX
     mov       rdx, gtk_main_quit              ; pointer to the handler
     mov       rsi, szDestroy             ; pointer to the signal
     mov       rdi, r13                        ; pointer to window instance in RDI
     call      g_signal_connect_data           ; the value in RAX is the handler, but we don't store it now

     mov       rdi, r13                                     ; pointer to window instance in RDI
     call      gtk_widget_show_all

     call      gtk_main
Exit:
     xor       rdi, rdi
     call      exit
