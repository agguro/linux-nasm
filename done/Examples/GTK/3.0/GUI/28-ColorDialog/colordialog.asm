; Name        : colordialog.asm
;
; Build       : nasm -felf64 -o colordialog.o -l colordialog.lst colordialog.asm
;               ld -s -m elf_x86_64 colordialog.o -o colordialog -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 `pkg-config --libs gtk+-2.0`
;
; Description : a color selection dialogbox
;
; C - source  : http://zetcode.com/tutorials/gtktutorial/gtkdialogs/

%define DEBUG 0                         ; 0 = no debugging

bits 64

[list -]
     %define   GTK_WINDOW_TOPLEVEL      0
     %define   GTK_WIN_POS_CENTER       1
     %define   TRUE                     1
     %define   FALSE                    0
     %define   GTK_TOOLBAR_ICONS        0
     %define   GTK_JUSTIFY_CENTER       2
     %define   GTK_RESPONSE_OK         -5
     %define   GTK_STATE_NORMAL         0
     
     extern    gtk_init
     extern    gtk_window_new
     extern    gtk_window_set_position
     extern    gtk_window_set_default_size     
     extern    gtk_window_set_title
     extern    gtk_window_set_modal
     extern    gtk_window_set_transient_for
     extern    gtk_vbox_new
     extern    gtk_container_add
     extern    gtk_toolbar_new
     extern    gtk_toolbar_set_style
     extern    gtk_container_set_border_width
     extern    gtk_tool_button_new_from_stock
     extern    gtk_toolbar_insert
     extern    gtk_box_pack_start
     extern    gtk_label_new
     extern    gtk_label_set_justify
     extern    g_signal_connect_data
     extern    gtk_main_quit
     extern    gtk_widget_show_all
     extern    gtk_main
     extern    exit
     extern    gtk_color_selection_dialog_new
     extern    gtk_dialog_run
     extern    gtk_color_selection_dialog_get_color_selection
     extern    gtk_color_selection_get_current_color
     extern    gtk_widget_modify_fg
     extern    gtk_widget_destroy
     ; debugging
%if DEBUG = 1
     extern    g_print
%endif     
     
[list +]

     struc GdkColor
          .pixel:         resd      1
          .red:           resw      1
          .green:         resw      1
          .blue:          resw      1
     endstruc

section .data
     window:
     .handle:       dq   0
     .title:        db   "Color Selection Dialog",0

     signal:
     .destroy:      db   "destroy", 0
     .clicked:      db   "clicked", 0

     label:
     .handle:       dq   0
     .caption:      db   "This is the demonstration text", 0
     
     box:
     .handle:       dq   0
     
     toolbar:
     .handle:       dq   0

     result:        dq   0
     dialog:
     .handle:       dq   0
     .title:        db   "Select Color", 0
     
     GTK_STOCK_SELECT_COLOR:  db   "gtk-select-color", 0
         
     colorsel:                dq   0
     
     color:    istruc GdkColor
          at GdkColor.pixel,            dd   0
          at GdkColor.red,              dw   0
          at GdkColor.green,            dw   0
          at GdkColor.blue,             dw   0
     iend
     
     .handle:                           dq   0
     format:  db "%d", 10, 0
     
section .text
        global _start

_start:
     xor       rsi, rsi                  ; argv
     xor       rdi, rdi                  ; argc
     call      gtk_init
    
     mov       rdi,GTK_WINDOW_TOPLEVEL
     call      gtk_window_new
     mov       qword[window], rax

     mov       rdi, QWORD[window]
     mov       rsi, GTK_WIN_POS_CENTER
     call      gtk_window_set_position

     mov       rdi, qword [window]
     mov       rsi, 500
     mov       rdx, 200
     call      gtk_window_set_default_size

     ; gtk_window_set_title
     mov       rdi, QWORD[window]
     mov       rsi, window.title
     call      gtk_window_set_title

     mov       rdi, FALSE
     mov       rsi, 0
     call      gtk_vbox_new                      ; don't use gtk_vbox_new <- deprecated
     mov       qword[box.handle], rax

     mov       rdi, qword[window.handle]
     mov       rsi, qword[box.handle]
     call      gtk_container_add

     call      gtk_toolbar_new
     mov       qword[toolbar.handle], rax

     mov       rdi, qword[toolbar.handle]
     mov       rsi, GTK_TOOLBAR_ICONS
     call      gtk_toolbar_set_style

     mov       rdi, qword[toolbar.handle]
     mov       rsi, 2
     call      gtk_container_set_border_width

     mov       rdi, GTK_STOCK_SELECT_COLOR
     call      gtk_tool_button_new_from_stock
     mov       qword[color.handle], rax

     mov       rdi, qword[toolbar.handle]
     mov       rsi, qword[color.handle]
     mov       rdx, -1
     call      gtk_toolbar_insert

     mov       rdi, qword[box.handle]
     mov       rsi, qword[toolbar.handle]
     mov       rdx, FALSE
     mov       rcx, FALSE
     mov       r8d, 5
     call      gtk_box_pack_start

     mov       rdi, label.caption
     call      gtk_label_new
     mov       qword[label.handle], rax

     mov       rdi, qword[label.handle]
     mov       rsi, GTK_JUSTIFY_CENTER
     call      gtk_label_set_justify

     mov       rdi, qword[box.handle]
     mov       rsi, qword[label.handle]
     mov       rdx, TRUE
     mov       rcx, FALSE
     mov       r8, 5
     call      gtk_box_pack_start

     xor       r9d, r9d                             ; combination of GConnectFlags 
     xor       r8d, r8d                             ; a GClosureNotify for data
     mov       rcx, qword[label.handle]             ; pointer to the data to pass
     mov       rdx, select_color                    ; pointer to the handler
     mov       rsi, signal.clicked                  ; pointer to the signal
     mov       rdi, qword[color.handle]             ; pointer to the widget instance
     call      g_signal_connect_data                ; the value in RAX is the handler, but we don't store it now

     xor       r9d, r9d                             ; combination of GConnectFlags 
     xor       r8d, r8d                             ; a GClosureNotify for data
     mov       rcx, qword[window.handle]            ; pointer to the data to pass
     mov       rdx, gtk_main_quit      ; pointer to the handler
     mov       rsi, signal.destroy     ; pointer to the signal
     mov       rdi, qword[window.handle]      ; pointer to the widget instance
     call      g_signal_connect_data   ; the value in RAX is the handler, but we don't store it now

     ; we set the window modal
     mov       rdi, qword [window.handle]
     call      gtk_window_set_modal

     mov       rdi, qword [window.handle]
     call      gtk_widget_show_all

     call      gtk_main
Exit:
     ; to avoid the error message "(simplewindow:9051): Gtk-CRITICAL **: gtk_main_quit: assertion 'main_loops != NULL' failed"
     xor       rdi, rdi                ; we don't expect much errors now
     call      exit

select_color:     
     ; RDI has GtkWidget *widget
     ; RSI has gpointer label
     ; create stackframe to prevent segmentation faults
     push      rbp
     mov       rbp, rsp
     ;mov       r14, rdi
     ;mov       r15, rsi

     mov       rdi, dialog.title
     call      gtk_color_selection_dialog_new
     mov       qword[dialog.handle], rax

         ; if we should leave next three lines we get : Gtk-Message: GtkDialog mapped without a transient parent. This is discouraged.
     mov       rdi, qword[dialog.handle]
     mov       rsi, qword[window.handle]
     call      gtk_window_set_transient_for
    
     mov       rdi, qword[dialog.handle]
     call      gtk_dialog_run
     mov       qword[result], rax

     cmp       eax, GTK_RESPONSE_OK                         ; don't use RAX
     jne       .exit

     mov       rdi, qword[dialog.handle]
     call      gtk_color_selection_dialog_get_color_selection
     mov       qword[colorsel], rax

     mov       rdi, qword[colorsel]
     mov       rsi, color
     call      gtk_color_selection_get_current_color

     ; debugging
%if DEBUG = 1    
     mov       rdi, format
     mov       esi, dword[color+GdkColor.pixel]
     xor       rax, rax
     call      g_print

     mov       rdi, format
     xor       rsi, rsi
     mov       si,  word[color+GdkColor.red]
     xor       rax, rax
     call      g_print

     mov       rdi, format
     xor       rsi, rsi
     mov       si,  word[color+GdkColor.green]
     xor       rax, rax
     call      g_print

     mov       rdi, format
     xor       rsi, rsi
     mov       si,  word[color+GdkColor.blue]
     xor       rax, rax
     call      g_print
%endif

     mov       rdi, qword[label.handle]                                     ; label pointer
     mov       rsi, GTK_STATE_NORMAL
     mov       rdx, color
     call      gtk_widget_modify_fg

.exit:
     mov       rdi, qword[dialog.handle]
     call      gtk_widget_destroy
     leave
     ret
