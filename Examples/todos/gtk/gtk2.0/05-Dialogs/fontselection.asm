; Name        : fontselection.asm
;
; Build       : nasm -felf64 -o fontselection.o -l fontselection.lst fontselection.asm
;               ld -s -m elf_x86_64 fontselection.o -o fontselection -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 `pkg-config --libs gtk+-2.0`
;
; Description : a font selection dialogbox
;
; C - source : http://zetcode.com/tutorials/gtktutorial/gtkdialogs/

bits 64

[list -]
     %define   GTK_WINDOW_TOPLEVEL      0
     %define   GTK_WIN_POS_CENTER       1
     %define   TRUE                     1
     %define   FALSE                    0
     %define   GTK_TOOLBAR_ICONS        0
     %define   GTK_JUSTIFY_CENTER       2
     %define   GTK_RESPONSE_APPLY     -10
     %define   GTK_RESPONSE_OK         -5
     %define   GTK_RESPONSE_CANCEL     -6
     
     extern    exit
     extern    gtk_init
     extern    gtk_window_new
     extern    gtk_window_set_title
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_window_set_modal
     extern    gtk_window_set_transient_for
     extern    gtk_widget_show_all
     extern    gtk_widget_add_events
     extern    gtk_main
     extern    gtk_main_quit
     extern    g_signal_connect_data
     extern    gtk_container_set_border_width
     extern    gtk_vbox_new
     extern    gtk_container_add
     extern    gtk_tool_button_new_from_stock
     extern    gtk_toolbar_insert
     extern    gtk_toolbar_new
     extern    gtk_toolbar_set_style
     extern    gtk_box_pack_start
     extern    gtk_label_new
     extern    gtk_label_set_justify
     extern    gtk_box_pack_start
     extern    gtk_font_selection_dialog_get_font_name
     extern    gtk_font_selection_dialog_new
     extern    gtk_dialog_run
     extern    pango_font_description_from_string
     extern    gtk_widget_modify_font
     extern    g_free
     extern    gtk_widget_destroy
     
[list +]

section .data
     window:
     .handle:       dq   0
     .title:        db   "Font Selection Dialog",0

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
     
     font:
     .handle:       dq   0
     .description:  dq   0
     .name:         dq   0

     result:        dq   0
     dialog:
     .handle:       dq   0
     .title:        db   "Select Font", 0
     
     GTK_STOCK_SELECT_FONT    db   "gtk-select-font", 0
     
section .text
        global _start

_start:
    xor     rsi, rsi                  ; argv
    xor     rdi, rdi                  ; argc
    call    gtk_init
    
    mov     rdi,GTK_WINDOW_TOPLEVEL
    call    gtk_window_new
    mov     QWORD[window], rax

    mov     rdi, QWORD[window]
    mov     rsi, GTK_WIN_POS_CENTER
    call    gtk_window_set_position

    mov     rdi, qword [window]
    mov     rsi, 500
    mov     rdx, 200
    call    gtk_window_set_default_size

    ; gtk_window_set_title
    mov     rdi, QWORD[window]
    mov     rsi, window.title
    call    gtk_window_set_title
   
    mov     rdi, FALSE
    mov     rsi, 0
    call    gtk_vbox_new                      ; don't use gtk_vbox_new <- deprecated
    mov     qword[box.handle], rax
    
    mov     rdi, qword[window.handle]
    mov     rsi, qword[box.handle]
    call    gtk_container_add
    
    call    gtk_toolbar_new
    mov     qword[toolbar.handle], rax
    
    mov     rdi, qword[toolbar.handle]
    mov     rsi, GTK_TOOLBAR_ICONS
    call    gtk_toolbar_set_style
    
    mov     rdi, qword[toolbar.handle]
    mov     rsi, 2
    call    gtk_container_set_border_width
    
    mov     rdi, GTK_STOCK_SELECT_FONT
    call    gtk_tool_button_new_from_stock
    mov     qword[font], rax
    
    mov     rdi, qword[toolbar.handle]
    mov     rsi, qword[font]
    mov     rdx, -1
    call    gtk_toolbar_insert
     
    mov     rdi, qword[box.handle]
    mov     rsi, qword[toolbar.handle]
    mov     rdx, FALSE
    mov     rcx, FALSE
    mov     r8d, 5
    call    gtk_box_pack_start

    mov     rdi, label.caption
    call    gtk_label_new
    mov     qword[label.handle], rax

    mov     rdi, qword[label.handle]
    mov     rsi, GTK_JUSTIFY_CENTER
    call    gtk_label_set_justify

    mov     rdi, qword[box.handle]
    mov     rsi, qword[label.handle]
    mov     rdx, TRUE
    mov     rcx, FALSE
    mov     r8, 5
    call    gtk_box_pack_start

    xor     r9d, r9d                             ; combination of GConnectFlags 
    xor     r8d, r8d                             ; a GClosureNotify for data
    mov     rcx, qword[label.handle]             ; pointer to the data to pass
    mov     rdx, select_font                     ; pointer to the handler
    mov     rsi, signal.clicked                  ; pointer to the signal
    mov     rdi, qword[font.handle]              ; pointer to the widget instance
    call    g_signal_connect_data                ; the value in RAX is the handler, but we don't store it now

    xor     r9d, r9d                             ; combination of GConnectFlags 
    xor     r8d, r8d                             ; a GClosureNotify for data
    mov     rcx, qword[window.handle]            ; pointer to the data to pass
    mov     rdx, gtk_main_quit                   ; pointer to the handler
    mov     rsi, signal.destroy                  ; pointer to the signal
    mov     rdi, qword[window.handle]            ; pointer to the widget instance
    call    g_signal_connect_data                ; the value in RAX is the handler, but we don't store it now

    ; we set the window modal
    mov     rdi, qword [window.handle]
    call    gtk_window_set_modal

    mov     rdi, qword [window.handle]
    call    gtk_widget_show_all

    call    gtk_main
Exit:
    
    xor     rdi, rdi                ; we don't expect much errors now
    call    exit

select_font:
    ; RDI has GtkWidget *widget
    ; RSI has gpointer label
    ; create stackframe to prevent segmentation faults
    push    rbp
    mov     rbp, rsp
    mov     r14, rdi
    mov     r15, rsi
    
    mov     rdi, dialog.title
    call    gtk_font_selection_dialog_new
    mov     qword[dialog.handle], rax

    ; if we should leave next three lines we get : Gtk-Message: GtkDialog mapped without a transient parent. This is discouraged.
    mov     rdi, qword[dialog.handle]
    mov     rsi, qword[window.handle]
    call    gtk_window_set_transient_for
    
    mov     rdi, qword[dialog.handle]
    call    gtk_dialog_run
    mov     qword[result], rax
    
    cmp     eax, GTK_RESPONSE_OK
    je      .setFont
    cmp     eax, GTK_RESPONSE_APPLY
    jne     .exit
.setFont:
    mov     rdi, qword[dialog.handle]
    call    gtk_font_selection_dialog_get_font_name
    mov     qword[font.name], rax
    
    mov     rdi, qword[font.name]
    call    pango_font_description_from_string
    mov     qword[font.description], rax
    
    mov     rdi, qword[label.handle]
    mov     rsi, qword[font.description]
    call    gtk_widget_modify_font
    
    mov     rdi, qword[font.name]
    call    g_free
    
.exit:
    mov     rdi, qword[dialog.handle]
    call    gtk_widget_destroy
    leave
    ret
