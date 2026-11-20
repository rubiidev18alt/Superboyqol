; Bytecode interpreted by the sound driver (not Z80 instructions).
    macro tone reg, period, duration
    db reg
    dw period
    db duration
    endm
    macro phrase_end
    db $4b, $48
    endm
    macro rest_ticks duration
    db $52, duration
    endm
    macro tempo value
    db $54, value
    endm
    macro pitch_envelope index
    db $58, index
    endm
    macro volume_envelope index
    db $59, index
    endm
