/*
 * Auth: Eric Harlow
 * File: Notebook.c
 * 
 * Create a sample notebook application
 */

#include <gtk/gtk.h>
#include <stdio.h>
#include <stdlib.h>
#include "logtypes.h"


extern GTree *dateTree;
extern GTree *userTree;

GtkWidget *hourlyPage = NULL;
GtkWidget *dailyPage = NULL;
GtkWidget *userPage = NULL;
GtkWidget *hourlyCList = NULL;
GtkWidget *dailyCList = NULL;
GtkWidget *userCList = NULL;


typedef struct {
    GtkWidget *widget;
    long nMaxSize;
    long row;
} typGraphInfo;

/*
 * Titles displayed on the clist for the various pages
 */
char *szHourlyTitles[] = {"Hour", "Hits", "Size", "Graph"};
char *szDailyTitles[] = {"Date", "Hits", "Size", "Graph"};
char *szUserTitles[] = {"User", "Hits", "Size", "Graph"};

#define NUM_GRAPHS 21
GdkPixmap *pixmapGraph [NUM_GRAPHS];
GdkBitmap *mask[NUM_GRAPHS];

char **CreateBarBitmap (int height, int width, int size, char *sColor);
void FreeResources ();
void PopulateUser ();
void PopulateDaily ();
void PopulateHourly ();
void GetHitsForHour (int nHours, long *hits, long *size);
void FreeBarBitmap (char **bitmap);

/*
 * GeneratePixmaps
 *
 * Generate the pixmaps for all the sizes of horizontal bars 
 * that are supported. 
 */
void GeneratePixmaps (GtkWidget *widget)
{
    int i;
    gchar **pixmap_d;

    /* --- For each possible graph --- */
    for (i = 0; i < NUM_GRAPHS; i++) {

        /* --- Get the data for the graph --- */
        pixmap_d = CreateBarBitmap (9, 65, i * 3, "#ff0000");

        /* --- Create a pixmap --- */
        pixmapGraph[i] = gdk_pixmap_create_from_xpm_d (
                      widget->window,
                      &mask[i], NULL,
                      (gpointer) pixmap_d);

        /* --- Free the data --- */
        FreeBarBitmap (pixmap_d);
    }
}

/*
 * PageSwitch
 *
 * Event that occurs when a different page is now
 * the focus.
 */
static void PageSwitch (GtkWidget *widget, 
                         GtkNotebookPage *page, 
                         gint page_num)
{

}



/*
 * AddPage
 *
 * Add a page to the notebook 
 *
 * notebook - existing notebook
 * szName - name to give to the new page
 */
GtkWidget *AddPage (GtkWidget *notebook, char *szName)
{
    GtkWidget *label;
    GtkWidget *frame;

    /* --- Create a label from the name. --- */
    label = gtk_label_new (szName);
    gtk_widget_show (label);

    /* --- Create a frame for the page --- */
    frame = gtk_frame_new (szName);
    gtk_widget_show (frame);

    /* --- Add a page with the frame and label --- */
    gtk_notebook_append_page (GTK_NOTEBOOK (notebook), frame, label);

    return (frame);
}



/*
 * CreateNotebook
 *
 * Create a new notebook and add pages to it.
 *
 * window - window to create the notebook in.
 */
void CreateNotebook (GtkWidget *window)
{
    GtkWidget *notebook;

    /* --- Create the notebook --- */
    notebook = gtk_notebook_new ();

    /* --- Listen for the switch page event --- */
    gtk_signal_connect (GTK_OBJECT (notebook), "switch_page",
			  GTK_SIGNAL_FUNC (PageSwitch), NULL);

    /* --- Make sure tabs are on top --- */
    gtk_notebook_set_tab_pos (GTK_NOTEBOOK (notebook), GTK_POS_TOP);

    /* --- Add notebook to vbox --- */
    gtk_box_pack_start (GTK_BOX (window), notebook, TRUE, TRUE, 0);

    /* --- Give notebook a border --- */
    gtk_container_border_width (GTK_CONTAINER (notebook), 10);

    /* --- Add pages to the notebook --- */
    hourlyPage = AddPage (notebook, "Hourly Traffic");
    dailyPage = AddPage (notebook, "Daily Traffic");
    userPage = AddPage (notebook, "User Traffic");
      
    /* --- Show everything. --- */
    gtk_widget_show_all (window);
}


/*
 * PopulatePages
 *
 * Populate the pages on the notebook with the information.
 * Populates the hourly page, daily page, and the user page.
 *
 * Frees the data used to generate the page when done.
 */
void PopulatePages ()
{
    /* --- Free clist data if already used --- */
    if (userCList) {
        gtk_clist_clear (GTK_CLIST (userCList));
    }
    if (hourlyCList) {
        gtk_clist_clear (GTK_CLIST (hourlyCList));
    }
    if (dailyCList) {
        gtk_clist_clear (GTK_CLIST (dailyCList));
    }

    /* --- Populate each of the fields --- */
    PopulateHourly ();
    PopulateDaily ();
    PopulateUser ();

    /* --- Free the resources generated by parselog --- */
    FreeResources ();
}



/*
 * PopulateHourly 
 *
 * Populate the clist with the hourly information. 
 * Assumes that the trees are fully populated with
 * data ready to be picked.
 */
void PopulateHourly ()
{
    gchar *strValue[4];
    int i;
    int ix;
    long hits;
    long size;
    gchar buffer0[88];
    gchar buffer1[88];
    gchar buffer2[88];
    long nMaxSize = 0;
    GtkWidget *scroll_win;

    /* --- Here's the array used to insert into clist --- */
    strValue[0] = buffer0;
    strValue[1] = buffer1;
    strValue[2] = buffer2;

    /* --- This is NULL because it's a pixmap --- */
    strValue[3] = NULL;
    
    /* --- If clist not created yet... --- */
    if (hourlyCList == NULL) {

        /* --- Create a scrollable window for the clist --- */
        scroll_win = gtk_scrolled_window_new (NULL, NULL);
        gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (scroll_win),
                                        GTK_POLICY_AUTOMATIC,
                                        GTK_POLICY_AUTOMATIC);
        gtk_widget_show (scroll_win);

        /* --- Create the clist with four columns --- */
        hourlyCList = gtk_clist_new_with_titles (4, szHourlyTitles);

        /* --- Add clist to scrollable window --- */
        gtk_container_add (GTK_CONTAINER (scroll_win), hourlyCList);

        /* --- Make sure titles are visible --- */
        gtk_clist_column_titles_show (GTK_CLIST (hourlyCList));

        /* --- Set the column widths --- */
        gtk_clist_set_column_width (GTK_CLIST (hourlyCList), 0, 80);
        gtk_clist_set_column_width (GTK_CLIST (hourlyCList), 1, 80);
        gtk_clist_set_column_width (GTK_CLIST (hourlyCList), 2, 80);
        gtk_clist_set_column_width (GTK_CLIST (hourlyCList), 3, 40);

        /* --- Set the justification on each of the columns --- */
        gtk_clist_set_column_justification (GTK_CLIST (hourlyCList), 
                                            0, GTK_JUSTIFY_RIGHT);
        gtk_clist_set_column_justification (GTK_CLIST (hourlyCList), 
                                            1, GTK_JUSTIFY_RIGHT);
        gtk_clist_set_column_justification (GTK_CLIST (hourlyCList), 
                                            2, GTK_JUSTIFY_RIGHT);

        /* --- Add the clist to the correct page --- */
        gtk_container_add (GTK_CONTAINER (hourlyPage), scroll_win);
    }

    /* --- Generate a row for each hour of the day --- */
    for (i = 0; i < 24; i++) {

        /* --- Show the time - like 3:00 --- */
        sprintf (strValue[0], "%d:00", i);
 
        /* --- Get # of hits for that hour --- */
        GetHitsForHour (i, &hits, &size);

        /* --- Display hit count and byte count --- */
        sprintf (strValue[1], "%ld", hits);
        sprintf (strValue[2], "%ld", size);

        /* --- Add the data to the clist --- */
        gtk_clist_append (GTK_CLIST (hourlyCList), strValue);

        /* --- Keep track of max byte count --- */
        if (size > nMaxSize) {
            nMaxSize = size;
        }
    }


    /*
     * Now that the clist is generated, we need to go back 
     * and add the horizontal graph to the clist.  Couldn't do
     * it earlier since we didn't know what the max was. 
     */

    if (nMaxSize > 0) {

        /* --- Every hour of the day --- */
        for (i = 0; i < 24; i++) {

            /* --- Get hits for the hour --- */
            GetHitsForHour (i, &hits, &size);
    
            /* --- Calculate how big graph should be --- */
            ix = (int) (((double) size / (double) nMaxSize) * (NUM_GRAPHS-1));
     
            /* --- Display that graph in the clist --- */
            gtk_clist_set_pixmap (GTK_CLIST (hourlyCList), 
                  i, 3, (GdkPixmap *) pixmapGraph[ix], mask[ix]);
        }
    } else {

        printf ("Error: max size = 0\n");
    }
	
    /* --- Show the clist --- */
    gtk_widget_show_all (GTK_WIDGET (hourlyCList));
}




/*
 * ShowDateInfo
 *
 * Show information about the traffic on a particular 
 * day.  Dumps the information into the clist that 
 * represents the daily graph.
 *
 * This is called by the tree traverse callback!
 */
gint ShowDateInfo (gpointer key, gpointer value, gpointer data)
{
    char *strValue[4];
    typDateInfo *dateInfo;
    long *pnMax;
    char buffer0[88];
    char buffer1[88];
    char buffer2[88];

    /* --- Get info passed it --- */
    dateInfo = (typDateInfo *) value;   
    pnMax = (long *) data;

    /* --- Setup structures to populate clist --- */
    strValue[0] = buffer0;
    strValue[1] = buffer1;
    strValue[2] = buffer2;
    strValue[3] = NULL;

    /* --- Fill in the date in the first column --- */
    sprintf (strValue[0], "%02d/%02d/%4d", dateInfo->date->month, 
                                           dateInfo->date->day, 
                                           dateInfo->date->year);

    /* --- Fill in the hits and byte count --- */
    sprintf (strValue[1], "%ld", dateInfo->nHits);
    sprintf (strValue[2], "%ld", dateInfo->nSize);

    /* --- Append the data into the clist --- */
    gtk_clist_append (GTK_CLIST (dailyCList), strValue);

    /* --- Keep track of the maximum value --- */
    if (*pnMax < dateInfo->nSize) {

        *pnMax = dateInfo->nSize;
    }

    /* --- 0 => keep on trucking --- */
    return (0);
}



/*
 * ShowUserInfo
 *
 * Shows information about a user (no graphs) but keeps track 
 * of the maximum byte count so that the graphs can be generated.
 *
 * This is called as the traverse tree callback.
 */
gint ShowUserInfo (gpointer key, gpointer value, gpointer data)
{
    char *strValue[4];
    typStat *info;
    long *pnMax;
    char buffer0[88];
    char buffer1[88];
    char buffer2[88];

    /* --- Get information passed in --- */
    info = (typStat *) value;   
    pnMax = (long *) data;

    /* --- Buffers to append data --- */
    strValue[0] = buffer0;
    strValue[1] = buffer1;
    strValue[2] = buffer2;
    strValue[3] = NULL;

    /* --- Update the URL in first column --- */
    sprintf (strValue[0], "%s", info->sURL);

    /* --- Update bytes and size in next column --- */
    sprintf (strValue[1], "%ld", info->nHits);
    sprintf (strValue[2], "%ld", info->nSize);

    /* --- Add the data to the clist --- */
    gtk_clist_append (GTK_CLIST (userCList), strValue);

    /* --- Keep track of the maximum size --- */
    if (info->nSize > *pnMax) {
        *pnMax = info->nSize;
    }

    return (0);
}


/*
 * DisplayGraph
 *
 * Display the daily graph in the clist.
 *
 * Called as a Tree traverse callback.
 */
gint DisplayGraph (gpointer key, gpointer value, gpointer data)
{
    int ix;
    typGraphInfo *graphInfo = (typGraphInfo *) data;
    typDateInfo *dateInfo = (typDateInfo *) value;   

    /* --- Figure out which graph to display based on size --- */
    ix = (dateInfo->nSize * NUM_GRAPHS-1) / graphInfo->nMaxSize;

    /* --- Set the pixmap in the clist to this one --- */
    gtk_clist_set_pixmap (GTK_CLIST (graphInfo->widget), 
                          graphInfo->row, 3, pixmapGraph[ix], mask[ix]);

    /* --- Next row to display --- */
    graphInfo->row++;

    /* --- Continue... --- */
    return (0);
}



/*
 * PopulateDaily
 *
 * Populate the clist with the data from the tree. 
 * Assumes that the data in the tree has been fully
 * populated.
 */
void PopulateDaily ()
{
    gchar *strValue[4];
    long nMaxDaily;
    gchar buffer0[88];
    gchar buffer1[88];
    gchar buffer2[88];
    typGraphInfo graphInfo;
    GtkWidget *scroll_win;

    /* --- Create the table --- */
    strValue[0] = buffer0;
    strValue[1] = buffer1;
    strValue[2] = buffer2;

    /* --- NULL - graphic is going here. --- */
    strValue[3] = NULL;
    
    /* --- If the clist has not been created yet... --- */
    if (dailyCList == NULL) {

        /* --- Create a scrollable window for the clist --- */
        scroll_win = gtk_scrolled_window_new (NULL, NULL);
        gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (scroll_win),
                                        GTK_POLICY_AUTOMATIC,
                                        GTK_POLICY_AUTOMATIC);
        gtk_widget_show (scroll_win);

        /* --- Create the clist --- */
        dailyCList = gtk_clist_new_with_titles (4, szDailyTitles);

        /* --- Add clist to scrollable window --- */
        gtk_container_add (GTK_CONTAINER (scroll_win), dailyCList);

        /* --- Make sure titles are being shown --- */
        gtk_clist_column_titles_show (GTK_CLIST (dailyCList));

        /* --- Set the column widths --- */
        gtk_clist_set_column_width (GTK_CLIST (dailyCList), 0, 80);
        gtk_clist_set_column_width (GTK_CLIST (dailyCList), 1, 80);
        gtk_clist_set_column_width (GTK_CLIST (dailyCList), 2, 80);

        /* --- Set the column justifications --- */
        gtk_clist_set_column_justification (GTK_CLIST (dailyCList), 
                                            0, GTK_JUSTIFY_RIGHT);
        gtk_clist_set_column_justification (GTK_CLIST (dailyCList), 
                                            1, GTK_JUSTIFY_RIGHT);
        gtk_clist_set_column_justification (GTK_CLIST (dailyCList), 
                                            2, GTK_JUSTIFY_RIGHT);

        /* --- Add the clist to the notebook page --- */
        gtk_container_add (GTK_CONTAINER (dailyPage), scroll_win);
    }

    /* --- set max to zero --- */
    nMaxDaily = 0;

    /* 
     * --- Traverse tree and display the textual information 
     *     while gathering the maximum so that the graph can
     *     be displayed
     */
    g_tree_traverse (dateTree, ShowDateInfo, G_IN_ORDER, &nMaxDaily);
 
    /* --- Information for displaying of the graph --- */
    graphInfo.nMaxSize = nMaxDaily;
    graphInfo.widget = dailyCList;
    graphInfo.row = 0;

    /* --- Re-traverse the tree and display graphs --- */
    g_tree_traverse (dateTree, DisplayGraph, G_IN_ORDER, &graphInfo);

    /* --- Show the clist now --- */
    gtk_widget_show_all (GTK_WIDGET (dailyCList));
}


/*
 * DisplayUserGraph
 *
 * Display the graph for each user. 
 * This is called from a traverse tree - it's a callback with the
 * data passed into it. 
 *
 * value - contains information about this users activity
 * data - contains information about the graph, incl. widget and max
 */
gint DisplayUserGraph (gpointer key, gpointer value, gpointer data)
{
    int ix;
    typGraphInfo *graphInfo = (typGraphInfo *) data;
    typStat *statInfo = (typStat *) value;   

    /* --- How big should the graph be? --- */
    ix = (long) (((double) statInfo->nSize * NUM_GRAPHS-1) / 
                           graphInfo->nMaxSize);

    /* --- Set the pixmap to be an appropriate size --- */
    gtk_clist_set_pixmap (GTK_CLIST (graphInfo->widget), 
                          graphInfo->row, 3, pixmapGraph[ix], mask[ix]);

    /* --- Go to the next row. --- */
    graphInfo->row++;

    return (0);
}


/*
 * PopulateUser
 *
 * Populate the user graph with the information about each users's 
 * web site traffic.  The display is created in two parts.  The 
 * first part displays the text data and computes the necessary
 * values for the second part to display the graph.
 */
void PopulateUser ()
{
    gchar *strValue[4];
    gchar buffer0[88];
    gchar buffer1[88];
    gchar buffer2[88];
    long nMax;
    typGraphInfo graphInfo;
    GtkWidget *scroll_win;

    /* --- Buffered values --- */
    strValue[0] = buffer0;
    strValue[1] = buffer1;
    strValue[2] = buffer2;
    strValue[3] = NULL;
    
    /* --- If there's no user clist yet --- */
    if (userCList == NULL) {

        /* --- Create a scrollable window for the clist --- */
        scroll_win = gtk_scrolled_window_new (NULL, NULL);
        gtk_scrolled_window_set_policy (GTK_SCROLLED_WINDOW (scroll_win),
                                        GTK_POLICY_AUTOMATIC,
                                        GTK_POLICY_AUTOMATIC);
        gtk_widget_show (scroll_win);

        /* --- Create the clist with titles --- */
        userCList = gtk_clist_new_with_titles (4, szUserTitles);

        /* --- Add clist to scrollable window --- */
        gtk_container_add (GTK_CONTAINER (scroll_win), userCList);

        /* --- Show titles --- */
        gtk_clist_column_titles_show (GTK_CLIST (userCList));

        /* --- Show width of columns. --- */
        gtk_clist_set_column_width (GTK_CLIST (userCList), 0, 80);
        gtk_clist_set_column_width (GTK_CLIST (userCList), 1, 80);
        gtk_clist_set_column_width (GTK_CLIST (userCList), 2, 80);

        /* --- Justify columns --- */
        gtk_clist_set_column_justification (GTK_CLIST (userCList), 
                                            0, GTK_JUSTIFY_LEFT);
        gtk_clist_set_column_justification (GTK_CLIST (userCList), 
                                            1, GTK_JUSTIFY_RIGHT);
        gtk_clist_set_column_justification (GTK_CLIST (userCList), 
                                            2, GTK_JUSTIFY_RIGHT);

        /* --- Add clist to page. --- */
        gtk_container_add (GTK_CONTAINER (userPage), scroll_win);
    }

    /* --- Traverse the tree to show text info and get max --- */
    nMax = 0;
    g_tree_traverse (userTree, ShowUserInfo, G_IN_ORDER, &nMax);

    /* --- Populate structure for graphical tree traversal --- */
    graphInfo.nMaxSize = nMax;
    graphInfo.widget = userCList;
    graphInfo.row = 0;

    /* --- Display graphs --- */
    g_tree_traverse (userTree, DisplayUserGraph, G_IN_ORDER, &graphInfo);

    gtk_widget_show_all (GTK_WIDGET (userCList));
}



