#include <gtk/gtk.h>

int show_popup(GtkWidget *widget, GdkEvent *event) {
  
  const gint RIGHT_CLICK = 3;
    
  if (event->type == GDK_BUTTON_PRESS) {
      
      GdkEventButton *bevent = (GdkEventButton *) event;
      
      if (bevent->button == RIGHT_CLICK) {      
          
          gtk_menu_popup(GTK_MENU(widget), NULL, NULL, NULL, NULL,
              bevent->button, bevent->time);
          }
          
      return TRUE;
  }

  return FALSE;
}

int main(int argc, char *argv[]) {

  GtkWidget *window;
  GtkWidget *ebox;
  GtkWidget *pmenu;
  GtkWidget *hideMi;
  GtkWidget *quitMi;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window), 300, 200);
  gtk_window_set_title(GTK_WINDOW(window), "Popup menu");

  ebox = gtk_event_box_new();
  gtk_container_add(GTK_CONTAINER(window), ebox);
  
  pmenu = gtk_menu_new();
  
  hideMi = gtk_menu_item_new_with_label("Minimize");
  gtk_widget_show(hideMi);
  gtk_menu_shell_append(GTK_MENU_SHELL(pmenu), hideMi);
  
  quitMi = gtk_menu_item_new_with_label("Quit");
  gtk_widget_show(quitMi);
  gtk_menu_shell_append(GTK_MENU_SHELL(pmenu), quitMi);
  
  g_signal_connect_swapped(G_OBJECT(hideMi), "activate", 
      G_CALLBACK(gtk_window_iconify), GTK_WINDOW(window));    
  
  g_signal_connect(G_OBJECT(quitMi), "activate", 
      G_CALLBACK(gtk_main_quit), NULL);  

  g_signal_connect(G_OBJECT(window), "destroy",
      G_CALLBACK(gtk_main_quit), NULL);
        
  g_signal_connect_swapped(G_OBJECT(ebox), "button-press-event", 
      G_CALLBACK(show_popup), pmenu);  

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
