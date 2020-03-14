#include <gtk/gtk.h>

void value_changed(GtkRange *range, gpointer win) {

   gdouble val = gtk_range_get_value(range);
   gchar *str = g_strdup_printf("%.f", val);
   gtk_label_set_text(GTK_LABEL(win), str);

   g_free(str);
}

int main(int argc, char *argv[]) {

  GtkWidget *window;
  GtkWidget *halign;
  GtkWidget *hbox;
  GtkWidget *hscale;
  GtkWidget *label;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window), 300, 250);
  gtk_container_set_border_width(GTK_CONTAINER(window), 10);
  gtk_window_set_title(GTK_WINDOW(window), "GtkHScale");

  hbox = gtk_hbox_new(FALSE, 20);

  hscale = gtk_hscale_new_with_range(0, 100, 1);
  gtk_scale_set_draw_value(GTK_SCALE(hscale), FALSE);
  gtk_widget_set_size_request(hscale, 150, -1);
  label = gtk_label_new("...");
  gtk_misc_set_alignment(GTK_MISC(label), 0.0, 1);

  gtk_box_pack_start(GTK_BOX(hbox), hscale, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(hbox), label, FALSE, FALSE, 0);

  halign = gtk_alignment_new(0, 0, 0, 0);
  gtk_container_add(GTK_CONTAINER(halign), hbox);
  gtk_container_add(GTK_CONTAINER(window), halign);

  g_signal_connect(window, "destroy",
      G_CALLBACK(gtk_main_quit), NULL);

  g_signal_connect(hscale, "value-changed",
      G_CALLBACK(value_changed), label);

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
