; Name        : move-event.asm
;
; Build       : nasm -felf64 -o move-event.o -l move-event.lst move-event.asm
;               ld -s -m elf_x86_64 move-event.o -o move-event -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3 -lpango-1.0 -latk-1.0 -lgio-2.0
;               -lpangoft2-1.0  -lpangocairo-1.0 -lcairo -lfreetype -lfontconfig  -lgmodule-2.0 -lgthread-2.0 -lrt
;
; Description : observing window position while moving
;
; C - source : http://zetcode.com/tutorials/gtktutorial/gtkevents/

bits 64

[list -]
     extern    exit
     extern    sprintf
     extern    gtk_button_new_with_label
     extern    gtk_container_add
     extern    gtk_fixed_new
     extern    gtk_fixed_put
     extern    gtk_init
     extern    gtk_main
     extern    gtk_main_quit
     extern    gtk_widget_set_size_request
     extern    gtk_widget_show_all
     extern    gtk_widget_add_events
     extern    gtk_window_new
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_window_set_title
     extern    g_print
     extern    g_signal_connect_data
     
     %define   GTK_WIN_POS_CENTER        1
     %define   GTK_WINDOW_TOPLEVEL       0
     %define   NULL                      0
     %define   GDK_CONFIGURE            13
[list +]

struc GdkEventConfigure
     .type:          resq      1
     .window:        resq      1
     .send_event:    resd      1
     .x:             resd      1
     .y:             resd      1
     .width:         resd      1
     .height:        resd      1
endstruc

section .data

GdkEvent:
istruc GdkEventConfigure
     at GdkEventConfigure.type,            dq   0
     at GdkEventConfigure.window,          dq   0
     at GdkEventConfigure.send_event,      dd   0
     at GdkEventConfigure.x,               dd   0
     at GdkEventConfigure.y,               dd   0
     at GdkEventConfigure.width,           dd   0
     at GdkEventConfigure.height,          dd   0
iend
     
     mainwindow:
     .handle:  dq   0
     .title:   db   "Simple", 0
     
     fixed:
     .handle:  dq   0
     
     button:
     .handle:  dq   0
     .label:   db   "Click", 0
     
     signal:
     .clicked:           db   "clicked", 0
     .destroy:           db   "destroy", 0
     .configureevent:    db   "configure-event", 0
     message:
     .format:            db   "left: %d, top: %d, width: %d, height: %d", 0
     .formatsize:        equ  $-message.format+8                         ; message.formatlength + 2 bytes for each %d (dword takes 4 bytes)
     ; if the window title disappears you probably must make this buffer taller
     .buffer:            times message.formatsize db 0
     
section .text
     global _start
     
_start:

     xor       rdi, rdi                      ; no commandline arguments will be passed
     xor       rsi, rsi
     call      gtk_init

     mov       rdi, GTK_WINDOW_TOPLEVEL
     call      gtk_window_new
     mov       qword[mainwindow.handle], rax
     
     mov       rsi, mainwindow.title
     mov       rdi, qword[mainwindow.handle]
     call      gtk_window_set_title
     
     mov       rdx, 300
     mov       rsi, 500
     mov       rdi, qword[mainwindow.handle]
     call      gtk_window_set_default_size
     
     mov       rsi, GTK_WIN_POS_CENTER
     mov       rdi, qword[mainwindow.handle]
     call      gtk_window_set_position

     mov       rdi, qword[mainwindow.handle]
     mov       rsi, GDK_CONFIGURE
     call      gtk_widget_add_events

     xor       r9d, r9d
     xor       r8d, r8d
     mov       rcx, NULL
     mov       rdx, gtk_main_quit
     mov       rsi, signal.destroy
     mov       rdi, qword[mainwindow.handle]
     call      g_signal_connect_data
     
     xor       r9d, r9d
     xor       r8d, r8d
     mov       rcx, NULL
     mov       rdx, frame_callback
     mov       rsi, signal.configureevent
     mov       rdi, qword[mainwindow.handle]
     call      g_signal_connect_data

     mov       rdi, qword[mainwindow.handle]
     call      gtk_widget_show_all

     call      gtk_main
     
     xor       rdi, rdi
     call      exit
     
frame_callback:
; parameters are passed in rdi, rsi, rdx
     ; RDI = handle of calling window
     ; RSI = GdkEvent structure
     ; RDX = gpointer data
     mov       r14, rsi
     mov       r15, rdi
     mov       rax, rsi
     mov       rdi, message.buffer
     mov       rsi, message.format
     mov       r9d, dword[rax+GdkEventConfigure.height]
     mov       r8d, dword[rax+GdkEventConfigure.width]
     mov       ecx, dword[rax+GdkEventConfigure.y]
     mov       edx, dword[rax+GdkEventConfigure.x]
     xor       rax, rax
     call      sprintf                                           ; this function can be replaced by your own 
     mov       rax, r14
     mov       rdi, r15
     mov       rsi, message.buffer
     call      gtk_window_set_title
     ret
