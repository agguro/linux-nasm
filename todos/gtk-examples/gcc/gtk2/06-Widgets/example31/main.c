#include <gtk/gtk.h>

int main(int argc, char *argv[]) {

  GtkWidget *window;
  GtkWidget *table;

  GtkWidget *frame1;
  GtkWidget *frame2;
  GtkWidget *frame3;
  GtkWidget *frame4;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window), 250, 250);
  gtk_window_set_title(GTK_WINDOW(window), "GtkFrame");

  gtk_container_set_border_width(GTK_CONTAINER(window), 10);

  table = gtk_table_new(2, 2, TRUE);
  gtk_table_set_row_spacings(GTK_TABLE(table), 10);
  gtk_table_set_col_spacings(GTK_TABLE(table), 10);
  gtk_container_add(GTK_CONTAINER(window), table);

  frame1 = gtk_frame_new("Shadow In");
  gtk_frame_set_shadow_type(GTK_FRAME(frame1), GTK_SHADOW_IN);
  frame2 = gtk_frame_new("Shadow Out");
  gtk_frame_set_shadow_type(GTK_FRAME(frame2), GTK_SHADOW_OUT);
  frame3 = gtk_frame_new("Shadow Etched In");
  gtk_frame_set_shadow_type(GTK_FRAME(frame3), GTK_SHADOW_ETCHED_IN);
  frame4 = gtk_frame_new("Shadow Etched Out");
  gtk_frame_set_shadow_type(GTK_FRAME(frame4), GTK_SHADOW_ETCHED_OUT);

  gtk_table_attach_defaults(GTK_TABLE(table), frame1, 0, 1, 0, 1);
  gtk_table_attach_defaults(GTK_TABLE(table), frame2, 0, 1, 1, 2);
  gtk_table_attach_defaults(GTK_TABLE(table), frame3, 1, 2, 0, 1);
  gtk_table_attach_defaults(GTK_TABLE(table), frame4, 1, 2, 1, 2);

  g_signal_connect(G_OBJECT(window), "destroy",
        G_CALLBACK(gtk_main_quit), G_OBJECT(window));

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
