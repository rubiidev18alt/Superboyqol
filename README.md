# Superboyqol
Super Boy I for the Master System: a byte-identical disassembly and a separate playable QoL edition.

## Play the QoL edition

[QoL v0.1 IPS patch](releases/superboy-qol-v0.1.ips) · [Gameplay with sound](docs/qol-preview.mp4) · [Installation, controls and changes](docs/qol.md)

Run `make qol` to build `build/superboy-qol.sms`. The mod changes movement, graphics and music, and adds a same-stage continue. The stock build and its regression tests remain available below.

## Rebuild the ROM

Install [SjASMPlus](https://github.com/z00m128/sjasmplus/releases/tag/v1.21.1)
(tested with 1.21.1) and GNU Make. From the repository root:

```sh
make          # assembles src/superboy.asm into build/superboy.sms
make verify   # compares every byte with Super_Boy_1_Kor_Unl_2011.sms
```

If the assembler is not on `PATH`, pass `SJASMPLUS=/path/to/sjasmplus`
to `make`. The build uses only assembly source; the original `.sms` is needed
only for verification. The unmodified result is 49,152 bytes, SHA-256
`569888be8bfb7f3bf86d2bfb46535132a12060c8faf0d696f081187a3b7ef6ba`.

## Source layout

- `$0000–$3fff` and `$8000–$bfff` are identical 16 KiB banks. Both assemble
  from `src/shared.asm`, using the high addresses referenced by the sound
  driver. The low copy supplies the reset (`$0000`) and IM 1 (`$0038`) vectors.
- `$4000–$7fff` contains the main program (`game.asm`), stage data
  (`stage_tables.asm`), video and sound output routines (`support.asm`),
  and trailing data (`bank1_tail.asm`). Start at `reset_handler` for startup
  or `stage_init_table` for the 16 stage entry points.

Code uses Z80 mnemonics; tables, graphics, and unidentified bytes are kept
as data directives. Many references are still absolute, so preserve addresses
when patching unless you also update the affected pointers.

## Explore and test the disassembly

[Full walkthrough video: all 16 stages, from power-on to the ending (10:26).](docs/all-stages.mp4)

- [ROM notes and editing guide](docs/rom-notes.md): memory map, level format,
  collision and exit logic, VDP layout, sound bytecode and remaining unknowns.
- `make maps` (Python 3) renders all 16 stage backgrounds into `build/maps/`.
- [Emulator playthrough](docs/playthrough.md): replay every stage from reset
  using controller inputs, including the 4-4 maze and the wrap back to 1-1.

The verified controller-only run shows **TO BE CONTINUED** in 4-4, then
returns to 1-1 on frame **37,475** with five lives. A second run exercises
timeouts, game over and attract mode. Neither test modifies the ROM or RAM.
