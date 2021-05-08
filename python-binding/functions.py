from ctypes import *
so_file = "./libpyfunctions.so"
functions = CDLL(so_file)

print(functions.square(10))
print(functions.square(8))
print(functions.square(-8))