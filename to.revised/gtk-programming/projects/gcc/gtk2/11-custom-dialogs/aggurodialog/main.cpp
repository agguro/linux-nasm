// source of image: https://notagreymouse.com/
// This example is different than the one in assembly language created in 2015 with GTK3.
// Here we need to set a label to show the website label and to hide the website link
// which can be a bit long.

#include <gtk/gtk.h>

GtkWidget *dialog;

GdkPixbuf *create_pixbuf(const gchar * filename) {
    
   GdkPixbuf *pixbuf;
   GError *error = NULL;
   pixbuf = gdk_pixbuf_new_from_file(filename, &error);
   
   if (!pixbuf) {
       
      fprintf(stderr, "%s\n", error->message);
      g_error_free(error);
   }

   return pixbuf;
}

void show_about(GtkWidget *widget, gpointer data) {

  GdkPixbuf *pixbuf = gdk_pixbuf_new_from_file("picture.png", NULL);

  gtk_about_dialog_set_name(GTK_ABOUT_DIALOG(dialog), "This example");
  gtk_about_dialog_set_version(GTK_ABOUT_DIALOG(dialog), "1.0"); 
  gtk_about_dialog_set_copyright(GTK_ABOUT_DIALOG(dialog),"(c) Agguro - 2015");
  gtk_about_dialog_set_comments(GTK_ABOUT_DIALOG(dialog), 
     "This is an example to create an about dialogbox.");
  gtk_about_dialog_set_website_label(GTK_ABOUT_DIALOG(dialog),"visit website");
  gtk_about_dialog_set_website(GTK_ABOUT_DIALOG(dialog), 
     "https://www.linuxnasm.be/home/zetcode-examples/more-examples/a-mature-dialogbox");
  gtk_about_dialog_set_logo(GTK_ABOUT_DIALOG(dialog), pixbuf);
  g_object_unref(pixbuf), pixbuf = NULL;
  gtk_dialog_run(GTK_DIALOG (dialog));
  gtk_widget_destroy(dialog);
}

int main(int argc, char *argv[]) {
    
  GtkWidget *window;
  GdkPixbuf *icon;
  
  
  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window), 220, 150);
  gtk_window_set_title(GTK_WINDOW(window), "click on the window");
  
  icon = create_pixbuf("logo.png");  
  gtk_window_set_icon(GTK_WINDOW(window), icon);
  
  gtk_container_set_border_width(GTK_CONTAINER(window), 15);
  gtk_widget_add_events(window, GDK_BUTTON_PRESS_MASK);

  g_signal_connect(G_OBJECT(window), "button-press-event", 
        G_CALLBACK(show_about), (gpointer) window); 

  g_signal_connect(G_OBJECT(window), "destroy",
        G_CALLBACK(gtk_main_quit), G_OBJECT(window));

  dialog = gtk_about_dialog_new();
  gtk_window_set_transient_for(GTK_WINDOW(dialog),GTK_WINDOW(window));
  gtk_widget_show_all(window);

  g_object_unref(icon); 
  
  gtk_main();

  return 0;
}
