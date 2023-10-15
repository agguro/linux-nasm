//https://en.wikibooks.org/wiki/GTK%2B_By_Example/Tree_View/DnD
#include <gtk/gtk.h>

enum
{
  COL_URI = 0,
  NUM_COLS
} ;


void
view_onDragDataReceived(GtkWidget *wgt, GdkDragContext *context, int x, int y,
                        GtkSelectionData *seldata, guint info, guint time,
                        gpointer userdata)
{
  GtkTreeModel *model;
  GtkTreeIter   iter;

  model = GTK_TREE_MODEL(userdata);

  gtk_list_store_append(GTK_LIST_STORE(model), &iter);

  gtk_list_store_set(GTK_LIST_STORE(model), &iter, COL_URI, (gchar*)seldata->data, -1);
}

static GtkWidget *
create_view_and_model (void)
{
  GtkTreeViewColumn   *col;
  GtkCellRenderer     *renderer;
  GtkListStore        *liststore;
  GtkWidget           *view;

  liststore = gtk_list_store_new(NUM_COLS, G_TYPE_STRING);

  view = gtk_tree_view_new_with_model(GTK_TREE_MODEL(liststore));

  g_object_unref(liststore); /* destroy model with view */

  col = gtk_tree_view_column_new();
  renderer = gtk_cell_renderer_text_new();

  gtk_tree_view_column_set_title(col, "URI");
  gtk_tree_view_append_column(GTK_TREE_VIEW(view), col);
  gtk_tree_view_column_pack_start(col, renderer, TRUE);
  gtk_tree_view_column_add_attribute(col, renderer, "text", COL_URI);

  gtk_tree_selection_set_mode(gtk_tree_view_get_selection(GTK_TREE_VIEW(view)),
                              GTK_SELECTION_SINGLE);

  /* Make tree view a destination for Drag'n'Drop */
  if (1)
  {
    enum
    {
      TARGET_STRING,
      TARGET_URL
    };

    static GtkTargetEntry targetentries[] =
    {
      { "STRING",        0, TARGET_STRING },
      { "text/plain",    0, TARGET_STRING },
      { "text/uri-list", 0, TARGET_URL },
    };

    gtk_drag_dest_set(view, GTK_DEST_DEFAULT_ALL, targetentries, 3,
                      GDK_ACTION_COPY|GDK_ACTION_MOVE|GDK_ACTION_LINK);

    g_signal_connect(view, "drag_data_received",
                     G_CALLBACK(view_onDragDataReceived), liststore);
  }

  return view;
}

int
main (int argc, char **argv)
{
  GtkWidget *window, *vbox, *view, *label;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  g_signal_connect(window, "delete_event", gtk_main_quit, NULL); /* dirty */
  gtk_window_set_default_size(GTK_WINDOW(window), 400, 200);

  vbox = gtk_vbox_new(FALSE, 0);
  gtk_container_add(GTK_CONTAINER(window), vbox);

  label = gtk_label_new("\nDrag and drop links from your browser into the tree view.\n");
  gtk_box_pack_start(GTK_BOX(vbox), label, FALSE, FALSE, 0);

  view = create_view_and_model();
  gtk_box_pack_start(GTK_BOX(vbox), view, TRUE, TRUE, 0);

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
