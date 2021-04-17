%ifndef _ISATTY_INC_
%define _ISATTY_INC_

    %include "unistd.inc"
    %include "sys/termios.inc"

    extern    gtk_init
    extern    gtk_window_new
    extern    gtk_window_set_icon
    extern    gdk_pixbuf_loader_new
    extern    gdk_pixbuf_loader_write
    extern    gdk_pixbuf_loader_get_pixbuf
    extern    gtk_about_dialog_new
    extern    gtk_about_dialog_set_comments
    extern    gtk_about_dialog_set_copyright
    extern    gtk_about_dialog_set_logo
    extern    gtk_about_dialog_set_program_name
    extern    gtk_about_dialog_set_version
    extern    gtk_about_dialog_set_website
    extern    gtk_dialog_run
    extern    gtk_widget_destroy
    extern    gtk_about_dialog_set_website_label

    %define   GTK_WINDOW_TOPLEVEL      0
    %define   GTK_WIN_POS_CENTER       1
    %define   GDK_BUTTON_PRESS_MASK    256

%endif
