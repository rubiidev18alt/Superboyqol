SJASMPLUS ?= sjasmplus
ROM := build/superboy.sms
REFERENCE := Super_Boy_1_Kor_Unl_2011.sms

.PHONY: all verify clean
.DELETE_ON_ERROR:

all: $(ROM)

$(ROM): $(wildcard src/*.asm) Makefile
	mkdir -p build
	$(SJASMPLUS) --raw=$@ src/superboy.asm

verify: $(ROM)
	cmp $(REFERENCE) $(ROM)
	@echo "Rebuilt ROM is byte-for-byte identical to $(REFERENCE)"

clean:
	$(RM) $(ROM) build/replay build/superboy.sym
	$(RM) -r build/maps

# Optional headless emulator regression (Linux). See docs/playthrough.md.
.PHONY: replay
replay: verify
	@test -n "$(GPGX)" || { echo 'Set GPGX to the built Genesis-Plus-GX directory'; exit 1; }
	$(CC) -std=c99 -O2 -Wall -Wextra -I"$(GPGX)/libretro/libretro-common/include" \
		tests/replay.c "$(abspath $(GPGX))/genesis_plus_gx_libretro.so" -o build/replay
	build/replay $(ROM) tests/all-stages.pad
	build/replay $(ROM) --idle

.PHONY: maps
maps: $(ROM)
	$(SJASMPLUS) --sym=build/superboy.sym src/superboy.asm
	python3 tools/render_maps.py $(ROM) build/superboy.sym build/maps
