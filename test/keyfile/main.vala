using GLib;

public static void main(string[] args) {
	KeyFile kf = new KeyFile();
	try {
		kf.load_from_file ("test.ini", KeyFileFlags.NONE);
		kf.load_from_file ("test2.ini", KeyFileFlags.NONE);
		print ("==> file0 = %s\n", kf.get_value ("LastFiles", "file0"));
	} catch (KeyFileError err) {
		warning (err.message);
	} catch (FileError err) {
		kf.set_string ("LastFiles", "file0", "patata");
		var str = kf.to_data (null);
		try {
			FileUtils.set_contents ("test.ini", str, str.length);
		} catch (FileError err) {
			warning (err.message);
		}
		print ("%s\n", str);
	}
}
