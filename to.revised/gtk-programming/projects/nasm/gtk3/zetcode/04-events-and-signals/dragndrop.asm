; Name        : dragndrop.asm
;
; Build       : nasm -felf64 -o dragndrop.o -l dragndrop.lst dragndrop.asm
;               ld -s -m elf_x86_64 dragndrop.o -o dragndrop -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3 -lpango-1.0
;
; Description : drag and drop demo
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkevents/

bits 64

[list -]
     extern    exit
     extern    gtk_button_new_with_label
     extern    gtk_init
     extern    gtk_main
     extern    gtk_main_quit
     extern    gtk_widget_show_all
     extern    gtk_window_new
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_window_set_title
     extern    gtk_widget_add_events
     extern    gtk_window_set_decorated
     extern    g_signal_connect_data
     extern    g_print
     extern    gtk_window_begin_move_drag
     extern    gtk_widget_get_toplevel
     
     %define   GTK_WIN_POS_CENTER       1
     %define   GTK_WINDOW_TOPLEVEL      0
     %define   NULL                     0
     %define   TRUE                     1
     %define   FALSE                    0
     %define   GDK_BUTTON_PRESS_MASK    256
     %define   GDK_BUTTON_PRESS         4
     %define   LEFT_MOUSE_BUTTON        1
     %define   MIDDLE_MOUSE_BUTTON      2
     %define   RIGHT_MOUSE_BUTTON       3
     
[list +]

     struc GdkEventButton
          .type:          resq      1
          .window:        resq      1
          .send_event:    resd      1
          .time:          resd      1
          .x:             resq      1
          .y:             resq      1
          .axes:          resq      1
          .state:         resd      1
          .button:        resd      1
          .device:        resq      1
          .x_root:        resq      1
          .y_root:        resq      1
     endstruc

section .data

event:    istruc GdkEventButton
          at GdkEventButton.type,            dq   0
          at GdkEventButton.window,          dq   0
          at GdkEventButton.send_event,      dd   0
          at GdkEventButton.time,            dd   0
          at GdkEventButton.x,               dq   0
          at GdkEventButton.y,               dq   0
          at GdkEventButton.axes,            dq   0
          at GdkEventButton.state,           dd   0
          at GdkEventButton.button,          dd   0
          at GdkEventButton.device,          dq   0
          at GdkEventButton.x_root,          dq   0
          at GdkEventButton.y_root,          dq   0
     iend

     window:
     .handle:  dq   0
     .title:   db   "Drag and Drop", 0
         
     signal:
     .buttonpressevent:  db   "button-press-event", 0
     .destroy:           db   "destroy", 0   
      
section .text
     global _start
     
_start:

     xor       rdi, rdi                      ; no commandline arguments will be passed
     xor       rsi, rsi
     call      gtk_init

     mov       rdi, GTK_WINDOW_TOPLEVEL
     call      gtk_window_new
     mov       qword[window.handle], rax
     
     mov       rdx, GTK_WIN_POS_CENTER
     mov       rsi, GTK_WIN_POS_CENTER
     mov       rdi, qword[window.handle]
     call      gtk_window_set_position

     mov       rdx, 150
     mov       rsi, 230
     mov       rdi, qword[window.handle]
     call      gtk_window_set_default_size

     mov       rsi, window.title
     mov       rdi, qword[window.handle]
     call      gtk_window_set_title
     
     mov       rsi, FALSE
     mov       rdi, qword[window.handle]
     call      gtk_window_set_decorated
     
     mov       rsi, GDK_BUTTON_PRESS_MASK
     mov       rdi, qword[window.handle]
     call      gtk_widget_add_events
         
     xor       r9d, r9d
     xor       r8d, r8d
     mov       rcx, NULL
     mov       rdx, onbuttonpress
     mov       rsi, signal.buttonpressevent
     mov       rdi, qword[window.handle]
     call      g_signal_connect_data

     xor       r9d, r9d
     xor       r8d, r8d
     mov       rcx, NULL
     mov       rdx, gtk_main_quit
     mov       rsi, signal.destroy
     mov       rdi, qword[window.handle]
     call      g_signal_connect_data

     mov       rdi, qword[window.handle]
     call      gtk_widget_show_all

     call      gtk_main
     
     xor       rdi, rdi
     call      exit

onbuttonpress:
     ; RDI has GtkWidget *widget 
     ; RSI has GdkEventButton *event
     ; RDX has GdkWindowEdge edge
     push      rbp
     mov       rbp, rsp
    
     mov       r9, rsi
     mov       r8, rdi
     
     mov       rax, qword[r9+GdkEventButton.type]
     cmp       rax, GDK_BUTTON_PRESS
     jne       .exit                                        ; exit if no mouse button pressed
     
     mov       eax, dword[r9+GdkEventButton.button]
     cmp       eax, LEFT_MOUSE_BUTTON                                                              ; 
     jne       .exit
     
.startdragging:
     mov       rdi, r8
     call      gtk_widget_get_toplevel   
     mov       rdi, rax                                     ; store toplevel widget
     mov       esi, dword[r9+GdkEventButton.button]         ; event->button
     movq      xmm0, qword[r9+GdkEventButton.x_root]
     cvttsd2si edx, xmm0                                    ; event->x_root
     movq      xmm0, qword[r9+GdkEventButton.y_root]
     cvttsd2si ecx, xmm0                                    ; event->y_root
     mov       r8d, dword[r9+GdkEventButton.time]           ; event->time
     call      gtk_window_begin_move_drag     
.exit:
     mov    rax, TRUE
     pop    rbp
     ret
