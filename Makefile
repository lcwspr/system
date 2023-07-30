build/boot.bin: src/boot/boot.asm
	mkdir -p build
	nasm -f bin src/boot/boot.asm -o build/boot.bin

build/master.img: build/boot.bin
	echo yes | bximage -q -mode=create -hd=16 -sectsize=512 -imgmode=flat build/master.img
	dd if=build/boot.bin of=build/master.img bs=512 count=1 conv=notrunc

.PHONY: bochs
bochs: build/master.img
	bochs -q

.PHONY:clean
clean:
	rm -rf build