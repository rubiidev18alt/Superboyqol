; Sound driver: four entry jumps at $a800, called at their high addresses.

sound_tick:
    jp loc_a80c

reset_sound_channels:
    jp sound_reset

sound_init:
    jp loc_abfb

sound_effect:
    jp loc_ac98

loc_a80c:
    ld a,(audio_enabled)
    or a
    ret z
    ld a,(sfx_channel)
    or a
    jr nz,loc_a827
    ld a,($fac2)
    ld c,$06
    call sub_ab3d
    ld a,($fac3)
    ld c,$07
    call sub_ab3d

loc_a827:
    xor a
    ld ($fa1f),a
    ld a,$08
    ld ($fa1e),a
    ld ix,music_channel_1
    ld a,(ix+$00)
    or a
    jr z,loc_a83d
    call tick_channel

loc_a83d:
    ld a,$02
    ld ($fa1f),a
    ld a,$09
    ld ($fa1e),a
    ld ix,music_channel_2
    ld a,(ix+$00)
    or a
    jr z,loc_a854
    call tick_channel

loc_a854:
    ld a,$04
    ld ($fa1f),a
    ld a,$0a
    ld ($fa1e),a
    ld ix,music_channel_3
    ld a,(ix+$00)
    or a
    jr z,loc_a86b
    call tick_channel

loc_a86b:
    ld ix,sfx_channel
    ld a,(ix+$00)
    or a
    jr z,loc_a888
    ld a,($fac4)
    ld c,$06
    call sub_ab3d
    ld a,($fac5)
    ld c,$07
    call sub_ab3d
    call tick_channel

loc_a888:
    xor a
    ld ix,music_channel_1
    or (ix+$00)
    ret nz
    or (ix+$20)
    ret nz
    or (ix+$40)
    ret nz
    ld a,$01
    ld (ix+$00),a
    ld (ix+$20),a
    ld (ix+$40),a
    ld a,(music_fade)
    or a
    jp z,loc_a80c
    ld ix,$fa27
    ld a,$06
    ld e,$00
    cp (ix+$00)
    jr nc,loc_a8bf
    inc e
    dec (ix+$00)
    dec (ix+$00)

loc_a8bf:
    cp (ix+$20)
    jr nc,loc_a8cb
    inc e
    dec (ix+$20)
    dec (ix+$20)

loc_a8cb:
    cp (ix+$40)
    jr nc,loc_a8d9
    dec (ix+$40)
    dec (ix+$40)
    jp loc_a827

loc_a8d9:
    ld a,e
    or a
    ld (audio_enabled),a
    jp nz,loc_a827
    ld a,$08
    ld c,$00
    call write_sound_register
    inc a
    call write_sound_register
    inc a
    jp write_sound_register

tick_channel:
    ld a,(ix+$00)
    or a
    ret z
    ld a,$ff
    ld (ix+$03),a
    call apply_envelopes
    ld a,(ix+$04)
    or a
    jr z,loc_a908
    dec a
    ld (ix+$04),a
    ret

loc_a908:
    ld l,(ix+$0a)
    ld h,(ix+$0b)
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld (ix+$0c),e
    ld (ix+$0d),d
    ld l,(ix+$08)
    ld h,(ix+$09)
    ld e,(hl)
    inc hl
    ld d,(hl)
    ld (ix+$0e),e
    ld (ix+$0f),d
    ld l,(ix+$01)
    ld h,(ix+$02)
    ld a,($fa1e)
    ld d,a
    ld a,(hl)
    cp d
    call z,sub_ab5c
    cp $40
    jp nc,loc_a9c4
    cp $06
    jr nc,loc_a983
    inc hl
    ld c,(hl)
    ld e,c
    call write_sound_register
    inc hl
    inc a
    ld c,(hl)
    ld d,c
    call write_sound_register
    ld a,(ix+$12)
    or a
    jr nz,loc_a95b
    ld a,(ix+$07)
    ld c,a
    ld a,($fa1e)
    call write_sound_register

loc_a95b:
    ld (ix+$10),e
    ld (ix+$11),d

loc_a961:
    inc hl
    push hl
    ld c,(hl)
    push bc
    res 7,c
    ld a,(ix+$05)
    ld l,a
    call divide_l_by_c
    ld a,l
    pop bc
    bit 7,c
    jr z,loc_a977
    srl l
    add a,l

loc_a977:
    pop hl
    ld (ix+$04),a
    inc hl
    ld (ix+$01),l
    ld (ix+$02),h
    ret

loc_a983:
    cp $0b
    jr z,loc_a9af
    inc hl
    ld c,(hl)
    call write_sound_register
    inc hl
    ld (ix+$01),l
    ld (ix+$02),h
    ld c,a
    ld a,($fa1e)
    cp c
    jp nz,loc_a908
    ld a,(ix+$0c)
    or a
    jp nz,loc_a908
    call sub_aa42
    ld a,c
    ld (ix+$06),a
    ld (ix+$07),a
    jp loc_a908

loc_a9af:
    inc hl
    ld c,(hl)
    call write_sound_register
    inc hl
    ld c,(hl)
    inc a
    call write_sound_register
    inc hl
    ld (ix+$01),l
    ld (ix+$02),h
    jp loc_a908

loc_a9c4:
    cp $4b
    jr z,loc_a9e8
    cp $54
    jr z,loc_aa04
    cp $52
    jr z,loc_a9dd
    cp $58
    jp z,loc_aa64
    cp $59
    jp z,loc_aa82
    jp loc_aa2d

loc_a9dd:
    ld a,($fa1e)
    ld c,$00
    call write_sound_register
    jp loc_a961

loc_a9e8:
    inc hl
    ld a,(hl)
    cp $48
    jr nz,loc_a9fd
    inc hl

loc_a9ef:
    ld (ix+$01),l
    ld (ix+$02),h
    xor a
    ld (ix+$00),a
    ld (ix+$03),a
    ret

loc_a9fd:
    inc hl
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    jr loc_a9ef

loc_aa04:
    inc hl
    ld a,(hl)
    inc hl
    push hl
    push de
    ld de,$3840
    ld c,a
    ld b,$00
    call divide_de_by_bc
    ld a,e
    pop de
    ld (ix+$05),a
    pop hl
    ld (ix+$01),l
    ld (ix+$02),h
    ret

divide_l_by_c:
    ld h,$00
    ld b,$08

loc_aa23:
    add hl,hl
    ld a,h
    sub c
    jr c,loc_aa2a
    inc l
    ld h,a

loc_aa2a:
    djnz loc_aa23
    ret

loc_aa2d:
    xor a
    ld (ix+$12),a
    ld a,$45
    ld (ix+$03),a
    ret

write_sound_register:
    call suppress_ch3_during_effect
    jp psg_write

sub_aa3d:
    ld a,c
    out ($7f),a
    pop af
    ret

sub_aa42:
    ret

sub_aa43:
    and b
    push af
    in a,($a2)
    ld c,a
    pop af
    ret

divide_de_by_bc:
    ld hl,$0000
    exx
    ld b,$10

loc_aa50:
    exx
    sla e
    rl d
    adc hl,hl
    sbc hl,bc
    jr c,loc_aa5e
    inc e
    jr loc_aa5f

loc_aa5e:
    add hl,bc

loc_aa5f:
    exx
    djnz loc_aa50
    exx
    ret

loc_aa64:
    inc hl
    push de
    ld e,(hl)
    sla e
    push hl
    ld hl,$f932
    ld d,$00
    add hl,de
    ld (ix+$08),l
    ld (ix+$09),h
    pop hl
    pop de
    inc hl
    ld (ix+$01),l
    ld (ix+$02),h
    jp loc_a908

loc_aa82:
    inc hl
    push de
    ld e,(hl)
    ld (ix+$12),e
    sla e
    push hl
    ld hl,$f944
    ld d,$00
    add hl,de
    ld (ix+$0a),l
    ld (ix+$0b),h
    pop hl
    pop de
    inc hl
    ld (ix+$01),l
    ld (ix+$02),h
    jp loc_a908

apply_envelopes:
    ld l,(ix+$0c)
    ld h,(ix+$0d)
    ld c,(hl)
    ld a,$ff
    cp c
    jr z,loc_aae6
    bit 7,c
    jr nz,loc_aad8
    ld a,(ix+$07)
    cp c
    jr nc,loc_aad2
    xor a

loc_aaba:
    ld c,a
    ld a,($fa1e)
    push af
    ld a,(sfx_channel)
    or a
    jr nz,loc_aad5
    pop af
    call write_sound_register

loc_aac9:
    inc hl
    ld (ix+$0c),l
    ld (ix+$0d),h
    jr loc_aae6

loc_aad2:
    sub c
    jr loc_aaba

loc_aad5:
    pop af
    jr loc_aac9

loc_aad8:
    res 7,c
    ld b,$00
    scf
    ccf
    sbc hl,bc
    ld (ix+$0c),l
    ld (ix+$0d),h

loc_aae6:
    ld l,(ix+$0e)
    ld h,(ix+$0f)
    ld c,(hl)
    ld a,$ff
    cp c
    ret z
    push hl
    bit 7,c
    jr nz,loc_ab2e
    bit 6,c
    jr nz,loc_ab1f
    res 6,c
    res 7,c
    ld l,(ix+$10)
    ld h,(ix+$11)
    ld b,$00
    scf
    ccf
    sbc hl,bc

loc_ab0a:
    ld c,l
    ld a,($fa1f)
    call write_sound_register
    inc a
    ld c,h
    call write_sound_register
    pop hl
    inc hl
    ld (ix+$0e),l
    ld (ix+$0f),h
    ret

loc_ab1f:
    res 6,c
    res 7,c
    ld l,(ix+$10)
    ld h,(ix+$11)
    ld b,$00
    add hl,bc
    jr loc_ab0a

loc_ab2e:
    res 7,c
    ccf
    ld b,$00
    sbc hl,bc
    ld (ix+$0e),l
    ld (ix+$0f),h
    pop hl
    ret

sub_ab3d:
    ld b,a
    ld a,c
    ld c,b
    jp write_sound_register

suppress_ch3_during_effect:
    push af
    push hl
    push ix
    pop hl
    ld a,l
    cp $60
    jr nz,loc_ab59
    ld a,(sfx_channel)
    or a
    jr z,loc_ab59
    pop hl
    pop af
    exx
    pop af
    exx
    ret

loc_ab59:
    pop hl
    pop af
    ret

sub_ab5c:
    push af
    push hl
    ld a,(music_fade)
    or a
    jr nz,loc_ab69
    inc hl
    ld a,(hl)
    ld (ix+$07),a

loc_ab69:
    pop hl
    pop af
    ret

sound_reset:
    di
    ld ix,music_channel_1
    call reset_channel
    ld ix,music_channel_2
    call reset_channel
    ld ix,music_channel_3
    call reset_channel
    ld hl,modulation_accf
    ld ($f932),hl
    ld hl,modulation_acd0
    ld ($f934),hl
    ld hl,modulation_acd3
    ld ($f936),hl
    ld hl,modulation_acd5
    ld ($f938),hl
    ld hl,modulation_accf
    ld ($f944),hl
    ld hl,modulation_acda
    ld ($f946),hl
    ld hl,modulation_ace5
    ld ($f948),hl
    ld hl,modulation_acf4
    ld ($f94a),hl
    ld hl,modulation_ad02
    ld ($f94c),hl
    ld hl,modulation_ad1f
    ld ($f94e),hl
    ld hl,modulation_ad2d
    ld ($f950),hl
    ld hl,modulation_ad3b
    ld ($f952),hl
    ld hl,modulation_ad4a
    ld ($f954),hl
    ld hl,modulation_ad50
    ld ($f956),hl
    xor a
    ld (music_fade),a
    ld (audio_enabled),a
    ret

reset_channel:
    ld (ix+$00),$00
    ld (ix+$04),$00
    ld (ix+$05),$78
    ld (ix+$08),$32
    ld (ix+$09),$f9
    ld (ix+$0a),$44
    ld (ix+$0b),$f9
    ret

loc_abfb:
    push af
    call sound_reset
    pop af
    cp $01
    jr z,loc_ac2f
    cp $02
    jr z,loc_ac52
    cp $03
    jr z,loc_ac75
    ld hl,$98c5
    ld ($fac2),hl
    ld ix,music_channel_1
    ld (ix+$01),low track_0_ch1
    ld (ix+$02),high track_0_ch1
    ld (ix+$21),low track_0_ch2
    ld (ix+$22),high track_0_ch2
    ld (ix+$41),low track_0_ch3
    ld (ix+$42),high track_0_ch3
    ret

loc_ac2f:
    ld hl,$986e
    ld ($fac2),hl
    ld ix,music_channel_1
    ld (ix+$01),low track_1_ch1
    ld (ix+$02),high track_1_ch1
    ld (ix+$21),low track_1_ch2
    ld (ix+$22),high track_1_ch2
    ld (ix+$41),low track_1_ch3
    ld (ix+$42),high track_1_ch3
    ret

loc_ac52:
    ld hl,$986e
    ld ($fac2),hl
    ld ix,music_channel_1
    ld (ix+$01),low track_2_ch1
    ld (ix+$02),high track_2_ch1
    ld (ix+$21),low track_2_ch2
    ld (ix+$22),high track_2_ch2
    ld (ix+$41),low track_2_ch3
    ld (ix+$42),high track_2_ch3
    ret

loc_ac75:
    ld hl,$986e
    ld ($fac2),hl
    ld ix,music_channel_1
    ld (ix+$01),low track_3_ch1
    ld (ix+$02),high track_3_ch1
    ld (ix+$21),low track_3_ch2
    ld (ix+$22),high track_3_ch2
    ld (ix+$41),low track_3_ch3
    ld (ix+$42),high track_3_ch3
    ret

loc_ac98:
    di
    push hl
    push de
    push bc
    push af
    xor a
    ld ($fa84),a
    pop af
    nop
    nop
    nop
    nop
    ld hl,effect_pointers - 2
    ld de,$0002
    ld b,a

loc_acad:
    add hl,de
    djnz loc_acad
    ld (sfx_channel),a
    ld a,(hl)
    inc hl
    ld ($fa81),a
    ld a,(hl)
    ld ($fa82),a
    ld hl,($fa81)
    inc hl
    ld a,(hl)
    ld ($fac5),a
    inc hl
    inc hl
    ld a,(hl)
    ld ($fac4),a
    pop bc
    pop de
    pop hl
    ei
    ret
