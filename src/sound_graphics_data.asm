; Pitch and volume modulation sequences installed by sound_reset.
modulation_accf:
    db $ff
modulation_acd0:
    db $41, $42, $81
modulation_acd3:
    db $01, $80
modulation_acd5:
    db $02, $03, $81, $07, $80
modulation_acda:
    db $01, $02, $03, $04, $05, $06, $07, $08, $09, $0f, $80
modulation_ace5:
    db $00, $00, $00, $00, $01, $02, $03, $04, $02, $03, $04, $04, $05, $07, $80
modulation_acf4:
    db $00, $00, $00, $00, $00, $01, $02, $03, $04, $05, $06, $07, $09, $80
modulation_ad02:
    db $00, $00, $00, $01, $01, $01, $01, $01, $01, $02, $02, $02, $02, $03, $03, $04
    db $04, $05, $05, $05, $06, $06, $06, $07, $07, $07, $07, $08, $80
modulation_ad1f:
    db $02, $03, $04, $05, $06, $04, $02, $03, $04, $05, $06, $02, $0f, $80
modulation_ad2d:
    db $02, $03, $04, $05, $06, $04, $02, $03, $04, $05, $06, $02, $0f, $80
modulation_ad3b:
    db $01, $02, $07, $0f, $0f, $0f, $07, $06, $02, $02, $06, $0f, $0f, $0f, $88
modulation_ad4a:
    db $04, $03, $02, $03, $0f, $80
modulation_ad50:
    db $0f, $80, $01, $02, $03, $04, $04, $03, $00, $01, $00, $01, $00, $02, $0f, $80

effect_pointers:
    ifdef GENERIC
    dw generic_hop,generic_big_hop
    else
    dw effect_01
    dw effect_02
    endif
    dw effect_03
    ifdef POLISH
    dw p_break,p_bump
    else
    dw effect_04
    dw effect_05
    endif
    dw effect_06
    ifdef GENERIC
    dw generic_coin_chime
    else
    dw effect_07
    endif
    dw effect_08
    ifdef POLISH
    dw p_extra_life,p_contact
    else
    dw effect_09
    dw effect_10
    endif
    dw effect_11
    dw effect_12
    dw effect_13

track_3_ch1:
    tempo $82
    pitch_envelope $00
    volume_envelope $00
    db $08, $0b  ; register, value
    tone 0, $01ac, $08
    tone 0, $00f0, $08
    rest_ticks $08
    tone 0, $00f0, $08
    tone 0, $00f0, $08
    tone 0, $00fe, $08
    tone 0, $011d, $08
    rest_ticks $01
    db $08, $00  ; register, value
    db $ff, $48

track_3_ch2:
    tempo $82
    pitch_envelope $00
    volume_envelope $00
    db $09, $0a  ; register, value
    tone 2, $01ac, $08
    tone 2, $01ac, $08
    rest_ticks $08
    tone 2, $01ac, $08
    tone 2, $01ac, $08
    tone 2, $017d, $08
    db $09, $0d  ; register, value
    pitch_envelope $00
    volume_envelope $01
    tone 2, $0153, $08
    tone 2, $0140, $04
    tone 2, $01ac, $04
    tone 2, $0501, $04
    rest_ticks $01
    db $09, $00  ; register, value
    db $ff, $48

track_3_ch3:
    db $0a, $00  ; register, value
    db $ff, $8f, $e6, $20, $20, $4c, $44, $20, $28, $49, $58, $2b, $32, $31, $48, $29
    db $2c, $30, $42, $32, $48, $00, $0e, $ae, $f8, $1b, $3a, $8f, $e6, $20, $20, $4c
    db $44, $20

track_2_ch1:
    db $08, $0b  ; register, value
    pitch_envelope $01
    volume_envelope $01
    tempo $b4
    tone 0, $00d6, $08
    tone 0, $011d, $08
    tone 0, $0153, $08
    tone 0, $00d6, $08
    tone 0, $011d, $08
    tone 0, $0153, $08
    tone 0, $00d6, $02
    phrase_end
    tone 0, $00ca, $08
    tone 0, $010d, $08
    tone 0, $0140, $08
    tone 0, $00ca, $08
    tone 0, $010d, $08
    tone 0, $0140, $08
    phrase_end
    tone 0, $00ca, $02
    tone 0, $00b4, $08
    tone 0, $00f0, $08
    tone 0, $012e, $08
    tone 0, $00b4, $08
    phrase_end
    tone 0, $00f0, $08
    tone 0, $012e, $08
    tone 0, $00b4, $04
    tone 0, $00a0, $08
    tone 0, $00a0, $08
    tone 0, $00a0, $08
    tone 0, $008f, $01
    db $08, $00  ; register, value
    db $ff, $48

track_2_ch2:
    db $09, $09  ; register, value
    tempo $b4
    tone 2, $00d6, $08
    tone 2, $011d, $08
    tone 2, $0153, $08
    tone 2, $00d6, $08
    tone 2, $011d, $08
    tone 2, $0153, $08
    tone 2, $00d6, $02
    phrase_end
    tone 2, $00ca, $08
    tone 2, $010d, $08
    tone 2, $0140, $08
    tone 2, $00ca, $08
    tone 2, $010d, $08
    tone 2, $0140, $08
    phrase_end
    tone 2, $00ca, $02
    tone 2, $00b4, $08
    tone 2, $00f0, $08
    tone 2, $012e, $08
    tone 2, $00b4, $08
    phrase_end
    tone 2, $00f0, $08
    tone 2, $012e, $08
    tone 2, $00b4, $04
    tone 2, $00a0, $08
    tone 2, $00a0, $08
    tone 2, $00a0, $08
    tone 2, $008f, $01
    db $09, $00  ; register, value
    db $ff, $48

track_2_ch3:
    tempo $b4
    db $0a, $00  ; register, value
    phrase_end
    phrase_end
    phrase_end
    db $ff, $48, $00, $fd, $a7, $50, $19, $3a, $8f, $e6, $00, $0f, $a8, $5a

    ifdef QOL
    include "qol/score.asm"
    include "qol/movement.asm"
    include "qol/continue.asm"
    assert $ <= $b5aa
    ds $b5aa - $, 0
    else
track_0_ch1:
    tempo $78
    pitch_envelope $00
    volume_envelope $01
    db $08, $09  ; register, value
    tone 0, $00aa, $10
    tone 0, $00aa, $08
    tone 0, $00aa, $10
    volume_envelope $00
    rest_ticks $10
    volume_envelope $03
    tone 0, $00d6, $10
    tone 0, $00aa, $08
    tone 0, $008f, $04
    tone 0, $011d, $04
    phrase_end
    tone 0, $00d6, $88
    tone 0, $011d, $10
    tone 0, $011d, $08
    tone 0, $0153, $08
    volume_envelope $00
    rest_ticks $10
    volume_envelope $03
    tone 0, $00fe, $08
    tone 0, $00e3, $10
    volume_envelope $00
    rest_ticks $10
    volume_envelope $03
    tone 0, $00e3, $10
    tone 0, $00fe, $08
    phrase_end
    tone 0, $011d, $0c
    tone 0, $00aa, $0c
    tone 0, $008f, $0c
    tone 0, $007f, $08
    tone 0, $00a0, $10
    tone 0, $008f, $10
    tone 0, $008f, $10
    tone 0, $00aa, $08
    tone 0, $00d6, $10
    tone 0, $00be, $10
    tone 0, $00e3, $88
    phrase_end
    tone 0, $00d6, $88
    tone 0, $011d, $10
    tone 0, $011d, $08
    tone 0, $0153, $08
    volume_envelope $00
    rest_ticks $10
    volume_envelope $03
    tone 0, $00fe, $08
    tone 0, $00e3, $10
    volume_envelope $00
    rest_ticks $10
    volume_envelope $03
    tone 0, $00e3, $10
    tone 0, $00fe, $08
    phrase_end
    tone 0, $011d, $0c
    tone 0, $00aa, $0c
    tone 0, $008f, $0c
    tone 0, $007f, $08
    tone 0, $00a0, $10
    tone 0, $008f, $10
    tone 0, $008f, $10
    tone 0, $00aa, $08
    tone 0, $00d6, $10
    tone 0, $00be, $10
    tone 0, $00e3, $88
    phrase_end
    volume_envelope $00
    rest_ticks $08
    volume_envelope $03
    tone 0, $008f, $10
    tone 0, $0097, $10
    tone 0, $00a0, $10
    tone 0, $00b4, $08
    tone 0, $00aa, $10
    rest_ticks $10
    tone 0, $011d, $10
    tone 0, $00fe, $10
    tone 0, $00d6, $10
    volume_envelope $00
    rest_ticks $10
    volume_envelope $03
    tone 0, $00fe, $10
    tone 0, $00d6, $10
    tone 0, $00be, $10
    phrase_end
    volume_envelope $00
    rest_ticks $08
    volume_envelope $03
    tone 0, $008f, $10
    tone 0, $0097, $10
    tone 0, $00a0, $10
    tone 0, $00b4, $08
    tone 0, $00aa, $10
    tone 0, $00aa, $10
    volume_envelope $02
    tone 0, $008f, $08
    tone 0, $008f, $10
    tone 0, $008f, $04
    phrase_end
    volume_envelope $00
    rest_ticks $08
    volume_envelope $03
    tone 0, $008f, $10
    tone 0, $0097, $10
    tone 0, $00a0, $10
    tone 0, $00b4, $08
    tone 0, $00aa, $10
    rest_ticks $10
    tone 0, $010d, $10
    tone 0, $00fe, $10
    tone 0, $00d6, $10
    rest_ticks $10
    tone 0, $00fe, $10
    tone 0, $00d6, $10
    tone 0, $00be, $10
    phrase_end
    volume_envelope $00
    rest_ticks $08
    volume_envelope $03
    tone 0, $00aa, $08
    tone 0, $00aa, $10
    tone 0, $00be, $08
    tone 0, $00d6, $10
    volume_envelope $00
    rest_ticks $02
    phrase_end
    volume_envelope $03
    tone 0, $00d6, $10
    tone 0, $00d6, $08
    tone 0, $00d6, $10
    rest_ticks $10
    tone 0, $00d6, $10
    tone 0, $00be, $08
    tone 0, $00aa, $10
    tone 0, $00d6, $08
    tone 0, $00fe, $10
    tone 0, $011d, $04
    phrase_end
    tone 0, $00d6, $10
    tone 0, $00d6, $08
    tone 0, $00d6, $10
    volume_envelope $00
    rest_ticks $10
    volume_envelope $03
    tone 0, $00d6, $10
    tone 0, $00be, $08
    tone 0, $00aa, $04
    volume_envelope $00
    rest_ticks $04
    phrase_end
    volume_envelope $03
    tone 0, $00d6, $10
    tone 0, $00d6, $08
    tone 0, $00d6, $10
    rest_ticks $10
    tone 0, $00d6, $10
    tone 0, $00be, $08
    tone 0, $00aa, $10
    tone 0, $00d6, $08
    tone 0, $00fe, $10
    tone 0, $011d, $04
    phrase_end
    tone 0, $00aa, $10
    tone 0, $00aa, $08
    tone 0, $00aa, $10
    tone 0, $00aa, $10
    tone 0, $00d6, $10
    tone 0, $00aa, $08
    tone 0, $008f, $04
    tone 0, $011d, $04
    db $4b, $4c
    dw track_0_ch1
    db $00, $af

track_0_ch2:
    tempo $78
    pitch_envelope $01
    volume_envelope $04
    db $09, $09  ; register, value
    tone 2, $00d6, $10
    tone 2, $00d6, $08
    tone 2, $00d6, $10
    rest_ticks $10
    tone 2, $00d6, $10
    tone 2, $00d6, $08
    tone 2, $008f, $04
    tone 2, $011d, $04
    phrase_end
    tone 2, $011d, $08
    tone 2, $011d, $10
    tone 2, $0153, $10
    tone 2, $0153, $08
    tone 2, $01ac, $08
    rest_ticks $10
    tone 2, $0140, $08
    tone 2, $00e3, $10
    rest_ticks $10
    tone 2, $00e3, $10
    tone 2, $00fe, $08
    phrase_end
    tone 2, $011d, $0c
    tone 2, $00aa, $0c
    tone 2, $008f, $0c
    tone 2, $007f, $08
    tone 2, $00a0, $10
    tone 2, $008f, $10
    tone 2, $008f, $10
    tone 2, $00aa, $08
    tone 2, $00d6, $10
    tone 2, $00be, $10
    tone 2, $00e3, $88
    phrase_end
    tone 2, $011d, $88
    tone 2, $0153, $10
    tone 2, $0153, $08
    tone 2, $01ac, $08
    rest_ticks $10
    tone 2, $00fe, $08
    tone 2, $00e3, $10
    rest_ticks $10
    tone 2, $00e3, $10
    tone 2, $00fe, $08
    phrase_end
    tone 2, $011d, $0c
    tone 2, $00aa, $0c
    tone 2, $008f, $0c
    tone 2, $007f, $08
    tone 2, $00a0, $10
    tone 2, $008f, $10
    tone 2, $008f, $10
    tone 2, $00aa, $08
    tone 2, $00d6, $10
    tone 2, $00be, $10
    tone 2, $00e3, $88
    phrase_end
    rest_ticks $08
    tone 2, $00aa, $10
    tone 2, $00b4, $10
    tone 2, $00be, $10
    tone 2, $00d6, $08
    tone 2, $00d6, $10
    rest_ticks $10
    tone 2, $0153, $10
    tone 2, $0140, $10
    tone 2, $00fe, $10
    rest_ticks $10
    tone 2, $0140, $10
    tone 2, $00fe, $10
    tone 2, $011d, $10
    phrase_end
    rest_ticks $08
    tone 2, $00aa, $10
    tone 2, $00b4, $10
    tone 2, $00be, $10
    tone 2, $00e3, $08
    tone 2, $00d6, $10
    tone 2, $00d6, $10
    tone 2, $00a0, $08
    tone 2, $00a0, $10
    tone 2, $00a0, $04
    phrase_end
    rest_ticks $08
    tone 2, $00aa, $10
    tone 2, $00b4, $10
    tone 2, $00be, $10
    tone 2, $00e3, $08
    tone 2, $00d6, $10
    rest_ticks $10
    tone 2, $0153, $10
    tone 2, $0140, $10
    tone 2, $00fe, $10
    rest_ticks $10
    tone 2, $0140, $10
    tone 2, $00fe, $10
    tone 2, $011d, $10
    phrase_end
    rest_ticks $08
    tone 2, $00d6, $08
    tone 2, $00d6, $10
    tone 2, $00e3, $08
    tone 2, $011d, $10
    rest_ticks $04
    rest_ticks $04
    phrase_end
    tone 2, $0153, $10
    tone 2, $0153, $08
    tone 2, $0153, $10
    rest_ticks $10
    tone 2, $0153, $10
    tone 2, $0140, $08
    tone 2, $011d, $10
    tone 2, $0153, $08
    tone 2, $0140, $10
    tone 2, $0140, $04
    phrase_end
    tone 2, $0153, $10
    tone 2, $0153, $08
    tone 2, $0153, $10
    rest_ticks $10
    tone 2, $0153, $10
    tone 2, $0140, $08
    tone 2, $011d, $04
    rest_ticks $04
    phrase_end
    tone 2, $0153, $10
    tone 2, $0153, $08
    tone 2, $0153, $10
    rest_ticks $10
    tone 2, $0153, $10
    tone 2, $0140, $08
    tone 2, $011d, $10
    tone 2, $0153, $08
    tone 2, $0140, $10
    tone 2, $0153, $04
    phrase_end
    tone 2, $00d6, $10
    tone 2, $00d6, $08
    tone 2, $00d6, $10
    tone 2, $00d6, $10
    tone 2, $011d, $10
    tone 2, $00d6, $08
    tone 2, $00aa, $04
    tone 2, $011d, $04
    db $4b, $4c
    dw track_0_ch2
    db $40, $c1

track_0_ch3:
    tempo $78
    pitch_envelope $00
    volume_envelope $01
    db $0a, $09  ; register, value
    tone 4, $00aa, $10
    tone 4, $00aa, $08
    tone 4, $00aa, $10
    rest_ticks $10
    tone 4, $00d6, $10
    tone 4, $00aa, $08
    tone 4, $008f, $04
    tone 4, $011d, $04
    phrase_end
    db $0a, $08  ; register, value
    tone 4, $00d6, $04
    tone 4, $00fe, $08
    tone 4, $00fe, $08
    tone 4, $00d6, $04
    tone 4, $00fe, $10
    tone 4, $00fe, $10
    tone 4, $00fe, $10
    tone 4, $00fe, $10
    phrase_end
track_0_ch3_loop:
    tone 4, $00d6, $04
    tone 4, $00fe, $08
    tone 4, $00fe, $08
    tone 4, $00d6, $04
    tone 4, $00fe, $10
    tone 4, $00fe, $10
    tone 4, $00fe, $10
    tone 4, $00fe, $10
    db $4b, $4c
    dw track_0_ch3_loop

track_1_ch1:
    pitch_envelope $01
    volume_envelope $02
    tempo $5a
    db $08, $0a  ; register, value
    tone 0, $0357, $10
    tone 0, $00d6, $10
    tone 0, $01fd, $10
    tone 0, $00fe, $10
    tone 0, $01c5, $10
    tone 0, $00e3, $10
    volume_envelope $00
    rest_ticks $08
    volume_envelope $02
    tone 0, $01ac, $10
    tone 0, $00d6, $10
    tone 0, $01fd, $10
    tone 0, $00fe, $10
    tone 0, $01c5, $10
    tone 0, $00e3, $10
    volume_envelope $00
    rest_ticks $08
    phrase_end
    volume_envelope $02
    tempo $59
    tone 0, $0281, $10
    tone 0, $0140, $10
    tone 0, $02fa, $10
    tone 0, $017d, $10
    tone 0, $02a7, $10
    tone 0, $0168, $10
    volume_envelope $00
    rest_ticks $08
    volume_envelope $02
    tone 0, $01fd, $10
    tone 0, $0140, $10
    tone 0, $0281, $10
    tone 0, $017d, $10
    tone 0, $023b, $10
    tone 0, $0153, $10
    volume_envelope $00
    rest_ticks $08
    phrase_end
    volume_envelope $02
    tone 0, $0168, $10
    tone 0, $017d, $10
    tone 0, $0194, $10
    tone 0, $01ac, $08
    tone 0, $0168, $08
    tone 0, $017d, $08
    tone 0, $021b, $08
    tone 0, $023b, $08
    tone 0, $017d, $10
    tone 0, $0194, $10
    tone 0, $01ac, $90
    phrase_end
    tone 0, $011d, $90
    tone 0, $0153, $90
    tone 0, $017d, $90
    tone 0, $00e3, $90
    tone 0, $00fe, $90
    tone 0, $010d, $10
    tone 0, $0153, $08
    tone 0, $0168, $04
    tone 0, $01ac, $10
    phrase_end
    tone 0, $01c5, $10
    tone 0, $023b, $10
    tone 0, $0281, $04
    volume_envelope $00
    rest_ticks $04
    rest_ticks $08
    db $08, $00  ; register, value
    db $4b, $4c
    dw track_1_ch1

track_1_ch2:
    pitch_envelope $03
    volume_envelope $01
    tempo $5a
    db $09, $07  ; register, value
    tone 2, $0357, $10
    tone 2, $00d6, $10
    tone 2, $01fd, $10
    tone 2, $00fe, $10
    tone 2, $01c5, $10
    tone 2, $00e3, $10
    rest_ticks $08
    tone 2, $01ac, $10
    tone 2, $00d6, $10
    tone 2, $01fd, $10
    tone 2, $00fe, $10
    tone 2, $01c5, $10
    tone 2, $00e3, $10
    rest_ticks $08
    phrase_end
    tempo $59
    tone 2, $0281, $10
    tone 2, $0140, $10
    tone 2, $02fa, $10
    tone 2, $017d, $10
    tone 2, $02a7, $10
    tone 2, $0168, $10
    rest_ticks $08
    tone 2, $01fd, $10
    tone 2, $0140, $10
    tone 2, $0281, $10
    tone 2, $017d, $10
    tone 2, $023b, $10
    tone 2, $0153, $10
    rest_ticks $08
    phrase_end
    volume_envelope $00
    tone 2, $0168, $10
    tone 2, $017d, $10
    tone 2, $0194, $10
    tone 2, $01ac, $08
    tone 2, $0168, $08
    tone 2, $017d, $08
    tone 2, $021b, $08
    tone 2, $023b, $08
    tone 2, $017d, $10
    tone 2, $0194, $10
    tone 2, $01ac, $90
    phrase_end
    tone 2, $011d, $90
    tone 2, $0153, $90
    tone 2, $017d, $90
    tone 2, $00e3, $90
    tone 2, $00fe, $90
    tone 2, $010d, $10
    tone 2, $0153, $08
    tone 2, $0168, $04
    tone 2, $01ac, $10
    phrase_end
    volume_envelope $01
    tone 2, $01c5, $10
    tone 2, $023b, $10
    tone 2, $0281, $04
    db $09, $00  ; register, value
    db $4b, $4c
    dw track_1_ch2

track_1_ch3:
    tempo $5a
    volume_envelope $00
    pitch_envelope $00
    db $0a, $00  ; register, value
    rest_ticks $01
    phrase_end
    phrase_end
    phrase_end
    phrase_end
    rest_ticks $01
    db $4b, $4c
    dw track_1_ch3
    endif

effect_01:
    db $07, $b8  ; register, value
    pitch_envelope $01
    volume_envelope $01
    db $0a, $0d  ; register, value
    tempo $ff
    tone 4, $01ac, $39
    tone 4, $017d, $39
    tone 4, $0153, $39
    tone 4, $0140, $39
    tone 4, $011d, $39
    tone 4, $011d, $39
    tone 4, $00fe, $39
    tone 4, $00e3, $39
    tone 4, $00d6, $39
    tone 4, $00be, $39
    tone 4, $00d6, $39
    db $0a, $00  ; register, value
    phrase_end

effect_02:
    db $07, $b8  ; register, value
    pitch_envelope $01
    volume_envelope $01
    db $0a, $0d  ; register, value
    tempo $ff
    tone 4, $0357, $39
    tone 4, $02fa, $39
    tone 4, $02a7, $39
    tone 4, $0281, $39
    tone 4, $023b, $39
    tone 4, $023b, $39
    tone 4, $01fd, $39
    tone 4, $01c5, $39
    tone 4, $01ac, $39
    tone 4, $017d, $39
    tone 4, $01ac, $39
    db $0a, $00  ; register, value
    phrase_end

effect_03:
    db $07, $b8  ; register, value
    pitch_envelope $02
    volume_envelope $01
    db $0a, $0d  ; register, value
    tempo $ff
    tone 4, $00b4, $14
    tone 4, $00b4, $14
    tone 4, $00aa, $14
    db $0a, $08  ; register, value
    tone 4, $00a0, $14
    db $0a, $06  ; register, value
    tone 4, $007f, $14
    db $0a, $04  ; register, value
    tone 4, $006b, $14
    db $0a, $00  ; register, value
    phrase_end

effect_04:
    db $07, $98  ; register, value
    db $06, $0d  ; register, value
    db $0a, $0e  ; register, value
    tempo $78
    pitch_envelope $02
    volume_envelope $04
    tone 4, $06af, $08
    pitch_envelope $00
    volume_envelope $00
    db $0a, $00  ; register, value
    phrase_end

effect_05:
    db $07, $b8  ; register, value
    db $0a, $0d  ; register, value
    tempo $78
    pitch_envelope $01
    volume_envelope $01
    tone 4, $0be7, $10
    db $0a, $00  ; register, value
    phrase_end

effect_06:
    db $07, $b8  ; register, value
    db $0a, $0d  ; register, value
    tempo $78
    pitch_envelope $01
    volume_envelope $01
    tempo $96
    tone 4, $038a, $32
    tone 4, $03f9, $32
    tone 4, $0476, $32
    tone 4, $0357, $32
    tone 4, $038a, $32
    tone 4, $02fa, $32
    tone 4, $0357, $32
    tone 4, $02a7, $32
    db $0a, $0e  ; register, value
    tone 4, $02fa, $32
    tone 4, $0357, $32
    db $0a, $0f  ; register, value
    tone 4, $023b, $32
    db $0a, $0e  ; register, value
    tone 4, $0281, $32
    tone 4, $02a7, $32
    db $0a, $0f  ; register, value
    tone 4, $01c5, $32
    db $0a, $0c  ; register, value
    tone 4, $01fd, $32
    db $0a, $0a  ; register, value
    tone 4, $01c5, $32
    db $0a, $00  ; register, value
    phrase_end

effect_07:
    db $07, $b8  ; register, value
    db $0a, $0e  ; register, value
    pitch_envelope $01
    volume_envelope $01
    tempo $64
    tone 4, $008f, $28
    tone 4, $004c, $10
    db $0a, $00  ; register, value
    phrase_end

effect_08:
    db $07, $b8  ; register, value
    db $0a, $0e  ; register, value
    tempo $fa
    pitch_envelope $01
    volume_envelope $07
    tone 4, $025d, $08
    tone 4, $021b, $08
    tone 4, $01e0, $08
    db $0a, $00  ; register, value
    phrase_end

effect_09:
    db $07, $b8  ; register, value
    db $0a, $0f  ; register, value
    tempo $64
    pitch_envelope $01
    volume_envelope $01
    tone 4, $01ac, $10
    tone 4, $0035, $10
    db $0a, $00  ; register, value
    phrase_end

effect_10:
    db $07, $b8  ; register, value
    db $0a, $0d  ; register, value
    tempo $dc
    pitch_envelope $01
    volume_envelope $08
    db $0a, $0d  ; register, value
    tone 4, $00a0, $23
    db $0a, $00  ; register, value
    tone 4, $00a0, $0f
    db $0a, $0d  ; register, value
    tone 4, $006b, $16
    db $0a, $00  ; register, value
    phrase_end

effect_11:
    db $07, $b8  ; register, value
    db $0a, $0d  ; register, value
    pitch_envelope $01
    volume_envelope $08
    tempo $dc
    tone 4, $00e3, $c2
    tone 4, $00f0, $c2
    tone 4, $0140, $c2
    tone 4, $012e, $c2
    tone 4, $01ac, $c2
    db $0a, $00  ; register, value
    tone 4, $011d, $0a
    db $0a, $0d  ; register, value
    tone 4, $00e3, $c2
    tone 4, $00f0, $c2
    tone 4, $0140, $c2
    tone 4, $012e, $c2
    tone 4, $01ac, $c2
    db $0a, $00  ; register, value
    tone 4, $011d, $0a
    db $0a, $0f  ; register, value
    tone 4, $00e3, $c2
    tone 4, $00f0, $c2
    tone 4, $0140, $c2
    tone 4, $012e, $c2
    tone 4, $01ac, $c2
    db $0a, $00  ; register, value
    phrase_end

effect_12:
    db $07, $98  ; register, value
    db $06, $12  ; register, value
    db $0a, $0c  ; register, value
    tempo $78
    pitch_envelope $01
    volume_envelope $04
    tone 4, $03f9, $02
    db $0a, $00  ; register, value
    phrase_end

effect_13:
    db $07, $b8  ; register, value
    db $0a, $0d  ; register, value
    tempo $ff
    pitch_envelope $01
    volume_envelope $09
    tone 4, $05f4, $46
    tone 4, $03f9, $32
    db $0a, $00  ; register, value
    phrase_end

phrase_b7ba:
    db $07, $b8  ; register, value
    db $0a, $0d  ; register, value
    tempo $78
    pitch_envelope $01
    volume_envelope $09
    tone 4, $00a0, $10
    db $0a, $00  ; register, value
    phrase_end

phrase_b7cc:
    db $07, $b8  ; register, value
    db $0a, $0d  ; register, value
    tempo $78
    pitch_envelope $01
    volume_envelope $09
    tone 4, $00a0, $10
    db $0a, $00  ; register, value
    phrase_end

phrase_b7de:
    tone 4, $00d6, $04
    tone 4, $00fe, $08
    tone 4, $00fe, $08
    tone 4, $00d6, $04
    tone 4, $00fe, $10
    tone 4, $00fe, $10
    tone 4, $00fe, $10
    tone 4, $00fe, $10
    phrase_end

; 2 KiB copied to VRAM $3800 during video initialization.
background_patterns:
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $01, $03, $07, $0f, $1f, $3f, $7f, $ff, $00, $00, $00, $00, $00, $07, $3f, $ff
    db $00, $00, $00, $00, $00, $e0, $fc, $ff, $80, $c0, $e0, $f0, $f8, $fc, $fe, $ff
    db $fb, $f1, $f1, $f1, $91, $9b, $9f, $9f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $07, $0f, $1f, $1f, $7f, $ff, $ff, $7f, $03, $07, $1f, $3f, $3f, $3f, $79, $f7
    db $c0, $e0, $f0, $f4, $fe, $bf, $df, $ff, $90, $b8, $f8, $fa, $ff, $ff, $ff, $fe
    db $3f, $7f, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7e, $3c
    db $f8, $fc, $fe, $fe, $ff, $ff, $ff, $ff, $a0, $40, $a0, $40, $a0, $40, $a0, $40
    db $00, $01, $03, $03, $03, $03, $01, $00, $f0, $f8, $fc, $fc, $fc, $fc, $f8, $f0
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $07, $0f, $1f, $1f, $7f, $ff, $ff, $7f
    db $03, $07, $1f, $3f, $3f, $3f, $79, $f7, $c0, $e0, $f0, $f4, $fe, $bf, $df, $ff
    db $90, $b8, $f8, $fa, $ff, $ff, $ff, $fe, $3b, $1d, $0e, $0f, $07, $00, $00, $00
    db $ff, $bf, $1c, $c0, $f3, $ff, $7e, $1c, $bf, $7f, $3d, $83, $c7, $ff, $ff, $3c
    db $fc, $fe, $ff, $fe, $fe, $f8, $60, $00, $00, $00, $03, $0f, $1f, $3f, $7f, $7f
    db $00, $00, $c0, $f0, $f8, $fc, $fe, $fe, $7f, $7f, $7f, $3f, $3f, $1f, $0f, $07
    db $fe, $fe, $fe, $fc, $fc, $f8, $f0, $f0, $80, $80, $80, $80, $80, $80, $80, $80
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    ifdef QOL
    db %01111111, %10000000, %10100000, %10000111, %10001100, %10001100, %10000000, %10000001  ; tile $28
    db %11111110, %00000001, %00000101, %11100001, %00110001, %00110001, %01100001, %11000001  ; tile $29
    else
    db $7f, $80, $a0, $87, $8f, $8e, $8e, $86, $fe, $01, $05, $c1, $e1, $71, $71, $f1
    endif
    ifdef QOL
    db %10000001, %10000001, %10000000, %10000001, %10000001, %10100000, %10000000, %01111111  ; tile $2a
    db %10000001, %10000001, %00000001, %10000001, %10000001, %00000101, %00000001, %11111110  ; tile $2b
    else
    db $81, $81, $80, $81, $81, $a0, $80, $ff, $f1, $c1, $c1, $81, $c1, $c5, $01, $ff
    endif
    db $7f, $80, $a0, $80, $80, $80, $80, $80, $fe, $01, $05, $01, $01, $01, $01, $01
    db $80, $80, $80, $80, $80, $a0, $80, $7f, $01, $01, $01, $01, $01, $05, $01, $fe
    db $7f, $80, $a0, $80, $80, $80, $80, $80, $fe, $01, $05, $01, $01, $01, $01, $01
    db $80, $80, $80, $80, $80, $a0, $80, $7f, $01, $01, $01, $01, $01, $05, $01, $fe
    ifdef QOL
    db $00, $08, $08, $08, $10, $10, $10, $00  ; tile $34
    db %11111111, %10000001, %10110001, %10000001, %11111111, %00010000, %01010010, %00010000  ; tile $35
    else
    db $00, $08, $08, $08, $10, $10, $10, $00, $01, $01, $01, $ff, $10, $10, $10, $ff
    endif
    ifdef QOL
    db %11111111, %10000001, %10100001, %10000001, %11111111, %00010000, %01010010, %00010000  ; tile $36
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; tile $37
    else
    db $01, $01, $01, $ff, $10, $10, $10, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    endif
    db $7f, $bf, $df, $ef, $f5, $fa, $f5, $fa, $f5, $fa, $f5, $ff, $f0, $e0, $c0, $80
    db $ff, $fe, $fc, $f8, $50, $b0, $50, $b0, $ff, $ff, $66, $24, $18, $24, $66, $ff
    db $00, $00, $00, $00, $ff, $ff, $66, $24, $18, $24, $66, $ff, $00, $00, $00, $00
    db $07, $0f, $1f, $3f, $7f, $7f, $7f, $7f, $e0, $f0, $f8, $fc, $fe, $fe, $fe, $fe
    db $ff, $ff, $83, $f3, $f3, $f3, $f3, $f3, $ff, $ff, $f0, $f6, $f6, $f6, $f6, $f6
    db $ff, $ff, $00, $00, $00, $00, $00, $00, $ff, $ff, $01, $57, $2f, $57, $2f, $57
    db $f3, $f3, $f3, $f3, $f3, $f3, $ff, $3f, $f6, $f6, $f6, $f6, $f6, $f6, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $2f, $57, $2f, $57, $2f, $57, $ff, $fc, $3f, $78, $e7, $cf, $58, $58, $50, $90
    db $b0, $fc, $e2, $c1, $c1, $83, $8f, $7e, $fe, $03, $0f, $91, $70, $60, $20, $31
    db $3f, $3f, $1d, $39, $7b, $f3, $86, $fe, $00, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $ff, $ff, $ff, $ff, $ff, $00, $ff, $ff, $ff, $aa, $55, $aa, $00, $00, $ff, $00
    db $3c, $3c, $3c, $3c, $3c, $3c, $3c, $3c, $fb, $fb, $fb, $fb, $fb, $fb, $fb, $fb
    db $bc, $5c, $bc, $5c, $bc, $5c, $bc, $5c, $00, $00, $03, $0f, $1f, $3f, $7f, $7f
    db $00, $00, $c0, $f0, $f8, $fc, $fe, $fe, $7f, $7f, $7f, $3f, $3f, $1f, $0f, $07
    db $fe, $fe, $fe, $fc, $fc, $f8, $f0, $f0, $81, $c1, $a3, $a3, $9d, $81, $81, $81
    db $ff, $ff, $00, $00, $00, $00, $00, $00, $03, $03, $03, $03, $03, $03, $03, $03
    db $c0, $c0, $c0, $c0, $c0, $c0, $c0, $c0, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e
    db $7e, $7e, $7e, $7f, $7f, $7f, $3f, $1f, $00, $00, $00, $00, $80, $c0, $e0, $f0
    db $0f, $07, $03, $01, $00, $00, $00, $00, $f0, $f8, $fc, $fc, $fe, $7e, $7e, $7e
    db $7f, $80, $a0, $80, $80, $80, $80, $80, $fe, $01, $05, $01, $01, $01, $01, $01
    db $80, $80, $80, $80, $80, $a0, $80, $7f, $01, $01, $01, $01, $01, $05, $01, $fe
    db $fe, $fe, $fe, $fc, $fc, $f8, $f0, $e0, $7f, $7f, $7f, $3f, $3f, $1f, $0f, $07
    db $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f
    db $30, $49, $9e, $be, $be, $be, $be, $be, $0c, $92, $79, $7d, $7d, $7d, $7d, $7d
    db $9e, $49, $31, $61, $c1, $01, $01, $01, $79, $92, $8c, $86, $83, $80, $80, $80
    db $7f, $bf, $df, $ef, $f5, $fa, $f5, $fa, $f5, $fa, $f5, $ff, $f0, $e0, $c0, $80
    db $ff, $fe, $fc, $f8, $50, $b0, $50, $b0, $50, $b0, $50, $f0, $08, $04, $02, $01
    ifdef QOL
    db %11111111,%10000011,%10000011,%10000110,%01111100,%11000110,%10000011,%10000001  ; ledge tile $70
    db %11111111,%00000001,%00000001,%00000011,%00000011,%00000110,%11111100,%10000110  ; ledge tile $71
    db %10000001,%10000011,%01111110,%11000011,%10000001,%10000011,%10000110,%11111100  ; ledge tile $72
    db %10000011,%00000001,%00000001,%00000011,%11111110,%00000011,%00000001,%00000001  ; ledge tile $73
    else
    db $7f, $80, $80, $80, $80, $80, $80, $80, $de, $61, $61, $61, $71, $5e, $7f, $61
    db $80, $80, $c0, $f0, $bf, $8f, $81, $7e, $61, $61, $c1, $c1, $81, $81, $83, $fe
    endif
    db $1f, $10, $10, $f0, $10, $10, $10, $ff, $f1, $11, $11, $1f, $10, $10, $10, $ff
    db $01, $07, $0f, $1f, $3f, $3f, $7f, $7f, $80, $e0, $f0, $f8, $fc, $fc, $fe, $fe
    db $07, $0f, $1f, $1f, $7f, $ff, $ff, $7f, $03, $07, $1f, $3f, $3f, $3f, $79, $f7
    db $c0, $e0, $f0, $f4, $fe, $bf, $df, $ff, $90, $b8, $f8, $fa, $ff, $ff, $ff, $fe
    db $3b, $1d, $0e, $0f, $07, $00, $00, $00, $ff, $bf, $1c, $c0, $f3, $ff, $7e, $1c
    db $bf, $7f, $3d, $83, $c7, $ff, $ff, $3c, $fc, $fe, $ff, $fe, $fe, $f8, $60, $00
    db $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $01, $01, $06, $08, $18, $20, $20, $c0, $00, $08, $18, $38, $fc, $bf, $5e, $d9
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f
    db $00, $00, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $00, $00
    db $ee, $ae, $ea, $ee, $aa, $44, $aa, $44, $7e, $7c, $78, $78, $78, $7c, $7e, $7e
    db $7e, $7e, $3e, $3e, $3e, $3e, $3e, $3e, $00, $08, $18, $38, $fc, $bf, $5e, $d9
    db $3e, $3e, $3e, $3e, $3e, $3e, $3e, $3e, $38, $4c, $c6, $c6, $c6, $64, $38, $00
    db $ef, $4a, $ad, $4a, $ad, $4a, $ad, $4a, $fe, $aa, $d4, $aa, $d4, $aa, $d4, $aa
    db $3e, $3e, $3e, $7e, $7e, $7e, $7c, $78, $78, $7c, $7e, $7e, $7e, $3e, $3e, $3e
    db $01, $01, $01, $ff, $10, $10, $10, $ff, $ff, $01, $01, $ff, $10, $10, $10, $ff
    db $78, $78, $78, $78, $78, $78, $78, $78, $1e, $1e, $1e, $1e, $1e, $1e, $1e, $1e
    ifdef QOL
    db %00011000, %00111100, %01111110, %01100110, %11101111, %11101111, %11101111, %11101111  ; tile $98
    db %11101111, %11101111, %11101111, %11101111, %01100110, %01111110, %00111100, %00011000  ; tile $99
    else
    db $3c, $3c, $66, $5e, $df, $df, $df, $df, $df, $df, $df, $df, $5e, $7e, $3c, $3c
    endif
    db $1b, $1b, $1b, $1b, $1b, $0f, $0f, $07, $1f, $10, $10, $f0, $10, $10, $10, $ff
    db $f1, $11, $11, $1f, $10, $10, $10, $ff, $01, $07, $0f, $1f, $3f, $3f, $7f, $7f
    db $80, $e0, $f0, $f8, $fc, $fc, $fe, $fe, $38, $4c, $c6, $c6, $c6, $64, $38, $00
    db $ff, $ff, $ff, $ff, $ff, $80, $80, $ff, $fe, $ff, $ff, $ff, $ff, $03, $03, $ff
    db $ff, $ff, $ff, $ff, $80, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $03, $ff, $ff, $ff
    db $80, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $03, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $80, $80, $aa, $d5, $aa, $ff, $ff, $ff, $03, $03, $ab, $57, $ab, $ff, $ff, $fe
    db $0f, $0f, $0f, $0f, $0f, $0f, $07, $06, $f0, $f0, $b0, $b0, $b0, $b0, $e0, $60
    db $0d, $0f, $0f, $0f, $0f, $0f, $07, $06, $b0, $f0, $b0, $b0, $b0, $b0, $e0, $60
    db $03, $05, $0b, $0b, $0f, $0f, $07, $03, $c0, $e0, $f0, $f0, $f0, $f0, $e0, $c0
    db $7e, $7e, $7e, $7e, $7e, $3f, $1f, $0f, $7e, $7e, $7e, $7e, $7e, $fc, $f8, $f0
    db $00, $00, $03, $0f, $1f, $3f, $7f, $7f, $00, $00, $c0, $f0, $f8, $fc, $fe, $fe
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $7f, $7f, $7f, $3f, $3f, $1f, $0f, $07, $fe, $fe, $fe, $fc, $fc, $f8, $f0, $f0
    db $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
    db $fb, $f1, $f1, $f1, $91, $9b, $9f, $9f, $f0, $f0, $f0, $f0, $f0, $f0, $e0, $f0
    db $38, $4c, $c6, $c6, $c6, $64, $38, $00, $38, $4c, $c6, $c6, $c6, $64, $38, $00
    db $38, $4c, $c6, $c6, $c6, $64, $38, $00, $38, $4c, $c6, $c6, $c6, $64, $38, $00
    db $38, $4c, $c6, $c6, $c6, $64, $38, $00, $38, $4c, $c6, $c6, $c6, $64, $38, $00
    db $1b, $1b, $7b, $7b, $1b, $1b, $1b, $1b, $e8, $f0, $ee, $b6, $a8, $b0, $a8, $f0
    db $68, $58, $6e, $5e, $e8, $d8, $e8, $d8, $7e, $7e, $3c, $3c, $3c, $3c, $3c, $3c
    db $3c, $3c, $3c, $3c, $3c, $3c, $7e, $7e, $3c, $7e, $7e, $7e, $7e, $7e, $7e, $3c
    db $00, $00, $00, $44, $28, $10, $28, $44, $3c, $42, $99, $a1, $a1, $99, $42, $3c
    db $e3, $f7, $c1, $c1, $c1, $c1, $f7, $e3, $0f, $43, $5b, $53, $31, $19, $0f, $07
    db $10, $20, $22, $ba, $e6, $e1, $c0, $c0, $ff, $ff, $ff, $ff, $ff, $df, $ad, $73
    db $ff, $ff, $ff, $ff, $ff, $fb, $b5, $ce, $77, $77, $77, $77, $77, $77, $77, $77
    db $aa, $11, $aa, $11, $bb, $ba, $ab, $bb, $6f, $6f, $6f, $0f, $bf, $3f, $ff, $ff
    db $3c, $3c, $3c, $3c, $3c, $3c, $3c, $3c, $81, $c1, $a3, $a3, $9d, $81, $81, $81
    db $fb, $fb, $fb, $fb, $fb, $fb, $fb, $fb, $00, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $bc, $5c, $bc, $5c, $bc, $5c, $bc, $5c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $7e, $3c, $f8, $fc, $fe, $fe, $ff, $ff, $ff, $ff
    db $00, $38, $4c, $c6, $c6, $c6, $64, $38, $00, $18, $38, $18, $18, $18, $18, $7e
    db $00, $7c, $c6, $0e, $3c, $78, $e0, $fe, $00, $7e, $0c, $18, $3c, $06, $c6, $7c
    db $00, $1c, $3c, $6c, $cc, $fe, $0c, $0c, $00, $fc, $c0, $fc, $06, $06, $c6, $7c
    db $00, $3c, $60, $c0, $fc, $c6, $c6, $7c, $00, $fe, $c6, $0c, $18, $30, $30, $30
    db $00, $7c, $c6, $c6, $7c, $c6, $c6, $7c, $00, $7c, $c6, $c6, $7e, $06, $0c, $78
    db $00, $38, $6c, $c6, $c6, $fe, $c6, $c6, $00, $fc, $c6, $c6, $fc, $c6, $c6, $fc
    db $00, $3c, $66, $c0, $c0, $c0, $66, $3c, $00, $f8, $cc, $c6, $c6, $c6, $cc, $f8
    db $00, $fe, $c0, $c0, $fc, $c0, $c0, $fe, $00, $fe, $c0, $c0, $fc, $c0, $c0, $c0
    db $00, $3e, $60, $c0, $ce, $c6, $66, $3e, $00, $c6, $c6, $c6, $fe, $c6, $c6, $c6
    db $00, $7e, $18, $18, $18, $18, $18, $7e, $00, $1e, $06, $06, $06, $c6, $c6, $7c
    db $00, $c6, $cc, $d8, $f0, $f8, $dc, $ce, $00, $60, $60, $60, $60, $60, $60, $7e
    db $00, $c6, $ee, $fe, $fe, $d6, $c6, $c6, $00, $c6, $e6, $f6, $fe, $de, $ce, $c6
    db $00, $7c, $c6, $c6, $c6, $c6, $c6, $7c, $00, $fc, $c6, $c6, $c6, $fc, $c0, $c0
    db $00, $7c, $c6, $c6, $c6, $de, $cc, $7a, $00, $fc, $c6, $c6, $ce, $f8, $dc, $ce
    db $00, $78, $cc, $c0, $7c, $06, $c6, $7c, $00, $7e, $18, $18, $18, $18, $18, $18
    db $00, $c6, $c6, $c6, $c6, $c6, $c6, $7c, $00, $c6, $c6, $c6, $ee, $7c, $38, $10
    db $00, $c6, $c6, $d6, $fe, $fe, $ee, $c6, $00, $c6, $ee, $7c, $38, $7c, $ee, $c6
    db $00, $66, $66, $66, $3c, $18, $18, $18, $00, $fe, $0e, $1c, $38, $70, $e0, $fe
    db $3c, $42, $99, $a1, $a1, $99, $42, $3c, $00, $00, $00, $7e, $7e, $00, $00, $00
    db $00, $00, $00, $44, $28, $10, $28, $44, $00, $00, $00, $00, $00, $00, $00, $00
