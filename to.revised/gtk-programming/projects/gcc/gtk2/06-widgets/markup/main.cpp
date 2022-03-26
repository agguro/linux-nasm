#include <gtk/gtk.h>

int main(int argc, char *argv[]) {
    
  GtkWidget *window;
  GtkWidget *label;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window), 300, 100);
  gtk_window_set_title(GTK_WINDOW(window), "Markup label");

  gchar *str = (gchar*) ("<b>ZetCode</b>, knowledge only matters");

  label = gtk_label_new(NULL);
  gtk_label_set_markup(GTK_LABEL(label), str);

  gtk_container_add(GTK_CONTAINER(window), label);
  gtk_widget_show(label);

  g_signal_connect(window, "destroy",
      G_CALLBACK(gtk_main_quit), NULL);

  gtk_widget_show(window);

  gtk_main();

  return 0;
}
