/* codew.vapi generated by valac, do not modify. */

[CCode (cprefix = "RaguiWidget", lower_case_cprefix = "ragui_widget_")]
namespace RaguiWidget {
	[CCode (cprefix = "RaguiWidgetCodeView", lower_case_cprefix = "ragui_widget_code_view_")]
	namespace CodeView {
		[CCode (cheader_filename = "codeview.h")]
		public class CodeContext : GLib.Object {
			public CodeContext ();
		}
		[CCode (ref_function = "ragui_widget_code_view_jump_lines_ref", unref_function = "ragui_widget_code_view_jump_lines_unref", param_spec_function = "ragui_widget_code_view_param_spec_jump_lines", cheader_filename = "codeview.h")]
		public class JumpLines {
			public JumpLines ();
		}
		[CCode (ref_function = "ragui_widget_code_view_line_ref", unref_function = "ragui_widget_code_view_line_unref", param_spec_function = "ragui_widget_code_view_param_spec_line", cheader_filename = "codeview.h")]
		public class Line {
			public string hex;
			public uint64 offset;
			public string str;
			public void draw (Cairo.Context ctx);
			public Line ();
		}
	}
}
[CCode (cprefix = "Codeview", lower_case_cprefix = "codeview_")]
namespace Codeview {
	[CCode (cheader_filename = "codeview.h")]
	public class Widget : Gtk.ScrolledWindow {
		public int breakpoint;
		public int ccursor;
		public int cursor;
		public Gtk.DrawingArea da;
		public double lineh;
		public double pany;
		public double zoom;
		public const double S;
		public void create_widgets ();
		public void do_popup_generic ();
		public void draw ();
		public Widget ();
		public void refresh (Gtk.DrawingArea da);
		public static void square (Cairo.Context ctx, double w, double h);
		public static void triangle (Cairo.Context ctx, double w, double h, bool down);
	}
}
