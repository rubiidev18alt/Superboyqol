# Generic v0.3.1

[**Playable ROM**](../releases/superboy-generic-v0.3.1.sms) · Sega Master System,
256 KiB, Sega mapper with cartridge RAM. Uses the standalone Super Boy / QoL
artwork and soundtrack. Does not import Super Mario Bros. assets.

## Layout balance in v0.3.1

Selected gaps are 8 or 16 pixels narrower. For example, the first five-tile
pit in **1-2** now spans three tiles, the consecutive seven-tile jumps in
**2-4** each span five, and the longest gap in **3-4** drops from eleven tiles
to nine. In **4-2**, two wide pits gain a short stretch of floor on their
approach side. No pit is filled completely.

The edits replace empty columns in 13 stages. The opening course (1-1),
3-1 and the final maze (4-4) retain their layouts. No enemies, timers, exits
or movement settings changed. The [previous ROM](../releases/superboy-generic-v0.3.sms)
is still available for the original difficulty.

## Feel and sound

The first few horizontal updates now add speed twice as quickly; acceleration
then eases into the existing walk and run limits. The jump samples a parabola
instead of a long sequence of flat steps near the top. Releasing **1** still
cuts the ascent. In the emulator a six-frame press rises **19 px**, while a
held jump rises **79 px**. Small and powered-up jumps have different four-note
rises, and collecting a coin plays a short E–B–E chime with a quieter tail.
The effects use the third PSG voice so they don't interrupt the melody.

[Watch the scrolling block-coin check with game audio](generic-coin.mp4).

## Why the sprites are steadier

- The actor simulation runs every second logic tick, not asynchronously while
  the game is building a sprite list. The renderer interpolates nearby poses;
  collisions still use the simulation positions, not the interpolated ones.
- A completed sprite list and its camera offset are published together at
  vertical blank. Coarse scroll updates both interpolation endpoints. Matching
  colour layers are packed into one two-colour pattern rather than spending
  twice the sprites and rotating actor order on overflow. The hardware's
  eight-sprites-per-line limit still applies.
- A block coin is a world object, not a player overlay. Its existing coarse X
  adjustment is retained; its render X now also includes fine scroll. The
  popup stays over the spent block instead of sliding away between columns.

## Rebuild or test

`make generic` builds `build/superboy-generic.sms` with SjASMPlus 1.21.1,
GNU Make and Python 3 (standard library only). The release SHA-256 is
`aff4eadb359f3604a23820d111f1c39db17fce43d7d0e7636198cb7f1d9c3534`.
The stock, QoL and Deluxe build targets are unchanged.

With the [pinned Genesis Plus GX libretro core](playthrough.md) built:

```sh
make generic-test GPGX=/path/to/Genesis-Plus-GX
```

The regression walks and runs from rest, checks short/held jumps, measures
single-pixel scrolling with a fixed HUD, and then jumps into the first coin
block while holding right and run. It tracks the **rendered** coin and walker
against the floor pixels, not just their RAM positions. In the test the coin
rose 46 pixels over 24 visible frames while the floor scrolled 35 pixels;
its world-space centre did not change. The enemy walked 11 pixels without a
backward snap. Tests use NTSC-U; physical hardware has not been tested.

The same test target also checks the idle/game-over path and replays
`tests/generic-all-stages.pad` from reset. The packaged ROM clears 4-4 at
frame 41,061 and finishes the recording back at 1-1 with five lives.
