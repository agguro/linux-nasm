#include <gtk/gtk.h>

void combo_select (GtkWidget *widget, gpointer *data)
{
    g_print ("combo select - %s\n", data);
}

GtkWidget *CreateMenuCombobox ()
{
#define NUM_COMBO_ITEMS 5
    char *height_list[NUM_COMBO_ITEMS] = {
        "Tall",
        "Not quite tall",
        "Medium",
        "Short",
        "Wish I was tall"
};

    GtkWidget *omenu;
    GtkWidget *menu;
    GtkWidget *menuitem;
    GSList *group;
    int i;

    omenu = gtk_option_menu_new ();
    menu = gtk_menu_new ();
    group = NULL;

    for (i = 0; i < NUM_COMBO_ITEMS; i++) {

        // --- Create a menu item with a label
        menuitem = gtk_radio_menu_item_new_with_label (group, height_list[i]);

        // --- Get the group that the menu item is in.
        group = gtk_radio_menu_item_group (GTK_RADIO_MENU_ITEM (menuitem));

        // --- Add the menu item to the menu
        gtk_menu_append (GTK_MENU (menu), menuitem);

        // --- Make the item visible
        gtk_widget_show (menuitem);
}
        // --- Let me know when it's selected
        gtk_signal_connect_object (GTK_OBJECT (menuitem),
                                   "select",
                                   GTK_SIGNAL_FUNC (combo_select),
                                   height_list[i]);

//    }

    // --- Associate the menu with the option menu.
    gtk_option_menu_set_menu (GTK_OPTION_MENU (omenu), menu);

    gtk_widget_show (omenu);

    return (omenu);
}
//
// delete_event
//
// Called when the window is closed.
//
void delete_event (GtkWidget *widget, gpointer *data)
{
    gtk_main_quit ();
}


//
// Program starts here
//
int main (int argc, char *argv[])
{
    GtkWidget *window;
    GtkWidget *box;
    GtkWidget *vbox;

    // --- GTK initialization
    gtk_init (&argc, &argv);

    // --- Create the top level window
    window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

    // --- You should always remember to connect the destroy event
    //     to the main window.
    gtk_signal_connect (GTK_OBJECT (window), "delete_event",
            GTK_SIGNAL_FUNC (delete_event), NULL);

    // --- Give the window a border
    gtk_container_border_width (GTK_CONTAINER (window), 10);

    // --- Create a new vbox -
    vbox = gtk_vbox_new (FALSE, 3);

    // --- Create a drop down list.
    box = CreateMenuCombobox ();
    gtk_box_pack_start (GTK_BOX (vbox), box, FALSE, FALSE, 10);

    // --- Add the box and make it visible
    gtk_widget_show (vbox);

    // --- Make the main window visible
    gtk_container_add (GTK_CONTAINER (window), vbox);
    gtk_widget_show (window);

    gtk_main ();
    exit (0);
}
