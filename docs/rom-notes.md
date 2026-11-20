# Super Boy I: ROM notes

Addresses below are hexadecimal Z80 addresses. For this 48 KiB dump they also
match file offsets. These are reconstructed names, not original developer symbols.

| Range (inclusive) | Contents |
|---|---|
| `0000–3fff` | Duplicate of `8000–bfff`. Reset jumps to `4025`; IM 1 jumps from `0038` to `4000`. |
| `4000–5e31` | Interrupt handler, startup, game loop, stage setup, actors, collision, scrolling, HUD, input and video initialization, with embedded tables. |
| `5e32–5e89` | Small tables including the 16 initial timer values at `5e3a`. |
| `5e8a–6f89` | Sixteen 272-byte stage layouts, in play order. |
| `6f8a–7029` | Five additional 32-byte records. Not part of the sixteen indexed layouts. |
| `702a–7249` | Title and sixteen stage colour tables (32 bytes each). |
| `724a–72b5` | 36 attract-mode input records: IRQ countdown (word), held inputs (byte). |
| `72b6–748e` | Common sprite uploads, sound controls, time-over and game-over handlers and text. |
| `748f–7605` | Sixteen pointers followed by variable-length stage spawn lists. |
| `7606–76f6` | VDP and PSG output routines. |
| `76f7–76ff` | Nine bytes of undetermined purpose. |
| `7700–8c0d` | 245 reusable tile columns. This table **crosses the bank boundary**. |
| `8c0e–944d` | Three 32-column screens, used for the title and scripted sequences. |
| `944e–a7ff` | Sprite pattern blocks and intervening bytes. Stage setup selects and transforms patterns. |
| `a800–acce` | Four sound entry points and the music/effect interpreter. |
| `accf–b7ff` | Modulation tables, effect pointers, song/effect bytecode and some unreferenced tails. |
| `b800–bfff` | 256 background character patterns, 8 bytes each. |

## From reset to a stage clear

`reset_handler` selects IM 1, sets SP to `$f300`, and calls `init_video`.
The title accepts pad bit 4 (despite saying “PUSH SPACE”); if the title wait
expires it copies `attract_movie` into RAM. The IRQ saves both register sets,
reads the VDP, advances the sound driver and samples the active-low pad at
port `$dc`. `read_controller` substitutes the demo's recorded inputs only in
demo mode. In normal play bit 3 is right, bit 4 is jump, and holding bit 5
raises the horizontal speed cap (`$1f` to `$32`); it can also fire when powered up.

`load_stage` computes `stage_index = world_index * 4 + round_index`, copies the
layout and object data to RAM, initializes the timer and dispatches indirectly
through `stage_init_table`. All sixteen targets have labels. The loop updates
scrolling, collision and the timer; when `frame_ready` is set it advances the
clock, moves the player twice and updates the sprite attributes. The IRQ also
updates actors on alternating game ticks. These loops are **not** interchangeable
with one movement update per emulated video frame.

`tile_at_pixel` takes screen X in H and Y in L and finds a tile in the RAM
playfield. `is_solid_tile` returns **NZ** for a solid tile; IDs below `$12`,
IDs at or above `$d8`, and entries in `passable_tiles` are non-solid. There are
additional interactions: e.g. `$98/$99` award a coin and `$15/$17/$a4` are
checked by `check_exit_tile` *before* the ordinary side-collision test.

`finish_stage` advances the round, rolling to the next world every fourth round.
In **4-4** `game_loop` has two explicit maze tests on the low byte of the scroll
column. At `$62`, Y must be **below `$60` numerically** (take the upper route)
or the column is reset to `$19`. At `$c8`, Y must be **at least `$80`** (take the
lower route) or it is reset to `$62`. At the final castle exit the game writes
`TO BE CONTINUED` instead of `SORRY  NOTHING`, then wraps from 4-4 to 1-1.

## Editing a level

For world 2-3, for example:

- `layout_2_3` in `stage_tables.asm`: one dictionary ID per column. The tile at
  `(column, row)` is `ROM[map_columns + 22 * layout[column] + row]`. Row 0 is
  at the top. Column IDs are shared, so changing the dictionary changes *every*
  level using that ID. Some dictionary bytes also form the vectors; don't treat
  those as freely editable artwork.
- `colours_2_3`: one foreground/background pair per **eight pattern IDs**. The
  two nibbles are colour numbers, not independent per-pixel colour planes.
- `stage_data_07` in `support.asm`: `(scroll column, Y, type)` triples. The
  ordinary list ends with `$ff` in the column field. A first field of `$01`
  invokes a **repeating generator**, not a spawn at column one. These lists
  need not have a terminator. The loader copies `$32` bytes regardless of the
  length of the list; the consumer determines when to stop.
- `init_stage_07` in `game.asm`: stage-specific calls to load sprites, choose
  music and prime the scrolling window. `src/ram.asm` names the live values.

Run `make maps` to render `build/maps/1-1.png` through `4-4.png` (2176 × 176
pixels each), plus the three fixed screens. This reads the rebuilt ROM and
assembler symbols, not screenshots. These are the **stored backgrounds**:
no sprites, HUD, runtime tile changes or camera/maze loops are drawn.

## VDP and sound

This is TMS-compatible **Graphics I**, not the usual SMS Mode 4 tile format.
`init_video` sets VDP registers 0–6 to `$00,$e2,$0d,$dc,$07,$60,$00`.
Name table: VRAM `$3400`; colour table: `$3700`; background patterns: `$3800`;
sprite attributes: `$3000`. `upload_playfield` copies 32 × 22 tile IDs from
`$e83f` to VRAM `$3440`, below the two HUD rows. Sprites use separate pattern
banks; `mirror_sprite_patterns` swaps 16-byte halves and reverses the bits in
each byte. The HUD uses tile `$d8` for `0`, `$e2` for `A`, and `$00` for space.

`sound_init` selects three streams per track (four sets of starting pointers).
Three `$20`-byte music channel records start at `$fa20`; effects use the fourth
at `$fa80`. An active effect can suppress writes from music channel three.
`sound_effect` takes a **one-based** effect ID. Its pointer table begins at
`$ad60`; the code starts walking two bytes earlier. The bytecode in
`sound_graphics_data.asm` is data interpreted by `tick_channel`, not Z80 code:

| Bytes | Driver operation |
|---|---|
| `00..05 lo hi duration` | Tone-register pair and timed note. |
| `06..0a value` | Register write (mixer/noise/volume). |
| `52 duration` | Rest. |
| `54 value` | Set tempo. |
| `58 index`, `59 index` | Select pitch or volume modulation. |
| `4b 48` | End this channel's phrase, leave its pointer at the next byte. |
| `4b 4c lo hi` | End phrase with an explicit next pointer. |

`psg_write` translates register operations to SMS PSG writes at `$7f`.
Unidentified bytes and stream tails are preserved; an address label does not
mean a routine is reachable on SMS. In particular, there are keyboard-port
instructions in the ROM, but the active controller path uses `$dc`.
