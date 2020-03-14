; Name        : entersignal.asm
;
; Build       : nasm -felf64 -o entersignal.o -l entersignal.lst entersignal.asm
;               ld -s -m elf_x86_64 entersignal.o -o entersignal -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 `pkg-config --libs gtk+-2.0`
;
; Description : onenter and onleave signals and events example
;
; Remark:
; The original source intends to change the background color of the widget, in GTK+3.0 this have to be done with a css style approach.
; I've added this to be complete in this example.
;
; C - source : http://zetcode.com/tutorials/gtktutorial/gtkevents/
;              The text on the website mentions that the button color should change but I wasn't able to fix that. In the source and in this
;              program it doesn't work.  Got something to do with event boxes....

bits 64

[list -]
     extern    exit
     extern    gtk_button_new_with_label
     extern    gtk_container_add
     extern    gtk_fixed_new
     extern    gtk_fixed_put
     extern    gtk_init
     extern    gtk_main
     extern    gtk_main_quit
     extern    gtk_widget_modify_bg
     extern    gtk_widget_set_size_request
     extern    gtk_widget_show_all
     extern    gtk_window_new
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_window_set_title
     extern    g_signal_connect_data
     
     %define   GTK_WIN_POS_CENTER                 1
     %define   GTK_WINDOW_TOPLEVEL                0
     %define   NULL                               0
[list +]

struc GdkColor
     .pixel:   resd      1
     .red:     resw      1
     .green:   resw      1
     .blue:    resw      1
endstruc

section .data

color:
istruc GdkColor
     at GdkColor.pixel,  dd   0
     at GdkColor.red,    dw   65535
     at GdkColor.green,  dw   0
     at GdkColor.blue,   dw   0
iend

     window:
     .handle:       dq   0
     .title:        db   "enter signal", 0
     
     fixed:
     .handle:  dq   0
     
     button:
     .handle:  dq   0
     .label:   db   "Button", 0
     
     signal:
     .enter:   db   "enter-notify-event", 0
     .destroy: db   "destroy", 0
     
     message:
     .clicked: db   "Clicked", 10, 0
               
     display:
     .handle:  dq   0
     
     screen:
     .handle:  dq   0

section .text
     global _start
     
_start:

     xor       rdi, rdi                      ; no commandline arguments will be passed
     xor       rsi, rsi
     call      gtk_init

     mov       rdi, GTK_WINDOW_TOPLEVEL
     call      gtk_window_new
     mov       qword[window.handle], rax
     
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
     
     call      gtk_fixed_new
     mov       qword[fixed.handle], rax
     
     mov       rsi, qword[fixed.handle]
     mov       rdi, qword[window.handle]
     call      gtk_container_add

     mov       rdi, button.label
     call      gtk_button_new_with_label
     mov       qword[button.handle], rax
     
     mov       rdx, 35
     mov       rsi, 80
     mov       rdi, qword[button.handle]
     call      gtk_widget_set_size_request
     
     mov       rcx, 50
     mov       rdx, 50
     mov       rsi, qword[button.handle]
     mov       rdi, qword[fixed.handle]
     call      gtk_fixed_put
         
     xor       r9d, r9d
     xor       r8d, r8d
     mov       rcx, NULL
     mov       rdx, onenter
     mov       rsi, signal.enter
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

onenter:
; this event occurs when you hover over the button with the mousepointer
; parameters are passed in rdi, rsi
     ; change the textcolor of the button
     mov       rdx, color
     mov       rsi, 0       ;GTK_STATE_FLAG_NORMAL
     
     ; rdi has already the widget
     call      gtk_widget_modify_bg
     ret