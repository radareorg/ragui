public class Main : GLib.Object {
 
    static void main (string[] args) {
 
        string myString = "<c><a type='string' color='red'>b</a><d>e</d></c>";
 
        GLib.MarkupParser markupParser = { 
                (context, element_name, attribute_names, attribute_values) => {
                    stdout.printf("start |%s|\n",element_name);
                    for (int i = 0; i < attribute_names.length ; i++) {
                       stdout.printf("Attr name: %s, value: %s\n",attribute_names[i],attribute_values[i]);
                    }
                } , 
                (con, el) => { 
                    stdout.printf ("end |%s|\n",el);
                } , 
                (con, text, text_len ) => {
                    stdout.printf ("text %ld |%s|\n", (long)text_len, text); 
                } , null //call on non-interpresed text, like comments
                  , null //call on errors
        };
 
        GLib.MarkupParseContext parser = new GLib.MarkupParseContext 
                              (markupParser, GLib.MarkupParseFlags.TREAT_CDATA_AS_TEXT, null, null);
        try {
            parser.parse(myString, myString.length);
            parser.end_parse();
        } catch (GLib.MarkupError ex) {
            stdout.printf("Errorr: %s\n", ex.message);
        }
    }
}
