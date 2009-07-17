
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


#define RAGUI_WIDGET_CODE_VIEW_TYPE_CODE_CONTEXT (ragui_widget_code_view_code_context_get_type ())
#define RAGUI_WIDGET_CODE_VIEW_CODE_CONTEXT(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), RAGUI_WIDGET_CODE_VIEW_TYPE_CODE_CONTEXT, RaguiWidgetCodeViewCodeContext))
#define RAGUI_WIDGET_CODE_VIEW_CODE_CONTEXT_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), RAGUI_WIDGET_CODE_VIEW_TYPE_CODE_CONTEXT, RaguiWidgetCodeViewCodeContextClass))
#define RAGUI_WIDGET_CODE_VIEW_IS_CODE_CONTEXT(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), RAGUI_WIDGET_CODE_VIEW_TYPE_CODE_CONTEXT))
#define RAGUI_WIDGET_CODE_VIEW_IS_CODE_CONTEXT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), RAGUI_WIDGET_CODE_VIEW_TYPE_CODE_CONTEXT))
#define RAGUI_WIDGET_CODE_VIEW_CODE_CONTEXT_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), RAGUI_WIDGET_CODE_VIEW_TYPE_CODE_CONTEXT, RaguiWidgetCodeViewCodeContextClass))

typedef struct _RaguiWidgetCodeViewCodeContext RaguiWidgetCodeViewCodeContext;
typedef struct _RaguiWidgetCodeViewCodeContextClass RaguiWidgetCodeViewCodeContextClass;
typedef struct _RaguiWidgetCodeViewCodeContextPrivate RaguiWidgetCodeViewCodeContextPrivate;

#define RAGUI_WIDGET_CODE_VIEW_TYPE_JUMP_LINES (ragui_widget_code_view_jump_lines_get_type ())
#define RAGUI_WIDGET_CODE_VIEW_JUMP_LINES(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), RAGUI_WIDGET_CODE_VIEW_TYPE_JUMP_LINES, RaguiWidgetCodeViewJumpLines))
#define RAGUI_WIDGET_CODE_VIEW_JUMP_LINES_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), RAGUI_WIDGET_CODE_VIEW_TYPE_JUMP_LINES, RaguiWidgetCodeViewJumpLinesClass))
#define RAGUI_WIDGET_CODE_VIEW_IS_JUMP_LINES(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), RAGUI_WIDGET_CODE_VIEW_TYPE_JUMP_LINES))
#define RAGUI_WIDGET_CODE_VIEW_IS_JUMP_LINES_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), RAGUI_WIDGET_CODE_VIEW_TYPE_JUMP_LINES))
#define RAGUI_WIDGET_CODE_VIEW_JUMP_LINES_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), RAGUI_WIDGET_CODE_VIEW_TYPE_JUMP_LINES, RaguiWidgetCodeViewJumpLinesClass))

typedef struct _RaguiWidgetCodeViewJumpLines RaguiWidgetCodeViewJumpLines;
typedef struct _RaguiWidgetCodeViewJumpLinesClass RaguiWidgetCodeViewJumpLinesClass;
typedef struct _RaguiWidgetCodeViewJumpLinesPrivate RaguiWidgetCodeViewJumpLinesPrivate;

#define RAGUI_WIDGET_CODE_VIEW_TYPE_LINE (ragui_widget_code_view_line_get_type ())
#define RAGUI_WIDGET_CODE_VIEW_LINE(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), RAGUI_WIDGET_CODE_VIEW_TYPE_LINE, RaguiWidgetCodeViewLine))
#define RAGUI_WIDGET_CODE_VIEW_LINE_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), RAGUI_WIDGET_CODE_VIEW_TYPE_LINE, RaguiWidgetCodeViewLineClass))
#define RAGUI_WIDGET_CODE_VIEW_IS_LINE(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), RAGUI_WIDGET_CODE_VIEW_TYPE_LINE))
#define RAGUI_WIDGET_CODE_VIEW_IS_LINE_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), RAGUI_WIDGET_CODE_VIEW_TYPE_LINE))
#define RAGUI_WIDGET_CODE_VIEW_LINE_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), RAGUI_WIDGET_CODE_VIEW_TYPE_LINE, RaguiWidgetCodeViewLineClass))

typedef struct _RaguiWidgetCodeViewLine RaguiWidgetCodeViewLine;
typedef struct _RaguiWidgetCodeViewLineClass RaguiWidgetCodeViewLineClass;
typedef struct _RaguiWidgetCodeViewLinePrivate RaguiWidgetCodeViewLinePrivate;

#define RAGUI_WIDGET_CODEVIEW_TYPE_WIDGET (ragui_widget_codeview_widget_get_type ())
#define RAGUI_WIDGET_CODEVIEW_WIDGET(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), RAGUI_WIDGET_CODEVIEW_TYPE_WIDGET, RaguiWidgetCodeviewWidget))
#define RAGUI_WIDGET_CODEVIEW_WIDGET_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), RAGUI_WIDGET_CODEVIEW_TYPE_WIDGET, RaguiWidgetCodeviewWidgetClass))
#define RAGUI_WIDGET_CODEVIEW_IS_WIDGET(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), RAGUI_WIDGET_CODEVIEW_TYPE_WIDGET))
#define RAGUI_WIDGET_CODEVIEW_IS_WIDGET_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), RAGUI_WIDGET_CODEVIEW_TYPE_WIDGET))
#define RAGUI_WIDGET_CODEVIEW_WIDGET_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), RAGUI_WIDGET_CODEVIEW_TYPE_WIDGET, RaguiWidgetCodeviewWidgetClass))

typedef struct _RaguiWidgetCodeviewWidget RaguiWidgetCodeviewWidget;
typedef struct _RaguiWidgetCodeviewWidgetClass RaguiWidgetCodeviewWidgetClass;
typedef struct _RaguiWidgetCodeviewWidgetPrivate RaguiWidgetCodeviewWidgetPrivate;

struct _RaguiWidgetCodeViewCodeContext {
	GObject parent_instance;
	RaguiWidgetCodeViewCodeContextPrivate * priv;
};

struct _RaguiWidgetCodeViewCodeContextClass {
	GObjectClass parent_class;
};

struct _RaguiWidgetCodeViewJumpLines {
	GTypeInstance parent_instance;
	volatile int ref_count;
	RaguiWidgetCodeViewJumpLinesPrivate * priv;
};

struct _RaguiWidgetCodeViewJumpLinesClass {
	GTypeClass parent_class;
	void (*finalize) (RaguiWidgetCodeViewJumpLines *self);
};

struct _RaguiWidgetCodeViewLine {
	GTypeInstance parent_instance;
	volatile int ref_count;
	RaguiWidgetCodeViewLinePrivate * priv;
	guint64 offset;
	char* hex;
	char* str;
};

struct _RaguiWidgetCodeViewLineClass {
	GTypeClass parent_class;
	void (*finalize) (RaguiWidgetCodeViewLine *self);
};

/*using RaguiWidget.CodeView;*/
struct _RaguiWidgetCodeviewWidget {
	GtkScrolledWindow parent_instance;
	RaguiWidgetCodeviewWidgetPrivate * priv;
	GtkDrawingArea* da;
	double zoom;
	gint cursor;
	gint ccursor;
	double lineh;
	gint breakpoint;
	double pany;
};

struct _RaguiWidgetCodeviewWidgetClass {
	GtkScrolledWindowClass parent_class;
};


GType ragui_widget_code_view_code_context_get_type (void);
RaguiWidgetCodeViewCodeContext* ragui_widget_code_view_code_context_new (void);
RaguiWidgetCodeViewCodeContext* ragui_widget_code_view_code_context_construct (GType object_type);
gpointer ragui_widget_code_view_jump_lines_ref (gpointer instance);
void ragui_widget_code_view_jump_lines_unref (gpointer instance);
GParamSpec* ragui_widget_code_view_param_spec_jump_lines (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
void ragui_widget_code_view_value_set_jump_lines (GValue* value, gpointer v_object);
gpointer ragui_widget_code_view_value_get_jump_lines (const GValue* value);
GType ragui_widget_code_view_jump_lines_get_type (void);
RaguiWidgetCodeViewJumpLines* ragui_widget_code_view_jump_lines_new (void);
RaguiWidgetCodeViewJumpLines* ragui_widget_code_view_jump_lines_construct (GType object_type);
gpointer ragui_widget_code_view_line_ref (gpointer instance);
void ragui_widget_code_view_line_unref (gpointer instance);
GParamSpec* ragui_widget_code_view_param_spec_line (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
void ragui_widget_code_view_value_set_line (GValue* value, gpointer v_object);
gpointer ragui_widget_code_view_value_get_line (const GValue* value);
GType ragui_widget_code_view_line_get_type (void);
void ragui_widget_code_view_line_draw (RaguiWidgetCodeViewLine* self, cairo_t* ctx);
RaguiWidgetCodeViewLine* ragui_widget_code_view_line_new (void);
RaguiWidgetCodeViewLine* ragui_widget_code_view_line_construct (GType object_type);
GType ragui_widget_codeview_widget_get_type (void);
#define RAGUI_WIDGET_CODEVIEW_WIDGET_S ((double) 96)
void ragui_widget_codeview_widget_create_widgets (RaguiWidgetCodeviewWidget* self);
void ragui_widget_codeview_widget_do_popup_generic (RaguiWidgetCodeviewWidget* self);
void ragui_widget_codeview_widget_square (cairo_t* ctx, double w, double h);
void ragui_widget_codeview_widget_triangle (cairo_t* ctx, double w, double h, gboolean down);
void ragui_widget_codeview_widget_draw (RaguiWidgetCodeviewWidget* self);
void ragui_widget_codeview_widget_refresh (RaguiWidgetCodeviewWidget* self, GtkDrawingArea* da);
RaguiWidgetCodeviewWidget* ragui_widget_codeview_widget_new (void);
RaguiWidgetCodeviewWidget* ragui_widget_codeview_widget_construct (GType object_type);


G_END_DECLS

#endif
