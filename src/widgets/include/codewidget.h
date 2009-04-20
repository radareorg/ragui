
#ifndef _____INCLUDE_CODEWIDGET_H__
#define _____INCLUDE_CODEWIDGET_H__

#include <glib.h>
#include <glib-object.h>
#include <stdlib.h>
#include <string.h>
#include <cairo.h>
#include <gtk/gtk.h>
#include <float.h>
#include <math.h>

G_BEGIN_DECLS


#define CODEWIDGET_TYPE_CODE_CONTEXT (codewidget_code_context_get_type ())
#define CODEWIDGET_CODE_CONTEXT(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), CODEWIDGET_TYPE_CODE_CONTEXT, CodewidgetCodeContext))
#define CODEWIDGET_CODE_CONTEXT_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), CODEWIDGET_TYPE_CODE_CONTEXT, CodewidgetCodeContextClass))
#define CODEWIDGET_IS_CODE_CONTEXT(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), CODEWIDGET_TYPE_CODE_CONTEXT))
#define CODEWIDGET_IS_CODE_CONTEXT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), CODEWIDGET_TYPE_CODE_CONTEXT))
#define CODEWIDGET_CODE_CONTEXT_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), CODEWIDGET_TYPE_CODE_CONTEXT, CodewidgetCodeContextClass))

typedef struct _CodewidgetCodeContext CodewidgetCodeContext;
typedef struct _CodewidgetCodeContextClass CodewidgetCodeContextClass;
typedef struct _CodewidgetCodeContextPrivate CodewidgetCodeContextPrivate;

#define CODEWIDGET_TYPE_JUMPS (codewidget_jumps_get_type ())
#define CODEWIDGET_JUMPS(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), CODEWIDGET_TYPE_JUMPS, CodewidgetJumps))
#define CODEWIDGET_JUMPS_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), CODEWIDGET_TYPE_JUMPS, CodewidgetJumpsClass))
#define CODEWIDGET_IS_JUMPS(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), CODEWIDGET_TYPE_JUMPS))
#define CODEWIDGET_IS_JUMPS_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), CODEWIDGET_TYPE_JUMPS))
#define CODEWIDGET_JUMPS_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), CODEWIDGET_TYPE_JUMPS, CodewidgetJumpsClass))

typedef struct _CodewidgetJumps CodewidgetJumps;
typedef struct _CodewidgetJumpsClass CodewidgetJumpsClass;
typedef struct _CodewidgetJumpsPrivate CodewidgetJumpsPrivate;

#define CODEWIDGET_TYPE_LINE (codewidget_line_get_type ())
#define CODEWIDGET_LINE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), CODEWIDGET_TYPE_LINE, CodewidgetLine))
#define CODEWIDGET_LINE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), CODEWIDGET_TYPE_LINE, CodewidgetLineClass))
#define CODEWIDGET_IS_LINE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), CODEWIDGET_TYPE_LINE))
#define CODEWIDGET_IS_LINE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), CODEWIDGET_TYPE_LINE))
#define CODEWIDGET_LINE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), CODEWIDGET_TYPE_LINE, CodewidgetLineClass))

typedef struct _CodewidgetLine CodewidgetLine;
typedef struct _CodewidgetLineClass CodewidgetLineClass;
typedef struct _CodewidgetLinePrivate CodewidgetLinePrivate;

#define CODEWIDGET_TYPE_WIDGET (codewidget_widget_get_type ())
#define CODEWIDGET_WIDGET(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), CODEWIDGET_TYPE_WIDGET, CodewidgetWidget))
#define CODEWIDGET_WIDGET_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), CODEWIDGET_TYPE_WIDGET, CodewidgetWidgetClass))
#define CODEWIDGET_IS_WIDGET(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), CODEWIDGET_TYPE_WIDGET))
#define CODEWIDGET_IS_WIDGET_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), CODEWIDGET_TYPE_WIDGET))
#define CODEWIDGET_WIDGET_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), CODEWIDGET_TYPE_WIDGET, CodewidgetWidgetClass))

typedef struct _CodewidgetWidget CodewidgetWidget;
typedef struct _CodewidgetWidgetClass CodewidgetWidgetClass;
typedef struct _CodewidgetWidgetPrivate CodewidgetWidgetPrivate;

struct _CodewidgetCodeContext {
	GObject parent_instance;
	CodewidgetCodeContextPrivate * priv;
};

struct _CodewidgetCodeContextClass {
	GObjectClass parent_class;
};

struct _CodewidgetJumps {
	GTypeInstance parent_instance;
	volatile int ref_count;
	CodewidgetJumpsPrivate * priv;
};

struct _CodewidgetJumpsClass {
	GTypeClass parent_class;
	void (*finalize) (CodewidgetJumps *self);
};

struct _CodewidgetLine {
	GTypeInstance parent_instance;
	volatile int ref_count;
	CodewidgetLinePrivate * priv;
	guint64 offset;
	char* hex;
	char* str;
};

struct _CodewidgetLineClass {
	GTypeClass parent_class;
	void (*finalize) (CodewidgetLine *self);
};

struct _CodewidgetWidget {
	GtkScrolledWindow parent_instance;
	CodewidgetWidgetPrivate * priv;
	GtkDrawingArea* da;
	double zoom;
	gint cursor;
	gint ccursor;
	double lineh;
	gint breakpoint;
	double pany;
};

struct _CodewidgetWidgetClass {
	GtkScrolledWindowClass parent_class;
};


GType codewidget_code_context_get_type (void);
CodewidgetCodeContext* codewidget_code_context_new (void);
CodewidgetCodeContext* codewidget_code_context_construct (GType object_type);
gpointer codewidget_jumps_ref (gpointer instance);
void codewidget_jumps_unref (gpointer instance);
GParamSpec* codewidget_param_spec_jumps (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
void codewidget_value_set_jumps (GValue* value, gpointer v_object);
gpointer codewidget_value_get_jumps (const GValue* value);
GType codewidget_jumps_get_type (void);
CodewidgetJumps* codewidget_jumps_new (void);
CodewidgetJumps* codewidget_jumps_construct (GType object_type);
gpointer codewidget_line_ref (gpointer instance);
void codewidget_line_unref (gpointer instance);
GParamSpec* codewidget_param_spec_line (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
void codewidget_value_set_line (GValue* value, gpointer v_object);
gpointer codewidget_value_get_line (const GValue* value);
GType codewidget_line_get_type (void);
void codewidget_line_draw (CodewidgetLine* self, cairo_t* ctx);
CodewidgetLine* codewidget_line_new (void);
CodewidgetLine* codewidget_line_construct (GType object_type);
GType codewidget_widget_get_type (void);
#define CODEWIDGET_WIDGET_S (double) 96
GtkWidget* codewidget_widget_get_widget (CodewidgetWidget* self);
void codewidget_widget_create_widgets (CodewidgetWidget* self);
void codewidget_widget_do_popup_generic (CodewidgetWidget* self);
void codewidget_widget_square (cairo_t* ctx, double w, double h);
void codewidget_widget_triangle (cairo_t* ctx, double w, double h, gboolean down);
void codewidget_widget_draw (CodewidgetWidget* self);
void codewidget_widget_refresh (CodewidgetWidget* self, GtkDrawingArea* da);
CodewidgetWidget* codewidget_widget_new (void);
CodewidgetWidget* codewidget_widget_construct (GType object_type);


G_END_DECLS

#endif
