all:
	# XXX gtkamlc fails with "The class Grabin.Widget doesn't have container add methods"
	# Doesn't gtkamlc handle (ScrolledWindow) Inheritance?
	-gtkamlc --save-temps --pkg gtk+-2.0 --pkg r_core grabin.vala grabinsections.gtkon main.vala
	valac --pkg gtk+-2.0 --pkg r_core grabin.vala main.vala grabinsections.vala
