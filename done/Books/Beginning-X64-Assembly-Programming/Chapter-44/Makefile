name1=inline1
name2=inline2

all: $(name1) $(name2)

$(name1): $(name1).c 
	gcc -no-pie -o $(name1) $(name1).c -masm=intel
$(name2): $(name2).c 
	gcc -no-pie -o $(name2) $(name2).c -masm=intel
clean:
	@rm -f $(name1) $(name2) *.o
