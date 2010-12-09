using Gtk;
using Radare;

static int main (string[] args) {
	Gtk.init (ref args);
	var w = new Window (WindowType.TOPLEVEL);
	w.title = "gcode";
	var gcode = new Gcode.Widget ();
	gcode.data_handler.connect ((x)=>{
			if (x)
				print ("I WANT MOAR DATA! (NEXT)\n");
			else
				print ("I WANT MOAR DATA! (PREV)\n");

		});
	gcode.set_text("""
         0x0000261c    0                   55  push rbp
         0x0000261d    8+              4889e5  mov rbp, rsp
         0x00002620    8               0fb7d7  movzx edx, di
         0x00002623    8                 89d0  mov eax, edx
         0x00002625    8           2500f00000  and eax, 0xf000
         0x0000262a    8           3d00400000  cmp eax, 0x4000
     .=< 0x0000262f    8                 7429  jz 0x265a [1]
    .==< 0x00002631    8                 7f10  jg 0x2643 [2]
    ||   0x00002633    8           3d00100000  cmp eax, 0x1000
    ||   0x00002638    8                 744a  jz 0x2684 [3]
    ||   0x0000263a    8           3d00200000  cmp eax, 0x2000
    ||   0x0000263f    8                 7558  jnz 0x2699 [4]
    ||   0x00002641    8                 eb4f  jmp 0x2692 [5]
    `--> 0x00002643    8           3d00a00000  cmp eax, 0xa000
   .===< 0x00002648    8                 742c  jz 0x2676 [6]
   | |   0x0000264a    8           3d00c00000  cmp eax, 0xc000
   | |   0x0000264f    8                 742c  jz 0x267d [7]
   | |   0x00002651    8           3d00600000  cmp eax, 0x6000
   | |   0x00002656    8                 7541  jnz 0x2699 [8]
   | |   0x00002658    8                 eb31  jmp 0x268b [9]
   | `-> 0x0000265a    8               f6c202  test dl, 0x2
  .====< 0x0000265d    8                 7413  jz 0x2672 [?]
  ||     0x0000265f    8               80e602  and dh, 0x2
 .=====< 0x00002662    8                 7407  jz 0x266b [?]
 |||     0x00002664    8           bf09000000  mov edi, 0x9
 |||     0x00002669    8                 eb50  jmp 0x26bb [?]
 `-----> 0x0000266b    8           bf0a000000  mov edi, 0xa
""");
	w.add (gcode);
	w.show_all ();
	Gtk.main ();
	return 0;
}
