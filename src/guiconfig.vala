using Radare;

public class Ragui.GuiConfig {
	string home_rc;
	string user_rc;
	string sys_rc;
	KeyFile kf;

	public GuiConfig () {
		kf = new KeyFile ();
		sys_rc = "/opt/ragui/config.ini";
		home_rc = Environment.get_home_dir () + "/.ragui/config.ini";
		user_rc = Environment.get_home_dir () + "/.ragui/user.ini";
	}

	public bool load_default () {
		load (sys_rc);
		load (home_rc);
		return load (user_rc);
	}

	public bool load (string file) {
		try {
			kf.load_from_file (file, KeyFileFlags.NONE);
		} catch (FileError err) {
			warning (err.message);
			return false;
		} catch (KeyFileError err) {
			warning (err.message);
			return false;
		}
		return true;
	}

	public bool save (string? file = null) {
		if (file == null)
			file = home_rc;
		var data = kf.to_data ();
		try {
			FileUtils.set_contents (file, data, data.length);
		} catch (FileError err) {
			warning (err.message);
			return false;
		}
		return true;
	}

	public string get_value (string domain, string key) {
		try {
			return kf.get_value (domain, key);
		} catch (KeyFileError err) {
			warning (err.message);
			return "";
		}
	}

	public void apply (GuiCore core) {
		get_value ("User", "name");
		get_value ("User", "email");
		get_value ("User", "company");
		//get_value ("Keys", "dbg-step");
		//get_value ("Keys", "dbg-continue");
	}
}
