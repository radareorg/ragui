/*
 *  Grava - General purpose codewing library for Vala
 *  Copyright (C) 2007, 2008  pancake <youterm.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef __CODEWIDGET_H__
#define __CODEWIDGET_H__

#include <glib.h>
#include <glib-object.h>
#include <gtk/gtk.h>
#include <float.h>
#include <math.h>
#include <cairo.h>

G_BEGIN_DECLS


#define CODEWIDGET_TYPE_WIDGET (codewidget_widget_get_type ())
#define CODEWIDGET_WIDGET(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), CODEWIDGET_TYPE_WIDGET, CodewidgetWidget))
#define CODEWIDGET_WIDGET_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), CODEWIDGET_TYPE_WIDGET, CodewidgetWidgetClass))
#define CODEWIDGET_IS_WIDGET(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), CODEWIDGET_TYPE_WIDGET))
#define CODEWIDGET_IS_WIDGET_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), CODEWIDGET_TYPE_WIDGET))
#define CODEWIDGET_WIDGET_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), CODEWIDGET_TYPE_WIDGET, CodewidgetWidgetClass))

typedef struct _CodewidgetWidget CodewidgetWidget;
typedef struct _CodewidgetWidgetClass CodewidgetWidgetClass;
typedef struct _CodewidgetWidgetPrivate CodewidgetWidgetPrivate;

struct _CodewidgetWidget {
	GtkScrolledWindow parent_instance;
	CodewidgetWidgetPrivate * priv;
	GtkDrawingArea* da;
	double zoom;
	gint cursor;
	double lineh;
	gint breakpoint;
	double pany;
};

struct _CodewidgetWidgetClass {
	GtkScrolledWindowClass parent_class;
};


#define CODEWIDGET_WIDGET_S (double) 96
GtkWidget* codewidget_widget_get_widget (CodewidgetWidget* self);
void codewidget_widget_create_widgets (CodewidgetWidget* self);
void codewidget_widget_do_popup_generic (CodewidgetWidget* self);
void codewidget_widget_do_popup_menu (CodewidgetWidget* self);
void codewidget_widget_square (cairo_t* ctx, double w, double h);
void codewidget_widget_triangle (cairo_t* ctx, double w, double h, gboolean down);
void codewidget_widget_draw (CodewidgetWidget* self);
void codewidget_widget_refresh (CodewidgetWidget* self, GtkDrawingArea* da);
CodewidgetWidget* codewidget_widget_construct (GType object_type);
CodewidgetWidget* codewidget_widget_new (void);
GType codewidget_widget_get_type (void);


G_END_DECLS

#endif
