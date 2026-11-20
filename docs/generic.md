# Generic v0.3

[**Playable ROM**](../releases/superboy-generic-v0.3.sms) · Sega Master System,
256 KiB, Sega mapper with cartridge RAM. Uses the standalone Super Boy / QoL
artwork and soundtrack. Does not import Super Mario Bros. assets.

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
`0cea48c858d3ef0779c08b27d60fe816e9f6136e2004530af9c021fe9ec71a51`.
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
frame 42,976 and finishes the recording back at 1-1 with five lives.
