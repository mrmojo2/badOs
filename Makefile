all:
	nasm -f bin -o ./bin/boot.bin ./src/bootloader/boot.asm

clean:
	rm -rf ./bin/*.bin
