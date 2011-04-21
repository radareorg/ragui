using Gtk;
using Gdk;

public struct ListviewData {
	public uint64 offset;
	public string name;

	public ListviewData(uint64 offset, string name) {
		this.offset = offset;
		this.name = name;
	}
}

public class Listview.Widget : ScrolledWindow {
	TreeView view;
	ListStore model;
	SList<ListviewData?> rows;
	[Widget]
	public SList<string> actions;

	// if action is null then we are doing double click, so default action is performed
	public signal void menu_handler(string? action, ListviewData? row);
	public signal void menu_construct();

	private ListviewData? get_listviewdata () {
		ListviewData? data = null;
		var sel = view.get_selection ();
		if (sel.count_selected_rows () == 1) {
			TreeModel m;
			GLib.List<unowned Gtk.TreePath> list = sel.get_selected_rows (out m);
			foreach (var row in list) {
				Value a;
				TreeIter? it;
				m.get_iter (out it, row);
				m.get_value (it, 2, out a);
				int pos = a.get_int ();
				data = rows.nth_data (pos);
				break;
			}
		}
		return data;
	}

	private bool button_press (Gtk.Widget _w, Gdk.EventButton eb) {
		if (eb.button != 3)
			return false;

		var data = get_listviewdata ();
		var sel = view.get_selection ();
		if (sel.count_selected_rows () == 1) {
			TreeModel m;
			GLib.List<unowned Gtk.TreePath> list = sel.get_selected_rows (out m);
			foreach (var row in list) {
				var nth = row.to_string ();
				data = rows.nth_data (int.parse (nth));
				break;
			}
		}
		var menu = new Menu();
		menu_construct ();
		foreach (var str in this.actions) {
			var imi = new ImageMenuItem.with_label (str);
			imi.activate.connect ((x)=> { menu_handler (x.label, data); });
			//imi.activate.connect ((x)=> { menu_handler (str, data); }); // XXX vala bug
			menu.append (imi);
		}
		menu.show_all ();
		menu.popup (null, null, null, 0, 0);
		return false;
	}

	enum Column {
		OFFSET,
		NAME,
		INDEX
	}

	construct {
		create_widgets ();
	}

	private int sort_offset(TreeModel model, TreeIter a, TreeIter b) {
		uint64 num0, num1;
		string str0, str1;
		model.get (a, Column.OFFSET, out str0);
		model.get (b, Column.OFFSET, out str1);
		str0.scanf ("0x%08llx", out num0);
		str1.scanf ("0x%08llx", out num1);
		var ret = num0-num1;
		return (int)(ret); 
		//XXX return ret>0?1:ret<0?-1:0;
	}

	private int sort_name(TreeModel model, TreeIter a, TreeIter b) {
		string str0, str1;
		model.get (a, Column.NAME, out str0);
		model.get (b, Column.NAME, out str1);
		return strcmp (str0, str1);
	}

	// TODO: rewrite in gtkon :D
	public void create_widgets () {
		this.rows = new SList <ListviewData?> ();
		this.actions = new SList<string> ();
		set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
		view = new TreeView ();
		model = new ListStore (3, typeof (string), typeof (string), typeof (int));
		view.set_model (model);
		model.set_sort_func (Column.OFFSET, sort_offset);
		model.set_sort_func (Column.NAME, sort_name);
		view.insert_column_with_attributes (Column.OFFSET, "Offset",
			new CellRendererText (), "text", 0);
		view.insert_column_with_attributes (Column.NAME, "Name",
			new CellRendererText (), "text", 1);
		var col0 = view.get_column (Column.OFFSET);
		var col1 = view.get_column (Column.NAME);
		col0.set_clickable (true);
		col0.set_sort_indicator (false);
		view.row_activated.connect ((e)=> {
			var data = get_listviewdata ();
			menu_handler (null, data); //action, data);
		});
		view.button_press_event.connect ((e)=> {
		// TODO: we have to use this callback!! view.row_activated.connect ((x,y)=> {
			if (e.type == EventType.2BUTTON_PRESS) {
				//print (@"DOUBLE LICK! $action\n");
				var data = get_listviewdata ();
			//	menu_construct ();
			//	var action = actions.nth_data (0);
				menu_handler (null, data); //action, data);
				return true;
			}
			return false;
		});
		col0.clicked.connect ((x)=> {
			var order = x.get_sort_order ();
			if (order == SortType.ASCENDING)
				order = SortType.DESCENDING;
			else order = SortType.ASCENDING;
			x.sort_order = order;
			col0.set_sort_indicator (true);
			col1.set_sort_indicator (false);
			model.set_sort_column_id (Column.OFFSET, order);
			});
		col1.set_clickable (true);
		col1.set_sort_indicator (false);
		col1.clicked.connect ((x)=> {
			var order = x.get_sort_order ();
			order = (order == SortType.ASCENDING)?
				SortType.DESCENDING:SortType.ASCENDING;
			x.sort_order = order;
			col0.set_sort_indicator (false);
			col1.set_sort_indicator (true);
			model.set_sort_column_id (Column.NAME, order);
			});
		//model.set_sort_column_id (Column.OFFSET, SortType.ASCENDING);

	/*
		//col1.clicked.connect ( (x)=> {
			var s = view.get_settings ();
			var t = s.gtk_double_click_time ();
			var d = s.gtk_double_click_distance ();
			print (@"Go fuck myself $s $t $d\n");
		//});
*/
		view.button_release_event.connect (button_press);
		view.set_search_column (Column.NAME);
		view.set_enable_search (true);
		add (view);
	}

	public void set_actions(string x, ...) {
		this.actions = new SList<string> ();
		this.actions.append (x);
		var l = va_list();
		for (;;) {
			string? k = l.arg ();
			if (k == null)
				break;
			this.actions.append (k);
		}
	}

	public void add_row_s (string key, string val) {
		uint nth = rows.length ();
		TreeIter iter;
		model.append (out iter);
		model.set (iter, 0, key, 1, val, 2, nth);
		//rows.append (ListviewData (off, name));
	}

	public void add_row (uint64 off, string name) {
		TreeIter iter;
		uint nth = rows.length ();
		model.append (out iter);
		model.set (iter,
			0, off.to_string ("0x%"+uint64.FORMAT_MODIFIER+"x"), 
			1, name,
			2, nth);
		rows.append (ListviewData (off, name));
	}

	public inline void clear () {
		model.clear ();
		rows = new SList <ListviewData?> ();
	}
}
