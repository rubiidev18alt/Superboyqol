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
	$(RM) build/superboy-polish.sms build/polish.core build/polish.sym
	$(RM) build/superboy-generic.sms build/generic.core build/generic.sym
	$(RM) build/superboy-deluxe*.sms build/deluxe.core build/deluxe.sym build/import.core build/import.sym build/superboy-deluxe.ips
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

# Native SMS Mode 4 renderer. The two builds have separate intermediates.
DX_SOURCES := $(wildcard src/*.asm src/qol/*.asm src/deluxe/*.asm tools/deluxe/*.py)
.PHONY: deluxe deluxe-smb deluxe-test
deluxe: build/superboy-deluxe.sms
build/superboy-deluxe.sms: $(DX_SOURCES) Makefile
	mkdir -p build
	$(SJASMPLUS) -DQOL -DDELUXE --raw=build/deluxe.core --sym=build/deluxe.sym src/superboy.asm
	python3 tools/deluxe/assets.py build/deluxe.core build/deluxe.sym $@

deluxe-smb:
	@test -f "$(SMB_ROM)" || { echo 'Set SMB_ROM to your local Super Mario Bros. (World) NES dump'; exit 1; }
	mkdir -p build
	$(SJASMPLUS) -DQOL -DDELUXE -DSMB_ASSETS --raw=build/import.core --sym=build/import.sym src/superboy.asm
	python3 tools/deluxe/assets.py build/import.core build/import.sym build/superboy-deluxe-smb.sms --smb "$(SMB_ROM)"

deluxe-test: deluxe build/replay
	build/replay build/superboy-deluxe.sms --qol-controls
	build/replay build/superboy-deluxe.sms --deluxe-camera
	build/replay build/superboy-deluxe.sms tests/deluxe-all-stages.pad

.PHONY: deluxe-patch deluxe-smb-test
deluxe-patch: verify deluxe
	python3 tools/make_ips.py $(REFERENCE) build/superboy-deluxe.sms build/superboy-deluxe.ips

deluxe-smb-test: deluxe-smb build/replay
	build/replay build/superboy-deluxe-smb.sms --qol-controls
	build/replay build/superboy-deluxe-smb.sms --deluxe-camera
	build/replay build/superboy-deluxe-smb.sms tests/deluxe-smb-all-stages.pad

# Self-contained follow-up, with no SMB donor or py65 dependency.
.PHONY: generic generic-test
generic: build/superboy-generic.sms
build/superboy-generic.sms: $(DX_SOURCES) $(wildcard src/generic/*.asm) Makefile
	mkdir -p build
	$(SJASMPLUS) -DQOL -DDELUXE -DGENERIC --raw=build/generic.core --sym=build/generic.sym src/superboy.asm
	python3 tools/deluxe/assets.py build/generic.core build/generic.sym $@

generic-test: generic build/replay
	build/replay build/superboy-generic.sms --qol-controls
	build/replay build/superboy-generic.sms --deluxe-camera
	build/replay build/superboy-generic.sms --generic-actors
	build/replay build/superboy-generic.sms --idle
	build/replay build/superboy-generic.sms tests/generic-all-stages.pad

# Opt-in candidate; generic and the published v0.3.1 ROM remain stable.
.PHONY: polish polish-test
polish: build/superboy-polish.sms
build/superboy-polish.sms: $(DX_SOURCES) $(wildcard src/generic/*.asm src/playtest/*.asm) Makefile
	mkdir -p build
	$(SJASMPLUS) -DQOL -DDELUXE -DGENERIC -DPOLISH --raw=build/polish.core --sym=build/polish.sym src/superboy.asm
	python3 tools/deluxe/assets.py build/polish.core build/polish.sym $@

polish-test: polish build/replay
	build/replay build/superboy-polish.sms --qol-controls
	build/replay build/superboy-polish.sms --deluxe-camera
	build/replay build/superboy-polish.sms --block-cycle
	build/replay build/superboy-polish.sms --polish-opening
	build/replay build/superboy-polish.sms --generic-actors
	build/replay build/superboy-polish.sms --idle
	build/replay build/superboy-polish.sms tests/polish-power-ups.pad --power-ups
	build/replay build/superboy-polish.sms tests/polish-all-stages.pad
