#include <gtk/gtk.h>//jjk.c
static void destroy(GtkWidget *widget, gpointer data)
{
gtk_main_quit();
}
int main(int argc, char *argv[])
{
gtk_init(&argc, &argv);
GtkWidget *window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
gtk_window_set_title(GTK_WINDOW(window), "Window");
g_signal_connect(window, "destroy", G_CALLBACK(destroy), NULL);

GtkWidget *k;
k= gtk_fixed_new();
    gtk_container_add(GTK_CONTAINER(window), k);


       GtkWidget* la,*r;
    la = gtk_button_new_with_label (",mkl");
     gtk_fixed_put (GTK_FIXED (k), la,50,237);
    gtk_widget_set_size_request(la, 98, 90);
//    gtk_container_set_border_width(GTK_CONTAINER (la)    , 5);

union {
char w[4]={0xf,0xe,0xd,0xa};;
uint t;
} tc;



GtkCssProvider *provider = gtk_css_provider_new ();
gtk_css_provider_load_from_path (provider,
    "/home/alex/gtk-widgets.css", NULL);

    r = gtk_button_new_with_label (",kii");
     gtk_fixed_put (GTK_FIXED (k), r,150,237);
    gtk_widget_set_size_request(r, 98, 90);

    gtk_widget_set_size_request(GTK_WIDGET(window),300,349);

GtkStyleContext *context;
        context = gtk_widget_get_style_context(la);
gtk_style_context_add_provider (context,
                                    GTK_STYLE_PROVIDER(provider),
                                    GTK_STYLE_PROVIDER_PRIORITY_USER);

//    gtk_style_context_save (context);
//    gtk_style_context_add_provider_for_screen(gdk_screen_get_default(),
//                                              GTK_STYLE_PROVIDER(provider),TK_STYLE_PROVIDER_PRIORITY_USER);


gtk_widget_show_all(GTK_WIDGET(window));
#define h 7


printf("%xh\n",tc.t);
gtk_main();
return 0;
}

