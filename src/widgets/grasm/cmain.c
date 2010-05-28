#include "grasmwidget.h"

int main(int argc, char **argv) {
	GrasmwidgetWidget *grasm;
	GtkWindow *w;
	char *_tmp0 = "label";
	char *_tmp1 = "mov eax, ebx\nmov ebx,ecx\n inc ecx";
	
	gtk_init (&argc, &argv);

	grasm = grasmwidget_widget_new();

	/* window and so */
	w = (GtkWindow *)gtk_window_new(GTK_WINDOW_TOPLEVEL);
	gtk_window_resize(w, 300, 200);
	g_signal_connect (w, "destroy", G_CALLBACK (gtk_main_quit), NULL);

	gtk_container_add(GTK_CONTAINER(w), grasmwidget_widget_get_widget(grasm));

	//g_signal_connect_object (grava, "load-graph-at", ((GCallback) load_graph_at), grava, 0);

	gtk_widget_show_all(GTK_WIDGET(w));

	gtk_main();

	return 0;
}
