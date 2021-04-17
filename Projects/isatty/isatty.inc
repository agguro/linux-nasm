%ifndef _ISATTY_INC_
%define _ISATTY_INC_

%include "unistd.inc"
%include "sys/termios.inc"

extern    exit
extern    gtk_init
extern    gtk_window_new
extern    gtk_window_set_title
extern    gtk_window_set_default_size
extern    gtk_window_set_position
extern    gtk_window_set_icon
extern    gtk_widget_show_all
extern    gtk_widget_add_events
extern    gtk_main
extern    gtk_main_quit
extern    g_signal_connect_data
extern    gdk_pixbuf_new_from_file
extern    gdk_pixbuf_loader_new
extern    gdk_pixbuf_loader_write
extern    gdk_pixbuf_loader_get_pixbuf
extern    gtk_image_new_from_pixbuf
extern    gtk_container_add
extern    gtk_container_set_border_width
extern    gtk_about_dialog_new
extern    gtk_about_dialog_set_comments
extern    gtk_about_dialog_set_copyright
extern    gtk_about_dialog_set_logo
extern    gtk_about_dialog_set_program_name
extern    gtk_about_dialog_set_version
extern    gtk_about_dialog_set_website
extern    gtk_dialog_run
extern    gtk_widget_destroy
extern    gtk_widget_hide
extern    gtk_window_set_transient_for
extern    gtk_about_dialog_set_website_label

%define   GTK_WINDOW_TOPLEVEL      0
%define   GTK_WIN_POS_CENTER       1
%define   GDK_BUTTON_PRESS_MASK    256

%endif
