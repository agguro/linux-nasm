This small project is a first attempt to create oop like programs in nasm on Linux.
Classes are in fact structures with data and data-related procedures together.
An instance of such a class is an object.
For the data it wasn't hard to implement, as following psuedocode proves

class STRUC
	data	dq	?	; undefined attribute data
class ENDS

now for procedure or better, methods on the data of a Class, I've decided pointers to pprocedures (subroutines)

class STRUC
	data	dq	?	; attribute
	method	dq	offset (or ADDR) procedure	; pointer to an existing procedure
class ENDS

Instantiating an object of the class I can do at design time:

.data
	instance	class<>

either with the class method pointers and attributes filled in at run time or at design time

with indirect indexed addressing I can get access to both the method pointers and the attributes content.

I designed the structures so that I don't have to put indirect indexed addressing in the source file but instead replace it by a
namespace like macro
so to speak

class.method
no parameters required since class is defined at design time

I still need to find a way to deal with objects at runtime. So I need a constructor and a destructor plus a reference to the object

At runtime I have to make a class constructor which gets the size of the class (number of bytes required to store the class on the heap
reserve this memory with syscall brk and copy the data of that class into the heapmemory.
The pointer of the reserved memory is the instance of my class aka the object.
The destructor must be a routine to release the memory an object occupies on the heap.

Anyway it's a work in progress....
