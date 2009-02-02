
#ifndef __CODEJUMP_H__
#define __CODEJUMP_H__

#include <glib.h>
#include <glib-object.h>

G_BEGIN_DECLS


#define CODEWIDGET_TYPE_JUMPS (codewidget_jumps_get_type ())
#define CODEWIDGET_JUMPS(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), CODEWIDGET_TYPE_JUMPS, CodewidgetJumps))
#define CODEWIDGET_JUMPS_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), CODEWIDGET_TYPE_JUMPS, CodewidgetJumpsClass))
#define CODEWIDGET_IS_JUMPS(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), CODEWIDGET_TYPE_JUMPS))
#define CODEWIDGET_IS_JUMPS_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), CODEWIDGET_TYPE_JUMPS))
#define CODEWIDGET_JUMPS_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), CODEWIDGET_TYPE_JUMPS, CodewidgetJumpsClass))

typedef struct _CodewidgetJumps CodewidgetJumps;
typedef struct _CodewidgetJumpsClass CodewidgetJumpsClass;
typedef struct _CodewidgetJumpsPrivate CodewidgetJumpsPrivate;
typedef struct _CodewidgetParamSpecJumps CodewidgetParamSpecJumps;

struct _CodewidgetJumps {
	GTypeInstance parent_instance;
	volatile int ref_count;
	CodewidgetJumpsPrivate * priv;
};

struct _CodewidgetJumpsClass {
	GTypeClass parent_class;
	void (*finalize) (CodewidgetJumps *self);
};

struct _CodewidgetParamSpecJumps {
	GParamSpec parent_instance;
};


CodewidgetJumps* codewidget_jumps_construct (GType object_type);
CodewidgetJumps* codewidget_jumps_new (void);
GParamSpec* codewidget_param_spec_jumps (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
gpointer codewidget_value_get_jumps (const GValue* value);
void codewidget_value_set_jumps (GValue* value, gpointer v_object);
GType codewidget_jumps_get_type (void);
gpointer codewidget_jumps_ref (gpointer instance);
void codewidget_jumps_unref (gpointer instance);


G_END_DECLS

#endif
