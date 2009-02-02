
#ifndef __CODECONTEXT_H__
#define __CODECONTEXT_H__

#include <glib.h>
#include <glib-object.h>

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

struct _CodewidgetCodeContext {
	GObject parent_instance;
	CodewidgetCodeContextPrivate * priv;
};

struct _CodewidgetCodeContextClass {
	GObjectClass parent_class;
};


CodewidgetCodeContext* codewidget_code_context_construct (GType object_type);
CodewidgetCodeContext* codewidget_code_context_new (void);
GType codewidget_code_context_get_type (void);


G_END_DECLS

#endif
