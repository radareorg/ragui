// -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
//
// segmentedbar.vala
//
// Author:
//
//  Steve Wood <steve.wood@inixsys.com> (eeebuntu)
//  
//  Based on SegmentedBar.cs by Aaron Bockover <abockover@novell.com>
//
// Copyright (C) 2010 Inixsys Ltd ( developed for eeebuntu installer )
// Copyright (C) 2008 Novell, Inc.
// 
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
using Gtk;
using Cairo;
 
 
public class SegmentedBar : Widget
{
 
    public enum CairoCorners
    {
        None = 0,
        TopLeft = 1,
        TopRight = 2,
        BottomLeft = 4,
        BottomRight = 8,
        All = 15
    }
 
    public struct BarColour
    {
        public double R { get; set; } 
        public double G { get; set; }
        public double B { get; set; }
        public double A { get; set; }
 
        public BarColour(double red, double green, double blue, double alpha)
        {
            R = red;
            G = green;
            B = blue;
            A = alpha;
        }
    }
 
    public delegate string BarValueFormatHandler (Segment segment);
    private int pango_size_normal;
 
    public class Segment
    {
        public string Title { get; set; }
        public double Percent { get; set; }
        public BarColour Color { get; set; }
        public bool ShowInBar { get; set; }
        internal int LayoutWidth;
        internal int LayoutHeight;
 
        public Segment (string title, double percent, BarColour color, bool showInBar)
        {
            Title = title;
            Percent = percent;
            Color = color;
            ShowInBar = showInBar;
        }
    }
 
    // State
    private List<Segment> segments = new List<Segment> ();
    private int layout_width;
    private int layout_height;
 
    // Properties
    private int bar_height = 26;
    private int bar_label_spacing = 8;
    private int segment_label_spacing = 16;
    private int segment_box_size = 12;
    private int segment_box_spacing = 6;
    private int h_padding = 0;
 
    private bool show_labels = true;
    private bool reflect = true;
 
    private BarColour remainder_color = RgbToColor (0xeeeeee);
 
 
    private BarValueFormatHandler format_handler;
 
    public SegmentedBar ()
    { this.flags |= WidgetFlags.NO_WINDOW; }
 
    protected override void realize ()
    {
        window = parent.window;
        base.realize ();
    }
 
// Size Calculations
 
    protected override void size_request (ref Requisition requisition)
    {
        requisition.width = 200;
        requisition.height = 0;
    }
 
    protected override void size_allocate (Gdk.Rectangle allocation)
    {
        int _bar_height = reflect ? (int)Math.ceil (bar_height * 1.75) : bar_height;
 
        if (show_labels) 
        {
            ComputeLayoutSize ();
            height_request = int.max (bar_height + bar_label_spacing + layout_height, _bar_height);
            width_request  = layout_width + (2 * h_padding);
        } 
        else 
        {
            height_request = _bar_height;
            width_request = bar_height + (2 * h_padding);
        }
 
        base.size_allocate (allocation);
    }
 
    private void ComputeLayoutSize ()
    {
        if ( segments == null ) 
        { return; }
 
        Pango.Layout layout = null;
 
        layout_width = layout_height = 0;
 
        foreach (Segment seg in segments) 
        {
            int aw, ah, bw, bh;
 
            layout = CreateAdaptLayout (layout, false, true);
            layout.set_text (FormatSegmentText (seg), (int)seg.Title.length);
            layout.get_pixel_size (out aw, out ah);
 
            layout = CreateAdaptLayout (layout, true, false);
            layout.set_text (FormatSegmentValue (seg), (int)seg.Title.length);
            layout.get_pixel_size (out bw, out bh);
 
            int w = int.max (aw, bw);
            int h = ah + bh;
 
            seg.LayoutWidth = w;
            seg.LayoutHeight = int.max (h, segment_box_size * 2);
 
            layout_width += seg.LayoutWidth + segment_box_size + segment_box_spacing + segment_label_spacing;
            layout_height = int.max (layout_height, seg.LayoutHeight);
        }
        layout.dispose ();
    }
 
 
 
// Public Methods
 
    public void AddSegmentRgba (string title, double percent, uint rgbaColor)
    { AddSegmentB (title, percent, RgbaToColor (rgbaColor)); }
 
    public void AddSegmentRgb (string title, double percent, uint rgbColor)
    { AddSegmentB (title, percent, RgbToColor (rgbColor)); }
 
    public void AddSegmentB (string title, double percent, BarColour color)
    { AddSegment (new Segment (title, percent, color, true)); }
 
    public void AddSegmentA (string title, double percent, BarColour color, bool showInBar)
    { AddSegment (new Segment (title, percent, color, showInBar)); }
 
    public void AddSegment (Segment segment)
    {
        lock (segments) {
            segments.append (segment);
            queue_draw ();
        }
    }
 
    public void UpdateSegment (int index, double percent)
    {
        int i = 0;
 
        foreach (Segment seg in segments)
        {
            i++;
            if ( i == index )
            { 
                seg.Percent = percent;
                queue_draw();
                break; 
            }
        }
    }
 
// Public Properties
 
    public BarValueFormatHandler ValueFormatter 
    {
        get { return format_handler; }
        set { format_handler = value; }
    }
 
    public BarColour RemainderColor 
    {
        get { return remainder_color; }
        set 
        {
            remainder_color = value;
            queue_draw();
        }
    }
 
    public int BarHeight 
    {
        get { return bar_height; }
        set 
        {
            if (bar_height != value) 
            {
                bar_height = value;
                queue_resize();
            }
        }
    }
 
    public bool ShowReflection 
    {
        get { return reflect; }
        set 
        {
            if (reflect != value) 
            {
                reflect = value;
                queue_resize();
            }
        }
    }
 
    public bool ShowLabels 
    {
        get { return show_labels; }
        set 
        {
            if (show_labels != value) 
            {
                show_labels = value;
                queue_resize();
            }
        }
    }
 
    public int SegmentLabelSpacing {
        get { return segment_label_spacing; }
        set 
        {
            if (segment_label_spacing != value) 
            {
                segment_label_spacing = value;
                queue_resize();
            }
        }
    }
    public int SegmentBoxSize {
        get { return segment_box_size; }
        set 
        {
            if (segment_box_size != value) 
            {
                segment_box_size = value;
                queue_resize();
            }
        }
    }
 
    public int SegmentBoxSpacing {
        get { return segment_box_spacing; }
        set 
        {
            if (segment_box_spacing != value) 
            {
                segment_box_spacing = value;
                queue_resize();
            }
        }
    }
 
    public int BarLabelSpacing {
        get { return bar_label_spacing; }
        set 
        {
            if (bar_label_spacing != value) 
            {
                bar_label_spacing = value;
                queue_resize();
            }
        }
    }
 
    public int HorizontalPadding 
    {
        get { return h_padding; }
        set 
        {
            if (h_padding != value) 
            {
                h_padding = value;
                queue_resize();
            }
        }
    }
 
// Rendering
 
    protected override bool expose_event (Gdk.EventExpose evnt)
    {
        if (evnt.window != window) 
        { return base.expose_event (evnt); }
 
        Cairo.Context cr = Gdk.cairo_create( evnt.window);
 
        if ( reflect ) 
        { cr.push_group(); }
 
        cr.set_operator(Operator.OVER);
        cr.translate (allocation.x + h_padding, allocation.y);
        cr.rectangle (0, 0, allocation.width - h_padding, int.max (2 * bar_height, bar_height + bar_label_spacing + layout_height));
        cr.clip ();
 
        Pattern bar = RenderBar (allocation.width - 2 * h_padding, bar_height);
 
        cr.save ();
        cr.set_source(bar);
        cr.paint ();
        cr.restore ();
 
        if ( reflect ) 
        {
            cr.save ();
 
            cr.rectangle (0, bar_height, allocation.width - h_padding, bar_height);
            cr.clip ();
 
            Matrix matrix = Matrix(1, 0, 0, 1, 0, 0);
            matrix.scale (1, -1);
            matrix.translate (0, -(2 * bar_height) + 1);
 
            cr.transform (matrix);
 
            cr.set_source (bar);
 
            Pattern mask = new Cairo.Pattern.linear(0, 0, 0, bar_height);
 
            mask.add_color_stop_rgba(0.25, 0, 0, 0, 0);
            mask.add_color_stop_rgba(0.5, 0, 0, 0, 0.125);
            mask.add_color_stop_rgba(0.75, 0, 0, 0, 0.4);
            mask.add_color_stop_rgba(1.0, 0, 0, 0, 0.7);            
 
            cr.mask (mask);
            mask = null;
 
            cr.restore ();
 
            cr.pop_group_to_source();
            cr.paint ();
        }
 
        if (show_labels) 
        {
            cr.translate ((reflect ? allocation.x : -h_padding) + (allocation.width - layout_width) / 2,
                 (reflect ? allocation.y : 0) + bar_height + bar_label_spacing);
            RenderLabelsA (cr);
        }
        return true;
    }
 
    private Pattern RenderBar (int w, int h)
    {
        ImageSurface s = new ImageSurface (Cairo.Format.ARGB32, w, h);
        Context cr = new Context (s);
        RenderBarA (cr, w, h, h / 2);
        Cairo.Pattern pattern = new Cairo.Pattern.for_surface(s);
        cr = null;
        s = null;
        return pattern;
    }
 
    private void RenderBarA (Context cr, int w, int h, int r)
    {
        RenderBarSegments (cr, w, h, r);
        RenderBarStrokes (cr, w, h, r);
    }
 
    private void RenderBarSegments (Context cr, int w, int h, int r)
    {
        Cairo.Pattern grad = new Cairo.Pattern.linear (0, 0, w, 0);
        double last = 0.0;
 
        foreach (Segment segment in segments) 
        {
            if (segment.Percent > 0) 
            {
                grad.add_color_stop_rgba (last, segment.Color.R, segment.Color.G, segment.Color.B, segment.Color.A);
                grad.add_color_stop_rgba (last += segment.Percent, segment.Color.R, segment.Color.G, segment.Color.B, segment.Color.A);
            }
        }
 
        RoundedRectangleA (cr, 0, 0, w, h, r);
        cr.set_source(grad);
        cr.fill_preserve ();
        grad = null;
 
        grad = new Cairo.Pattern.linear (0, 0, 0, h);
        grad.add_color_stop_rgba(0.0, 1, 1, 1, 0.125);
        grad.add_color_stop_rgba(0.35, 1, 1, 1, 0.255);
        grad.add_color_stop_rgba(1, 0, 0, 0, 0.4);
        cr.set_source(grad);
        cr.fill ();
        grad = null;
    }
 
    private void RenderBarStrokes (Context cr, int w, int h, int r)
    {
        Cairo.Pattern stroke = MakeSegmentGradient (h, RgbaToColor ((uint)0x00000040));
        Cairo.Pattern seg_sep_light = MakeSegmentGradient (h, RgbaToColor ((uint)0xffffff20));
        Cairo.Pattern seg_sep_dark = MakeSegmentGradient (h, RgbaToColor ((uint)0x00000020));
 
        cr.set_line_width (1);
 
        double seg_w = 20;
        double x = seg_w > r ? seg_w : r;
 
        while (x <= w - r) 
        {
            cr.move_to (x - 0.5, 1);
            cr.line_to (x - 0.5, h - 1);
            cr.set_source (seg_sep_light);
            cr.stroke ();
 
            cr.move_to (x + 0.5, 1);
            cr.line_to (x + 0.5, h - 1);
            cr.set_source (seg_sep_dark);
            cr.stroke ();
 
            x += seg_w;
        }
 
        RoundedRectangleA (cr, 0.5, 0.5, w - 1, h - 1, r);
        cr.set_source(stroke);
        cr.stroke ();
        seg_sep_light = null;
        seg_sep_dark = null;
    }
 
    private Cairo.Pattern MakeSegmentGradient (int h, BarColour color)
    { return MakeSegmentGradientA (h, color, false); }
 
    private Cairo.Pattern MakeSegmentGradientA (int h, BarColour color, bool diag)
    {
        Cairo.Pattern grad = new Cairo.Pattern.linear(0, 0, 0, h);
 
        BarColour col = ColorShade(color, 1.1);
        grad.add_color_stop_rgba(0, col.R, col.G, col.B, col.A);
 
        col = ColorShade(color, 1.2);
        grad.add_color_stop_rgba(0, col.R, col.G, col.B, col.A);
 
        col = ColorShade (color, 0.8);
        grad.add_color_stop_rgba(1, col.R, col.G, col.B, col.A);
 
        return grad;
    }
 
 
    private void RenderLabelsA (Context cr)
    {
        if (segments == null) 
        { return;  }
 
        Pango.Layout layout = null;
        BarColour text_color = GdkColorToCairoColorA(style.fg[state]);
 
        int x = 1;
 
        foreach (Segment segment in segments) 
        {
            cr.set_line_width(1);
            cr.rectangle (x + 0.5, 2 + 0.5, segment_box_size - 1, segment_box_size - 1);
 
            Cairo.Pattern grad = new Cairo.Pattern.linear (0, 0, 2.5, 0);
            grad.add_color_stop_rgba (0, segment.Color.R, segment.Color.G, segment.Color.B, segment.Color.A);
 
            cr.set_source(grad);
            cr.fill_preserve ();
            cr.set_source_rgba(0, 0, 0, 0.6);
            cr.stroke ();
            grad = null;
 
            x += segment_box_size + segment_box_spacing;
 
            int lw, lh;
            layout = CreateAdaptLayout (layout, false, true);
            layout.set_text( FormatSegmentText (segment), (int)segment.Title.length);
            layout.get_pixel_size (out lw, out lh);
 
            cr.move_to (x, 0);
            text_color.A = 0.9;
            cr.set_source_rgba(text_color.R, text_color.G, text_color.B, text_color.A);
			Pango.cairo_show_layout(cr, layout);
 
            cr.fill ();
 
            layout = CreateAdaptLayout (layout, true, false);
            layout.set_text (FormatSegmentValue (segment), (int)segment.Title.length);
 
            cr.move_to (x, lh);
            text_color.A =  0.75;
            cr.set_source_rgba(text_color.R, text_color.G, text_color.B, text_color.A);
			Pango.cairo_show_layout(cr, layout);
 
            cr.fill ();
 
            x += segment.LayoutWidth + segment_label_spacing;
        }
        layout.dispose ();
    }
 
    private void RenderLabels (Context cr)
    {
        if (segments == null) 
        { return;  }
 
        Pango.Layout layout = null;
        BarColour text_color = GdkColorToCairoColorA(style.fg[state]);
 
        int x = 0;
 
        foreach (Segment segment in segments) 
        {
            cr.set_line_width(1);
            cr.rectangle (x + 0.5, 2 + 0.5, segment_box_size - 1, segment_box_size - 1);
 
            Cairo.Pattern grad = MakeSegmentGradientA (segment_box_size, segment.Color, true);
 
            cr.set_source(grad);
            cr.fill_preserve ();
            cr.set_source_rgba(0, 0, 0, 0.6);
            cr.stroke ();
            grad = null;
            // grad.destroy ();
 
            x += segment_box_size + segment_box_spacing;
 
            int lw, lh;
            layout = CreateAdaptLayout (layout, false, true);
            layout.set_text( FormatSegmentText (segment), (int)segment.Title.length);
            layout.get_pixel_size (out lw, out lh);
 
            cr.move_to (x, 0);
            text_color.A = 0.9;
            cr.set_source_rgba(text_color.R, text_color.G, text_color.B, text_color.A);
			Pango.cairo_show_layout(cr, layout);
 
            cr.fill ();
 
            layout = CreateAdaptLayout (layout, true, false);
            layout.set_text (FormatSegmentValue (segment), (int)segment.Title.length);
 
            cr.move_to (x, lh);
            text_color.A =  0.75;
            cr.set_source_rgba(text_color.R, text_color.G, text_color.B, text_color.A);
			Pango.cairo_show_layout(cr, layout);
 
            cr.fill ();
 
            x += segment.LayoutWidth + segment_label_spacing;
        }
 
        layout.dispose ();
    }
 
 
 
// Utilities
 
    private Pango.Layout CreateAdaptLayout (Pango.Layout *layout, bool small, bool bold)
    {
        Pango.FontDescription fd;
        Pango.Context context;
 
        if (layout == null ) 
        {
            context =  create_pango_context();
            layout = create_pango_layout("widget"); 
        }
        context = get_pango_context();
        fd = context.get_font_description();
        pango_size_normal = fd.get_size();
 
        if (small)
        { fd.set_size( (int)(fd.get_size() * Pango.Scale.SMALL) ); }
        else
        { fd.set_size(pango_size_normal); }
 
        if (bold)
        { fd.set_weight(Pango.Weight.BOLD); }
        else
        { fd.set_weight(Pango.Weight.NORMAL); }  
 
        return layout;
    }
 
 
    private string FormatSegmentText (Segment segment)
    { return segment.Title; }
 
    private string FormatSegmentValue (Segment segment)
    {
        return format_handler == null
            ? ((double)(segment.Percent * 100.0)).to_string() + "%"
            : format_handler (segment);
    }
 
// cairo stuff
 public static Pango.Layout CreateLayout (Gtk.Widget widget, Cairo.Context cairo_context)
    {
        Pango.Layout layout = Pango.cairo_create_layout(cairo_context);
        layout.set_font_description(widget.get_pango_context().get_font_description() );
 
        double resolution = widget.get_screen().resolution;
        if (resolution != -1) {
            Pango.Context context = layout.get_context( );
            Pango.cairo_context_set_resolution (context, resolution);
            // context.Dispose ();
        }
        return layout;
    }
 
    public static BarColour AlphaBlend (BarColour ca, BarColour cb, double alpha)
    {
        return BarColour (
            (1.0 - alpha) * ca.R + alpha * cb.R,
            (1.0 - alpha) * ca.G + alpha * cb.G,
            (1.0 - alpha) * ca.B + alpha * cb.B,
            alpha);
    }
 
    public static BarColour GdkColorToCairoColorA(Gdk.Color color)
    {
        return GdkColorToCairoColor(color, 1.0);
    }
 
    public static BarColour GdkColorToCairoColor(Gdk.Color color, double alpha)
    {
        return BarColour(
            (double)(color.red >> 8) / 255.0,
            (double)(color.green >> 8) / 255.0,
            (double)(color.blue >> 8) / 255.0,
            alpha);
    }
 
 
    public static BarColour RgbToColor (uint rgbColor)
    { return RgbaToColor ((rgbColor << 8) | 0x000000ff); }
 
    public static BarColour RgbaToColor (uint rgbaColor)
    {
        return  BarColour (
            (uint) (( rgbaColor >> 24)&0xFF) / 255.0,
            (uint) (( rgbaColor >> 16)&0xFF) / 255.0,
            (uint) (( rgbaColor >> 8)&0xFF) / 255.0,
            (uint) (( rgbaColor & 0x000000ff)&0xFF) / 255.0);
    }
 
    public static bool ColorIsDark (BarColour color)
    {
        double h, s, b;
        HsbFromColor (color, out h, out s, out b);
        return b < 0.5;
    }
 
    public static void HsbFromColor(BarColour color, out double hue, out double saturation, out double brightness)
    {
        double min, max, delta;
        double red = color.R;
        double green = color.G;
        double blue = color.B;
 
        hue = 0;
        saturation = 0;
        brightness = 0;
 
        if(red > green) 
        {
            max = double.max(red, blue);
            min = double.min(green, blue);
        } 
        else 
        {
            max = double.max(green, blue);
            min = double.min(red, blue);
        }
 
        brightness = (max + min) / 2;
 
        if(  Math.fabs(max - min) < 0.0001) 
        {
            hue = 0;
            saturation = 0;
        } 
        else 
        {
            saturation = brightness <= 0.5
                ? (max - min) / (max + min)
                : (max - min) / (2 - max - min);
 
            delta = max - min;
 
            if(red == max) 
            { hue = (green - blue) / delta; } 
            else if(green == max) 
            { hue = 2 + (blue - red) / delta; } 
            else if(blue == max) 
            { hue = 4 + (red - green) / delta; }
 
            hue *= 60;
            if(hue < 0) 
            { hue += 360; }
        }
    }
 
    private static double Modula(double number, double divisor)
    { return ((int)number % (int)divisor) + (number - (int)number); }
 
    public static BarColour ColorFromHsb(double hue, double saturation, double brightness)
    {
        int i;
        double [] hue_shift = { 0, 0, 0 };
        double [] color_shift = { 0, 0, 0 };
        double m1, m2, m3;
 
        m2 = brightness <= 0.5
            ? brightness * (1 + saturation)
            : brightness + saturation - brightness * saturation;
 
        m1 = 2 * brightness - m2;
 
        hue_shift[0] = hue + 120;
        hue_shift[1] = hue;
        hue_shift[2] = hue - 120;
 
        color_shift[0] = color_shift[1] = color_shift[2] = brightness;
 
        i = saturation == 0 ? 3 : 0;
 
        for(; i < 3; i++) {
            m3 = hue_shift[i];
 
            if(m3 > 360) {
                m3 = Modula(m3, 360);
            } else if(m3 < 0) {
                m3 = 360 - Modula(Math.fabs(m3), 360);
            }
 
            if(m3 < 60) {
                color_shift[i] = m1 + (m2 - m1) * m3 / 60;
            } else if(m3 < 180) {
                color_shift[i] = m2;
            } else if(m3 < 240) {
                color_shift[i] = m1 + (m2 - m1) * (240 - m3) / 60;
            } else {
                color_shift[i] = m1;
            }
        }
        return BarColour(color_shift[0], color_shift[1], color_shift[2], 0);
    }
 
    public static BarColour ColorShade (BarColour col,  double ratio)
    {
        double h, s, b;
 
        HsbFromColor (col, out h, out s, out b);
 
        b = double.max (double.min (b * ratio, 1), 0);
        s = double.max (double.min (s * ratio, 1), 0);
 
        BarColour color = ColorFromHsb (h, s, b);
        color.A = col.A;
        return color;
    }
 
    public static BarColour ColorAdjustBrightness(BarColour col, double br)
    {
        double h, s, b;
        HsbFromColor(col, out h, out s, out b);
        b = double.max(double.min(br, 1), 0);
        return ColorFromHsb(h, s, b);
    }
 
    public static string ColorGetHex (BarColour color, bool withAlpha)
    {
        double r, g, b, a;
        r = color.R * 255;
        g = color.G * 255;
        b = color.B * 255;
        a = color.A * 255;
 
        if (withAlpha) 
        { return r.to_string() + g.to_string() +  b.to_string() + a.to_string(); } 
        else 
        { return r.to_string() + g.to_string() +  b.to_string(); }
    }
 
    public static void RoundedRectangleA(Cairo.Context cr, double x, double y, double w, double h, double r)
    { RoundedRectangle(cr, x, y, w, h, r, CairoCorners.All, false); }
 
    public static void RoundedRectangleB(Cairo.Context cr, double x, double y, double w, double h,  double r, CairoCorners corners)
    { RoundedRectangle(cr, x, y, w, h, r, corners, false); }
 
    public static void RoundedRectangle(Cairo.Context cr, double x, double y, double w, double h,  double r, CairoCorners corners, bool topBottomFallsThrough)
    {
        if(topBottomFallsThrough && corners == CairoCorners.None) {
            cr.move_to(x, y - r);
            cr.line_to(x, y + h + r);
            cr.move_to(x + w, y - r);
            cr.line_to(x + w, y + h + r);
            return;
        } else if(r < 0.0001 || corners == CairoCorners.None) {
            cr.rectangle(x, y, w, h);
            return;
        }
 
        if((corners & (CairoCorners.TopLeft | CairoCorners.TopRight)) == 0 && topBottomFallsThrough) {
            y -= r;
            h += r;
            cr.move_to(x + w, y);
        } else {
            if((corners & CairoCorners.TopLeft) != 0) {
                cr.move_to(x + r, y);
            } else {
                cr.move_to(x, y);
            }
 
            if((corners & CairoCorners.TopRight) != 0) {
                cr.arc(x + w - r, y + r, r, Math.PI * 1.5, Math.PI * 2);
            } else {
                cr.line_to(x + w, y);
            }
        }
 
        if((corners & (CairoCorners.BottomLeft | CairoCorners.BottomRight)) == 0 && topBottomFallsThrough) {
            h += r;
            cr.line_to(x + w, y + h);
            cr.move_to(x, y + h);
            cr.line_to(x, y + r);
            cr.arc(x + r, y + r, r, Math.PI, Math.PI * 1.5);
        } else {
            if((corners & CairoCorners.BottomRight) != 0) {
                cr.arc(x + w - r, y + h - r, r, 0, Math.PI * 0.5);
            } else {
                cr.line_to(x + w, y + h);
            }
 
            if((corners & CairoCorners.BottomLeft) != 0) {
                cr.arc(x + r, y + h - r, r, Math.PI * 0.5, Math.PI);
            } else {
                cr.line_to(x, y + h);
            }
 
            if((corners & CairoCorners.TopLeft) != 0) {
                cr.arc(x + r, y + r, r, Math.PI, Math.PI * 1.5);
            } else {
                cr.line_to(x, y);
            }
        }
    }
 
    public static void DisposeContext (Cairo.Context cr)
    {
        // ((IDisposable)cr.Target).Dispose ();
        // ((IDisposable)cr).Dispose ();
    }
}
