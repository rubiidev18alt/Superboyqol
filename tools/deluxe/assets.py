"""Build the banked Mode 4 cartridge. Donor data is read only from a local dump."""
import argparse
import hashlib
from pathlib import Path

BANK = 16384
DONOR = 'fcb6a0ef3a20c19b356005fbb21dc8009563b1cb5a9aaebc8e9386b4a8c5912e'


def pack(rows):
    return bytes(sum(((p >> n) & 1) << (7-x) for x, p in enumerate(row))
                 for row in rows for n in range(4))


def nes_tile(chr_, tile, palette, background=False):
    start = (4096 if background else 0) + tile * 16
    return [[palette[((chr_[start+y] >> x) & 1) | ((chr_[start+8+y] >> x) & 1)*2]
             for x in reversed(range(8))] for y in range(8)]


def backdrop(chr_, sheet):
    earth = (0, 11, 6, 1) if sheet not in (2, 14) else (0, 5, 15, 4)
    gold, leaf = (0, 10, 1, 11), (0, 2, 12, 3)
    tiles = {}
    for dest, src, pal in [(0x28, (0x53,0x54,0x55,0x56),gold),
                           (0x60, (0x57,0x58,0x59,0x5a),earth),
                           (0x35, (0x45,0x47),earth),
                           (0x70, (0xb4,0xb5,0xb6,0xb7),earth),
                           (0x6c, (0xab,0xad,0xac,0xae),earth),
                           (0x40, range(0x60,0x67),leaf),
                           (0x48, (0x67,),leaf),
                           (0x50, (0x68,0x69,0x6a),leaf),
                           (0x0d, (0x26,),leaf),
                           (0xd0, (0x68,0x68,0x69,0x69,0x26,0x26,0x6a,0x6a),leaf)]:
        for i, t in enumerate(src):
            tiles[dest+i] = pack(nes_tile(chr_, t, pal, True))
    # The SMS coin hitbox is only one tile wide. Crop the central 8 px.
    for i in range(2):
        a,b = [nes_tile(chr_, t, gold, True) for t in (0xa5+i*2,0xa6+i*2)]
        tiles[0x98+i] = pack([x[4:]+y[:4] for x,y in zip(a,b)])
    return tiles


def sprite(donor, stage, bank, p):
    """Return a coloured 16x16 layer, or None to keep a stage-specific prop."""
    chr_ = donor[32768:]
    player, enemy = donor[0x6e17:], donor[0x673e:]
    flip = mirror_right = False
    pal = (0, 9, 13, 6)
    if p < 0x68:
        if bank < 2:
            flip = 0x30 <= p < 0x60
            frame = [23,16,12,13,14,15][(p%0x30)//8] if p < 0x60 else 22
            offset = 8*frame+4
        else:
            flip = bank < 4
            frame = [25,4,0,1,2,3,10][p//16]
            offset = 8*frame + (4 if p & 8 else 0)
        tiles = player[offset:offset+4]
    elif p == 0xc8 and stage != 16:
        offset = 0x66be + (4 if bank >= 2 else 0)
        tiles = donor[offset:offset+4]
        mirror_right = bank >= 2
    elif stage == 16 or stage%4 == 3:
        return None  # pole/pipe scripts and Super Boy castle bosses
    elif p < 0x88:
        if stage in (8,13):
            return None  # preserve the ghost's actual flipping animation
        pal = (0,1,6,13)
        if p >= 0x78:
            frame = 23
            mirror_right = True
        elif stage in (5,6):
            frame = bank%2  # beetle
        elif stage in (9,12,14):
            frame = 6+bank%2  # spiny
            pal = (0,9,1,15)
        else:
            frame = 14
            flip = bool(bank%2)
        flip ^= p == 0x70
        tiles = enemy[6*frame+2:6*frame+6]
    elif p <= 0xa0:
        if stage == 12:
            return None
        frame = (4 if stage in (2,5,6,9,14) else 2)+bank%2
        offset = 6*frame
        tiles = [0xfc,0xfc,*enemy[offset:offset+2]] if p & 8 else enemy[offset+2:offset+6]
        flip = p >= 0x98
        pal = (0,2,1,11)
    elif p == 0xc0:
        offset = 6*(17+bank%2)+2
        tiles = enemy[offset:offset+4]
        mirror_right = True
        pal = (0,2,1,11)
    else:
        return None
    quads = [nes_tile(chr_,t,pal) for t in tiles]
    rows = [x+(y[::-1] if mirror_right else y) for l,r in [(0,1),(2,3)] for x,y in zip(quads[l],quads[r])]
    if flip:
        rows = [row[::-1] for row in rows]
    return pack([r[:8] for r in rows] + [r[8:] for r in rows])


def install_sprites(rom, donor):
    # Dedup identical poses. Page 12 indexes [scene][bank][pattern / 4];
    # pages 13/14 hold native 128-byte frames. $fe hides a redundant layer.
    shapes = {}
    for stage in range(17):
        for bank in range(6):
            for p in range(0,256,8):
                pixels = sprite(donor,stage,bank,p)
                i = 12*BANK + (stage*6+bank)*64 + p//4
                if pixels is None:
                    rom[i:i+2] = b'\xff\xff'
                else:
                    idx = shapes.setdefault(pixels,len(shapes))
                    rom[i:i+2] = bytes((idx,254))
    assert len(shapes) < 254
    for data,idx in shapes.items():
        start = 13*BANK+idx*128
        rom[start:start+128] = data


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for name in ('core','symbols','output'):
        ap.add_argument(name,type=Path)
    ap.add_argument('--smb',type=Path)
    args = ap.parse_args()
    core = args.core.read_bytes()
    assert len(core) == 3*BANK
    sym = {k[:-1]: int(v,16) for k,_,v in (l.split() for l in args.symbols.read_text().splitlines() if ': EQU ' in l)}
    rom = bytearray(16*BANK)
    rom[:len(core)] = core
    donor = None
    if args.smb:
        raw = args.smb.read_bytes()
        donor = raw[16:] if raw.startswith(b'NES\x1a') else raw
        if hashlib.sha256(donor).hexdigest() != DONOR:
            ap.error('expected the original 32K PRG + 8K CHR Super Mario Bros. (World)')
    for sheet in range(18):
        replacements = backdrop(donor[32768:],sheet) if donor and sheet not in (0,17) else {}
        for tile in range(256):
            pair = core[sym['title_colours']+32*sheet+tile//8] if sheet<17 else 0xf1
            sky = core[sym['title_colours']+32*sheet]&15 if sheet<17 else 1
            fg,bg = pair>>4,pair&15
            if sheet < 17 and 0x78 <= tile <= 0x7f and bg == 4:
                bg = sky
            pal = [v if v not in (0,sky) else 0 for v in (bg,fg)]
            addr = sym['shared.background_patterns']+8*tile
            pix = [[pal[(b>>x)&1] for x in reversed(range(8))] for b in core[addr:addr+8]]
            if 'p_clear_field' in sym and 0 < sheet < 17:
                # Give rock and brick faces a lit lip, without changing their
                # silhouettes or replacing the Super Boy motifs. In caves
                # use blue-grey rather than the outdoor copper highlight.
                if tile in (0x35, 0x36, 0x70, 0x71, 0x72, 0x73):
                    highlight = 10 if 6 in pal else 14
                    pix = [[highlight if y and c == pal[0] and pix[y-1][x] == pal[1]
                            else c for x,c in enumerate(row)] for y,row in enumerate(pix)]
                # The question mark uses true dark ink even on night sheets
                # where the legacy converter mapped its ink to backdrop zero.
                slot = core[sym['p_block_slots'] + sheet]
                if 0x28 <= tile <= 0x2b:
                    pix = [[1 if b >> x & 1 else slot for x in reversed(range(8))]
                           for b in core[addr:addr+8]]
                elif any(slot in row for row in pix):
                    raise ValueError(f'block palette slot {slot} shared by sheet {sheet}, tile {tile}')
            start = 3*BANK+8192*sheet+32*tile
            rom[start:start+32] = replacements.get(tile) or pack(pix)
    # Pre-bake a 4-pose spin for each stage's two stacked coin tiles.
    for sheet in range(18):
        src = 3*BANK + sheet*8192 + 0x98*32
        for phase,width in enumerate((8,5,2,5)):
            result = bytearray()
            for row in range(16):
                planes = rom[src+4*row:src+4*row+4]
                for mask in planes:
                    v = 0
                    for x in range(width):
                        u = 8*x//width
                        if phase == 3:
                            u = 7-u
                        v |= ((mask >> (7-u)) & 1) << (7-(8-width)//2-x)
                    result.append(v)
            addr = 12*BANK+8192+sheet*256+phase*64
            rom[addr:addr+64] = result
    if donor:
        install_sprites(rom, donor)
        from score import music_bank
        music = music_bank(donor[:32768])
        rom[15*BANK:15*BANK+len(music)] = music
    # HUD-only alphabet ($180-$1bf), white figures / amber captions on ink.
    for i in range(64):
        addr = sym['shared.background_patterns']+8*(0xc0+i)
        pix = [[(11 if i>=34 else 15) if b & (1<<x) else 4 for x in reversed(range(8))]
               for b in core[addr:addr+8]] if i else [[4]*8 for _ in range(8)]
        start = sym['dx_hud_font']+i*32
        rom[start:start+32] = pack(pix)
    if 'p_mushroom_art' in sym:
        # Catch stale item coordinates if a layout edit removes or moves a ?.
        for stage in range(16):
            rec = sym['p_item_blocks'] + stage*6
            for pair in range(rec, rec+6, 2):
                x,y = core[pair:pair+2]
                y &= 127
                if x == 255:
                    continue
                col = sym['stage_layouts'] + stage*272 + x
                for half, selector in enumerate(core[col:col+2]):
                    cell = sym['map_columns'] + selector*22 + y
                    if not 1 <= y < 22 or core[cell-1:cell+1] != bytes((0x28+half, 0x2a+half)):
                        raise ValueError(f'no question block at stage {stage+1}, column {x}, row {y}')
        # Original 16x16 pickup silhouettes. Mode 4 sprites store the whole
        # left half before the right half; zero is transparent sprite ink.
        for label, art in (
            ('p_mushroom_art', (
                '.....rrrrrr.....', '...rrrwwwrrr....', '..rwwrwwwrrwwr..',
                '..rwwrrwrrrwwr..', '.rrrrrrrrrrrrrr.', '.rrrwwrrrrwwrrr.',
                'rrrrwwwrrrwwwrrr', 'rrrrwwrrrrrwwrrr', 'rrrrrrrrrrrrrrrr',
                '.rrrrwwwwwwrrrr.', '....wwwwwwww....', '....wwkwwkww....',
                '....wwkwwkww....', '....wwwwwwww....', '.....wwwwww.....',
                '......wwww......')),
            ('p_star_art', (
                '.......yy.......', '.......yy.......', '......yyyy......',
                '......yyyy......', '.....yyyyyy.....', 'yyyyyyyyyyyyyyyy',
                '.yyyywyyyywyyyy.', '..yyykyyyykyyy..', '...yykyyyykyy...',
                '....yyyyyyyy....', '....yyyyyyyy....', '...yyyyyyyyyy...',
                '...yyyy..yyyy...', '..yyy......yyy..', '..yy........yy..',
                '.yy..........yy.')),
            ('p_flower_art', (
                '.....rrrrrr.....', '...rryyyyyyrr...', '..rryywwwwyyrr..',
                '..ryywwkkwwyyr..', '..ryywwkkwwyyr..', '..rryywwwwyyrr..',
                '...rryyyyyyrr...', '.....rrrrrr.....', '.......gg.......',
                '..gg...gg...gg..', '..gggg.gg.gggg..', '...gggggggggg...',
                '....gggggggg....', '.......gg.......', '......gggg......',
                '.....gggggg.....'))):
            ink = {'.': sym['spr_clear'], 'r': sym['spr_red'], 'w': sym['spr_white'],
                   'k': sym['spr_outline'], 'y': sym['spr_gold'], 'g': sym['spr_leaf']}
            assert len(art) == 16 and all(len(row) == 16 for row in art)
            pixels = [[ink[c] for c in row[x:x+8]] for x in (0,8) for row in art]
            start = sym[label]
            rom[start:start+128] = pack(pixels)
    args.output.write_bytes(rom)


if __name__ == '__main__':
    main()
