; Name        : buttonclick.asm
;
; Build       : nasm -felf64 -o buttonclick.o -l buttonclick.lst buttonclick.asm
;               ld -s -m elf_x86_64 buttonclick.o -o buttonclick -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 `pkg-config --libs gtk+-3.0`
; Description : events and signals intro
;
; Remark      : run this program from a terminal
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkevents/

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
     
     %define   GTK_WIN_POS_CENTER       1
     %define   GTK_WINDOW_TOPLEVEL      0
     %define   NULL                     0
     
[list +]

section .data

     window:
     .handle:  dq   0
     .title:   db   "GtkButton", 0
     
     fixed:
     .handle:  dq   0
     
     button:
     .handle:  dq   0
     .label:   db   "Click", 0
     
     signal:
     .clicked: db   "clicked", 0
     .destroy: db   "destroy", 0
     
     message:
     .clicked: db   "Clicked", 10, 0
     
section .text
     global _start
     
_start:

     xor       rdi, rdi                      ; no commandline arguments will be passed
     xor       rsi, rsi
     call      gtk_init

     mov       rdi, GTK_WINDOW_TOPLEVEL
     call      gtk_window_new
     mov       qword[window.handle], rax
     
     mov       rsi, window.title
     mov       rdi, qword[window.handle]
     call      gtk_window_set_title
     
     mov       rdx, 150
     mov       rsi, 230
     mov       rdi, qword[window.handle]
     call      gtk_window_set_default_size
     
     mov       rsi, GTK_WIN_POS_CENTER
     mov       rdi, qword[window.handle]
     call      gtk_window_set_position

     call      gtk_fixed_new
     mov       qword[fixed.handle], rax
     
     mov       rsi, qword[fixed.handle]
     mov       rdi, qword[window.handle]
     call      gtk_container_add

     mov       rdi, button.label
     call      gtk_button_new_with_label
     mov       qword[button.handle], rax
     
     mov       rcx, 50
     mov       rdx, 50
     mov       rsi, qword[button.handle]
     mov       rdi, qword[fixed.handle]
     call      gtk_fixed_put
     
     mov       rdx, 35
     mov       rsi, 80
     mov       rdi, qword[button.handle]
     call      gtk_widget_set_size_request
     
     xor       r9d, r9d
     xor       r8d, r8d
     mov       rcx, NULL
     mov       rdx, button_clicked
     mov       rsi, signal.clicked
     mov       rdi, qword[button.handle]
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

button_clicked:
; parameters are passed in rdi, rsi
	push	rbp
	mov		rbp,rsp
     mov       rdi, message.clicked                ; print signal to terminal
     xor       rax, rax
     call      g_print
     mov	rsp,rbp
     pop	rbp
     ret
