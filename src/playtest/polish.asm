; Brake the existing velocity before accelerating the other way. The old
; dual-speed path stopped moving while it cancelled two nonzero speeds.
p_accel_left:
    ld a,(ix+2)
    or a
    jr nz,p_braking
    ld a,(ix+1)
    jp generic_accelerate
p_accel_right:
    ld a,(ix+1)
    or a
    jr nz,p_braking
    ld a,(ix+2)
    jp generic_accelerate
p_braking:
    xor a
    ret

; Stream a full playfield clear one physical row at a time. Circular column
; order is irrelevant to a uniform fill. Never touch the two pinned HUD rows.
p_clear_field:
    ld hl,$3880
    ld d,22
.row:
    di
    call dx_address
    xor a
    ld b,32
.tile:
    out ($be),a
    out ($be),a
    djnz .tile
    ei
    ld bc,64
    add hl,bc
    dec d
    jr nz,.row
    ret

; $3000-$37ff is dedicated to the HUD. This flag is cleared by the normal
; title/reset RAM clear; neither gameplay sprites nor stage sheets overlap it.
p_font_loaded equ $eb26

; Pitched PSG cues use voice three only. Each one ends by releasing the
; voice to the music; different registers distinguish impacts from rewards.
p_break:
    hop_attack
    tone 4,226,48
    tone 4,339,48
    db $0a,7
    tone 4,508,32
    db $0a,0
    phrase_end
p_bump:
    hop_attack
    tone 4,480,48
    db $0a,7
    tone 4,640,32
    db $0a,0
    phrase_end
p_extra_life:
    hop_attack
    tone 4,254,24
    tone 4,202,24
    tone 4,170,24
    db $0a,9
    tone 4,127,12
    db $0a,0
    phrase_end
p_contact:
    hop_attack
    tone 4,320,48
    db $0a,7
    tone 4,452,32
    db $0a,0
    phrase_end

; Full-screen column data is already in display order. For the mixed
; 18-column openings and the one-column flag sequence keep the old loader.
p_screen_columns:
    ld a,b
    cp 32
    jp nz,load_screen_columns
    ld hl,playfield
.column:
    push bc
    push hl
    call unpack_column
    pop hl
    inc hl
    pop bc
    djnz .column
    dec de
    ld a,(de)
    inc de
    ld (playfield+704),a       ; legacy shift scratch
    ret

; Fast path only for the pristine, spawn-suppressed 32-column stage prime.
; The first request is a no-op, then columns 1..31 enter. The normal next
; scroll still spawns the first actor and presents the now-complete window.
p_prime_columns:
    ld a,b
    cp 32
    jp nz,prime_scroll_columns
    ld a,(suppress_map_upload)
    or a
    jp z,prime_scroll_columns
    ld hl,(scroll_column)
    ld a,(scroll_request)
    or h
    or l
    jp nz,prime_scroll_columns
    ld hl,playfield+31
    ld de,playfield
    ld b,22
.retain:
    ld a,(hl)
    ld (de),a
    ld a,32
    add a,e
    ld e,a
    jr nc,.dst_ok
    inc d
.dst_ok:
    ld a,32
    add a,l
    ld l,a
    jr nc,.src_ok
    inc h
.src_ok:
    djnz .retain
    ld hl,$e088
    ld b,10
.shift_actor:
    ld a,(hl)
    add a,8                    ; -31 * 8 mod 256
    ld (hl),a
    inc hl
    inc hl
    djnz .shift_actor
    ld hl,current_layout+1
    ld de,playfield+1
    ld b,31
.decode:
    push bc
    ld a,(hl)
    inc hl
    push hl
    push de
    ld l,a
    ld h,0
    add hl,hl
    ld b,h
    ld c,l
    add hl,hl
    ld d,h
    ld e,l
    add hl,hl
    add hl,hl
    add hl,de
    add hl,bc                  ; 22 bytes per dictionary entry
    ld de,map_columns
    add hl,de
    pop de
    push de
    ex de,hl
    call unpack_column
    pop de
    inc de
    pop hl
    pop bc
    djnz .decode
    ld hl,31
    ld (scroll_column),hl
    ld a,1
    ld (scroll_request),a
    ret

; IRQs are already masked by the tileset or coin animation transfer. A is
; phase 0..3. Change one background CRAM entry, never the sprite palette.
p_block_colour:
    ld c,a
    ld a,(dx_sheet)
    ld hl,p_block_slots
    ld b,0
    push bc
    ld c,a
    add hl,bc
    ld a,(hl)
    pop bc
    or a                       ; no reserved colour on title or stage cards
    ret z
    out ($bf),a
    ld a,$c0
    out ($bf),a
    ld hl,p_block_ramp
    add hl,bc
    ld a,(hl)
    out ($be),a
    ret
p_block_ramp: db $1f,$0b,$06,$0b    ; bright gold, amber, copper, amber
p_block_slots:
    db 0
    ds 14,9
    db 3,9,0                  ; sheet 15 already uses colour 9 elsewhere

; Each pair is (layout column, bottom tile row). Only these authored blocks
; give upgrades. All unlisted question blocks, including stacked neighbours,
; still take the normal coin path. $ff = no block; castles have no ? blocks.
p_item_blocks:
    ; Three (column,row) pairs per stage; row bit 7 designates a star.
    db 34,13,177,13,124,128+13, 14,13,255,0,18,128+13
    db 89,13,255,0,255,0,       255,0,255,0,255,0
    db 124,13,168,13,154,128+13, 164,7,255,0,255,0
    db 115,7,255,0,255,0,        255,0,255,0,255,0
    db 74,13,255,0,86,128+6,    132,6,255,0,255,0
    db 89,13,255,0,255,0,       255,0,255,0,255,0
    db 40,13,196,13,110,128+13, 80,13,255,0,90,128+13
    db 36,7,89,13,255,0,        255,0,255,0,255,0

p_item_rise equ $eb27
p_item_kind equ $e251          ; 0 mushroom, $10 flower, 1 star
p_star_time equ $eb28          ; 240 half-rate ticks (~8s NTSC)
p_hit_question:
    push hl
    call sub_5c77               ; canonical left half; H/L = pixel X/Y
    ld a,l
    rrca
    rrca
    rrca
    dec a                       ; lower tile row relative to playfield
    ld c,a
    ld a,h
    rrca
    rrca
    rrca
    ld e,a
    ld d,0
    ld hl,(scroll_column)       ; layout column at right edge of window
    add hl,de
    ld de,31
    or a
    sbc hl,de
    ld b,l
    ld a,h
    or a
    jr nz,.coin
    ld a,(stage_index)
    ld e,a
    add a,a
    add a,e
    add a,a
    ld e,a
    ld d,0
    ld hl,p_item_blocks
    add hl,de
    ld d,3
.find:
    ld a,(hl)
    inc hl
    cp $ff
    jr z,.next
    cp b
    jr nz,.next
    ld a,(hl)
    and $7f
    cp c
    jr z,.item
.next:
    inc hl
    dec d
    jr nz,.find
.coin:
    pop hl
    jp loc_4cd6
.item:
    ld a,(hl)
    rlca
    and 1
    ld e,a
    pop hl
    ld a,($e04f)               ; dedicated item slot; don't spend a second
    or a                       ; authored block until the slot is free
    ret nz
    ld a,e
    or a
    jr nz,.typed
    ld a,(player_big)
.typed:
    ld (p_item_kind),a
    call sub_5c77
    ld ($e089),hl              ; rise from the spent block, then move
    call sub_4cf3
    ld hl,$e04f
    ld (hl),$10
    ld de,$e051
    inc hl
    ld (hl),0
    ld bc,5
    ldir                       ; clear all six actor state bytes
    ld a,16
    ld (p_item_rise),a
    ld a,(p_item_kind)
    or a
    ld a,9
    jr z,.colour
    ld a,(p_item_kind)
    cp 1
    ld a,10
    jr z,.colour
    inc a
.colour:
    ld ($e0bc),a
    xor a
    ld ($e0c0),a              ; one native multicolour pattern, no overlay
    ld a,64
    ld ($e0bb),a              ; pattern cache key = 4 * hidden rows
    ld a,6
    call shared.sound_effect
    jp upload_playfield

p_item_tick:
    ld a,(p_item_rise)
    or a
    ret z
    dec a
    ld (p_item_rise),a
    ld hl,$e089
    dec (hl)
    add a,a
    add a,a
    ld ($e0bb),a
    or a
    jr nz,.done
    ld a,(p_item_kind)
    cp $10
    jr z,.done
    ld a,2                     ; native walker: right, reverse at walls, fall
    ld ($e051),a
.done:
    ld hl,$e04f                ; caller iterates the actor records from here
    ret

p_side_contact:
    ld a,(ix+0)
    cp $10
    jp z,p_collect_item
    ld a,(p_star_time)
    or a
    jr nz,p_defeat
    ld a,($e377)
    or a
    jp z,loc_5565
    jp loc_554e

p_top_contact:
    ld a,(ix+0)
    cp $10
    jp z,p_collect_item
    ld a,(p_star_time)
    or a
    ld a,(ix+0)
    jp z,p_normal_stomp
p_defeat:
    ld (ix+0),0
    ld (hl),$dc
    jp loc_5537

p_collect_item:
    ld a,(p_item_rise)
    or a
    jp nz,loc_5537
    ld (ix+0),0
    ld (hl),$dc
    ld a,(p_item_kind)
    or a
    jr z,.grow
    cp 1
    jr nz,.flower
    ld a,240
    ld (p_star_time),a
    ld a,9
    call shared.sound_effect
    jp loc_5537
.flower:
    ld a,(player_big)          ; hurt after flower spawned? regain size only
    ld (player_can_shoot),a
.grow:
    ld a,$10
    ld (player_big),a
    call sub_55cd
    jp loc_5537

; Two native 8x16 halves. During emergence the lower rows are still inside
; the block: stream transparent rows there instead of drawing over its face.
; The actor pattern key tracks the rise; use the live counter for clipping
; even if another animation has just rewritten the legacy attributes.
p_draw_item:
    ld a,(p_item_rise)
    add a,a
    add a,a
    ld e,a
    ld hl,p_mushroom_art
    ld a,(p_item_kind)
    or a
    jr z,.shape
    ld hl,p_star_art
    dec a
    jr z,.shape
    ld hl,p_flower_art
.shape:
    ld d,2
.half:
    ld a,64
    sub e
    jr z,.mask
    ld b,a
    ld c,$be
    otir
.mask:
    ld a,e
    or a
    jr z,.next
    ld b,a
    xor a
.blank:
    out ($be),a
    inc hl
    djnz .blank
.next:
    dec d
    jr nz,.half
    ei
    ret
p_mushroom_art: ds 128,0       ; packed by the standalone asset builder
p_flower_art: ds 128,0
p_star_art: ds 128,0

p_reset_motion:
    xor a
    ld (p_star_time),a
    jp shared.reset_motion

; One additional swept horizontal pixel per four ticks only when running
; flat out. Never repeat vertical physics, jump input, or actor updates.
p_run_tick:
    ld a,(frame_counter)
    bit 0,a
    ret nz
    ld hl,p_star_time
    inc (hl)
    dec (hl)
    jr z,.run
    dec (hl)
.run:
    and 3
    ret nz
    ld a,($e386)
    or a
    ret nz
    ld a,(pad_held)
    and $2c
    cp $24
    jr z,.left
    cp $28
    ret nz
    ld a,(pad_held+2)
    cp 32
    ret nz
    call probe_right
    ret nz
    ld hl,player_x
    ld a,(hl)
    cp $f4
    ret nc
    cp $63
    jr c,.right
    ld a,(scroll_at_end)
    or a
    jp z,dx_camera_step
.right:
    inc (hl)
    ret
.left:
    ld a,(pad_held+1)
    cp 32
    ret nz
    call probe_left
    ret nz
    ld hl,player_x
    ld a,(hl)
    cp 9
    ret c
    dec (hl)
    ret

p_draw_player:
    ld a,(p_star_time)
    or a
    jp z,draw_player
    ; Keep normal colours intact for the instant the timer expires.
    ld a,($e0ac)
    push af
    ld a,($e0b4)
    push af
    ld a,(frame_counter)
    and 24
    rrca
    rrca
    rrca
    ld hl,.inks
    ld e,a
    ld d,0
    add hl,de
    ld a,(hl)
    ld ($e0ac),a
    ld ($e0b4),a
    call draw_player
    pop af
    ld ($e0b4),a
    pop af
    ld ($e0ac),a
    ret
.inks: db 11,3,13,9

p_castle_contact:
    ld a,(p_star_time)
    or a
    ret nz
    jp hurt_player
