// gcc -o search main.c `pkg-config --libs --cflags gtk+-2.0`
#include <gtk/gtk.h>
#include <gdk/gdkkeysyms.h>

gboolean key_pressed(GtkWidget *window,
    GdkEventKey* event, GtkTextBuffer *buffer) {

  GtkTextIter start_sel, end_sel;
  GtkTextIter start_find, end_find;
  GtkTextIter start_match, end_match;
  gboolean selected;
  gchar *text;

  if ((event->type == GDK_KEY_PRESS) &&
     (event->state & GDK_CONTROL_MASK)) {

    switch (event->keyval) {

      case GDK_m :
        selected = gtk_text_buffer_get_selection_bounds(buffer,
            &start_sel, &end_sel);
      if (selected) {
        gtk_text_buffer_get_start_iter(buffer, &start_find);
        gtk_text_buffer_get_end_iter(buffer, &end_find);

        gtk_text_buffer_remove_tag_by_name(buffer, "gray_bg",
            &start_find, &end_find);
        text = (gchar *) gtk_text_buffer_get_text(buffer, &start_sel,
            &end_sel, FALSE);

        while (gtk_text_iter_forward_search(&start_find, text,
                GTK_TEXT_SEARCH_TEXT_ONLY |
                GTK_TEXT_SEARCH_VISIBLE_ONLY,
                &start_match, &end_match, NULL)) {

          gtk_text_buffer_apply_tag_by_name(buffer, "gray_bg",
              &start_match, &end_match);
          gint offset = gtk_text_iter_get_offset(&end_match);
          gtk_text_buffer_get_iter_at_offset(buffer,
              &start_find, offset);
        }

        g_free(text);
      }

      break;

      case GDK_r:
        gtk_text_buffer_get_start_iter(buffer, &start_find);
        gtk_text_buffer_get_end_iter(buffer, &end_find);

        gtk_text_buffer_remove_tag_by_name(buffer, "gray_bg",
            &start_find, &end_find);
      break;
    }
  }

  return FALSE;
}

int main(int argc, gchar *argv[]) {

  GtkWidget *window;
  GtkWidget *view;
  GtkWidget *vbox;

  GtkTextBuffer *buffer;
  GtkTextIter start, end;
  GtkTextIter iter;

  gtk_init(&argc, &argv);

  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_window_set_position(GTK_WINDOW(window), GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window), 350, 300);
  gtk_window_set_title(GTK_WINDOW(window), "Search & highlight");
  GTK_WINDOW(window)->allow_shrink = TRUE;

  vbox = gtk_vbox_new(FALSE, 0);
  view = gtk_text_view_new();
  gtk_widget_add_events(view, GDK_BUTTON_PRESS_MASK);
  gtk_box_pack_start(GTK_BOX(vbox), view, TRUE, TRUE, 0);

  buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(view));
  gtk_text_buffer_create_tag(buffer, "gray_bg",
      "background", "lightgray", NULL);
  gtk_container_add(GTK_CONTAINER(window), vbox);

  g_signal_connect(G_OBJECT(window), "destroy",
        G_CALLBACK(gtk_main_quit), NULL);

  g_signal_connect(G_OBJECT(window), "key-press-event",
        G_CALLBACK(key_pressed), buffer);

  gtk_widget_show_all(window);

  gtk_main();

  return 0;
}
