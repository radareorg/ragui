/*
 * Johan Dahlin 2008
 *
 * A quite simple Gtk.Widget subclass which demonstrates how to subclass
 * and do realizing, sizing and drawing. Based on widget.py in PyGTK
 */ 
 
using Gtk;
using Cairo;
 
public class ValaWidget : Widget {

    private static const string TEXT = "Hello World!";
    private static const int BORDER_WIDTH = 10;
    private Pango.Layout layout;

    construct {
        this.layout = create_pango_layout (TEXT);
    }

    /*
     * This method Gtk+ is calling on a widget to ask
     * the widget how large it wishes to be. It's not guaranteed
     * that Gtk+ will actually give this size to the widget.
     */
    public override void size_request (out Gtk.Requisition requisition) {
        int width, height;

        // In this case, we say that we want to be as big as the
        // text is, plus a little border around it.
        this.layout.get_size (out width, out height);
        requisition.width = width / Pango.SCALE + BORDER_WIDTH * 4;
        requisition.height = height / Pango.SCALE + BORDER_WIDTH * 4;
    }

    /*
     * This method gets called by Gtk+ when the actual size is known
     * and the widget is told how much space could actually be allocated.
     * It is called every time the widget size changes, for example when the
     * user resizes the window.
     */
    public override void size_allocate (Gdk.Rectangle allocation) {
        // The base method will save the allocation and move/resize the
        // widget's GDK window if the widget is already realized.
        base.size_allocate (allocation);

        // Move/resize other realized windows if necessary
    }

    /*
     * This method is responsible for creating GDK (windowing system)
     * resources. In this example we will create a new GDK window which we
     * then draw on.
     */
    public override void realize () {
        // Create a new Gdk.Window which we can draw on.
        // Also say that we want to receive exposure events by setting
        // the event_mask
        var attrs = Gdk.WindowAttr () {
            window_type = Gdk.WindowType.CHILD,
            wclass = Gdk.WindowClass.INPUT_OUTPUT,
            event_mask = get_events () | Gdk.EventMask.EXPOSURE_MASK
        };
        this.window = new Gdk.Window (get_parent_window (), attrs, 0);
        this.window.move_resize (this.allocation.x, this.allocation.y,
                                 this.allocation.width, this.allocation.height);

        // Associate the GDK window with ourselves, Gtk+ needs a reference
        // between the widget and the GDK window
        this.window.set_user_data (this);

        // Attach the style to the GDK window. A style contains colors and
        // GC contexts used for drawing
        this.style = this.style.attach (this.window);

        // The default color of the background should be what
        // the style (theme engine) tells us
        this.style.set_background (this.window, Gtk.StateType.NORMAL);

        // Set an internal flag telling that we're realized
        set_flags (WidgetFlags.REALIZED);
    }

    /*
     * This method is called when the widget is asked to draw itself.
     * Remember that this will be called a lot of times, so it's usually
     * a good idea to write this code as optimized as it can be, don't
     * create any resources in here.
     */
    public override bool expose_event (Gdk.EventExpose event) {
        // Cairo context to draw on
        var cr = Gdk.cairo_create (this.window);

        // In this example, draw a rectangle in the foreground color
        Gdk.cairo_set_source_color (cr, this.style.fg[this.state]);
        cr.rectangle (BORDER_WIDTH, BORDER_WIDTH,
                      this.allocation.width - 2 * BORDER_WIDTH,
                      this.allocation.height - 2 * BORDER_WIDTH);
        cr.set_line_width (5.0);
        cr.set_line_join (LineJoin.ROUND);
        cr.stroke ();

        // And draw the text in the middle of the allocated space
        int fontw, fonth;
        this.layout.get_pixel_size (out fontw, out fonth);
        cr.move_to ((this.allocation.width - fontw) / 2,
                    (this.allocation.height - fonth) / 2);
        Pango.cairo_update_layout (cr, this.layout);
        Pango.cairo_show_layout (cr, this.layout);

        return true;
    }
 
    /*
     * This method is responsible for freeing the GDK resources.
     */
    public override void unrealize () {
        // The base method will de-associate the GDK window we created in
        // method 'realize' with ourselves.
        base.unrealize ();

        // De-associate other windows with 'set_user_data (null)' if necessary
    }

    static int main (string[] args) {
        Gtk.init (ref args);

        var win = new Window (WindowType.TOPLEVEL);
        win.border_width = 5;
        win.title = "Widget test";
        win.destroy += Gtk.main_quit;

        var frame = new Frame ("Example Vala Widget");
        win.add (frame);

        var widget = new ValaWidget ();
        frame.add (widget);

        win.show_all ();

        Gtk.main ();
        return 0;
    }
}

