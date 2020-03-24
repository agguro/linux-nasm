//glib-compile-resources exampleapp.gresource.xml --target=resource.c --generate-source
//glib-compile-schemas --strict --dry-run --schema-file=org.gtk.exampleapp.gschema.xml && mkdir -p . && touch org.gtk.exampleapp.gschema.valid
//glib-compile-schemas .
//https://gitlab.gnome.org/GNOME/gtk/tree/gtk-3-22/examples/application9

#include <gtk/gtk.h>

#include "exampleapp.h"

int
main (int argc, char *argv[])
{
  /* Since this example is running uninstalled,
   * we have to help it find its schema. This
   * is *not* necessary in properly installed
   * application.
   */
  g_setenv ("GSETTINGS_SCHEMA_DIR", ".", FALSE);

  return g_application_run (G_APPLICATION (example_app_new ()), argc, argv);
}
