#https://developer.arm.com/open-source/gnu-toolchain/gnu-rm/downloads
set -e

mkdir -p build
cd build

arm-none-eabi-g++ -fcheck-new -Os -Werror -fno-common -mcpu=cortex-m3 -mthumb -msoft-float -fno-exceptions -fno-rtti -fno-threadsafe-statics -fno-use-cxa-atexit -Wno-psabi -DDS213 -MD -D _ARM -D STM32F10X_HD -D STM32F10X_HD -c \
  ../source/main.cpp \
  ../source/cat.cpp \
  ../source/wasmhost.cpp \
  ../../../os_host/source/framework/Serialize.cpp \
  -I../../../os_library/include/
arm-none-eabi-gcc -fPIC -mcpu=cortex-m3 -mthumb -o output.elf -nostartfiles -T ../source/app.lds \
  ./main.o ./Serialize.o ./cat.o ./wasmhost.o \
  -lbios_ds213 -L../../../os_library/build

arm-none-eabi-objdump -d -S output.elf > output.asm
arm-none-eabi-readelf -all output.elf > output.txt

find . -type f -name '*.o' -delete
find . -type f -name '*.d' -delete

../../../../tools/elfstrip/elfstrip output.elf ds140cat.elf


arm-none-eabi-g++ -fcheck-new -Os -Werror -fno-common -mcpu=cortex-m3 -mthumb -msoft-float -fno-exceptions -fno-rtti -fno-threadsafe-statics -fno-use-cxa-atexit -Wno-psabi -DLA104 -MD -D _ARM -D STM32F10X_HD -D STM32F10X_HD -c \
  ../source/main.cpp \
  ../source/cat.cpp \
  ../source/wasmhost.cpp \
  ../../../os_host/source/framework/Serialize.cpp \
  -I../../../os_library/include/
arm-none-eabi-gcc -fPIC -mcpu=cortex-m3 -mthumb -o output.elf -nostartfiles -T ../source/app.lds \
  ./main.o ./Serialize.o ./cat.o ./wasmhost.o \
  -lbios_ds213 -L../../../os_library/build

arm-none-eabi-objdump -d -S output.elf > output.asm
arm-none-eabi-readelf -all output.elf > output.txt

find . -type f -name '*.o' -delete
find . -type f -name '*.d' -delete

../../../../tools/elfstrip/elfstrip output.elf la140cat.elf
