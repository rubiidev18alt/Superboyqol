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
	$(RM) $(ROM) $(QOL_ROM) build/superboy-qol.ips build/replay build/superboy.sym build/qol.sym
	$(RM) -r build/maps build/qol-maps

# Optional headless emulator regression (Linux). See docs/playthrough.md.
.PHONY: replay
build/replay: tests/replay.c FORCE
	@mkdir -p build
	@test -n "$(GPGX)" || { echo 'Set GPGX to the built Genesis-Plus-GX directory'; exit 1; }
	$(CC) -std=c99 -O2 -Wall -Wextra -I"$(GPGX)/libretro/libretro-common/include" \
		tests/replay.c "$(abspath $(GPGX))/genesis_plus_gx_libretro.so" -o build/replay

.PHONY: FORCE
FORCE:

replay: verify build/replay
	build/replay $(ROM) tests/all-stages.pad
	build/replay $(ROM) --idle

.PHONY: maps
maps: $(ROM)
	$(SJASMPLUS) --sym=build/superboy.sym src/superboy.asm
	python3 tools/render_maps.py $(ROM) build/superboy.sym build/maps

QOL_ROM := build/superboy-qol.sms
.PHONY: qol qol-maps
qol: $(QOL_ROM)

$(QOL_ROM): $(wildcard src/*.asm src/qol/*.asm) Makefile
	mkdir -p build
	$(SJASMPLUS) -DQOL --raw=$@ src/superboy.asm

qol-maps: $(QOL_ROM)
	$(SJASMPLUS) -DQOL --sym=build/qol.sym src/superboy.asm
	python3 tools/render_maps.py $(QOL_ROM) build/qol.sym build/qol-maps

.PHONY: qol-patch
qol-patch: verify $(QOL_ROM)
	python3 tools/make_ips.py $(REFERENCE) $(QOL_ROM) build/superboy-qol.ips

.PHONY: qol-test
qol-test: verify $(QOL_ROM) build/replay
	build/replay $(QOL_ROM) --qol-controls
	build/replay $(QOL_ROM) --idle
	build/replay $(QOL_ROM) tests/qol-all-stages.pad
