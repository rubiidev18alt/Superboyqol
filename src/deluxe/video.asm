; Fixed ROM, visible even while $8000-$bfff is mapped to an asset page or
; cart RAM. BC/DE/HL postconditions of the stock VDP helpers matter to callers.
; The tile collision window stays in its original coordinate system.
dx_ring     equ $eb10           ; physical nametable column for logical x=0
dx_phase    equ $eb11           ; sub-tile displacement in pixels
dx_bank     equ $eb12           ; legacy 2 KiB sprite pattern bank
dx_fillbyte equ $eb13
dx_slot     equ $eb14
dx_count    equ $eb15
dx_colour   equ $eb16
dx_pat      equ $eb17
dx_y        equ $ec00           ; native sprite table staging
dx_xp       equ $ec40
dx_tags     equ $ed00           ; 32 (bank,pattern,colour) cache tags

; Caller has serialized the two control-port writes.
dx_address:                     ; HL = raw VRAM destination
    ld a,l
    out ($bf),a
    ld a,h
    or $40
    out ($bf),a
    ret

dx_register:
    ld a,c
    or a
    jr z,dx_init
    cp 6
    ret nz
    ld a,b
    ld (dx_bank),a
    ret

dx_init:
    di
    push hl
    push bc
    ld hl,dx_regs
    ld b,11
    ld c,$80
.reg:
    ld a,(hl)
    out ($bf),a
    ld a,c
    out ($bf),a
    inc hl
    inc c
    djnz .reg
    xor a
    ld (dx_ring),a
    ld (dx_phase),a
    ld (dx_bank),a
    ld ($fffc),a
    ld a,2
    ld ($ffff),a
    pop bc
    pop hl
    ei
    ret
dx_regs:
    db $64,$e2,$ff,$ff,$ff,$ff,$07,$00,$00,$00,$ff
    ; Mode 4, fixed HUD rows, mask the entering left edge, 8x16 sprites.

; R8 is a rightward displacement; the world moves left as the camera advances.
dx_scroll_reg:
    ld a,(dx_ring)
    add a,a
    add a,a
    add a,a
    ld c,a
    ld a,(dx_phase)
    add a,c
    neg
    di
    out ($bf),a
    ld a,$88
    out ($bf),a
    ei
    ret

dx_camera_step:
    ld a,(dx_phase)
    inc a
    ld (dx_phase),a
    cp 1
    call z,dx_lookahead
    ld a,(dx_phase)
    cp 8
    jr c,.fine
    ld a,1
    ld (scroll_request),a
    ret
.fine:
    jp dx_scroll_reg

dx_new_column:
    ; Replace the column that just left the viewport. All other 31 stay put.
    ld a,(dx_ring)
    inc a
    and 31
    ld (dx_ring),a
    ld a,(dx_phase)
    sub 8
    jr nc,.subpixel
    xor a                     ; scripted eight-pixel scroll
.subpixel:
    ld (dx_phase),a
    call dx_scroll_reg
    ld de,$345f
    ld hl,playfield+31
    ld b,22
.row:
    ld a,(hl)
    ex de,hl
    call dx_byte
    ex de,hl
    ld a,32
    add a,l
    ld l,a
    jr nc,.no_h
    inc h
.no_h:
    ld a,32
    add a,e
    ld e,a
    jr nc,.no_d
    inc d
.no_d:
    djnz .row
    ret

; Map a legacy name address to a native 2-byte entry in the circular plane.
dx_name_addr:
    ld a,h
    sub $34
    ld h,a
    jr nz,.rot
    ld a,l
    cp $40
    jr c,.linear              ; fixed two-row score panel
.rot:
    ld a,(dx_ring)
    add a,l
    xor l
    and 31
    xor l
    ld l,a
.linear:
    add hl,hl
    ld a,h
    add a,$38
    ld h,a
    jp dx_address

dx_byte:
    push hl
    push af
    di
    call dx_name_addr
    pop af
    push af
    call dx_entry
    ei
    pop af
    pop hl
    ret

dx_fill:
    push af
    push de
    push hl
    ld (dx_fillbyte),a
    ld a,h
    or a
    jr nz,.not_boot
    ld hl,0
    di
    call dx_address
    xor a
    ld d,a
.clear:
    out ($be),a
    dec bc
    ld a,b
    or c
    ld a,d
    jr nz,.clear
    ei
    jr .done
.not_boot:
    cp $37
    jr nz,.names
    ld a,17                   ; neutral colours for the stage card
    call dx_tileset
    jr .done
.names:
    ld a,(dx_fillbyte)
    call dx_byte
    inc hl
    dec bc
    ld a,b
    or c
    jr nz,.names
.done:
    pop hl
    pop de
    pop af
    ld bc,0
    ret

dx_copy:
    push de                   ; stock: HL=destination, DE=source+len, BC=A=0
    push hl
    add hl,bc
    ex (sp),hl                ; HL=source again; save source end
    ld a,d
    cp $30
    jr c,.legacy_patterns
    jp z,.sprites
    cp $37
    jp z,.colours
    jp nc,.done               ; BG tiles are preconverted at build time
    ; Normal name writes. Stream until a physical row boundary wraps.
.names:
    ld a,d
    cp $34
    jr nz,.stream
    ld a,e
    cp $40
    jr nc,.stream
    ld a,(hl)
    ex de,hl
    call dx_byte
    ex de,hl
    inc hl
    inc de
    dec bc
    ld a,b
    or c
    jr nz,.names
    jp .done
.stream:
    push bc
    push hl
    ex de,hl
    push hl
    di
    call dx_name_addr
    ld a,l
    rrca
    and 31
    ld c,a
    pop de                    ; logical destination
    ld a,e
    and 31
    cp c
    jr nc,.logical_end
    ld a,c
.logical_end:
    neg
    add a,32                  ; min(logical row remaining, physical remaining)
    pop hl
    pop bc
    push de
    ld d,a
    ld a,b
    or a
    jr nz,.span
    ld a,c
    cp d
    jr nc,.span
    ld d,a
.span:
    ld a,c
    sub d
    ld c,a
    jr nc,.no_borrow
    dec b
.no_borrow:
    push bc
    ld e,d
    ld b,d
    ld c,0
.emit:
    ld a,(hl)
    out ($be),a
    ld a,c
    out ($be),a
    inc hl
    djnz .emit
    ei
    ld a,e
    pop bc
    pop de
    add a,e
    ld e,a
    jr nc,.same_page
    inc d
.same_page:
    ld a,b
    or c
    jr nz,.names
    jr .done
.legacy_patterns:
    ; The original engine constructs some frames in scratch RAM, including
    ; flipped sprites. Store *its actual writes*, not a guessed sprite atlas.
    bit 6,h
    jr nz,.from_ram
    res 7,h                   ; $944e..$a7ff has a fixed low-ROM alias
.from_ram:
    set 7,d
    di
    ld a,8
    ld ($fffc),a
    ldir
    xor a
    ld ($fffc),a
    ei
    ; Pattern uploads are rare and occur outside the steady-state frame loop.
    ld hl,dx_tags
    ld de,dx_tags+1
    ld (hl),$ff
    ld bc,95
    ldir
    jr .done
.sprites:
    call dx_sprites
    jr .done
.colours:
    ld de,title_colours
    or a
    sbc hl,de
    add hl,hl
    add hl,hl
    add hl,hl
    ld a,h                    ; palette source offset / 32
    call dx_tileset
.done:
    pop de
    pop hl
    ld bc,0
    xor a
    ret

dx_tileset:
    ld (dx_sheet),a
    ; Each half-bank contains one full 256-tile sheet. Map in bounded bursts
    ; so sound/IRQ code always executes with the normal slot-2 page selected.
    push af
    and 1
    ld hl,$8000
    jr z,.address
    ld h,$a0
.address:
    pop af
    push af
    srl a
    add a,3
    ld e,a
    di
    push hl
    ld hl,0
    call dx_address
    pop hl
    ld d,32
.burst:
    di
    ld a,e
    ld ($ffff),a
    ld bc,$00be
    otir
    ld a,2
    ld ($ffff),a
    ei
    dec d
    jr nz,.burst
    pop af
    ; Palette group follows the sheet number, not the current stage index
    ; (bonus screens can temporarily use the first world's colours).
    ld e,a
    ld d,0
    ld hl,dx_skies
    add hl,de
    ld d,(hl)
    di
    xor a
    out ($bf),a
    ld a,$c0
    out ($bf),a
    ld a,d
    out ($be),a
    ld hl,dx_palette+1
    ld bc,$1fbe
    otir
    ld hl,dx_hud_font         ; fixed ROM source and VRAM destination both $3000
    call dx_address
    ld bc,2048
.hud_tiles:
    ld a,(hl)
    out ($be),a
    inc hl
    dec bc
    ld a,b
    or c
    jr nz,.hud_tiles
    ei
    ret
; SMS CRAM: --BBGGRR. Sky, pine, leaf, sand, copper and cloud whites.
dx_skies: db $39,$39,$01,$39,$10,$39,$39,$39,$10,$11,$11,$11,$10,$39,$01,$39,$10,$00
dx_palette:
    db $39,$00,$09,$1d,$10,$39,$06,$2e,$02,$07,$0b,$1f,$04,$27,$2a,$3f
    db $00,$00,$09,$1d,$10,$35,$06,$2e,$02,$03,$0b,$1f,$04,$1b,$2a,$3f

    include "sprites.asm"

dx_hud:
    xor a
    ld (dx_ring),a
    ld (dx_phase),a
    call dx_scroll_reg
    ld hl,dx_panel
    ld de,$3400
    ld bc,64
    call dx_copy
    jp draw_score
dx_panel:
    db 0,0,0
    abyte $a1 "BOY"
    ds 6,0
    abyte $a1 "GOLD"
    ds 3,0
    abyte $a1 "WORLD"
    ds 2,0
    abyte $a1 "TIME"
    ds 34,0
    assert $-dx_panel == 64

dx_prime:
    ifdef SMB_ASSETS
    xor a
    ld (dx_script),a
    endif
dx_rebuild:
    call scroll_one_column
    xor a
    ld (dx_phase),a
    ld (dx_ring),a
    call dx_scroll_reg
    jp upload_playfield

; HL is the translated native address. Keep HUD font and body art independent.
dx_entry:
    bit 2,h
    jr nz,.body
    bit 1,h
    jr nz,.body
    bit 0,h
    jr nz,.body
    bit 7,l
    jr nz,.body
    and $3f
    or $80
    out ($be),a
    ld a,1
    out ($be),a
    ret
.body:
    out ($be),a
    xor a
    out ($be),a
    ret

; The masked left column is already offscreen when fine scroll starts. Put
; the entering right edge there *before* any of its pixels become visible.
dx_lookahead:
    push hl
    ld hl,(scroll_column)
    inc hl
    ld de,$110
    or a
    sbc hl,de
    jr nc,.end
    ld de,current_layout+$110
    add hl,de
    ld l,(hl)
    ld h,0
    add hl,hl
    push hl                   ; 2 * column ID
    add hl,hl
    ld d,h
    ld e,l
    add hl,hl
    add hl,hl
    add hl,de
    pop de
    add hl,de                 ; 22 * ID
    ld de,map_columns
    add hl,de
    ld de,$3440
    ld b,22
.row:
    ld a,(hl)
    ex de,hl
    call dx_byte
    ex de,hl
    inc hl
    ld a,32
    add a,e
    ld e,a
    jr nc,.same
    inc d
.same:
    djnz .row
.end:
    pop hl
    ret

dx_sheet equ $eb1a

dx_animate:
    ld a,(frame_counter)
    and 7
    jp nz,animate_hit_block
    ld a,(frame_counter)
    rlca
    rlca
    rlca
    and $c0
    ld e,a
    ld a,(dx_sheet)
    add a,$a0
    ld d,a
    di
    ld hl,$1300              ; tile $98, two 8x8 halves
    call dx_address
    ld a,12
    ld ($ffff),a
    ex de,hl
    ld bc,$40be
    otir
    ld a,2
    ld ($ffff),a
    ei
    jp animate_hit_block
