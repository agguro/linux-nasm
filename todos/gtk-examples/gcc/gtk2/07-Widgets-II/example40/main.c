#include <gtk/gtk.h>
#include <assert.h>

enum {

  COL_DISPLAY_NAME,
  COL_PIXBUF,
  NUM_COLS
};

GtkTreeModel *init_model(void) {

  GtkListStore *list_store;
  GdkPixbuf *p1, *p2, *p3, *p4;
  GtkTreeIter iter;
  GError *err = NULL;

  p1 = gdk_pixbuf_new_from_file("ubuntu.png", &err);
  p2 = gdk_pixbuf_new_from_file("gnumeric.png", &err);
  p3 = gdk_pixbuf_new_from_file("blender.png", &err);
  p4 = gdk_pixbuf_new_from_file("inkscape.png", &err);

  assert(err==NULL);

  list_store = gtk_list_store_new(NUM_COLS,
      G_TYPE_STRING, GDK_TYPE_PIXBUF);

  gtk_list_store_append(list_store, &iter);
  gtk_list_store_set(list_store, &iter, COL_DISPLAY_NAME,
      "Ubuntu", COL_PIXBUF, p1, -1);
  gtk_list_store_append(list_store, &iter);
  gtk_list_store_set(list_store, &iter, COL_DISPLAY_NAME,
      "Gnumeric", COL_PIXBUF, p2, -1);
  gtk_list_store_append(list_store, &iter);
  gtk_list_store_set(list_store, &iter, COL_DISPLAY_NAME,
      "Blender", COL_PIXBUF, p3, -1);
  gtk_list_store_append(list_store, &iter);
  gtk_list_store_set(list_store, &iter, COL_DISPLAY_NAME,
      "Inkscape", COL_PIXBUF, p4, -1);

  g_object_unref(p1);
  g_object_unref(p2);
  g_object_unref(p3);
  g_object_unref(p4);

  return GTK_TREE_MODEL(list_store);
}

int main(int argc, char *argv[]) {

  GtkWidget *window;
  GtkWidget *icon_view;
  GtkWidget *sw;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);

  gtk_window_set_title(GTK_WINDOW(window), "IconView");
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_container_set_border_width(GTK_CONTAINER(window), 10);
  gtk_window_set_default_size(GTK_WINDOW(window), 350, 300);

  sw = gtk_scrolled_window_new(NULL, NULL);
  gtk_container_add(GTK_CONTAINER(window), sw);
  gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(sw),
      GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);
  gtk_scrolled_window_set_shadow_type(GTK_SCROLLED_WINDOW(sw),
      GTK_SHADOW_IN);

  icon_view = gtk_icon_view_new_with_model(init_model());
  gtk_container_add(GTK_CONTAINER(sw), icon_view);

  gtk_icon_view_set_text_column(GTK_ICON_VIEW(icon_view),
      COL_DISPLAY_NAME);
  gtk_icon_view_set_pixbuf_column(GTK_ICON_VIEW(icon_view), COL_PIXBUF);
  gtk_icon_view_set_selection_mode(GTK_ICON_VIEW(icon_view),
      GTK_SELECTION_MULTIPLE);

  g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
