#https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads

export PATH="/Users/gabrielvalky/Downloads/gcc-arm-none-eabi-7-2018-q2-update/bin/":"$PATH"
mkdir -p build
cd build

arm-none-eabi-g++ -Wall -Os -Werror -fno-common -mcpu=cortex-m3 -mthumb -msoft-float -fno-exceptions -fno-rtti -fno-threadsafe-statics -Wno-psabi -MD -c ../source/Main.c  ../source/Menu.c ../source/GUI.c ../source/Func.c ../source/Ctrl.c ../source/Analyze.c ../source/AppBios.c -I../../../os_library/include/

#exit 1
#arm-none-eabi-gcc -fPIC -mcpu=cortex-m3 -mthumb -o output.elf -nostartfiles -Wl,--unresolved-symbols=ignore-all -T ../app.lds ./main.o 
arm-none-eabi-gcc -fPIC -mcpu=cortex-m3 -mthumb -o output.elf -nostartfiles -T ../app.lds ./Main.o ./Menu.o ./GUI.o ./Func.o ./Ctrl.o ./Analyze.o ./AppBios.o -lbios -L../../../os_library/build

arm-none-eabi-objdump -d -S output.elf > output.asm

find . -type f -name '*.o' -delete
find . -type f -name '*.d' -delete

../../../../tools/elfstrip/elfstrip output.elf 17analys.elf
#../../../elfdump/elfdump snake.elf
rm output.elf