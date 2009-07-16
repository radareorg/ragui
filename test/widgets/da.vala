using Gtk;

public class CustomWidget : DrawingArea {

    public CustomWidget () {

        // Enable the events you wish to get notified about.
        // The 'expose' event is already enabled by the DrawingArea.
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK
                  | Gdk.EventMask.BUTTON_RELEASE_MASK
                  | Gdk.EventMask.POINTER_MOTION_MASK);

        // Set favored widget size
        set_size_request (100, 100);
    }

    /* Widget is asked to draw itself */
    public override bool expose_event (Gdk.EventExpose event) {

        // Create a Cairo context
        var cr = Gdk.cairo_create (this.window);

        // Set clipping area in order to avoid unnecessary drawing
        cr.rectangle (event.area.x, event.area.y,
                      event.area.width, event.area.height);
        cr.clip ();

        // ...

        return false;
    }

    /* Mouse button got pressed over widget */
    public override bool button_press_event (Gdk.EventButton event) {
        // ...
        return false;
    }

    /* Mouse button got released */
    public override bool button_release_event (Gdk.EventButton event) {
        // ...
        return false;
    }

    /* Mouse pointer moved over widget */
    public override bool motion_notify_event (Gdk.EventMotion event) {
        // ...
        return false;
    }
}
