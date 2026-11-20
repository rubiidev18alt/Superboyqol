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
