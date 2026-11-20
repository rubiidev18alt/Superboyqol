# Super Boy Deluxe v0.2

Two editions, the same 16-stage Super Boy campaign. Both keep the v0.1
acceleration, variable-height jumps, run/fire button and same-stage continues.
Neither replaces the layouts or collision maps with NES levels.

| Edition | How to get it | Art and music |
|---|---|---|
| Standalone | [IPS](../releases/superboy-deluxe-v0.2.ips) or `make deluxe` | Super Boy / QoL, converted to native SMS tiles and sprites; v0.1 score |
| SMB import | `make deluxe-smb SMB_ROM="/path/to/game.nes"` | Local NES character and terrain graphics; three SMB scores translated to SMS PSG |

**[Watch 1-1 in the standalone build](deluxe-preview.mp4).**

## Play

Apply the standalone IPS **once** to `Super_Boy_1_Kor_Unl_2011.sms` (stock SHA-256
`569888be8bfb7f3bf86d2bfb46535132a12060c8faf0d696f081187a3b7ef6ba`).
Use a patcher that supports expanding the ROM. The result should be **262,144
bytes**, SHA-256 `49c89e1fc3407a88b4768ce7f4ce999277d8ab6ae49ffb6b612f3c5e2729b9f7`.
Open it as a Master System cartridge. Tested on Genesis Plus GX, NTSC-U; a
Sega mapper with cartridge RAM is required. The RAM is sprite conversion
scratch, **not** a savegame. Physical cartridges have not been tested.

Button **1** starts and jumps; tap for a short hop, hold for height. **2** runs
and fires when powered up. At game over, **1** retries the stage, **2** returns
to the title.

## Build with SMB graphics and music

Install [SjASMPlus 1.21.1](https://github.com/z00m128/sjasmplus/releases/tag/v1.21.1), GNU Make and Python 3. From the repository root:

```sh
python3 -m venv .venv
. .venv/bin/activate
python3 -m pip install py65==1.2.0
make deluxe-smb SMB_ROM="/path/to/Super Mario Bros. (World).nes"
```

Output: `build/superboy-deluxe-smb.sms`. The importer validates the 32 KiB
PRG + 8 KiB CHR payload, with or without the 16-byte iNES header. Payload
SHA-256: `fcb6a0ef3a20c19b356005fbb21dc8009563b1cb5a9aaebc8e9386b4a8c5912e`.
Multi-game cartridges, modified dumps and other revisions aren't interchangeable:
the converter uses this version's graphics tables and sound engine addresses.
No NES game, extracted tiles, score data or donor-based IPS is supplied. No
runtime connection to the donor is needed after building. The standalone build
uses only the Python standard library and does not read an NES file.

### What changes on screen and in the score?

- **Camera:** the CPU still shifts the collision map on tile boundaries, but
  the VDP scroll register moves the picture at pixel resolution. A circular
  name table and a one-column lookahead supply the entering edge. The top
  two rows stay pinned; captions and digits have a dedicated dark panel.
- **Colour and animation:** warm stone and gold, green pipework, stage-specific
  sky colours, independently coloured sprite pixels and a four-pose coin spin.
  With the import, small and big player forms use the NES stand, three walk,
  brake and jump poses, facing either way. Common enemies use Goomba, beetle,
  Spiny and Koopa/Paratroopa art, with timed walk frames, shells and flattened
  poses where appropriate. Mushrooms, flowers, coins, pipes, bricks, question
  blocks, spent blocks, stairs and ground also use converted NES art. The
  title, landscapes, ghosts, castle bosses and special scenes retain Super
  Boy artwork. This is an asset conversion, not NES emulation.
- **Music:** the build tool steps the donor's 6502 music engine and records
  pitch, rests, durations and phrase loops. Ground, underground and castle
  themes play on the SMS’s three tone channels. The ground intro plays once;
  the loop starts at frame 144. Lead and bass continue when an original
  Super Boy effect borrows the harmony channel. The SMS does not reproduce
  NES pulse duty, triangle timbre or noise percussion exactly.

## Implementation and checks

`src/deluxe/video.asm` translates the old VDP writes, `sprites.asm` expands
16×16 layers into pairs of 8×16 sprites, and `music.asm` plays the imported
score. `tools/deluxe/assets.py` packs the ROM banks; `score.py` builds the
three PSG streams. The stock and v0.1 targets still assemble separately.
Donor table identification was cross-checked against the
[annotated SMB disassembly](https://github.com/Xkeeper0/smb1/tree/1cc3c92cbbe8cda44903657f3da332688e806a89).

With the [pinned Genesis Plus GX core](playthrough.md) built locally:

```sh
make verify                       # stock ROM byte-for-byte
make deluxe-patch                 # regenerate standalone IPS
make deluxe-test GPGX=/path/to/Genesis-Plus-GX
make deluxe-smb-test GPGX=/path/to/Genesis-Plus-GX SMB_ROM="/path/to/game.nes"
```

Each Deluxe test boots from reset, checks short/held jumps and acceleration,
compares rendered floor pixels across successive frames of walking, verifies
that the HUD caption pixels stay fixed, and replays its own 16-stage controller
recording. Different code paths change timing, so the editions use different
recordings. Both finish 4-4 and return to 1-1 with five lives.
