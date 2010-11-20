all:
	valac -C --library segmentbar --vapi=../include/segmentbar.vapi --use-header -H ../include/segmentbar.h --pkg gtk+-2.0 segmentedbar.vala
	#valac -C --library grabin --vapi=../include/grabin.vapi -H ../include/grabin.h ${VALAFLAGS} grabin.vala

	#valac -H ../include/segmentbar.h -C segmentedbar.vala --pkg gtk+-2.0
	valac --pkg gtk+-2.0 *.vala

clean:
	rm -f main
