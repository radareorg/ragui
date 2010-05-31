using Gtk;
using WebKit;
 
public class ValaBrowser : Window {
 
    private const string TITLE = "Vala Browser";
    private const string HOME_URL = "http://acid3.acidtests.org/";
    private const string DEFAULT_PROTOCOL = "http";
 
    private Regex protocol_regex;
 
    private Entry url_bar;
    private WebView web_view;
    private Label status_bar;
    private ToolButton back_button;
    private ToolButton forward_button;
    private ToolButton reload_button;
 
    public ValaBrowser () {
        this.title = ValaBrowser.TITLE;
        set_default_size (800, 600);
 
        try {
            this.protocol_regex = new Regex (".*://.*");
        } catch (RegexError e) {
            critical ("%s", e.message);
        }
 
        create_widgets ();
        connect_signals ();
        this.url_bar.grab_focus ();
    }
 
    private void create_widgets () {
        var toolbar = new Toolbar ();
        this.back_button = new ToolButton.from_stock (STOCK_GO_BACK);
        this.forward_button = new ToolButton.from_stock (STOCK_GO_FORWARD);
        this.reload_button = new ToolButton.from_stock (STOCK_REFRESH);
        toolbar.add (this.back_button);
        toolbar.add (this.forward_button);
        toolbar.add (this.reload_button);
        this.url_bar = new Entry ();
        this.web_view = new WebView ();
        var scrolled_window = new ScrolledWindow (null, null);
        scrolled_window.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scrolled_window.add (this.web_view);
        this.status_bar = new Label ("Welcome");
        this.status_bar.xalign = 0;
        var vbox = new VBox (false, 0);
        vbox.pack_start (toolbar, false, true, 0);
        vbox.pack_start (this.url_bar, false, true, 0);
        vbox.add (scrolled_window);
        vbox.pack_start (this.status_bar, false, true, 0);
        add (vbox);
    }
 
    private void connect_signals () {
        this.destroy.connect (Gtk.main_quit);
        this.url_bar.activate.connect (on_activate);
        this.web_view.title_changed.connect ((source, frame, title) => {
            this.title = "%s - %s".printf (title, ValaBrowser.TITLE);
        });
        this.web_view.load_committed.connect ((source, frame) => {
            this.url_bar.text = frame.get_uri ();
            update_buttons ();
        });
        this.back_button.clicked.connect (this.web_view.go_back);
        this.forward_button.clicked.connect (this.web_view.go_forward);
        this.reload_button.clicked.connect (this.web_view.reload);
	this.web_view.load_started += (x) => {
		print ("LOADING %s\n", x.get_uri ());
	};
    }
 
    private void update_buttons () {
        this.back_button.sensitive = this.web_view.can_go_back ();
        this.forward_button.sensitive = this.web_view.can_go_forward ();
    }
 
    private void on_activate () {
        var url = this.url_bar.text;
        if (!this.protocol_regex.match (url)) {
            url = "%s://%s".printf (ValaBrowser.DEFAULT_PROTOCOL, url);
        }
        this.web_view.open (url);
    }
 
    public void start () {
        show_all ();
        //this.web_view.open (ValaBrowser.HOME_URL);
var code = """
<pre>
0x8048000  mov eax, 33
0x8048003  push ebp
0x8048008  inc ecx
<a href="/bin/ls/Symbols">Symbols</a>
</pre>

"""
;
        this.web_view.load_html_string (code, "/bin/ls/Disassemble");
    }
 
    public static int main (string[] args) {
        Gtk.init (ref args);
 
        var browser = new ValaBrowser ();
        browser.start ();
 
        Gtk.main ();
 
        return 0;
    }
}
