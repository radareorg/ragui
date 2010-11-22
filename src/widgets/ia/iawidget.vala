VBox $IAWidget {
	HBox {
		ScrolledWindow {
			TextArea $text;
		}
		Image image=ia.png;
	}
	Entry $text activate=chat;
	Button label=ask activate=chat released=chat;
	-{
		public void chat() {
			// 
		}
		public static void main (string[] args) {
			Gtk.init (ref args);
			var w = new Window (WindowType.TOP_LEVEL);
			w.add (new IAWidget ());
			Gtk.main_loop ();
		}
	}-
}
