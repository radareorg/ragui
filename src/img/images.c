/* hacky inline icons */
 
#include <gtk/gtk.h>
#include <gdk/gdkpixbuf.h>
#include "rlogo.h"

GdkPixbuf* img_get_rlogo() {
	return gdk_pixbuf_new_from_inline (-1, rlogo_pixmap, FALSE, NULL);
}
