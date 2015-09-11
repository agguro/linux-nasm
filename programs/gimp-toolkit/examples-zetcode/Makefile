PROGRAMS = simplewindow centeredwindow applicationicon appiconmemory inc-dec simplemenu imagemenu statusbar toolbar undoredo gtkalignment gtkfixed gtktable gtkvbox windows disconncallback dragndrop entersignal eventssignals move-event timer aboutbox colorselection fontselection msgdialogs gtkbutton gtkcheckbutton gtkframe gtkmarkuplabel gtkcombobox gtkseparators gtkentry gtkstatusbar gtkiconview

all: $(PROGRAMS)

% : %.asm
	nasm -felf64 -o $@.o -l $@.lst $@.asm
	ld -s -m elf_x86_64 $@.o -o $@ -lc --dynamic-linker /lib64/ld-linux-x86-64.so.2 -lgtk-3 -lgobject-2.0  -lglib-2.0 -lgdk_pixbuf-2.0 -lgdk-3 -lpango-1.0 -latk-1.0 -lgio-2.0 -lpangoft2-1.0  -lpangocairo-1.0 -lcairo -lfreetype -lfontconfig  -lgmodule-2.0 -lgthread-2.0 -lrt
	
simplewindow: simplewindow.asm
centeredwindow: centeredwindow.asm
applicationicon: applicationicon.asm
appiconmemory: appiconmemory.asm
inc-dec: inc-dec.asm
simplemenu: simplemenu.asm
imagemenu: imagemenu.asm
statusbar: statusbar.asm
toolbar: toolbar.asm
undoredo: undoredo.asm
gtkalignment: gtkalignment.asm
gtkfixed: gtkfixed.asm
gtktable: gtktable.asm
gtkvbox: gtkvbox.asm
windows: windows.asm
disconncallback: disconncallback.asm
dragndrop: dragndrop.asm
entersignal: entersignal.asm
eventssignals:eventssignals.asm
move-event: move-event.asm
timer: timer.asm
aboutbox: aboutbox.asm
colorselection: colorselection.asm
fontselection: fontselection.asm
msgdialogs: msgdialogs.asm
gtkbutton: gtkbutton.asm
gtkcheckbutton: gtkcheckbutton.asm
gtkframe: gtkframe.asm
gtkmarkuplabel: gtkmarkuplabel.asm
gtkcombobox: gtkcombobox.asm
gtkseparators: gtkseparators.asm
gtkentry: gtkentry.asm
gtkstatusbar: gtkstatusbar.asm
gtkiconview: gtkiconview.asm

clean:
	rm -f $(PROGRAMS) *.lst *.o
