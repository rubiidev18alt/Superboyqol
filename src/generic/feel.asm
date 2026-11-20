; Standalone build only. The game runs two horizontal updates per logic tick.
; Keep maximum speeds and the swept wall/floor probes. A small initial push
; reaches deliberate walking speed sooner; running builds more gradually.
generic_accelerate:
    cp 6
    jr nc,.ramp
    inc a
.ramp:
    jp shared.accelerate

; Short, pitched PSG gestures. Last note is quieter and releases the voice
; promptly so the accompaniment can resume even during repeated jumps.
    macro hop_attack
    db $07,$b8
    pitch_envelope 0
    volume_envelope 1
    tempo 200
    db $0a,11
    endm
generic_hop:
    hop_attack
    tone 4,380,48
    tone 4,302,48
    tone 4,240,32
    db $0a,8
    tone 4,213,32
    db $0a,0
    phrase_end
generic_big_hop:
    hop_attack
    tone 4,508,48
    tone 4,403,48
    tone 4,320,32
    db $0a,8
    tone 4,285,32
    db $0a,0
    phrase_end
generic_coin_chime:
    hop_attack
    tone 4,170,32              ; E5, B5, then a light octave resolution
    tone 4,113,32
    db $0a,8
    tone 4,85,16
    db $0a,0
    phrase_end
