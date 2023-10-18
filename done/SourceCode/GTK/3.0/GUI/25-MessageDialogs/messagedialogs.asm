;name        : messagedialogs.asm
;
;build       : nasm -felf64 -o messagedialogs.o -l messagedialogs.lst messagedialogs.asm
;              ld -s -m elf_x86_64 messagedialogs.o -o messagedialogs -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 `pkg-config --libs gtk+-3.0`
;
;description : message dialog boxes

;source : http://zetcode.com/tutorials/gtktutorial/gtkdialogs/

bits      64
align     16

[list -]
     extern    exit
     extern    gtk_button_new_with_label
     extern    gtk_container_add
     extern    gtk_container_set_border_width
     extern    gtk_init
     extern    gtk_main
     extern    gtk_main_quit
     extern    gtk_widget_set_size_request
     extern    gtk_widget_show_all
     extern    gtk_window_new
     extern    gtk_window_set_default_size
     extern    gtk_window_set_position
     extern    gtk_window_set_title
     extern    g_signal_connect_data
     extern    gtk_dialog_run
     extern    gtk_message_dialog_new
     extern    gtk_widget_destroy
     extern    gtk_table_new
     extern    gtk_table_set_col_spacings
     extern    gtk_table_set_row_spacings
     extern    gtk_table_attach
     
     %define   GTK_WIN_POS_CENTER                 1
     %define   GTK_WINDOW_TOPLEVEL                0
     %define   NULL                               0
     %define   TRUE                               1
     %define   FALSE                              0
     %define   GTK_BUTTONS_OK                     1
     %define   GTK_BUTTONS_YES_NO                 4
     %define   GTK_DIALOG_DESTROY_WITH_PARENT     2
     %define   GTK_MESSAGE_ERROR                  3
     %define   GTK_MESSAGE_INFO                   0
     %define   GTK_MESSAGE_QUESTION               2
     %define   GTK_MESSAGE_WARNING                1
     %define   FLOAT1                             0x3F800000
     %define   FLOAT2                             0x40
     %define   GTK_FILL                           4
     %define   GTK_EXPAND                         1
     %define   GTK_SHRINK                         2
     
[list +]

section .data
     
     window:
     .handle:       dq   0
     .title:        db   "Message dialogs", 0
     
     table:
     .handle:       dq   0
          
     signal:
     .clicked:      db   "clicked", 0
     .destroy:      db   "destroy", 0

     dialog:
     .handle:       dq   0
     
     info:
     .message:      db   "Download completed", 0
     .title:        db   "Information", 0
     .handle:       dq   0
     .label:        db   "Info", 0
     
     error:
     .message:      db   "Error loading file", 0
     .title:        db   "Error", 0
     .handle:       dq   0
     .label:        db   "Error", 0
     
     question:
     .message:      db   "Are you sure to quit?", 0
     .title:        db   "Question", 0
     .handle:       dq   0
     .label:        db   "Question", 0
     
     warning:
     .message:      db   "Unallowed operation", 0
     .title:        db   "Warning", 0
     .handle:       dq   0
     .label:        db   "Warning", 0
     
     
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
     mov       rsi, 220
     mov       rdi, qword[window.handle]
     call      gtk_window_set_default_size

     mov       rsi, window.title
     mov       rdi, qword[window.handle]
     call      gtk_window_set_title
     
     mov       rdi, 2
     mov       rsi, 2
     mov       rdx, TRUE
     call      gtk_table_new
     mov       qword[table.handle], rax
     
     mov       rdi, qword[table.handle]
     mov       rsi, 2
     call      gtk_table_set_row_spacings
     
     mov       rdi, qword[table.handle]
     mov       rsi, 2
     call      gtk_table_set_col_spacings
     
     mov       rdi, info.label
     call      gtk_button_new_with_label
     mov       qword[info.handle], rax
     
     mov       rdi, warning.label
     call      gtk_button_new_with_label
     mov       qword[warning.handle], rax
     
     mov       rdi, question.label
     call      gtk_button_new_with_label
     mov       qword[question.handle], rax
     
     mov       rdi, error.label
     call      gtk_button_new_with_label
     mov       qword[error.handle], rax
     
     mov       rdi, qword[table.handle]
     mov       rsi, qword[info.handle]
     mov       rdx, 0
     mov       rcx, 1
     mov       r8d, 0
     mov       r9d, 1
     ; last parameter now first on stack
     push      3
     push      3
     push      GTK_FILL
     push      GTK_FILL
     call      gtk_table_attach
     
     mov       rdi, qword[table.handle]
     mov       rsi, qword[warning.handle]
     mov       rdx, 1
     mov       rcx, 2
     mov       r8d, 0
     mov       r9d, 1
     ; last parameter now first on stack
     push      3
     push      3
     push      GTK_FILL
     push      GTK_FILL
     call      gtk_table_attach
     
     mov       rdi, qword[table.handle]
     mov       rsi, qword[question.handle]
     mov       rdx, 0
     mov       rcx, 1
     mov       r8d, 1
     mov       r9d, 2
     ; last parameter now first on stack
     push      3
     push      3
     push      GTK_FILL
     push      GTK_FILL
     call      gtk_table_attach
     
     mov       rdi, qword[table.handle]
     mov       rsi, qword[error.handle]
     mov       rdx, 1
     mov       rcx, 2
     mov       r8d, 1
     mov       r9d, 2
     ; last parameter now first on stack
     push      3
     push      3
     push      GTK_FILL
     push      GTK_FILL
     call      gtk_table_attach
     
     mov       rsi, qword[table.handle]
     mov       rdi, qword[window.handle]
     call      gtk_container_add

     mov       rdi, qword[window.handle]
     mov       rsi, 15
     call      gtk_container_set_border_width
         
     xor       r9d, r9d
     xor       r8d, r8d
     mov       rcx, qword[window.handle]
     mov       rdx, show_info
     mov       rsi, signal.clicked
     mov       rdi, qword[info.handle]
     call      g_signal_connect_data

     xor       r9d, r9d
     xor       r8d, r8d
     mov       rcx, qword[window.handle]
     mov       rdx, show_warning
     mov       rsi, signal.clicked
     mov       rdi, qword[warning.handle]
     call      g_signal_connect_data

     xor       r9d, r9d
     xor       r8d, r8d
     mov       rcx, qword[window.handle]
     mov       rdx, show_question
     mov       rsi, signal.clicked
     mov       rdi, qword[question.handle]
     call      g_signal_connect_data

     xor       r9d, r9d
     xor       r8d, r8d
     mov       rcx, qword[window.handle]
     mov       rdx, show_error
     mov       rsi, signal.clicked
     mov       rdi, qword[error.handle]
     call      g_signal_connect_data

     xor       r9d, r9d
     xor       r8d, r8d
     mov       rcx, qword[window.handle]
     mov       rdx, gtk_main_quit
     mov       rsi, signal.destroy
     mov       rdi, qword[window.handle]
     call      g_signal_connect_data

     mov       rdi, qword[window.handle]
     call      gtk_widget_show_all

     call      gtk_main
     
     xor       rdi, rdi
     call      exit

show_info:
     push      rbp
     mov       rbp, rsp
     mov       rdi, rsi
     mov       rsi, GTK_DIALOG_DESTROY_WITH_PARENT
     mov       rdx, GTK_MESSAGE_INFO
     mov       rcx, GTK_BUTTONS_OK
     mov       r8,  info.message
     call      gtk_message_dialog_new
     mov       qword[dialog.handle], rax
     mov       rdi, qword[dialog.handle]
     mov       rsi, info.title
     call      gtk_window_set_title
     mov       rdi, qword[dialog.handle]
     call      gtk_dialog_run
     mov       rdi, qword[dialog.handle]
     call      gtk_widget_destroy
     leave
     ret
     
show_error:
     push      rbp
     mov       rbp, rsp
     mov       rdi, rsi
     mov       rsi, GTK_DIALOG_DESTROY_WITH_PARENT
     mov       rdx, GTK_MESSAGE_ERROR
     mov       rcx, GTK_BUTTONS_OK
     mov       r8d, error.message
     call      gtk_message_dialog_new
     mov       qword[dialog.handle], rax
     mov       rdi, qword[dialog.handle]
     mov       rsi, error.title
     call      gtk_window_set_title
     mov       rdi, qword[dialog.handle]
     call      gtk_dialog_run
     mov       rdi, qword[dialog.handle]
     call      gtk_widget_destroy
     leave
     ret
     
show_question:
     push      rbp
     mov       rbp, rsp
     mov       rdi, rsi
     mov       rsi, GTK_DIALOG_DESTROY_WITH_PARENT
     mov       rdx, GTK_MESSAGE_QUESTION
     mov       rcx, GTK_BUTTONS_YES_NO
     mov       r8d, question.message
     call      gtk_message_dialog_new
     mov       qword[dialog.handle], rax
     mov       rdi, qword[dialog.handle]
     mov       rsi, question.title
     call      gtk_window_set_title
     mov       rdi, qword[dialog.handle]
     call      gtk_dialog_run
     mov       rdi, qword[dialog.handle]
     call      gtk_widget_destroy
     leave
     ret
     
show_warning:
     push      rbp
     mov       rbp, rsp
     mov       rdi, rsi
     mov       rsi, GTK_DIALOG_DESTROY_WITH_PARENT
     mov       rdx, GTK_MESSAGE_WARNING
     mov       rcx, GTK_BUTTONS_OK
     mov       r8d, warning.message
     call      gtk_message_dialog_new
     mov       qword[dialog.handle], rax
     mov       rdi, qword[dialog.handle]
     mov       rsi, warning.title
     call      gtk_window_set_title
     mov       rdi, qword[dialog.handle]
     call      gtk_dialog_run
     mov       rdi, qword[dialog.handle]
     call      gtk_widget_destroy
     mov       rsp, rbp
    pop     rbp
     ret
