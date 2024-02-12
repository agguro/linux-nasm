# makefile inline2.c
name=inline2

$(name): $(name).c
	gcc -o $(name) $(name).c -masm=intel -no-pie
clean:
	@rm -f $(name) *.o *.lst

