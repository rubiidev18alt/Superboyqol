; Graphics setup, stage object tables, VDP and sound output routines.

load_common_patterns:
    ld hl,shared.patterns_99ce
    ld de,$0640
    ld bc,$0040
    call vdp_copy_keep_hl_bc
    ld de,$0e40
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_9a0e
    ld de,$1640
    call vdp_copy_keep_hl_bc
    ld de,$1e40
    call vdp_copy_keep_hl_bc
    ld de,$2640
    call vdp_copy_keep_hl_bc
    ld de,$2e40
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_9a6e
    ld de,$1680
    call vdp_copy_keep_hl_bc
    ld de,$2680
    call vdp_copy_keep_hl_bc
    ld de,$e3ff
    ldir
    call sub_5b18
    ld hl,$e407
    ld bc,$0008
    ld de,$1e80
    call vdp_copy_keep_hl_bc
    ld de,$2e80
    call vdp_copy_keep_hl_bc
    ld hl,$e427
    ld de,$1ea0
    call vdp_copy_keep_hl_bc
    ld de,$2ea0
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_9aae
    ld de,$06c0
    ld bc,$0040
    call vdp_copy_keep_hl_bc
    ld de,$16c0
    call vdp_copy_keep_hl_bc
    ld de,$26c0
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_9aee
    ld de,$0ec0
    call vdp_copy_keep_hl_bc
    ld de,$1ec0
    call vdp_copy_keep_hl_bc
    ld de,$2ec0
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_994e
    ld bc,$0700
    push bc
    call copy_even_pattern_banks
    ld hl,shared.patterns_998e
    pop bc
    call copy_odd_pattern_banks
    ld hl,shared.patterns_a72e
    ld bc,$0740
    push bc
    call copy_even_pattern_banks
    pop bc
    call copy_odd_pattern_banks
    ld hl,shared.patterns_9b6e
    ld bc,$0780
    push bc
    call copy_even_pattern_banks
    pop bc
    call copy_odd_pattern_banks
    ld hl,shared.patterns_9b2e
    ld de,$1780
    call vdp_copy_keep_hl_bc
    ld de,$1f80
    call vdp_copy_keep_hl_bc
    ld de,$2780
    call vdp_copy_keep_hl_bc
    ld de,$2f80
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_9a4e
    ld de,$e3ff
    ld bc,$0020
    push hl
    push bc
    ldir
    pop bc
    pop hl
    ld de,$e41f
    ldir
    ld hl,$e3ff
    ld bc,$07c0
    push bc
    call copy_even_pattern_banks
    pop bc
    call copy_odd_pattern_banks
    ld hl,$e09b
    ld bc,$0003
    ld (hl),$e0
    inc hl
    ld (hl),$0a
    add hl,bc
    ld (hl),$e4
    inc hl
    ld (hl),$0f
    add hl,bc
    ld (hl),$e8
    inc hl
    ld (hl),$0c
    add hl,bc
    ld (hl),$ec
    inc hl
    ld (hl),$02
    ld hl,$e103
    ld (hl),$f0
    add hl,bc
    inc hl
    ld (hl),$f4
    ld hl,$e10c
    ld (hl),$08
    add hl,bc
    inc hl
    ld (hl),$0a
    ld hl,$e114
    ld (hl),fireball_ink
    add hl,bc
    inc hl
    ld (hl),spr_amber
    ret

vdp_copy_keep_hl_bc:
    push hl
    push bc
    call vdp_copy
    pop bc
    pop hl
    ret

start_music:
    ifdef SMB_ASSETS
    call dx_song_init
    else
    ifdef POLISH
    call p_song_init
    else
    call shared.sound_init
    endif
    endif
    xor a
    ld hl,music_fade
    ld (hl),a
    inc hl
    inc a
    ld (hl),a
    ret

fade_music:
    ld a,$01
    ld (music_fade),a
    ret

disable_sound:
    xor a
    ld (audio_enabled),a
    ret

hide_sprites:
    ld hl,sprite_attributes
    ld a,$dc
    ld b,$20
    ld de,$0004

loc_7414:
    ld (hl),a
    add hl,de
    djnz loc_7414
    ld hl,$e089
    ld b,$07

loc_741d:
    ld (hl),$dc
    inc hl
    inc hl
    djnz loc_741d
    call upload_first_sprites
    call upload_other_sprites
    ret

time_over:
    xor a
    ld (player_big),a
    ld (player_can_shoot),a
    call fade_music
    call hide_sprites
    call clear_message_area
    ld hl,text_time_over
    ld de,$352b
    ld bc,$0009
    call vdp_copy
    ld a,$ff
    call busy_wait
    ld a,$ff
    call busy_wait
    jp lose_life

text_time_over:
    abyte $a1 "TIME"
    db $00
    abyte $a1 "OVER"

game_over:
    call fade_music
    call clear_message_area
    ld hl,text_game_over
    ld de,$352b
    ld bc,$0009
    call vdp_copy
    ifdef QOL
    jp shared.continue_menu
    ds $747b - $, 0
    else
    ld a,$ff
    call busy_wait
    ld a,$ff
    call busy_wait
    jp loc_402e
    endif

clear_message_area:
    di
    ld hl,$3420
    ld bc,$02e0
    xor a
    jp vdp_fill

text_game_over:
    abyte $a1 "GAME"
    db $00
    abyte $a1 "OVER"

stage_data_table:
    dw stage_data_01, stage_data_02, stage_data_03, stage_data_04
    dw stage_data_05, stage_data_06, stage_data_07, stage_data_08
    dw stage_data_09, stage_data_10, stage_data_11, stage_data_12
    dw stage_data_13, stage_data_14, stage_data_15, stage_data_16

; One record per scroll trigger: column, Y coordinate, object type.
; $01 in the column field selects a repeating generator rather than a position.
stage_data_01:  ; World 1-1
    db $24, $a0, $01
    db $42, $a0, $01
    db $50, $a0, $01
    db $52, $a0, $01
    db $80, $a0, $01
    db $82, $a0, $01
    db $a6, $a0, $01
    db $b2, $a0, $05
    db $be, $a0, $01
    db $e0, $a0, $01
    db $ff

stage_data_02:  ; World 1-2
    db $20, $a0, $01
    db $32, $a0, $01
    db $4a, $a0, $05
    db $64, $a0, $01
    db $69, $a0, $05
    db $84, $38, $01
    db $8c, $5a, $01
    db $b0, $a0, $05
    db $be, $a0, $01
    db $e4, $64, $01
    db $e6, $64, $01
    db $ff

stage_data_03:  ; World 1-3
    db $2e, $70, $01
    db $42, $20, $01
    db $66, $8a, $01
    db $7c, $58, $06
    db $83, $2c, $01
    db $a7, $50, $01
    db $b4, $46, $01
    db $bd, $60, $06
    db $de, $a0, $01
    db $ff

stage_data_04:  ; World 1-4
    db $20, $c1, $08
    db $27, $c1, $08
    db $30, $c1, $08
    db $6e, $c1, $08
    db $79, $88, $08
    db $8a, $c1, $08
    db $92, $c1, $08
    db $a0, $c1, $08
    db $a4, $70, $08
    db $bc, $c1, $08
    db $fc, $60, $09
    db $ff

stage_data_05:  ; World 2-1
    db $30, $60, $01
    db $40, $a0, $05
    db $6c, $a0, $01
    db $80, $a0, $01
    db $8c, $a0, $05
    db $a6, $a0, $05
    db $b3, $a0, $01
    db $be, $a0, $05
    db $d8, $a0, $01
    db $f2, $60, $01
    db $ff

stage_data_06:  ; World 2-2
    db $01, $16, $0a

stage_data_07:  ; World 2-3
    db $01, $16, $0b

stage_data_08:  ; World 2-4
    db $6c, $c1, $08
    db $80, $c1, $08
    db $d5, $c1, $08
    db $dd, $c1, $08
    db $fc, $60, $09
    db $ff

stage_data_09:  ; World 3-1
    db $20, $a0, $05
    db $35, $a0, $05
    db $40, $a0, $03
    db $4a, $a0, $03
    db $6e, $a0, $05
    db $78, $a0, $03
    db $8c, $a0, $03
    db $a0, $a0, $05
    db $b4, $60, $05
    db $cc, $a0, $03
    db $ff

stage_data_10:  ; World 3-2
    db $1a, $a0, $06
    db $32, $a0, $06
    db $50, $a0, $04
    db $60, $a0, $06
    db $74, $a0, $04
    db $82, $a0, $04
    db $aa, $a0, $06
    db $bc, $a0, $06
    db $e8, $a0, $04
    db $ff

stage_data_11:  ; World 3-3
    db $2b, $64, $01
    db $46, $28, $05
    db $72, $58, $05
    db $b6, $46, $01
    db $c2, $58, $05
    db $e6, $a0, $01
    db $ff

stage_data_12:  ; World 3-4
    db $4c, $88, $08
    db $8a, $c1, $08
    db $93, $c1, $08
    db $9c, $c1, $08
    db $a6, $c1, $08
    db $fc, $60, $09
    db $ff

stage_data_13:  ; World 4-1
    db $01, $16, $0c

stage_data_14:  ; World 4-2
    db $34, $a0, $03
    db $46, $a0, $05
    db $48, $5a, $03
    db $78, $a0, $03
    db $86, $a0, $05
    db $8e, $a0, $05
    db $9e, $a0, $03
    db $d6, $a0, $05
    db $e2, $a0, $03
    db $f7, $70, $03
    db $ff

stage_data_15:  ; World 4-3
    db $3c, $60, $04
    db $46, $20, $04
    db $59, $60, $06
    db $85, $28, $04
    db $a0, $60, $06
    db $b8, $40, $04
    db $c8, $60, $06
    db $d8, $60, $06
    db $e8, $a0, $04
    db $ff

stage_data_16:  ; World 4-4
    db $fc, $60, $09
    db $ff

; B = value, C = VDP register.
    ifdef DELUXE
vdp_write_register: jp dx_register
vdp_write_byte:     jp dx_byte
vdp_fill:           jp dx_fill
vdp_copy:           jp dx_copy
    ds $7645 - $, 0
    else
vdp_write_register:
    ld a,b
    di
    out ($bf),a
    ld a,c
    add a,$80
    out ($bf),a
    ei
    ret

; A = byte, HL = VRAM address.
vdp_write_byte:
    push af
    call vdp_set_write_address
    ex (sp),hl
    ex (sp),hl
    pop af
    out ($be),a
    ret

vdp_set_write_address:
    ld a,l
    di
    out ($bf),a
    ld a,h
    and $3f
    add a,$40
    out ($bf),a
    ei
    ret

; Fill BC bytes at VRAM address HL with A.
vdp_fill:
    push af
    call vdp_set_write_address

loc_762c:
    pop af
    out ($be),a
    push af
    dec bc
    ld a,b
    or c
    jr nz,loc_762c
    pop af
    ret

; Copy BC bytes from CPU address HL to VRAM address DE.
vdp_copy:
    ex de,hl
    call vdp_set_write_address

loc_763b:
    ld a,(de)
    out ($be),a
    inc de
    dec bc
    ld a,b
    or c
    jr nz,loc_763b
    ret

    endif
psg_write:
    push af
    push hl
    push de
    push bc
    ld e,c
    nop
    nop
    di
    ld h,$ff
    ld c,a
    cp $06
    jr c,loc_7665
    jr z,loc_765f
    cp $07
    jr z,loc_769b
    cp $0b
    call c,psg_attenuation

loc_765f:
    ei
    pop bc
    pop de
    pop hl
    pop af
    ret

loc_7665:
    ld l,a
    ld (hl),e
    cp $02
    jr c,loc_767b
    cp $04
    jr c,loc_7675
    ld l,$04
    ld b,$c0
    jr loc_767f

loc_7675:
    ld l,$02
    ld b,$a0
    jr loc_767f

loc_767b:
    ld l,$00
    ld b,$80

loc_767f:
    ld a,(hl)
    ld e,a
    and $0f
    or b
    out ($7f),a
    inc hl
    srl e
    srl e
    srl e
    srl e
    ld a,(hl)
    and $03
    add a,a
    add a,a
    add a,a
    add a,a
    or e
    out ($7f),a
    jr loc_765f

loc_769b:
    ld l,a
    ld a,e
    and $07
    ld b,(hl)
    ld (hl),a
    xor b
    jr z,loc_76c1
    ld a,e
    ld bc,$037f
    ld d,$10

loc_76aa:
    rra
    jr c,loc_76b1
    ld h,$08
    jr loc_76b3

loc_76b1:
    ld h,$0f

loc_76b3:
    ex af,af'
    ld a,$80
    add a,d
    add a,h
    out (c),a
    ld a,d
    add a,$20
    ld d,a
    ex af,af'
    djnz loc_76aa

loc_76c1:
    ld a,e
    and $38
    ld e,a
    ld a,($ff0f)
    ld b,a
    ld a,e
    ld ($ff0f),a
    xor b
    jp z,loc_765f
    ld a,$38
    and e
    jr nz,loc_76da
    ld a,$e2
    jr loc_76dc

loc_76da:
    ld a,$ff

loc_76dc:
    out ($7f),a
    jp loc_765f

psg_attenuation:
    res 3,a
    scf
    rla
    rlca
    rlca
    rlca
    rlca
    set 7,a
    ld b,a
    ld a,e
    and $0f
    ld e,a
    ld a,$0f
    sub e
    or b
    out ($7f),a
    ret
