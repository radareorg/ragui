using Gtk;

public class Grabin.Widget : ScrolledWindow {
	public ListStore listmodel;
	public SList<string> actions;
	public int retcol;
	public signal void menu_handler(string action, string data);

	public Widget() {
		set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
		retcol = 0;
	}

	public void sort_column(TreeView tv, int n) {
		for (int i = 0; i < tv.get_columns ().length (); i++) {
			var col = tv.get_column (i);
			if (i == n) {
				col.set_sort_indicator (true);
				var order = (col.get_sort_order ()==SortType.ASCENDING)?
					SortType.DESCENDING: SortType.ASCENDING;
				col.sort_order = order;
				listmodel.set_sort_column_id (i, order);
			} else col.set_sort_indicator (false);
		}
	}

	public bool button_press (Gtk.Widget w, Gdk.EventButton eb) {
		string? data = null;
		TreeModel model;
		TreeIter iter;
		GLib.Value val;

		if (eb.button != 3)
			return false;
		var sel = (w as TreeView).get_selection ();
		if (sel.get_selected (out model, out iter)) {
			model.get_value (iter, retcol, out val);
			data = val.get_string ();
		}
		var menu = new Menu();
		foreach (var str in this.actions) {
			var imi = new ImageMenuItem.with_label (str);
			imi.activate.connect ((x)=> { menu_handler (x.label, data); });
			menu.append (imi);
		}
		menu.show_all ();
		menu.popup (null, null, null, 0, 0);
		return false;
	}

	public void set_actions(string x, ...) {
		this.actions = new SList<string> ();
		this.actions.append (x);
		var l = va_list();
		while (true) {
			string? k = l.arg ();
			if (k == null)
				break;
			this.actions.append (k);
		}
	}

	public void set_retcolumn(int i) {
		retcol = i;
	}

	public void clear () {
		listmodel.clear ();
	}
}
