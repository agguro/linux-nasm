; Name        : dragndrop
; Build       : see makefile
; Run         : ./dragndrop
; Description : drag and drop demo

; for this program to link you need sudo apt-get install gtk+-3.0-dev
; this will install libgtk3-dev and a lot more development libraries.

; when copying the linked application to another location you need to copy the image file 'logo.png' with it in the same directory.
; If you want to change the logo.png file with another picture, just overwrite the logo.png file with the new picture.
;
; C - source : http://zetcode.com/tutorials/gtktutorial/gtkevents/

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
     
     fixed:
     .handle:  dq   0
     
     button:
     .handle:  dq   0
     .label:   db   "Click", 0
     
     signal:
     .buttonpressevent:  db   "button-press-event", 0
     .destroy:           db   "destroy", 0
     
     message:
     .clicked: db   "Clicked", 10, 0
     
     format:
     .type:         db   "type         = %d", 10, 0
     .window:       db   "window       = %p", 10, 0
     .send_event:   db   "send_event   = %d", 10, 0
     .time:         db   "time         = %d", 10, 0
     .x:            db   "x            = %f", 10, 0
     .y:            db   "y            = %f", 10, 0
     .axes:         db   "axes         = %p", 10, 0
     .state:        db   "state        = %d", 10, 0
     .button:       db   "mouse button = %d", 10, 0
     .device:       db   "device       = %p", 10,  0
     .x_root:       db   "x_root       = %f", 10, 0
     .y_root:       db   "y_root       = %f", 10, 0
     .event:        db   "event        = %p", 10
                    db   "--------------------------", 10, 0
      
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
     
     mov       r13, rdi
     mov       r14, rsi
     mov       r15, rdx
     
         mov       rsi, qword[r14+GdkEventButton.type]
     mov       rdi, format.type
     xor       rax, rax
     call      g_print
     
     mov       rsi, qword[r14+GdkEventButton.window]
     mov       rdi, format.window
     xor       rax, rax
     call      g_print
     
     mov       esi, dword[r14+GdkEventButton.send_event]
     mov       rdi, format.send_event
     xor       rax, rax
     call      g_print
     
     mov       esi, dword[r14+GdkEventButton.time]
     mov       rdi, format.time
     xor       rax, rax
     call      g_print
     
     sub       rsp, 8
     movq      xmm0, qword[r14+GdkEventButton.x]
     mov       rdi, format.x
     mov       rax, 1
     call      g_print
    
     movq      xmm0, qword[r14+GdkEventButton.y]
     mov       rdi, format.y
     mov       rax, 1
     call      g_print
     add       rsp, 8
     
     mov       rsi, qword[r14+GdkEventButton.axes]
     mov       rdi, format.axes
     xor       rax, rax
     call      g_print
  
     mov       esi, dword[r14+GdkEventButton.state]
     mov       rdi, format.state
     xor       rax, rax
     call      g_print
  
     mov       esi, dword[r14+GdkEventButton.button]
     mov       rdi, format.button
     xor       rax, rax
     call      g_print
     
     mov       rsi, qword[r14+GdkEventButton.device]
     mov       rdi, format.device
     xor       rax, rax
     call      g_print
  
     sub       rsp, 8
     movq      xmm0, qword[r14+GdkEventButton.x_root]
     mov       rdi, format.x_root
     mov       rax, 1
     call      g_print
    
     movq      xmm0, qword[r14+GdkEventButton.y_root]
     mov       rdi, format.y_root
     mov       rax, 1
     call      g_print
     add       rsp, 8
     
     mov       rax, rsi
     mov       rsi, r14
     mov       rdi, format.event
     xor       rax, rax
     call      g_print
     
     mov       rax, qword[r14+GdkEventButton.type]
     cmp       rax, GDK_BUTTON_PRESS
     jne       .exit                                        ; exit if no mouse button pressed
     mov       eax, dword[r14+GdkEventButton.button]
     cmp       eax, LEFT_MOUSE_BUTTON                                                              ; 
     jne       .rightmousebutton                            ; no left mouse button, check right mouse button
     ; start dragging
     
     mov       rdi, r13
     call      gtk_widget_get_toplevel
     mov       rdi, rax                                     ; store toplevel widget
     mov       esi, dword[r14+GdkEventButton.button]
     movq      xmm0, qword[r14+GdkEventButton.x_root]
     cvttsd2si edx, xmm0
     movq      xmm0, qword[r14+GdkEventButton.y_root]
     cvttsd2si ecx, xmm0
     mov       r8d, dword[r14+GdkEventButton.time]
     call      gtk_window_begin_move_drag
.rightmousebutton:
     cmp       eax, RIGHT_MOUSE_BUTTON                                                              ; 
     jne       .exit                                        ; exit if not rightmousebutton
     call      gtk_main_quit                                ; quit application
     
.exit:
     ret