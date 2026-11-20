# Super Boy QoL v0.1

A playable overhaul for the 48 KiB Master System cartridge. It keeps the 16
stage layouts and their collision tile IDs so the new controls can be tested
against the original jumps, pipes, castle exits and 4-4 maze. It is inspired
by Super Mario Bros., not an exact NES physics or soundtrack port.

**[Playthrough sample with sound: world 1-1](qol-preview.mp4)**

## Play or build

Apply [the IPS patch](../releases/superboy-qol-v0.1.ips) **once** to a copy of
`Super_Boy_1_Kor_Unl_2011.sms`, then open the patched `.sms` in a Master System
emulator. IPS itself does not validate its input. Both files should be 49,152
bytes; use these SHA-256 hashes to distinguish them:

| File | SHA-256 |
|---|---|
| Original | `569888be8bfb7f3bf86d2bfb46535132a12060c8faf0d696f081187a3b7ef6ba` |
| QoL v0.1 | `4ea53ac5d3dfd8d7c35cd325fa3246edbc6704dfdc5a7baa5103ebce25066689` |

Alternatively, `make qol` produces `build/superboy-qol.sms` directly from the
assembly. `make qol-patch` regenerates the IPS; `make qol-maps` renders the
modified backgrounds. `make verify` still builds and checks the **stock** ROM.

## What changed

- **Movement:** walk builds to one pixel/frame; holding button 2 builds to two.
  Fractional movement replaces the old slow/fast switch. Releasing the run
  button bleeds speed back to walking pace; letting go of the direction brakes
  the player. Air steering responds every other movement update. Button 1 cuts
  the jump when released. Falling accelerates to terminal speed and still checks
  the floor between pixels. The tested six-frame hop rises 18 px; a held jump
  rises 80 px. Tuning and fixed-address hooks: `src/qol/movement.asm`, `game.asm`.
- **Presentation:** all sixteen stage colour pages and the title have been
  retuned within Graphics I's two-colours-per-eight-tiles limit. Gold question
  blocks and coins stand apart from obstacles; outdoor stone, cave masonry and
  castle walls have distinct treatments. Question blocks, bricks, ledges and
  coins have new pixel patterns, without changing collision geometry.
- **Sound:** two new, original three-channel PSG loops. *Sunlit Steps* has a
  syncopated lead, walking bass and offbeat answering voice. *Ember Hall* uses
  a minor-key pulse. The quietest part occupies channel 3 so jumping or picking
  up a coin doesn't steal the melody. The existing sound effects remain.
  `src/qol/score.asm` contains the actual notes, tempos and loop points.
- **Quality of life:** the title correctly says `PRESS 1`; the stage card is
  shorter. After game over, release the buttons and press **1 to retry the same
  stage with five lives** (score, coins and power-ups reset), or **2 for the
  title**. Doing nothing returns to the title after about eight seconds. This
  is a session continue, not battery-backed saving. Boot now clears the IRQ
  flags before video initialization, including on the NTSC-J power-on RAM pattern.

## Validation and scope

`make qol-test GPGX=/path/to/Genesis-Plus-GX` uses the [same pinned emulator
core](playthrough.md) as the stock regression. It tests short and held jumps,
walk and run caps, braking, five timeouts, game over and attract mode, then
plays `tests/qol-all-stages.pad` from power-on. A new controller recording is
necessary because the old movements no longer land at the same times.
The mod replay clears 4-4 at frame **39,300**, returns to 1-1 and ends with all
five lives. The retry choice was separately tested on 1-2 after exhausting the
five lives; the player resumed on 1-2 with five fresh lives. The NTSC-J boot
was also checked for a visible playfield and working movement.

The engine, not just the art, still differs from the NES game: scrolling is in
tile columns, actors use the original AI, and graphics use the SMS legacy VDP
mode. Those are candidates for later work, not features claimed by v0.1.
