#include <glib.h>
#include <stdio.h>
#include <string.h>

#define G_LOG_DOMAIN    ((gchar*) 0)

static void _dummy(const gchar *log_domain,
                     GLogLevelFlags log_level,
                     const gchar *message,
                     gpointer user_data )

{
  /* Dummy does nothing */
  return ;
}

int main(int argc, char **argv)
{
    /* Set dummy for all levels */
    g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_MASK, _dummy, NULL);
    /* Set default handler based on argument for appropriate log level */
    if ( argc > 1)
    {
         /* If -vv passed set to ONLY debug */
         if(!strncmp("-vv", argv[1], 3))
         {
            g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_DEBUG,  g_log_default_handler, NULL);
         }
         /* If -v passed set to ONLY info */
         else if(!strncmp("-v", argv[1], 2))
         {
             g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_INFO, g_log_default_handler, NULL);
         }
        /* For everything else, set to back to default*/
         else
         {
              g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_MASK, g_log_default_handler, NULL);
         }

    }
    else /* If no arguments then set to ONLY warning & critical levels */
    {
        g_log_set_handler(G_LOG_DOMAIN, G_LOG_LEVEL_WARNING| G_LOG_LEVEL_CRITICAL, g_log_default_handler, NULL);
    }

    g_warning("This is warning\n");
    g_message("This is message\n");
    g_debug("This is debug\n");
    g_critical("This is critical\n");
    g_log(NULL, G_LOG_LEVEL_INFO , "This is info\n");
    return 0;
}
