"""Make an IPS patch from the stock 48 KiB cartridge to either edition."""
import argparse
from pathlib import Path


def make_patch(original, modified):
    if len(original) != 49152 or len(modified) not in (49152, 262144):
        raise ValueError('expected stock 48 KiB input and 48 or 256 KiB output')
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
    # Append the extra banks explicitly so even the trailing zero-filled ROM
    # pages are present. Do not depend on an optional IPS truncation footer.
    while offset < len(modified):
        block = modified[offset:offset + 65535]
        patch.extend(offset.to_bytes(3, 'big'))
        if not any(block):
            patch.extend(b'\0\0' + len(block).to_bytes(2, 'big') + b'\0')
        else:
            patch.extend(len(block).to_bytes(2, 'big') + block)
        offset += len(block)
    return patch + b'EOF'


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('original', 'modified', 'patch'):
        parser.add_argument(name, type=Path)
    args = parser.parse_args()
    args.patch.write_bytes(make_patch(args.original.read_bytes(), args.modified.read_bytes()))
