#include <gtk/gtk.h>
#include <string.h>

static void
print_hello (GtkWidget *widget,
             gpointer   data)
{
  g_print ("Hello World\n");
}

int
main (int   argc,
      char *argv[])
{
  GtkBuilder *builder;
  GObject *window;
  GObject *button;

  gtk_init (&argc, &argv);

  /* Construct a GtkBuilder instance and load our UI description */
  /* don't use file extensions .ui with Qt, it gets upset because this is
   * the extension for forms that it wants to open in design mode. */
  builder = gtk_builder_new ();
  
  // shorter than resource, resource file is the same plus additional info
  // additional tip: with NASM this can be performed by the INCBIN directive
  char* str = \
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>" \
"<!-- Generated with glade 3.18.3 -->" \
"<interface>" \
"<requires lib=\"gtk+\" version=\"3.12\"/>" \
"<object class=\"GtkWindow\" id=\"window1\">" \
"<property name=\"visible\">True</property>" \
"<property name=\"can_focus\">False</property>" \
"<property name=\"border_width\">10</property>" \
"<property name=\"title\">Grid</property>" \
"<child>" \
"<object class=\"GtkGrid\" id=\"grid\">" \
"<property name=\"visible\">True</property>" \
"<property name=\"can_focus\">False</property>" \
"<child>" \
"<object class=\"GtkButton\" id=\"button1\">" \
"<property name=\"label\">Button 1</property>" \
"<property name=\"visible\">True</property>" \
"<property name=\"can_focus\">False</property>" \
"<property name=\"receives_default\">False</property>" \
"</object>" \
"<packing>" \
"<property name=\"left_attach\">0</property>" \
"<property name=\"top_attach\">0</property>" \
"</packing>" \
"</child>" \
"<child>" \
"<object class=\"GtkButton\" id=\"button2\">" \
"<property name=\"label\">Button 2</property>" \
"<property name=\"visible\">True</property>" \
"<property name=\"can_focus\">False</property>" \
"<property name=\"receives_default\">False</property>" \
"</object>" \
"<packing>" \
"<property name=\"left_attach\">1</property>" \
"<property name=\"top_attach\">0</property>" \
"</packing>" \
"</child>" \
"<child>" \
"<object class=\"GtkButton\" id=\"quit\">" \
"<property name=\"label\">Quit</property>" \
"<property name=\"visible\">True</property>" \
"<property name=\"can_focus\">False</property>" \
"<property name=\"receives_default\">False</property>" \
"</object>" \
"<packing>" \
"<property name=\"left_attach\">0</property>" \
"<property name=\"top_attach\">1</property>" \
"<property name=\"width\">2</property>" \
"</packing>" \
"</child>" \
"</object>" \
"</child>" \
"</object>" \
"</interface>";
          
  gtk_builder_add_from_string(builder,str,strlen(str),NULL);

  /* Connect signal handlers to the constructed widgets. */
  window = gtk_builder_get_object (builder, "window1");
  g_signal_connect (window, "destroy", G_CALLBACK (gtk_main_quit), NULL);
  g_signal_connect (window, "destroy", G_CALLBACK (gtk_main_quit), NULL);

  button = gtk_builder_get_object (builder, "button1");
  g_signal_connect (button, "clicked", G_CALLBACK (print_hello), NULL);

  button = gtk_builder_get_object (builder, "button2");
  g_signal_connect (button, "clicked", G_CALLBACK (print_hello), NULL);

  button = gtk_builder_get_object (builder, "quit");
  g_signal_connect (button, "clicked", G_CALLBACK (gtk_main_quit), NULL);

  gtk_main ();

  return 0;
}
