; A logic tick produces one complete sprite list and one horizontal scroll.
; Only publish the pair at VBlank. No actor simulation in the interrupt:
; a costly pattern-cache miss must not advance an enemy twice in one tick.
g_ready   equ $eb20
g_batch   equ $eb21
g_scroll  equ $eb22
g_latched equ $eb23
g_prev    equ $ee00            ; previous legacy enemy attributes (24 x 4)
g_sat     equ $ef00            ; VBlank-only copy: 64 Y bytes, 128 X/tile bytes
g_layers  equ $eb40            ; secondary ink tags per native pattern cache slot
g_ink2    equ $eb24
g_merged  equ $eb25
g_render  equ $ee60            ; interpolated view, never used for collisions

g_tick:
    call tick_stage_clock
    ld a,(actors_enabled)
    or a
    ret z
    ld a,(frame_counter)
    and 1
    ret nz
    ld hl,sprite_attributes+32
    ld de,g_prev
    ld bc,96
    ldir
    jp update_actors_irq       ; original AI cadence: once every two ticks

g_frame:
    ld a,1
    ld (g_batch),a
    call draw_player
    call upload_other_sprites
    xor a
    ld (g_batch),a
    jp g_queue

; The simulation positions in $e089.. are shifted by scroll_one_column. Its
; cached sprite positions previously stayed in the old column for a frame.
; Shift both interpolation endpoints. The tenth X in the original loop is
; already the coin popup ($e09a); only its *fine* offset belongs in dx_sprites.
g_column:
    ld hl,sprite_attributes+33
    call .shift
    ld hl,g_prev+1
    call .shift
    ld a,($e248)
    or a
    jr z,.done
    ld hl,sprite_attributes+1
    ld a,(hl)
    cp 248
    jr c,.done
    dec hl
    ld (hl),$dc
    xor a
    ld ($e248),a
.done:
    jp dx_new_column
.shift:
    ld de,4
    ld b,24
.one:
    ld a,(hl)
    sub 8
    ld (hl),a
    jr nc,.next
    dec hl
    ld (hl),$dc                ; no wraparound flash on the right
    inc hl
.next:
    add hl,de
    djnz .one
    ret

g_actor_view:
    ld hl,sprite_attributes+32
    ld a,(g_batch)
    or a
    jp z,loc_5b66
    ld a,(frame_counter)
    and 1
    jp nz,loc_5b66             ; second tick: full new pose
    ld de,g_render
    ld bc,96
    ldir
    ld hl,g_render
    ld de,g_prev
    ld b,24
.actor:
    ; Reject spawns, despawns and warps. Interpolate both coordinates as a
    ; pair so the two colour layers / two halves never separate.
    ld a,(de)
    cp $c0
    jr nc,.skip
    ld a,(hl)
    cp $c0
    jr nc,.skip
    ld a,(de)
    sub (hl)
    add a,8
    cp 17
    jr nc,.skip
    inc de
    inc hl
    ld a,(de)
    sub (hl)
    add a,8
    cp 17
    jr nc,.skip_x
    ld a,(de)
    add a,(hl)
    rra
    ld (hl),a
    dec hl
    dec de
    ld a,(de)
    add a,(hl)
    rra
    ld (hl),a
.skip:
    inc de
    inc hl
.skip_x:
    inc de
    inc hl
    inc de
    inc hl
    inc de
    inc hl
    djnz .actor
.ready:
    ld hl,g_render
    jp loc_5b66

g_queue:
    di
    ld hl,dx_y
    ld de,g_sat
    ld bc,192
    ldir
    ; Phase can be 8/9 until next game_loop commits the collision column.
    ; Do not repeat pixel seven (and skip eight) at that boundary.
    ld a,(dx_ring)
    add a,a
    add a,a
    add a,a
    ld b,a
    ld a,(dx_phase)
    add a,b
    neg
    ld (g_latched),a
    ld a,1
    ld (g_ready),a
    ei
    ret

g_present:
    ld a,(g_ready)
    or a
    ret z
    xor a
    ld (g_ready),a
    ld a,(g_latched)
    out ($bf),a
    ld a,$88
    out ($bf),a
    ld hl,$3f00
    call dx_address
    ld hl,g_sat
    ld bc,$40be
    otir
    ld hl,$3f80
    call dx_address
    ld hl,g_sat+64
    ld bc,$80be
    otir
    ret

; Two overlapping one-colour layers used to consume four of the SMS's eight
; sprites/scanline. Fuse actual pairs (not adjacent unrelated props) into a
; single two-colour pattern. Preserve the first layer's pixel priority.
g_pair:
    rrca
    jr c,.second
    xor a
    ld (g_merged),a
    ld (g_ink2),a
    ld a,(ix+0)
    cp $c0
    ret nc
    cp (ix+4)
    ret nz
    ld a,(ix+1)
    cp (ix+5)
    ret nz
    ld a,(ix+2)
    add a,4
    cp (ix+6)
    ret nz
    ld a,(ix+3)
    and 15
    ret z
    ld a,(ix+7)
    and 15
    ld (g_ink2),a
    ld (g_merged),a
    ret
.second:
    ld a,(ix-4)
    cp $c0
    ld a,0
    jr nc,.save
    ld a,(g_merged)
    or a
    jr z,.save
    ld a,$ff
.save:
    ld (g_ink2),a
    ret

g_paint_pair:                  ; HL = cart RAM source, B = primary ink
    push iy
    push hl
    pop iy
    ld c,a                    ; secondary ink, bytes 32..63 in the source
    ld h,32
.row:
    ld d,(iy+0)
    ld a,d
    cpl
    and (iy+32)
    ld e,a
    inc iy
    rept 4,plane
    xor a
    bit plane,b
    jr z,$+3
    ld a,d
    bit plane,c
    jr z,$+3
    or e
    out ($be),a
    endr
    dec h
    jr nz,.row
    xor a
    ld ($fffc),a
    pop iy
    ei
    ret

; Stream one column, using a single translated address rather than 22 calls
; through the general HUD/name writer. HL = tile source, C = source stride,
; A = physical column. Name rows start at $3880 and are 64 bytes apart.
g_stream_column:
    and 31
    add a,a
    add a,$80
    ld e,a
    ld d,$78                   ; $3880 + write flag
    ld b,22
    di
.row:
    ld a,e
    out ($bf),a
    ld a,d
    out ($bf),a
    ld a,(hl)
    out ($be),a
    xor a
    out ($be),a
    ld a,c
    add a,l
    ld l,a
    jr nc,.source
    inc h
.source:
    ld a,64
    add a,e
    ld e,a
    jr nc,.dest
    inc d
.dest:
    djnz .row
    ei
    ret
