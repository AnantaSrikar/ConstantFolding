INC=-I/usr/local/include
all: ConstantFolder.so

CXXFLAGS = -rdynamic $(shell llvm-config --cxxflags) $(INC) -fPIC -g -O0

%.so: %.o
	$(CXX) -dlyb -shared $^ -o $@

clean: 
	rm -f *.o *~ *.so