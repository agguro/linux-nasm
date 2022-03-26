#include <gtk/gtk.h>

gint handler_id;

void button_clicked() {
     
  g_print("clicked\n");
}

void toogle_signal(GtkWidget *widget, gpointer window) {
    
  if (gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(widget))) {
     handler_id = g_signal_connect(G_OBJECT(window), "clicked", 
           G_CALLBACK(button_clicked), NULL);
  } else {
     g_signal_handler_disconnect(window, handler_id);
  }
}

int main(int argc, char *argv[]) {

  GtkWidget *window;
  GtkWidget *hbox;
  GtkWidget *vbox;
  GtkWidget *btn;
  GtkWidget *cb;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window), 300, 200);
  gtk_container_set_border_width(GTK_CONTAINER(window), 15);
  gtk_window_set_title(GTK_WINDOW(window), "Disconnect");

  hbox = gtk_hbox_new(FALSE, 15);

  btn = gtk_button_new_with_label("Click");
  gtk_widget_set_size_request(btn, 70, 30);
  gtk_box_pack_start(GTK_BOX(hbox), btn, FALSE, FALSE, 0);

  cb = gtk_check_button_new_with_label("Connect");
  gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(cb), TRUE);
  gtk_box_pack_start(GTK_BOX(hbox), cb, FALSE, FALSE, 0);
  
  vbox = gtk_vbox_new(FALSE, 5);
  gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);
  gtk_container_add(GTK_CONTAINER(window), vbox);  

  handler_id = g_signal_connect(G_OBJECT(btn), "clicked", 
      G_CALLBACK(button_clicked), NULL);

  g_signal_connect(G_OBJECT(cb), "clicked",
      G_CALLBACK(toogle_signal), (gpointer) btn);

  g_signal_connect(G_OBJECT(window), "destroy",
      G_CALLBACK(gtk_main_quit), NULL);

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
