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
     %define   GTK_SHADOW_IN                      1
     %define   GTK_SHADOW_OUT                     2
     %define   GTK_SHADOW_ETCHED_IN               3
     %define   GTK_SHADOW_ETCHED_OUT              4
          
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
     extern    gtk_fixed_new
     extern    gtk_fixed_put
     extern    gtk_frame_new
     extern    gtk_frame_set_shadow_type
     extern    gtk_table_new
     extern    gtk_table_attach_defaults
     extern    gtk_table_set_col_spacings
     extern    gtk_table_set_row_spacings

[list +]

section .data
     logo:               incbin    "../logo.png"
          .size:         equ       $-logo    
     window:
          .title:        db   "GtkFrame", 0
     signal:
          .destroy:      db   "destroy", 0
     frame1:
          .shadowtype:   dd   GTK_SHADOW_IN
          .label:        db   "Shadow In", 0
     frame2:
          .shadowtype:   dd   GTK_SHADOW_OUT
          .label:        db   "Shadow Out", 0
     frame3:
          .shadowtype:   dd   GTK_SHADOW_ETCHED_IN
          .label:        db   "Shadow Etched In", 0
     frame4:
          .shadowtype:   dd   GTK_SHADOW_ETCHED_OUT
          .label:        db   "Shadow Etched Out", 0

section .text
     global _start

_start:

     ; Folowing code generates a window, shows it and can be closed. It has an application icon set
     ; and will be used for all GtkWidget demonstrations
     xor       rsi, rsi                  ; argv
     xor       rdi, rdi                  ; argc
     call      gtk_init

     ; loading the the application icon in a buffer -> pixbuffer

     call      gdk_pixbuf_loader_new
     mov       r13, rax                                  ; pointer to loader in R15

     mov       rdi, r13
     mov       rsi, logo
     mov       edx, logo.size
     xor       rcx, rcx
     call      gdk_pixbuf_loader_write

     mov       rdi, r13
     call      gdk_pixbuf_loader_get_pixbuf
     mov       r14, rax                                  ; pointer to pixbuffer in R14

     ; the main window
     xor       rdi, rdi                                  ; GTK_WINDOW_TOPLEVEL = 0 in RDI
     call      gtk_window_new
     mov       r13, rax                                  ; pointer to window in R15

     mov       rdi, r13                                  ; pointer to window in RDI
     mov       rsi, window.title
     call      gtk_window_set_title

     mov       rdi, r13                                  ; pointer to window in RDI
     mov       rsi, 500
     mov       rdx, 400
     call      gtk_window_set_default_size

     mov       rdi, r13                                  ; pointer to window in RDI
     mov       rsi, GTK_WIN_POS_CENTER
     call      gtk_window_set_position

     mov       rdi, r13                                  ; pointer to window instance in RDI
     mov       rsi, r14                                  ; pointer to pixbuffer instance in RSI
     call      gtk_window_set_icon

     xor       r9d, r9d                        ; combination of GConnectFlags
     xor       r8d, r8d                        ; a GClosureNotify for data
     mov       rcx, r13                        ; pointer to window instance in RCX
     mov       rdx, gtk_main_quit              ; pointer to the handler
     mov       rsi, signal.destroy             ; pointer to the signal
     mov       rdi, r13                        ; pointer to window instance in RDI
     call      g_signal_connect_data           ; the value in RAX is the handler, but we don't store it now

     ; create a table and add to the window
     mov       rdi, 4                                  ; rows
     mov       rsi, rdi                                ; columns
     mov       rdx, TRUE
     call      gtk_table_new
     mov       r14, rax                                ; pointer to table in r14
     mov       rdi, r14
     mov       rsi, 10
     call      gtk_table_set_row_spacings
     mov       rdi, r14
     mov       rsi, 10
     call      gtk_table_set_col_spacings
     mov       rdi, r13                                ; pointer to window in rdi
     mov       rsi, r14                                ; pointer to table in rsi
     call      gtk_container_add
     
     ; the frames
     
     mov       rdi, frame1.label
     call      gtk_frame_new
     ; r15 holds the pointer to the new frame created
     mov       r15, rax
     mov       rdi, r15
     mov       esi, [frame1.shadowtype]
     call      gtk_frame_set_shadow_type
     
     mov       rdx, 1
     mov       rcx, 2
     mov       r8,  1
     mov       r9,  2
     mov       rdi, r14                                ; pointer to table in rdi
     mov       rsi, r15                                ; pointer to frame in rsi
     call      gtk_table_attach_defaults

     mov       rdi, frame2.label
     call      gtk_frame_new
     ; r15 holds the pointer to the new frame created
     mov       r15, rax
     mov       rdi, r15
     mov       esi, [frame2.shadowtype]
     call      gtk_frame_set_shadow_type
     
     mov       rdx, 2
     mov       rcx, 3
     mov       r8,  1
     mov       r9,  2
     mov       rdi, r14                                ; pointer to table in rdi
     mov       rsi, r15                                ; pointer to frame in rsi
     call      gtk_table_attach_defaults

     mov       rdi, frame3.label
     call      gtk_frame_new
     ; r15 holds the pointer to the new frame created
     mov       r15, rax
     mov       rdi, r15
     mov       esi, [frame3.shadowtype]
     call      gtk_frame_set_shadow_type
     
     mov       rdx, 1
     mov       rcx, 2
     mov       r8,  2
     mov       r9,  3
     mov       rdi, r14                                ; pointer to table in rdi
     mov       rsi, r15                                ; pointer to frame in rsi
     call      gtk_table_attach_defaults

     mov       rdi, frame4.label
     call      gtk_frame_new
     ; r15 holds the pointer to the new frame created
     mov       r15, rax
     mov       rdi, r15
     mov       esi, [frame4.shadowtype]
     call      gtk_frame_set_shadow_type
     
     mov       rdx, 2
     mov       rcx, 3
     mov       r8,  2
     mov       r9,  3
     mov       rdi, r14                                ; pointer to table in rdi
     mov       rsi, r15                                ; pointer to frame in rsi
     call      gtk_table_attach_defaults
     
     mov       rdi, r13                                ; pointer to window instance in RDI
     call      gtk_widget_show_all

     call      gtk_main
Exit:
     xor       rdi, rdi
     call      exit
