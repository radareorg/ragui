using Gtk;

[Compact]
public struct ListWidgetData {
	public uint64 offset;
	public string name;

	public ListWidgetData(uint64 offset, string name) {
		this.offset = offset;
		this.name = name;
	}
	// TODO: add methods to sort by column ?
}

public class ListWidget : ScrolledWindow {
	TreeView view;
	ListStore model;

	private bool button_press (Gtk.Widget _w, Gdk.EventButton eb) {
		if (eb.button != 3)
			return false;
		var menu = new Menu();
		var imi = new ImageMenuItem.with_label ("Sync disasm");
		menu.append (imi);
		imi = new ImageMenuItem.with_label ("Sync hex");
		menu.append (imi);
		menu.show_all ();
		menu.popup (null, null, null, 0, 0);
		return false;
	}

	public ListWidget (string col0, string col1) {
		set_policy (PolicyType.AUTOMATIC,
			PolicyType.AUTOMATIC);
		view = new TreeView ();
		model = new ListStore (2, typeof (string), typeof (string));
		view.set_model (model);
		view.insert_column_with_attributes (-1, col0,
			new CellRendererText (), "text", 0);
		view.insert_column_with_attributes (-1, col1,
			new CellRendererText (), "text", 1);
		view.button_press_event.connect (button_press);
		add (view);
	}

	public void set_rows (SList<ListWidgetData?> list) {
		clear ();
		foreach (var item in list)
			add_row (item.offset, item.name);
	}

	public void add_row (uint64 off, string name) {
		TreeIter iter;
		model.append (out iter);
		model.set (iter, 0, off.to_string
			("0x%"+uint64.FORMAT_MODIFIER+"x"), 1, name);
	}

	public inline void clear () {
		model.clear ();
	}

	// TODO: del_row()
	// TODO: change_row()
}

public static int main (string[] args) {     
	Gtk.init (ref args);

	var w = new Window ();
	w.title = "treeview sample";

	var lw = new ListWidget ("offset", "name");
	var list = new SList<ListWidgetData?> ();
	list.append (ListWidgetData (0x8048000, "main"));
	list.append (ListWidgetData (0x8048530, "wait"));
	list.append (ListWidgetData (0x8048400, "system"));
	list.append (ListWidgetData (0x8048300, "patata"));
	lw.set_rows (list);

//	list = new SList<ListWidgetData?> ();
	list.append (ListWidgetData (0x80483ff, "zzzz"));
	lw.set_rows (list);

	w.add (lw);
	w.destroy.connect (Gtk.main_quit);

	w.show_all ();
	Gtk.main ();

	return 0;
}
