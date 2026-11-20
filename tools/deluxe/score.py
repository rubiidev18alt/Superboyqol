"""Run the verified donor's sound engine offline; capture pitched APU voices.

Header visits mark real sequence loops (the overworld introduction plays only
once). The runtime only sees run lengths and SN76489 timer periods, not 6502
code. No NES emulator or dependency is required on the Master System.
"""
from itertools import groupby
from struct import pack


def capture(prg, queue):
    try:
        from py65.devices.mpu6502 import MPU
    except ImportError:
        raise SystemExit('Music import needs py65: python3 -m pip install py65==1.2.0')
    mem = bytearray(65536)
    mem[0x8000:] = prg
    mem[0x770], mem[0xfb] = 1, queue   # OperMode, AreaMusicQueue
    cpu = MPU(memory=mem)
    seen, frames = {}, []
    for frame in range(16000):
        cpu.pc, cpu.sp = 0xf2d0, 0xfd
        mem[0x1fe:0x200] = b'\xff\x5f'  # RTS sentinel at $6000
        while cpu.pc != 0x6000:
            if cpu.pc == 0xf6f5:          # LoadHeader, Y = phrase index
                if cpu.y in seen:
                    return frames, seen[cpu.y]
                seen[cpu.y] = frame
            cpu.step()
        periods = []
        for base in (0x4004, 0x4008, 0x4000):  # lead, bass, harmony
            timer = 1 + mem[base+2] + ((mem[base+3] & 7) << 8)
            # NES CPU is half the PSG clock; triangle has 32 steps vs 16.
            period = timer*(2 if base == 0x4008 else 1)
            volume = mem[base] & (0x7f if base == 0x4008 else 15)
            periods.append(min(1023, period) if volume and timer > 1 else 0)
        frames.append(periods)
    raise ValueError('sound sequence did not loop')


def music_bank(prg):
    buf = bytearray(18)  # three songs x three channel pointers
    for song, queue in enumerate((1,4,8)):  # overworld, underground, castle
        frames, loop = capture(prg, queue)
        for ch in range(3):
            i = (song*3+ch)*2
            buf[i:i+2] = pack('<H', 0x8000+len(buf))
            for section in (frames[:loop],frames[loop:]):
                loopaddr = 0x8000+len(buf)
                for period, run in groupby(row[ch] for row in section):
                    n = sum(1 for _ in run)
                    while n:
                        t = min(n,255)
                        buf.extend(pack('<BH',t,period))
                        n -= t
            buf.extend(pack('<BH',0,loopaddr))
        print(f'Song {song+1}: {len(frames)} frames, loops to frame {loop}')
    if len(buf)>16384:
        raise ValueError('sound bank overflow')
    return buf
