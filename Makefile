FILES = ./build/kernel.asm.o	./build/kernel.c.o  ./build/memory.o ./build/idt.o
INCLUDES = -I./include/kernel \
	   -I./include/stdlib
FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

all: ./bin/boot.bin ./bin/kernel.bin
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o
	i686-elf-gcc $(FLAGS) -T ./src/linker.ld -o ./bin/kernel.bin ./build/kernelfull.o

./bin/boot.bin: ./src/bootloader/boot.asm
	nasm -f bin -o ./bin/boot.bin ./src/bootloader/boot.asm

./build/kernel.asm.o: ./src/kernel/kernel.asm
	nasm -f elf -g ./src/kernel/kernel.asm -o ./build/kernel.asm.o
./build/kernel.c.o:
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/kernel/kernel.c -o ./build/kernel.c.o

./build/memory.o: ./src/stdlib/memory.c
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/stdlib/memory.c -o ./build/memory.o
	
./build/idt.o: ./src/kernel/idt.c
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/kernel/idt.c -o ./build/idt.o
clean:
	rm -rf ./bin/*.bin
	rm -rf ./build/*.o
