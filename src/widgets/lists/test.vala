using Gtk;

[Compact]
public struct ListWidgetData {
	public uint64 offset;
	public string name;

	public ListWidgetData(uint64 offset, string name) {
		this.offset = offset;
		this.name = name;
	}
}

public class ListWidget : ScrolledWindow {
	TreeView view;
	ListStore model;
	SList<ListWidgetData?> rows;
	public SList<string> actions;

	public signal void menu_handler(ListWidget me, string action, ListWidgetData row);

	private bool button_press (Gtk.Widget _w, Gdk.EventButton eb) {
		if (eb.button != 3)
			return false;

		ListWidgetData? data = null;
		var sel = view.get_selection ();
		if (sel.count_selected_rows () == 1) {
			TreeModel m;
			GLib.List<unowned Gtk.TreePath> list = sel.get_selected_rows (out m);
			foreach (var row in list) {
				var nth = row.to_string ();
				data = rows.nth_data (nth.to_int ());
				break;
			}
		}
		var menu = new Menu();
		foreach (var str in this.actions) {
			var imi = new ImageMenuItem.with_label (str);
			imi.activate.connect ((x)=> { menu_handler (this, x.label, data); });
			//imi.activate.connect ((x)=> { menu_handler (str, data); }); // XXX vala bug
			menu.append (imi);
		}
		menu.show_all ();
		menu.popup (null, null, null, 0, 0);
		return false;
	}

	public ListWidget (string col0, string col1) {
		this.rows = new SList <ListWidgetData?> ();
		this.actions = new SList<string> ();
		set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
		view = new TreeView ();
		//view.set_reorderable (true); // reorder rows ?
		model = new ListStore (2, typeof (string), typeof (string));
		view.set_model (model);
		view.insert_column_with_attributes (-1, col0,
			new CellRendererText (), "text", 0);
		view.insert_column_with_attributes (-1, col1,
			new CellRendererText (), "text", 1);
		//view.button_press_event.connect (button_press);
		view.button_release_event.connect (button_press);
		add (view);
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

	public void add_row (uint64 off, string name) {
		TreeIter iter;
		model.append (out iter);
		model.set (iter, 0, off.to_string
			("0x%"+uint64.FORMAT_MODIFIER+"x"), 1, name);
		rows.append (ListWidgetData (off, name));
	}

	public inline void clear () {
		model.clear ();
		rows = new SList <ListWidgetData?> ();
	}
}

public static int main (string[] args) {     
	Gtk.init (ref args);

	var w = new Window ();
	w.title = "treeview sample";

	var lw = new ListWidget ("offset", "name");

	lw.add_row (0x8048000, "main");
	lw.add_row (0x8048230, "wait");
	lw.add_row (0x8048480, "system");
	lw.add_row (0x8049350, "patata");

	lw.set_actions ("seek", "breakpoint", "continue until", "inspect");
	lw.menu_handler.connect ((me, m, d) => {
		print ("clicked "+m.to_string ()+": "+
			d.name+"at addr"+d.offset.to_string ()+"\n");
//		me.clear();
//		lw.add_row (0, "hello world");
	});

	w.add (lw);
	w.destroy.connect (Gtk.main_quit);

	w.show_all ();
	Gtk.main ();

	return 0;
}
