#include <gtk/gtk.h>

int main(int argc, char *argv[]) {
    
  GtkWidget *window;
  GtkWidget *align;

  GtkWidget *lbl;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_title(GTK_WINDOW(window), "GtkAlignment");
  gtk_window_set_default_size(GTK_WINDOW(window), 300, 200);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_container_set_border_width(GTK_CONTAINER(window), 5);

  align = gtk_alignment_new(0, 1, 0, 0);
  lbl = gtk_label_new("bottom-left");
  
  gtk_container_add(GTK_CONTAINER(align), lbl);
  gtk_container_add(GTK_CONTAINER(window), align);

  g_signal_connect(G_OBJECT(window), "destroy", 
      G_CALLBACK(gtk_main_quit), NULL);

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
