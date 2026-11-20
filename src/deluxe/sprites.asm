; A Graphics I 16x16 layer becomes two Mode 4 8x16 sprites. Cache each
; slot separately: the legacy engine changes pattern banks and actor colours.
dx_sprites:
    push ix
    push hl
    pop ix
    ld a,c
    srl a
    srl a
    ld (dx_count),a
    ld a,e
    srl a
    srl a
.loop:
    ld (dx_slot),a
    add a,a
    ld e,a
    ld d,0
    ld hl,dx_y
    add hl,de
    ld a,(ix+0)
    cp $c0
    jr nc,.hide
    ld a,(ix+3)
    and 15
    jr z,.hide
    ld (dx_colour),a
    ld a,(ix+2)
    and $fc
    ld (dx_pat),a
    ifdef SMB_ASSETS
    push hl
    call dx_pick_sprite
    pop hl
    cp $fe
    jr z,.hide
    endif
    ld a,(ix+0)
    jr .y
.hide:
    ld a,$df
.y:
    ld (hl),a
    inc hl
    ld (hl),a
    cp $df
    jr z,.next
    ld a,(dx_phase)
    ld b,a
    ld a,(dx_slot)
    cp 8
    ld a,(ix+1)
    jr c,.x
    sub b
    jr nc,.x
    ; Don't wrap a sprite through the right side of the screen.
    ld (hl),$df
    dec hl
    ld (hl),$df
    jr .next
.x:
    sla e
    ld hl,dx_xp
    add hl,de
    ld (hl),a
    inc hl
    ld (hl),e
    inc hl
    add a,8
    ld (hl),a
    inc hl
    inc e
    inc e
    ld (hl),e
    ld a,(dx_slot)
    ld e,a
    add a,a
    add a,e
    ld e,a
    ld hl,dx_tags
    add hl,de
    ifdef SMB_ASSETS
    ld a,(dx_key)
    else
    ld a,(dx_bank)
    endif
    ld d,a
    ld a,(dx_pat)
    ld e,a
    ld a,(dx_colour)
    ld b,a
    ld a,(hl)
    cp d
    jr nz,.miss
    inc hl
    ld a,(hl)
    cp e
    dec hl
    jr nz,.miss
    inc hl
    inc hl
    ld a,(hl)
    cp b
    dec hl
    dec hl
    jr z,.next
.miss:
    ld (hl),d
    inc hl
    ld (hl),e
    inc hl
    ld (hl),b
    call dx_upload_shape
.next:
    ld de,4
    add ix,de
    ld hl,dx_count
    ld a,(dx_slot)
    inc a
    dec (hl)
    jp nz,.loop
    di
    ld hl,$3f00
    call dx_address
    ld hl,dx_y
    ld bc,$40be
    otir
    ld hl,$3f80
    call dx_address
    ld hl,dx_xp
    ld bc,$80be
    otir
    ei
    pop ix
    ret

dx_upload_shape:               ; D=bank, E=pattern, B=ink
    ld a,(dx_slot)
    srl a
    ld h,a
    ld l,0
    rr l
    set 5,h
    di
    call dx_address
    ifdef SMB_ASSETS
    bit 7,d
    jr z,.legacy
    ld a,13
    bit 7,e
    jr z,.page
    inc a
.page:
    ld ($ffff),a
    ld a,e
    and $7f
    srl a
    or $80
    ld h,a
    ld l,0
    bit 0,e
    jr z,.aligned
    set 7,l
.aligned:
    ld bc,$80be
    otir
    ld a,2
    ld ($ffff),a
    ei
    ret
.legacy:
    endif
    ld h,0
    ld l,e
    add hl,hl
    add hl,hl
    add hl,hl
    ld a,d
    rlca
    rlca
    rlca
    or h
    or $80
    ld h,a
    ld a,8
    ld ($fffc),a
    ld c,32
.row:
    ld e,(hl)
    inc hl
    rept 4,plane
    xor a
    bit plane,b
    jr z,$+3
    ld a,e
    out ($be),a
    endr
    dec c
    jr nz,.row
    xor a
    ld ($fffc),a
    ei
    ret

    ifdef SMB_ASSETS
dx_key    equ $eb18
dx_script equ $eb19

dx_script_room:
    ld a,16
    ld (dx_script),a
    ld hl,shared.patterns_a26e
    ret

dx_pick_sprite:
    ld a,(dx_bank)
    ld (dx_key),a
    ld c,a
    ld a,(dx_pat)
    cp $68
    jr c,.bank
    ; Walking enemies cycle at eight-frame intervals, not 60 Hz colour flicker.
    ld a,(frame_counter)
    rrca
    rrca
    rrca
    xor c
    and 1
    xor c
    ld c,a
.bank:
    ld a,(dx_script)
    or a
    jr nz,.scene
    ld a,(stage_index)
.scene:
    add a,a
    ld l,a
    add a,a
    add a,l
    add a,c
    ld h,0
    ld l,a
    rept 6
    add hl,hl
    endr
    set 7,h
    ld a,(dx_pat)
    rrca
    rrca
    or l
    ld l,a
    di
    ld a,12
    ld ($ffff),a
    ld b,(hl)
    ld a,2
    ld ($ffff),a
    ei
    ld a,b
    cp $fe
    ret nc
    ld (dx_pat),a
    ld a,$80
    ld (dx_key),a
    ret
    endif
