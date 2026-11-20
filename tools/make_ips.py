"""Make a literal-record IPS patch for the 48 KiB Super Boy cartridge."""
import argparse
from pathlib import Path


def make_patch(original, modified):
    if len(original) != 49152 or len(modified) != len(original):
        raise ValueError('expected two 48 KiB ROMs')
    patch = bytearray(b'PATCH')
    offset = 0
    while offset < len(original):
        if original[offset] == modified[offset]:
            offset += 1
            continue
        start = offset
        while offset < len(original) and original[offset] != modified[offset]:
            offset += 1
        patch.extend(start.to_bytes(3, 'big'))
        patch.extend((offset - start).to_bytes(2, 'big'))
        patch.extend(modified[start:offset])
    return patch + b'EOF'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('original', 'modified', 'patch'):
        parser.add_argument(name, type=Path)
    args = parser.parse_args()
    args.patch.write_bytes(make_patch(args.original.read_bytes(), args.modified.read_bytes()))
