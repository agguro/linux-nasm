#include "cpu.h"

void cb_changed(GtkRange *range, GtkWidget *cpu) {

   my_cpu_set_percent(MY_CPU(cpu), gtk_range_get_value(range));
}

int main(int argc, char *argv[]) {

   GtkWidget *window;
   GtkWidget *hbox;
   GtkWidget *vbox;
   GtkWidget *cpu;
   GtkWidget *scale;

   gtk_init(&argc, &argv);

   window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
   gtk_container_set_border_width(GTK_CONTAINER(window), 15);
   gtk_window_set_title(GTK_WINDOW(window), "CPU widget");

   vbox = gtk_vbox_new(FALSE, 0);
   hbox = gtk_hbox_new(FALSE, 25);

   cpu = my_cpu_new();
   gtk_box_pack_start(GTK_BOX(hbox), cpu, FALSE, FALSE, 0);

   scale = gtk_vscale_new_with_range(0, 100, 1);
   gtk_scale_set_draw_value(GTK_SCALE(scale), FALSE);
   gtk_range_set_inverted(GTK_RANGE(scale), TRUE);
   gtk_box_pack_start(GTK_BOX(hbox), scale, FALSE, FALSE, 0);

   gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);
   gtk_container_add(GTK_CONTAINER(window), vbox);

   g_signal_connect(scale, "value-changed", G_CALLBACK(cb_changed), cpu);
   g_signal_connect(window, "destroy", G_CALLBACK(gtk_main_quit), NULL);

   gtk_widget_show_all(window);

   gtk_main();

   return 0;
}
