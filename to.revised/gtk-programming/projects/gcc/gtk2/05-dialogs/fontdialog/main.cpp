#include <gtk/gtk.h>

void select_font(GtkWidget *widget, gpointer label) {
    
  GtkResponseType result;

  GtkWidget *dialog = gtk_font_selection_dialog_new("Select Font");

  result = (GtkResponseType) gtk_dialog_run(GTK_DIALOG(dialog));

  if (result == GTK_RESPONSE_OK || result == GTK_RESPONSE_APPLY) {

     PangoFontDescription *font_desc;
     gchar *fontname = gtk_font_selection_dialog_get_font_name(
                            GTK_FONT_SELECTION_DIALOG(dialog));

     font_desc = pango_font_description_from_string(fontname);

     gtk_widget_modify_font(GTK_WIDGET(label), font_desc);

     g_free(fontname);
   }

  gtk_widget_destroy(dialog);
}

int main(int argc, char *argv[]) {
    
  GtkWidget *window;
  GtkWidget *label;
  GtkWidget *vbox;

  GtkWidget *toolbar;
  GtkToolItem *font;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window), 280, 200);
  gtk_window_set_title(GTK_WINDOW(window), "Font Selection Dialog");

  vbox = gtk_vbox_new(FALSE, 0);
  gtk_container_add(GTK_CONTAINER(window), vbox);

  toolbar = gtk_toolbar_new();
  gtk_toolbar_set_style(GTK_TOOLBAR(toolbar), GTK_TOOLBAR_ICONS);

  gtk_container_set_border_width(GTK_CONTAINER(toolbar), 2);

  font = gtk_tool_button_new_from_stock(GTK_STOCK_SELECT_FONT);
  gtk_toolbar_insert(GTK_TOOLBAR(toolbar), font, -1);

  gtk_box_pack_start(GTK_BOX(vbox), toolbar, FALSE, FALSE, 5);

  label = gtk_label_new("ZetCode");
  gtk_label_set_justify(GTK_LABEL(label), GTK_JUSTIFY_CENTER);
  gtk_box_pack_start(GTK_BOX(vbox), label, TRUE, FALSE, 5);

  g_signal_connect(G_OBJECT(font), "clicked", 
        G_CALLBACK(select_font), label);

  g_signal_connect(G_OBJECT(window), "destroy",
        G_CALLBACK(gtk_main_quit), NULL);

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
