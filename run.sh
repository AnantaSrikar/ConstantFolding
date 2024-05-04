clang -fno-discard-value-names -Xclang -disable-O0-optnone -O0 -emit-llvm -c ./tests/computation.c -o fncomputation.bc
opt -S -bugpoint-enable-legacy-pm=1 -mem2reg fncomputation.bc -o fncomputation-m2r.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -constfold fncomputation-m2r.ll -o fncomputation-m2r-opt.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -cond-constfold fncomputation-m2r.ll -o fncomputation-m2r-cond-opt.ll 

# Repeating for other test cases
clang -fno-discard-value-names -Xclang -disable-O0-optnone -O0 -emit-llvm -c ./tests/loop.c -o loop.bc
opt -S -bugpoint-enable-legacy-pm=1 -mem2reg loop.bc -o loop-m2r.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -constfold loop-m2r.ll -o loop-m2r-opt.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -cond-constfold loop-m2r.ll -o loop-m2r-cond-opt.ll 

clang -fno-discard-value-names -Xclang -disable-O0-optnone -O0 -emit-llvm -c ./tests/conditionalbranch.c -o conditionalbranch.bc
opt -S -bugpoint-enable-legacy-pm=1 -mem2reg conditionalbranch.bc -o conditionalbranch-m2r.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -constfold conditionalbranch-m2r.ll -o conditionalbranch-m2r-opt.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -cond-constfold conditionalbranch-m2r.ll -o conditionalbranch-m2r-cond-opt.ll 

clang -fno-discard-value-names -Xclang -disable-O0-optnone -O0 -emit-llvm -c ./tests/inline-test.c -o inline-test.bc
opt -S -bugpoint-enable-legacy-pm=1 -mem2reg inline-test.bc -o inline-test-m2r.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -constfold inline-test-m2r.ll -o inline-test-m2r-opt.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -cond-constfold inline-test-m2r.ll -o inline-test-m2r-cond-opt.ll 

clang -fno-discard-value-names -Xclang -disable-O0-optnone -O0 -emit-llvm -c ./tests/memaccess.c -o memaccess.bc
opt -S -bugpoint-enable-legacy-pm=1 -mem2reg memaccess.bc -o memaccess-m2r.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -constfold memaccess-m2r.ll -o memaccess.ll 
opt -S -bugpoint-enable-legacy-pm=1 -load ./ConstantFolder.so -cond-constfold memaccess-m2r.ll -o memaccess-cond.ll 
