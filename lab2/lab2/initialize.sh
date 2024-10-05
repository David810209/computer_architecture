export LAB2_ROOT=$PWD
cd $LAB2_ROOT/tests/build
../configure --host=riscv32-unknown-elf
make
../convert

cd $LAB2_ROOT/ubmark/build
../configure --host=riscv32-unknown-elf
make
../convert
