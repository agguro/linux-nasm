#include <gtk/gtk.h>

int main(int argc, char *argv[]) {

  GtkWidget *window;
  GtkWidget *label;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_title(GTK_WINDOW(window), "No sleep");
  gtk_container_set_border_width(GTK_CONTAINER(window), 15);

  label = gtk_label_new("I've always been too lame\n\
To see what's before me\n\
And I know nothing sweeter than\n\
Champaign from last New Years\n\
Sweet music in my ears\n\
And a night full of no fears\n\
\n\
But if I had one wish fulfilled tonight\n\
I'd ask for the sun to never rise\n\
If God passed a mic to me to speak\n\
I'd say \"Stay in bed, world,\n\
Sleep in peace");

  gtk_label_set_justify(GTK_LABEL(label), GTK_JUSTIFY_CENTER);
  gtk_container_add(GTK_CONTAINER(window), label);

  g_signal_connect(window, "destroy",
      G_CALLBACK(gtk_main_quit), NULL);

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
