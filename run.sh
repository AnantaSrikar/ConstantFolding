#Script to test out our code

clang -fno-discard-value-names -Xclang -disable-O0-optnone -O0 -emit-llvm -c ./tests/computation.c -o fncomputation.bc
opt -S -bugpoint-enable-legacy-pm=1 -mem2reg fncomputation.bc -o fncomputation-m2r.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -constfold fncomputation-m2r.ll -o fncomputation-m2r-opt.ll 

clang -fno-discard-value-names -Xclang -disable-O0-optnone -O0 -emit-llvm -c ./tests/loop.c -o loop.bc
opt -S -bugpoint-enable-legacy-pm=1 -mem2reg loop.bc -o loop-m2r.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -constfold loop-m2r.ll -o loop-m2r-opt.ll 