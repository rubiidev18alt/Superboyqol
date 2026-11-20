; Comet Run — four bars of original PSG music. 1/16th-note lead pickups,
; alternating octave bass and clipped offbeats; each staff spans 16 beats.
; Periods come from NTSC clock/(32*Hz). Voice 3 yields to impact/jump cues.
p_star_lead:
    tempo 184
    pitch_envelope 0
    volume_envelope 1
    db 8,13
.loop:
    tone 0,214,8
    tone 0,170,16
    tone 0,143,16
    tone 0,107,4
    rest_ticks 8
    tone 0,127,8
    tone 0,143,4
    tone 0,170,8
    tone 0,127,8
    tone 0,107,4
    tone 0,85,8
    rest_ticks 16
    tone 0,107,16
    tone 0,127,4
    tone 0,160,8
    tone 0,127,16
    tone 0,107,16
    tone 0,80,4
    tone 0,85,8
    tone 0,107,8
    tone 0,127,4
    tone 0,143,8
    tone 0,95,8
    tone 0,113,8
    tone 0,143,8
    rest_ticks 8
    tone 0,190,16
    tone 0,170,16
    tone 0,143,8
    tone 0,113,8
    db $4b,$4c
    dw .loop
p_star_bass:
    tempo 184
    pitch_envelope 0
    volume_envelope 0
    db 9,11
.loop:
    macro star_bass root,oct,fifth
    tone 2,root,4
    tone 2,oct,8
    tone 2,fifth,8
    tone 2,root,4
    tone 2,fifth,8
    tone 2,oct,8
    endm
    star_bass 855,428,571
    star_bass 508,254,339
    star_bass 641,320,428
    star_bass 571,285,381
    db $4b,$4c
    dw .loop
p_star_echo:
    tempo 184
    pitch_envelope 0
    volume_envelope 1
    db 10,9
.loop:
    macro star_chop third,fifth
    rept 2
    rest_ticks 8
    tone 4,third,8
    rest_ticks 8
    tone 4,fifth,8
    endr
    endm
    star_chop 339,285
    star_chop 428,339
    star_chop 254,214
    star_chop 226,190
    db $4b,$4c
    dw .loop
