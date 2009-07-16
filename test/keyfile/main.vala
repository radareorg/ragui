using GLib;

public static void main(string[] args)
{
	KeyFile kf = new KeyFile();
	try {
		kf.load_from_file("test.ini", KeyFileFlags.NONE);
		stdout.printf("==> file0=%s\n",
			kf.get_value("LastFiles", "file0"));
	} catch (FileError err) {
		kf.set_string("LastFiles", "file0", "patata");
		var str = kf.to_data(null);
		FileUtils.set_contents("test.ini", str, str.length);
		stdout.printf("%s\n", str);
	}
}
