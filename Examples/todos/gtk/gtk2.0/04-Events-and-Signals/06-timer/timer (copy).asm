; Name        : timer.asm
;
; Build       : nasm -felf64 -o timer.o -l timer.lst timer.asm
;               ld -s -m elf_x86_64 aboutbox.o -o aboutbox -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 `pkg-config --libs gtk+-2.0`
;
; Description : a timer demo
;
; C - source : http://zetcode.com/tutorials/gtktutorial/gtkevents/

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
     extern    gtk_widget_set_size_request
     extern    gtk_widget_show_all
     extern    gtk_window_new
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_window_set_title
     extern    g_print
     extern    g_signal_connect_data
     extern    gtk_check_button_new_with_label
     extern    gtk_toggle_button_get_active
     extern    gtk_toggle_button_set_active
     extern    g_signal_handler_disconnect
     extern    g_timeout_add
     extern    gtk_widget_set_title
     
     %define   GTK_WIN_POS_CENTER       1
     %define   GTK_WINDOW_TOPLEVEL      0
     %define   NULL                     0
     %define   TRUE                     1
     %define   FALSE                    0
     
[list +]

section .data

     window:
     .handle:  dq   0
     .title:   db   "timer inactive", 0
     
     fixed:
     .handle:  dq   0
     
     checkbox:
     .handle:  dq   0
     .label:   db   "toggle timer", 0
     
     signal:
     .clicked: db   "clicked", 0
     .destroy: db   "destroy", 0
     
     message:       db   "timer active", 10, 0
     active:        db   "timer active", 0
     inactive:      db   "timer inactive", 0
     
     handler:
     .id:      dq   0
     
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
     mov       rsi, 250
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
        
     mov       rdi, checkbox.label
     call      gtk_check_button_new_with_label
     mov       qword[checkbox.handle], rax
     
     mov       rsi, FALSE
     mov       rdi, qword[checkbox.handle]
     call      gtk_toggle_button_set_active
     
     mov       rcx, 50
     mov       rdx, 130
     mov       rsi, qword[checkbox.handle]
     mov       rdi, qword[fixed.handle]
     call      gtk_fixed_put
     
     xor       r9d, r9d
     xor       r8d, r8d     
     mov       rcx, 0
     mov       rdx, toggle_signal
     mov       rsi, signal.clicked
     mov       rdi, qword[checkbox.handle]
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

     mov       rdi, 1000
     mov       rsi, timer_handler
     mov       rdx, qword[window]
     call      g_timeout_add
     
     mov       rdi, qword[window.handle]
     call      gtk_widget_show_all

     call      timer_handler
     call      gtk_main
     
     xor       rdi, rdi
     call      exit
     
timer_handler:
     mov       rdi, qword[checkbox.handle]
     call      gtk_toggle_button_get_active
     cmp       rax, TRUE
     jnz       .disconnect
     mov       rdi, message
     xor       rax, rax
     call      g_print
.disconnect:     
     mov       rax, TRUE
     ret

toggle_signal:
     ; RDI has GtkWidget *widget
     ; RSI has gpointer window
     call      gtk_toggle_button_get_active
     and       rax, rax
     jz        .disconnect
.connect:
     mov       rsi, active
     mov       rdi, qword[window]
     call      gtk_window_set_title
     ret
.disconnect:
     mov       rsi, inactive
     mov       rdi, qword[window]
     call      gtk_window_set_title
     ret     
