NAMES = mmxval.o xmmval.o mat4x4.o ymmval.o

all: $(NAMES)

mmxval.o: mmxval.cpp mmxval.h miscdefs.h
	g++ -c -m32 mmxval.cpp -o mmxval.o -std=c++11
xmmval.o: xmmval.cpp xmmval.h miscdefs.h	
	g++ -c -m32 xmmval.cpp -o xmmval.o -std=c++11
mat4x4.o: mat4x4.cpp mat4x4.h miscdefs.h	
	g++ -c -m32 mat4x4.cpp -o mat4x4.o -std=c++11
ymmval.o: ymm.cpp ymm.h miscdefs.h
	g++ -c -m32 ymmval.cpp -o ymmval.o -std=c++11
clean:
	rm -f *.o
