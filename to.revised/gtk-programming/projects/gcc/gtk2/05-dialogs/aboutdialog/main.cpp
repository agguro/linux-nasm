// source of image: https://heimann.tumblr.com/

#include <gtk/gtk.h>

void show_about(GtkWidget *widget, gpointer data) {

  GdkPixbuf *pixbuf = gdk_pixbuf_new_from_file("battery.png", NULL);

  GtkWidget *dialog = gtk_about_dialog_new();
  gtk_about_dialog_set_name(GTK_ABOUT_DIALOG(dialog), "Battery");
  gtk_about_dialog_set_version(GTK_ABOUT_DIALOG(dialog), "0.9"); 
  gtk_about_dialog_set_copyright(GTK_ABOUT_DIALOG(dialog),"(c) Jan Bodnar");
  gtk_about_dialog_set_comments(GTK_ABOUT_DIALOG(dialog), 
     "Battery is a simple tool for battery checking.");
  gtk_about_dialog_set_website(GTK_ABOUT_DIALOG(dialog), 
     "http://www.batteryhq.net");
  gtk_about_dialog_set_logo(GTK_ABOUT_DIALOG(dialog), pixbuf);
  g_object_unref(pixbuf), pixbuf = NULL;
  gtk_dialog_run(GTK_DIALOG (dialog));
  gtk_widget_destroy(dialog);
}

int main(int argc, char *argv[]) {
    
  GtkWidget *window;
  //GtkWidget *about;
  //GdkPixbuf *battery;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window), 220, 150);
  gtk_window_set_title(GTK_WINDOW(window), "Battery");

  gtk_container_set_border_width(GTK_CONTAINER(window), 15);
  gtk_widget_add_events(window, GDK_BUTTON_PRESS_MASK);

  g_signal_connect(G_OBJECT(window), "button-press-event", 
        G_CALLBACK(show_about), (gpointer) window); 

  g_signal_connect(G_OBJECT(window), "destroy",
        G_CALLBACK(gtk_main_quit), G_OBJECT(window));

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
