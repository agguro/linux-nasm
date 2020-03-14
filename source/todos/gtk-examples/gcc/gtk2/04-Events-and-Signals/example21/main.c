#include <gtk/gtk.h>

void enter_button(GtkWidget *widget, gpointer data) {
  g_print("button entered\n");
}

int main(int argc, char *argv[]) {

  GtkWidget *window;
  GtkWidget *halign;
  GtkWidget *btn;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window), 300, 200);
  gtk_container_set_border_width(GTK_CONTAINER(window), 15);
  gtk_window_set_title(GTK_WINDOW(window), "Enter signal");

  halign = gtk_alignment_new(0, 0, 0, 0);

  btn = gtk_button_new_with_label("Button");
  gtk_widget_set_size_request(btn, 70, 30);

  gtk_container_add(GTK_CONTAINER(halign), btn);
  gtk_container_add(GTK_CONTAINER(window), halign);

  g_signal_connect(G_OBJECT(btn), "enter",
      G_CALLBACK(enter_button), NULL);

  g_signal_connect(G_OBJECT(window), "destroy",
      G_CALLBACK(gtk_main_quit), NULL);

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
