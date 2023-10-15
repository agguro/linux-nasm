; Name        : fileselection.asm
;
; Build       : nasm -felf64 -o fileselection.o -l fileselection.lst fileselection.asm
;               ld -s -m elf_x86_64 fileselection.o -o fileselection -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3
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
     extern    gtk_box_new
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
     extern    gtk_dialog_run
     extern    gtk_widget_destroy

     extern gtk_color_chooser_dialog_new
     extern gtk_color_chooser_get_rgba
     extern gtk_widget_override_color

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
     .title:        db   "Select File", 0
     
     ;deprecated!!!
     OPEN_FILE:  db   "gtk-open", 0
         
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

     mov       rdi, TRUE                        ; for vertical menus use FALSE
     mov       rsi, 0
     call      gtk_box_new                      ; don't use gtk_vbox_new <- deprecated
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

     mov       rdi, OPEN_FILE
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
     mov       rcx, qword[window.handle]             ; pointer to the data to pass
     mov       rdx, select_file                    ; pointer to the handler
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

select_file:     
     ; RDI has GtkWidget *widget
     ; RSI has gpointer label
     push      rbp
     mov       rbp, rsp
    ;from GtkFileChooser.h
    %define GTK_FILE_CHOOSER_ACTION_OPEN    0
    %define GTK_FILE_CHOOSER_ACTION_SAVE    1
    %define GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER   2
    %define GTK_FILE_CHOOSER_ACTION_CREATE_FOLDER   3
    ;from GtkDialog.h
    %define GTK_RESPONSE_NONE          -1
    %define GTK_RESPONSE_REJECT        -2
    %define GTK_RESPONSE_ACCEPT        -3
    %define GTK_RESPONSE_DELETE_EVENT  -4
    %define GTK_RESPONSE_OK            -5
    %define GTK_RESPONSE_CANCEL        -6
    %define GTK_RESPONSE_CLOSE         -7
    %define GTK_RESPONSE_YES           -8
    %define GTK_RESPONSE_NO            -9
    %define GTK_RESPONSE_APPLY         -10
    %define GTK_RESPONSE_HELP          -11

     section .rodata
     szCancel: db "_Cancel",0
     szOpen:    db "_Open",0
     section .data
     action: dq 0
     section .text
     push      0
     push      GTK_RESPONSE_ACCEPT
     mov       r9,szOpen
     mov       r8,GTK_RESPONSE_CANCEL
     mov       rcx,szCancel
     mov       rdx,GTK_FILE_CHOOSER_ACTION_OPEN
     mov       rsi,0
     mov       rdi, dialog.title
section .data
     filename:  dq  0

extern gtk_file_chooser_dialog_new
section .text

     call      gtk_file_chooser_dialog_new
     mov       qword[dialog.handle], rax

     ; if we should leave next three lines we get : Gtk-Message: GtkDialog mapped without a transient parent. This is discouraged.
     mov       rdi, qword[dialog.handle]
     mov       rsi, qword[window.handle]
     call      gtk_window_set_transient_for
    
     mov       rdi, qword[dialog.handle]
     call      gtk_dialog_run
     mov       qword[result], rax

     cmp       eax, GTK_RESPONSE_ACCEPT                         ; don't use RAX
     jne       .exit
     extern   gtk_file_chooser_get_filename
     mov    rdi,[dialog.handle]
     call   gtk_file_chooser_get_filename
     mov    [filename],rax
     
     mov    rdi,[label.handle]
     mov    rsi,[filename]
     extern gtk_label_set_text
     call   gtk_label_set_text

     mov      rdi,[filename]
     extern g_free
     call     g_free
        
.exit:
     mov       rdi, qword[dialog.handle]
     call      gtk_widget_destroy
     mov       rsp,rbp
     pop       rbp
     ret

action_open:
ret

action_cancel:
ret
