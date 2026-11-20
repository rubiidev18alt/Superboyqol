"""Render the stored backgrounds (not sprites or simulated gameplay) as indexed PNGs."""
import argparse
from pathlib import Path
import struct
import zlib

# SMS VDP fixed palette in the TMS-compatible modes: --BBGGRR.
CROM = (0, 0, 8, 12, 16, 48, 1, 60, 2, 3, 5, 15, 4, 51, 21, 63)
PALETTE = bytes(((v >> shift) & 3) * 85 for v in CROM for shift in (0, 2, 4))


def png_chunk(kind, data):
    return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data))


def render(path, columns, patterns, colours):
    # Each group of eight tile IDs shares a foreground/background byte.
    # Colour zero selects the backdrop (low four bits of VDP register 7).
    tiles = []
    for tile in range(256):
        pair = colours[tile // 8]
        bg, fg = (c or (colours[0] & 15) for c in (pair & 15, pair >> 4))
        tiles.append([bytes(fg if row & (0x80 >> bit) else bg for bit in range(8))
                      for row in patterns[tile * 8:tile * 8 + 8]])
    raw = bytearray()
    for y in range(22 * 8):
        raw.append(0)  # PNG filter: none
        raw.extend(b''.join(tiles[column[y // 8]][y % 8] for column in columns))
    header = struct.pack('>IIBBBBB', len(columns) * 8, 22 * 8, 8, 3, 0, 0, 0)
    path.write_bytes(b'\x89PNG\r\n\x1a\n' + png_chunk(b'IHDR', header) + png_chunk(b'PLTE', PALETTE)
                     + png_chunk(b'IDAT', zlib.compress(raw, 9)) + png_chunk(b'IEND', b''))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for arg in ('rom', 'symbols', 'output_dir'):
        parser.add_argument(arg, type=Path)
    args = parser.parse_args()
    rom = args.rom.read_bytes()
    symbols = {name.rstrip(':'): int(addr, 16) for name, _, addr in
               (line.split() for line in args.symbols.read_text().splitlines() if ': EQU ' in line)}
    args.output_dir.mkdir(parents=True, exist_ok=True)

    def data(label, length):
        base = symbols[label]
        if base + length > len(rom):
            raise ValueError(f'{label} is outside the ROM')
        return rom[base:base + length]

    patterns = data('shared.background_patterns', 256 * 8)
    # Read across $8000: the vector bytes really are part of the dictionary.
    dictionary = data('map_columns', 245 * 22)
    for world in range(1, 5):
        for round_ in range(1, 5):
            key = f'{world}_{round_}'
            columns = [dictionary[n * 22:n * 22 + 22] for n in data('layout_' + key, 272)]
            render(args.output_dir / f'{world}-{round_}.png', columns, patterns, data('colours_' + key, 32))
    for screen, palette in [('title_screen', 'title_colours'), ('stage_screen_a', 'colours_1_1'),
                            ('stage_screen_b', 'colours_1_1')]:
        image = data('shared.' + screen, 32 * 22)
        render(args.output_dir / f'{screen}.png', [image[i:i + 22] for i in range(0, len(image), 22)],
               patterns, data(palette, 32))


if __name__ == '__main__':
    main()
