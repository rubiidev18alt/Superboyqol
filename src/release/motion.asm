; 1.0 movement hooks. Horizontal speeds are magnitudes in 1/32 px per
; update. RC7 already rejects acceleration until the opposite speed is zero.
v1_drag_left:
    dec (ix+1)                  ; neutral coast: one unit
    ret z
    bit 3,(ix+0)                ; steering into a skid: two units
    ret z
    dec (ix+1)
    ret
v1_drag_right:
    dec (ix+2)
    ret z
    bit 2,(ix+0)
    ret z
    dec (ix+2)
    ret

; A blocked side probe cancels momentum, not just one tick of acceleration.
; Both directions discard the unspent fractional pixel at the wall.
v1_wall_left:
    xor a
    ld (ix+1),a
    jr v1_wall_done
v1_wall_right:
    xor a
    ld (ix+2),a
v1_wall_done:
    ld (shared.x_fraction),a
    ret

v1_floor:
    ld a,(player_y)
    cp 176                     ; (feet + 8) below the last collision row?
    jp c,probe_floor
    xor a                      ; open pit, never read RAM beyond playfield
    ret

v1_fall:
    bit 1,(ix+5)
    ret z
    ld a,(shared.fall_rate)     ; 1/64 pixel per floor probe (four per tick)
    cp 64
    jr nc,.step
    inc a                      ; softer start at apex / on releasing jump
    cp 17
    jr c,.store
    inc a                      ; transition into full gravity
    cp 64
    jr c,.store
    ld a,64
.store:
    ld (shared.fall_rate),a
.step:
    ld c,a
    ld a,(shared.fall_fraction)
    add a,c
    cp 64
    jr c,.fraction
    sub 64
    ld (shared.fall_fraction),a
    ld hl,player_y
    inc (hl)                   ; one pixel maximum between collision probes
    ld a,(hl)
    cp $d2
    ret nz                     ; Y can wrap above the screen during high jumps
    jp v1_pit_death            ; pits kill even when big, rather than shrinking
.fraction:
    ld (shared.fall_fraction),a
    ret
v1_wall_left_return:
    call v1_wall_left
    jp loc_4a51
v1_wall_right_return:
    call v1_wall_right
    jp loc_4ae2

v1_pit_death:
    xor a
    ld (player_big),a
    ld (player_can_shoot),a
    jp death_animation
