MOO_PATH=../crawlo

all:
	make zxs -C $(MOO_PATH)
	cp $(MOO_PATH)/moonrn.bin $(MOO_PATH)/loading.scr pristine/
	scripts/repack
	scripts/build
	fuse --no-traps --no-accelerate-loader --no-fastload moo.tap
