https://en.wikibooks.org/wiki/GTK%2B_By_Example/Tree_View/DnD
#include <gtk/gtk.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define DESCRIPTION "Drag and Drop within a Treeview - by Pierre-Louis Malatray"

/* Row data structure */
struct DATA {
        char *row;
        char *item;
        int qty;
        float price;
};

/* A convenience enumerator to tag data types */
enum {
        TARGET_STRING,
        TARGET_INTEGER,
        TARGET_FLOAT
};

/* A convenience enumerator to count the columns */
enum {
        ROW_COL=0,
        ITEM_COL,
        QTY_COL,
        PRICE_COL,
        NUM_COLS
};

/* Some sample data for treeview 1. A NULL row is added so we dont
   need to pass around the size of the array */
static struct DATA row_data[] = {
        { "row0","item 12", 3, 4.3 },
        { "row1","item 23", 44,34.4},
        { "row2","item 33", 34,25.4},
        { "row3","item 43", 37,64.4},
        { "row4","item 53", 12,14.4},
        { "row5","item 68", 42,34.4},
        { "row6","item 75", 72,74.4},
        {NULL}
};

gboolean dndactive = FALSE;

/* Convenience function to deallocated memory used for DATA struct */
void free_DATA(struct DATA *data){
        if(data){
                free(data->row);
                free(data->item);
        }
        free(data);
}

/* Convenience function to print out the contents of a DATA struct onto stdout */
void print_DATA(struct DATA *data){
        printf("DATA @ %p\n",data);
        printf(" |->row = %s\n",data->row);
        printf(" |->item = %s\n",data->item);
        printf(" |->qty = %i\n",data->qty);
        printf(" +->price = %f\n",data->price);
}

void on_drag_data_deleted(GtkTreeModel *tree_model, GtkTreePath *path, GtkTreeIter *iter, gpointer user_data)
{
    /* useless for DnD operations */
    printf("on_drag_data_deleted\n");
}

void on_drag_data_inserted(GtkTreeModel *tree_model, GtkTreePath *path, GtkTreeIter *iter, gpointer user_data)
{
    printf("on_drag_data_inserted\n");
    /* activate DnD operation */
    dndactive = TRUE;
}

void on_drag_data_changed(GtkTreeModel *tree_model, GtkTreePath *path, GtkTreeIter *iter, gpointer user_data)
{
    /* Always initialise a GValue with 0 */
    GValue value={0,};
    char *cptr, *spath;
    gint prof;

    printf("on_drag_data_changed\n");
    if (!dndactive) {
        /* No DnD active here */
        printf("on_drag_data_changed : DND off\n");
        return;
    }

    /* Manage DnD operation */

    /* Get the GValue of a particular column from the row, the iterator currently points to*/
    gtk_tree_model_get_value(tree_model, iter, ROW_COL, &value);
    cptr = (char*) g_value_get_string(&value);
    spath = gtk_tree_path_to_string(path);
    prof = gtk_tree_path_get_depth(path);
    printf("on_drag_data_changed : cell=%s, path=%s, prof=%d\n", cptr, spath, prof);
    g_value_unset(&value);
}

/* Creates a scroll window, puts a treeview in it and populates it */
GtkWidget *add_treeview(GtkWidget *box, struct DATA array[])
{
    GtkWidget *swindow;
    GtkWidget *tree_view;
    GtkTreeStore *tree_store;
    GtkTreeModel *tree_model;
    GtkCellRenderer *renderer;
    GtkTreeViewColumn *column;
    int i;

    char column_names[NUM_COLS][16] = {"Row #", "Description", "Qty", "Price"};

    swindow = gtk_scrolled_window_new(NULL, NULL);

    /* Both Vertical and Horizontal scroll set to Auto (NULL) */
    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(swindow),
                                GTK_POLICY_AUTOMATIC,GTK_POLICY_AUTOMATIC);

    /* Add this window to the box */
    gtk_box_pack_start(GTK_BOX(box),swindow,TRUE,TRUE,2);

    /* Create the treeview and its tree store */
    tree_store = gtk_tree_store_new(NUM_COLS,
                            G_TYPE_STRING,G_TYPE_STRING,G_TYPE_INT,G_TYPE_FLOAT);

    tree_view = gtk_tree_view_new_with_model(GTK_TREE_MODEL(tree_store));

    /* Add the treeview to the scrolled window */
    gtk_container_add(GTK_CONTAINER(swindow), tree_view);

    /* Add the columns */
    for(i = 0; i < 4; i++) {
        renderer = gtk_cell_renderer_text_new();
        column = gtk_tree_view_column_new_with_attributes (
                                        column_names[i],renderer,"text",i,NULL);
        gtk_tree_view_column_set_sort_column_id (column, i);
        gtk_tree_view_append_column (GTK_TREE_VIEW(tree_view), column);
    }

    /* Tell the theme engine we would like differentiated row colour */
    gtk_tree_view_set_rules_hint(GTK_TREE_VIEW(tree_view),TRUE);

    /* Add the data */
    GtkTreeIter iter;
    i = 0;
    while(array[++i].row != NULL) {
        gtk_tree_store_append(tree_store, &iter, NULL);
        gtk_tree_store_set(tree_store, &iter,
                            ROW_COL,array[i].row,
                            ITEM_COL,array[i].item,
                            QTY_COL,array[i].qty,
                            PRICE_COL,array[i].price,-1);
    }

    /* Prepare treeview for DnD facility */

    /* Set treeview reorderable */
    gtk_tree_view_set_reorderable(GTK_TREE_VIEW(tree_view), TRUE);

    /* Get treeview model to connect events on it */
    tree_model = gtk_tree_view_get_model(GTK_TREE_VIEW(tree_view));

    // Attach a "drag-data-deleted" signal - useless here
    g_signal_connect(GTK_WIDGET(tree_model),"row-deleted", G_CALLBACK(on_drag_data_deleted), NULL);
    // Attach a "drag-data-inserted" signal to start DnD operation
    g_signal_connect(GTK_WIDGET(tree_model), "row-inserted", G_CALLBACK(on_drag_data_inserted), NULL);
    // Attach a "drag-data-changed" signal to manage data
    g_signal_connect(GTK_WIDGET(tree_model), "row-changed", G_CALLBACK(on_drag_data_changed), NULL);

    return tree_view;
}

int main(int argc, char **argv)
{
    GtkWidget *window;
    GtkTreeModel *model;

    gtk_init(&argc,&argv);

    /* Create the top level window and setup the quit callback */
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_default_size(GTK_WINDOW(window),666,266);
    g_signal_connect(G_OBJECT(window),"destroy",G_CALLBACK(gtk_exit),NULL);

    /* Build up the GUI with some boxes */
    GtkWidget *vbox = gtk_vbox_new(FALSE,10);
    gtk_container_add(GTK_CONTAINER(window),vbox);

    /* Add a title */
    GtkWidget *title = gtk_label_new(DESCRIPTION);
    gtk_box_pack_start(GTK_BOX(vbox),title,FALSE,FALSE,1);

    GtkWidget *hbox = gtk_hbox_new(TRUE,1);
    gtk_box_pack_start(GTK_BOX(vbox),hbox,TRUE,TRUE,1);

    /* Create treeview */
    GtkWidget *view1;
    view1 = add_treeview(hbox, row_data);

    /* Rock'n Roll */
    gtk_widget_show_all(window);
    gtk_main();
    return 0;
}
