#include <gtk/gtk.h>

void combo_selected(GtkWidget *widget, gpointer window) {
     
  gchar *text = gtk_combo_box_get_active_text(GTK_COMBO_BOX(widget));
  gtk_label_set_text(GTK_LABEL(window), text);
  g_free(text);
}

int main(int argc, char *argv[]) {
    
  GtkWidget *window;
  GtkWidget *hbox;
  GtkWidget *vbox;
  GtkWidget *combo;
  GtkWidget *label;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_title(GTK_WINDOW(window), "GtkComboBox");
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_container_set_border_width(GTK_CONTAINER(window), 15);
  gtk_window_set_default_size(GTK_WINDOW(window), 300, 200);
  
  hbox = gtk_hbox_new(FALSE, 0);
  vbox = gtk_vbox_new(FALSE, 15);

  combo = gtk_combo_box_new_text();
  gtk_combo_box_append_text(GTK_COMBO_BOX(combo), "Ubuntu");
  gtk_combo_box_append_text(GTK_COMBO_BOX(combo), "Arch");
  gtk_combo_box_append_text(GTK_COMBO_BOX(combo), "Fedora");
  gtk_combo_box_append_text(GTK_COMBO_BOX(combo), "Mint");
  gtk_combo_box_append_text(GTK_COMBO_BOX(combo), "Gentoo");
  gtk_combo_box_append_text(GTK_COMBO_BOX(combo), "Debian");

  gtk_box_pack_start(GTK_BOX(vbox), combo, FALSE, FALSE, 0);

  label = gtk_label_new("...");
  gtk_box_pack_start(GTK_BOX(vbox), label, FALSE, FALSE, 0);
  
  gtk_box_pack_start(GTK_BOX(hbox), vbox, FALSE, FALSE, 0);
  gtk_container_add(GTK_CONTAINER(window), hbox);

  g_signal_connect(G_OBJECT(window), "destroy",
        G_CALLBACK(gtk_main_quit), NULL);

  g_signal_connect(G_OBJECT(combo), "changed", 
        G_CALLBACK(combo_selected), (gpointer) label);

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
