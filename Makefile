MOO_PATH=../crawlo

all:
	make zxs -C $(MOO_PATH)
	mkdir -p build/
	make moonrn.tap

build/moonrn.bin: $(MOO_PATH)/moonrn.bin
	cp $(MOO_PATH)/moonrn.bin build/moonrn.bin

build/bzpack: bzpack/src/*.cpp
	g++ bzpack/src/*.cpp -o build/bzpack

build/code.pck: build/bzpack build/moonrn.bin
	build/bzpack build/moonrn.bin build/code.pck -ue2 -o -e -r

build/loading.pck: build/bzpack $(MOO_PATH)/loading.scr
	build/bzpack $(MOO_PATH)/loading.scr build/loading.pck -ue2 -o -e -r

moonrn.tap: build/code.pck build/loading.pck
	sjasmplus --syntax=ab \
		--sym=build/loader.sym \
		--lst=build/loader.lst \
		src/loader.asm

run: all
	fuse --no-traps --no-accelerate-loader --no-fastload moonrn.tap

clean:
	rm build moonrn.tap -rf
