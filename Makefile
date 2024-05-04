INC=-I/usr/local/include

CC=clang
# Find all C source files in the directory
SOURCES = $(wildcard tests/*.c)

# Convert the .c files to .o files
OBJECTS = $(SOURCES:.c=.o)
BCOBJS = $(SOURCES:.c=.bc)
M2ROBJS = $(BCOBJS:.bc=-m2r.ll)
OPTOBJS = $(M2ROBJS:-m2r.ll=-m2r-opt.ll)

all: ConstantFolder.so $(OBJECTS) $(BCOBJS) $(M2ROBJS) $(OPTOBJS)

CXXFLAGS = -rdynamic $(shell llvm-config --cxxflags) $(INC) -fPIC -g -O0

# Rule to compile a .c file into a .o file
%.o: %.c
	clang $< -o $@

%.bc: %.c
	clang -fno-discard-value-names -Xclang -disable-O0-optnone -O0 -emit-llvm -c $< -o $@

%-m2r.ll: %.bc
	opt -S -bugpoint-enable-legacy-pm=1 -mem2reg  $< -o $@

%-m2r-opt.ll: %-m2r.ll
	opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -constfold $< -o $@

%.so: %.o
	$(CXX) -dlyb -shared $^ -o $@

clean: 
	rm -fr *.o *~ *.so tests/*.ll tests/*.bc tests/*.o
