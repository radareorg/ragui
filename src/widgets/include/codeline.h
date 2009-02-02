
#ifndef __CODELINE_H__
#define __CODELINE_H__

#include <glib.h>
#include <glib-object.h>
#include <stdlib.h>
#include <string.h>
#include <cairo.h>

G_BEGIN_DECLS


#define CODEWIDGET_TYPE_LINE (codewidget_line_get_type ())
#define CODEWIDGET_LINE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), CODEWIDGET_TYPE_LINE, CodewidgetLine))
#define CODEWIDGET_LINE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), CODEWIDGET_TYPE_LINE, CodewidgetLineClass))
#define CODEWIDGET_IS_LINE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), CODEWIDGET_TYPE_LINE))
#define CODEWIDGET_IS_LINE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), CODEWIDGET_TYPE_LINE))
#define CODEWIDGET_LINE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), CODEWIDGET_TYPE_LINE, CodewidgetLineClass))

typedef struct _CodewidgetLine CodewidgetLine;
typedef struct _CodewidgetLineClass CodewidgetLineClass;
typedef struct _CodewidgetLinePrivate CodewidgetLinePrivate;
typedef struct _CodewidgetParamSpecLine CodewidgetParamSpecLine;

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

struct _CodewidgetParamSpecLine {
	GParamSpec parent_instance;
};


void codewidget_line_draw (CodewidgetLine* self, cairo_t* ctx);
CodewidgetLine* codewidget_line_construct (GType object_type);
CodewidgetLine* codewidget_line_new (void);
GParamSpec* codewidget_param_spec_line (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
gpointer codewidget_value_get_line (const GValue* value);
void codewidget_value_set_line (GValue* value, gpointer v_object);
GType codewidget_line_get_type (void);
gpointer codewidget_line_ref (gpointer instance);
void codewidget_line_unref (gpointer instance);


G_END_DECLS

#endif
