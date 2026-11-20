; Three independent duration/period streams in ROM page 15. Keep the Super
; Boy effects driver: the third tone is yielded while an effect is active.
dx_voices equ $ed80             ; each: pointer, frames left, period word
dx_mix    equ $ed90
dx_fade   equ $ed91

dx_song_init:
    push af
    call shared.sound_init
    pop af
    cp 2
    jr c,.import
    xor a
    ld (dx_mix),a
    ret
.import:
    or a
    jr z,.select
    ld a,(round_index)
    cp 3
    ld a,1
    jr nz,.select
    inc a
.select:
    add a,a
    ld l,a
    add a,a
    add a,l
    ld l,a
    ld h,$80
    di
    ld a,15
    ld ($ffff),a
    ld de,dx_voices
    ld b,3
.ptr:
    ld a,(hl)
    ld (de),a
    inc hl
    inc de
    ld a,(hl)
    ld (de),a
    inc hl
    inc de
    ld a,1
    ld (de),a
    inc de
    inc de
    inc de
    djnz .ptr
    ld a,2
    ld ($ffff),a
    ld (dx_mix),a
    xor a
    ld (dx_fade),a
    ei
    ret

dx_song_tick:
    ld a,(dx_mix)
    or a
    jp z,shared.sound_tick
    ld a,(audio_enabled)
    or a
    jr nz,.playing
    ld (dx_mix),a
    ld a,$9f
    out ($7f),a
    ld a,$bf
    out ($7f),a
    ld a,$df
    out ($7f),a
    ret
.playing:
    call dx_effect_tick
    ld a,(music_fade)
    or a
    jr z,.volume
    ld hl,dx_fade
    ld a,(hl)
    cp 15
    jr c,.quieter
    xor a
    ld (audio_enabled),a
    jr .volume
.quieter:
    inc (hl)
.volume:
    ld ix,dx_voices
    ld d,$80
    ld e,3
    di
    ld a,15
    ld ($ffff),a
.channel:
    dec (ix+2)
    jr nz,.output
    ld l,(ix+0)
    ld h,(ix+1)
.fetch:
    ld a,(hl)
    inc hl
    or a
    jr nz,.note
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    jr .fetch
.note:
    ld (ix+2),a
    ld a,(hl)
    inc hl
    ld (ix+3),a
    ld a,(hl)
    inc hl
    ld (ix+4),a
    ld (ix+0),l
    ld (ix+1),h
.output:
    ld a,e
    cp 1
    jr nz,.tone
    ld a,(sfx_channel)
    or a
    jr nz,.advance
.tone:
    ld a,(ix+3)
    or (ix+4)
    ld c,15
    jr z,.volume_out
    ld a,(ix+3)
    and 15
    or d
    out ($7f),a
    ld a,(ix+4)
    ld l,(ix+3)
    rept 4
    srl a
    rr l
    endr
    ld a,l
    out ($7f),a
    ld a,(dx_fade)
    sub e
    add a,7
    cp 16
    jr nc,.volume_out
    ld c,a
.volume_out:
    ld a,d
    or $10
    or c
    out ($7f),a
.advance:
    ld bc,5
    add ix,bc
    ld a,d
    add a,$20
    ld d,a
    dec e
    jr nz,.channel
    ld a,2
    ld ($ffff),a
    ret                         ; IRQ epilogue restores interrupts

; Same channel-3 register selection and envelope interpreter as the stock
; IRQ, without also ticking three inaudible background channels.
dx_effect_tick:
    ld ix,sfx_channel
    ld a,(ix+0)
    or a
    ret z
    ld a,4
    ld ($fa1f),a
    ld a,10
    ld ($fa1e),a
    ld a,($fac4)
    ld c,6
    call shared.sub_ab3d
    ld a,($fac5)
    ld c,7
    call shared.sub_ab3d
    jp shared.tick_channel
