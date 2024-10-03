all: file1
        
file1: file1.asm
	nasm -f elf32 -o file1.o file1.asm
	ld -m elf_i386 -o file1 file1.o
