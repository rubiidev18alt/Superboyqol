# Generic polish playtest (RC1)

[Download the standalone SMS ROM](../releases/superboy-generic-polish-rc1.sms) · [Watch the opening with game audio](polish-opening.mp4) · [Stable v0.3.1](generic.md)

This build keeps the balanced Generic layouts. Try running at full speed and
pressing the opposite direction, then try the same turn near a ledge. The
player now brakes **through** the old velocity instead of freezing while two
opposing speeds cancel out. Account for about one tile of skid from a full
run. Top speed, the short-hop release and the full-height jump are unchanged.
When powered up, **2** fires on press; letting go of run no longer wastes a shot.

Bricks and ground have highlighted edges; question marks keep dark ink on a
bright face even on night sheets. Only tile pixels change, not collision IDs.
Four PSG cues distinguish bumping a brick from breaking it, enemy contact
from collecting a coin, and earning an extra life from an ordinary pickup.
They borrow the effects voice rather than stopping the stage music.

## Measured on Genesis Plus GX (NTSC-U)

| Same cold boot and input | v0.3.1 | RC1 |
| --- | ---: | ---: |
| Start press to active 1-1 | 38 frames | 20 frames |
| First leftward pixel after reversing a full rightward run | frame 18 | frame 10 |
| Forward travel during that reversal | 0 px (stall) | 8 px (skid) |
| Frames with opposing velocities in the reversal | 15 | 0 |
| Six-frame / held jump height | 19 / 79 px | 19 / 79 px |

The start benchmark checks **all 704 tiles** of the title and first playable
window against ROM data. Full screens decode directly to their final columns.
During a full stage prime, the engine no longer shifts a 704-byte buffer for
each column before anything can be seen. Mixed openings and live streaming
retain the original path. A full clear writes each physical playfield row in
one burst and leaves the HUD untouched. Stage cards need only 5 × 256 bytes
of background tiles instead of 32 × 256; the 2 KiB HUD font stays resident.
The card itself (world, player and life count) is still displayed.

## Reproduce

```sh
make polish                             # build/superboy-polish.sms
make verify generic                     # stock still matches its original
cmp build/superboy-generic.sms releases/superboy-generic-v0.3.1.sms
cmp build/superboy-polish.sms releases/superboy-generic-polish-rc1.sms
make polish-test GPGX=/path/to/Genesis-Plus-GX
build/replay releases/superboy-generic-v0.3.1.sms --opening  # A/B baseline
```

Use GNU Make, SjASMPlus 1.21.1, Python 3 and the [pinned emulator for tests](playthrough.md).
RC1 SHA-256: `35211ee9a94858b40f1876df1b8241462546c4ef149abffe29c4f871167ce707`.
The focused checks cover movement, the opening benchmark, fine scrolling with
a fixed HUD, scrolling enemies and coin popups, and five timeouts through
game over and attract mode. The controller recording
`tests/polish-all-stages.pad` then clears all 16 stages from reset: 4-4
completes at frame 35,190 and the recording ends back at 1-1 on frame
35,218 with five lives. This is a different route from v0.3.1’s recording,
not a benchmark of total loading time. Physical hardware has not been tested.

## Next playtest priorities

- **Late jumps:** log missed takeoffs on the longer gaps before adding coyote
  time or buffered jumps. Both would affect the difficulty beyond the 1–2
  tile landing adjustments already in v0.3.1.
- **Busy scenes:** count dropped actor scanlines on hardware in the castle
  stages. If shots or hazards disappear, prioritize those over coin sparkles.
- **Sound mix:** compare rapid bumps and pickups over each world theme on a
  console PSG before changing their priority or extending the cues.
- **Transitions:** measure the mixed cave openings and retries independently;
  the 18-frame saving above is for starting 1-1, not a campaign-wide average.
