; Name        : gtkcombobox.asm
;
; Build       : nasm -felf64 -o gtkcombobox.o -l gtkcombobox.lst gtkcombobox.asm
;               ld -s -m elf_x86_64 gtkcombobox.o -o gtkcombobox -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
;
; Description : Gtk widgets examples
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkwidgets/

bits 64

[list -]
     
     %define   GTK_WINDOW_TOPLEVEL   0
     %define   GTK_WIN_POS_CENTER    1
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
     extern    gtk_combo_box_text_append_text
     extern    gtk_combo_box_text_new
     extern    gtk_combo_box_text_get_active_text
     extern    gtk_label_new
     extern    gtk_label_set_text
[list +]

section .data
     logo:               incbin    "../logo.png"
          .size:         equ       $-logo    
     window:
          .title:        db        "GtkComboBox", 0
     signal:
          .destroy:      db        "destroy", 0
          .changed:      db        "changed", 0
     combo:
          .txt1:         db        "Ubuntu", 0
          .txt2:         db        "Mandriva", 0
          .txt3:         db        "Fedora", 0
          .txt4:         db        "Mint", 0
          .txt5:         db        "Gentoo", 0
          .txt6:         db        "Debian", 0
     label:
          .caption:      db        "here comes your choice", 0
          
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
     mov       r13, rax                                  ; pointer to loader in R13

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
     mov       rdx, 300
     call      gtk_window_set_default_size

     mov       rdi, r13                                  ; pointer to window in RDI
     mov       rsi, GTK_WIN_POS_CENTER
     call      gtk_window_set_position

     mov       rdi, r13                                  ; pointer to window instance in RDI
     mov       rsi, r14                                  ; pointer to pixbuffer instance in RSI
     call      gtk_window_set_icon

     xor       r9d, r9d                                  ; combination of GConnectFlags
     xor       r8d, r8d                                  ; a GClosureNotify for data
     mov       rcx, r13                                  ; pointer to window instance in RCX
     mov       rdx, gtk_main_quit                        ; pointer to the handler
     mov       rsi, signal.destroy                       ; pointer to the signal
     mov       rdi, r13                                  ; pointer to window instance in RDI
     call      g_signal_connect_data                     ; the value in RAX is the handler, but we don't store it now

     ; r13 has the pointer to the window, do not use anymore
     call      gtk_fixed_new
     mov       r14, rax                                  ; pointer to fixed in R14
     
     call      gtk_combo_box_text_new
     mov       r12, rax                                  ; pointer to combobox in r12
     
     mov       rdi, r12
     mov       rsi, combo.txt1
     call      gtk_combo_box_text_append_text
     mov       rdi, r12
     mov       rsi, combo.txt2
     call      gtk_combo_box_text_append_text
     mov       rdi, r12
     mov       rsi, combo.txt3
     call      gtk_combo_box_text_append_text
     mov       rdi, r12
     mov       rsi, combo.txt4
     call      gtk_combo_box_text_append_text
     mov       rdi, r12
     mov       rsi, combo.txt5
     call      gtk_combo_box_text_append_text
     mov       rdi, r12
     mov       rsi, combo.txt6
     call      gtk_combo_box_text_append_text

     mov       rdi, r14
     mov       rsi, r12
     mov       rdx, 50                                   ; position of combobox (x)
     mov       rcx, 50                                   ; position of combobox (y)
     call      gtk_fixed_put
     
     mov       rdi, r13
     mov       rsi, r14
     call      gtk_container_add

     ; R15 may be overridden by new value
     mov       rdi, label.caption
     call      gtk_label_new
     mov       r15, rax
     
     mov       rsi, rax
     mov       rdi, r14
     mov       rdx, 150                                  ; position of label (x)
     mov       rcx, 110                                  ; position of label (y)
     call      gtk_fixed_put

     xor       r9d, r9d                                  ; combination of GConnectFlags
     xor       r8d, r8d                                  ; a GClosureNotify for data
     mov       rcx, r15                                  ; pointer to label instance in RCX
     mov       rdx, combo_select                         ; pointer to the handler
     mov       rsi, signal.changed                       ; pointer to the signal
     mov       rdi, r12                                  ; pointer to combo instance in RDI
     call      g_signal_connect_data                     ; the value in RAX is the handler, but we don't store it now
       
     mov       rdi, r13                                  ; pointer to window instance in RDI
     call      gtk_widget_show_all

     call      gtk_main
Exit:
     xor       rdi, rdi
     call      exit
     
combo_select:
     ; RDI has pointer to calling widget (combobox)
     ; RSI has pointer to label
     push      rbp
     mov       rbp, rsp
     mov       r15, rsi
     call      gtk_combo_box_text_get_active_text
     mov       rdi, r15
     mov       rsi, rax
     call      gtk_label_set_text
     leave
     ret
