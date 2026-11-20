; Main program: interrupt handler, reset, stage setup and game loop.

irq_handler:
    push hl
    push de
    push bc
    push af
    push iy
    push ix
    ex af,af'
    exx
    push hl
    push de
    push bc
    push af
    call irq_update
    in a,($bf)
    and a
    pop af
    pop bc
    pop de
    pop hl
    exx
    ex af,af'
    pop ix
    pop iy
    pop af
    pop bc
    pop de
    pop hl
    ei
    reti

; init_video enables interrupts before the RAM clear below. Boot RAM values matter.
reset_handler:
    di
    im 1
    ld sp,$f300
    ifdef QOL
    call shared.safe_video_init
    else
    call init_video
    endif

loc_402e:
    di
    ld hl,spawn_index
    ld bc,$137f
    ld d,h
    ld e,l
    inc e
    ld (hl),l
    ldir
    ld a,$80
    ld ($e384),a
    ld hl,sprite_attributes
    ld (hl),$dc
    ld d,h
    ld e,l
    inc de
    ld bc,$007f
    ldir
    di
    ld hl,$e22e
    ld a,$d8
    ld (hl),a
    inc hl
    ld (hl),a
title_screen_entry:
    call hide_sprites
    call draw_hud
    ld hl,lives_bcd
    ld (hl),$05
    ld de,shared.title_screen
    ld b,$20
    call load_screen_columns
    call upload_playfield
    ld hl,stage_colours
    ld b,(hl)
    ld c,$07
    call vdp_write_register
    ld de,$3700
    ld bc,$0020
    call vdp_copy
    ld hl,text_copyright
    ld de,$35e9
    ld bc,$000d
    call vdp_copy
    ld hl,text_push_space
    ld de,$362b
    ld bc,$000a
    call vdp_copy

loc_4096:
    di
    ex (sp),hl
    ex (sp),hl
    ex (sp),hl
    ex (sp),hl
    ex (sp),hl
    ex (sp),hl
    ex (sp),hl
    ex (sp),hl
    ei
    ld hl,($e381)
    dec hl
    ld ($e381),hl
    ld a,h
    or l
    jr nz,loc_40c2
    ld (demo_record),a
    cpl
    di
    ld (demo_active),a
    ei
    ld hl,attract_movie
    ld de,demo_buffer
    ld bc,$006c
    ldir
    jp loc_40d6

loc_40c2:
    ld hl,pad_held
    bit 4,(hl)
    jr z,loc_4096
    ld hl,world_index
    xor a
    ld (hl),a
    inc hl
    ld (hl),a
    ld (player_big),a
    ld (coins_bcd),a

loc_40d6:
    ld hl,score_bcd
    xor a
    ld (hl),a
    inc hl
    ld (hl),a

; Display the stage card, copy layout/spawn data, then dispatch through stage_init_table.
load_stage:
    ifdef QOL
    call shared.reset_motion
    else
    ld hl,projectile_defaults
    endif
    ld de,$e3f8
    ld bc,$0007
    ldir
    ld hl,scroll_column
    ld de,$e236
    ld bc,$001f
    ld (hl),$00
    ldir
    ld a,$80
    ld ($e384),a
    call hide_sprites
    ld de,$090f
    ld hl,$e0ac
    ld (hl),d
    ld bc,$0004
    add hl,bc
    ld (hl),e
    add hl,bc
    ld (hl),d
    add hl,bc
    ld (hl),e
    ld hl,$e0bb
    ld (hl),$c8
    inc hl
    ld (hl),$09
    inc hl
    inc hl
    inc hl
    ld (hl),$cc
    inc hl
    ld (hl),$0f
    ld hl,$3440
    xor a
    ld bc,$02c0
    call vdp_fill
    ld b,$01
    ld c,$07
    call vdp_write_register
    ld a,$f1
    ld hl,$3700
    ld bc,$0020
    call vdp_fill
    ld hl,player_pose
    ld (hl),$01
    inc hl
    ld (hl),$00
    ld hl,$6575
    ld (player_y),hl
    call draw_player
    ld a,$fe
    ld hl,$35f0
    call vdp_write_byte
    ld a,(lives_bcd)
    add a,$d8
    inc hl
    call vdp_write_byte
    ld hl,text_world
    ld de,$354c
    ld bc,$0005
    call vdp_copy
    ld a,(world_index)
    ld b,a
    rlca
    rlca
    ld c,a
    ld a,(round_index)
    add a,c
    ld (stage_index),a
    ld a,b
    add a,$d9
    ld de,$3434
    ld hl,$358c
    call vdp_write_byte
    ex de,hl
    call vdp_write_byte
    inc hl
    ex de,hl
    inc hl
    ld a,$fd
    call vdp_write_byte
    ex de,hl
    call vdp_write_byte
    inc hl
    ex de,hl
    inc hl
    ld a,(round_index)
    add a,$d9
    call vdp_write_byte
    ex de,hl
    call vdp_write_byte
    ifdef QOL
    ld a,$08            ; shorter stage card on starts and retries
    call busy_wait
    ld a,(stage_index)
    else
    ld a,$14
    call busy_wait
    ld a,(stage_index)
    endif
    add a,a
    ld hl,stage_data_table
    add a,l
    ld l,a
    ld a,$00
    adc a,h
    ld h,a
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    ld de,spawn_list
    ld bc,$0032
    ldir
    xor a
    ld (spawn_index),a
    ld hl,$e04f
    ld d,h
    ld e,l
    inc de
    ld bc,$0037
    ld (hl),$00
    ldir
    ld a,(stage_index)
    ld hl,stage_times
    add a,l
    ld l,a
    ld a,$00
    adc a,h
    ld h,a
    ld l,(hl)
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld a,h
    daa
    ld h,a
    ld a,l
    daa
    ld l,a
    ld (timer_bcd),hl
    call draw_timer
    xor a
    inc a
    ld (suppress_map_upload),a
    ld a,(stage_index)
    ld hl,stage_layouts
    and a
    jr z,loc_4203
    ld b,a
    ld de,$0110

loc_4200:
    add hl,de
    djnz loc_4200

loc_4203:
    ld de,current_layout
    ld bc,$0110
    ldir
    add a,a
    ld hl,stage_init_table
    add a,l
    ld l,a
    ld a,$00
    adc a,h
    ld h,a
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    jp (hl)

projectile_defaults:
    db $0a, $00, $01, $02, $14, $00, $05  ; $421a

; 4-4 maze: stay high at column $62 and low at $c8 or repeat part of the layout.
game_loop:
    call scroll_one_column
    ld a,(stage_index)
    cp $0f
    jr nz,loc_4253
    ld a,(scroll_column)
    cp $62
    jr nz,loc_4240
    ld a,(player_y)
    cp $60
    jr c,loc_4253
    ld a,$19
    ld (scroll_column),a
    jr loc_4253

loc_4240:
    ld a,(scroll_column)
    cp $c8
    jr nz,loc_4253
    ld a,(player_y)
    cp $80
    jr nc,loc_4253
    ld a,$62
    ld (scroll_column),a

loc_4253:
    ld a,($e386)
    and a
    call z,check_player_actor_collisions
    call check_actor_pairs
    call draw_timer
    ld a,(frame_ready)
    and a
    jr z,game_loop
    xor a
    ld (frame_ready),a
    call tick_stage_clock
    call update_player
    call animate_hit_block
    call sub_5014
    call upload_other_sprites
    call update_player
    call draw_player
    jr game_loop

sub_4281:
    ld a,$06
    ld c,$0b
    ld b,$04
    call set_actor_sprite_colours
    ld hl,shared.patterns_9bae
    ld de,$e3ff
    ld bc,$0040
    ldir
    ld b,$02
    call mirror_sprite_patterns
    ld hl,shared.patterns_9bae
    ld bc,$0340
    call copy_even_pattern_banks
    ld bc,$0380
    call copy_odd_pattern_banks
    ld hl,$e3ff
    ld bc,$0340
    call copy_odd_pattern_banks
    ld bc,$0380
    call copy_even_pattern_banks
    call sub_5b18
    ld hl,$e3ff
    ld bc,$0400
    push bc
    call copy_even_pattern_banks
    pop bc
    call copy_odd_pattern_banks
    ld hl,$e3ff
    ld de,$e400
    ld bc,$003f
    xor a
    ld (hl),a
    ldir
    ld de,shared.patterns_9bae
    ld hl,$e407
    ld c,$04

loc_42de:
    ld b,$08

loc_42e0:
    ld a,(de)
    ld (hl),a
    inc de
    inc de
    inc hl
    djnz loc_42e0
    ld a,$08
    add a,l
    ld l,a
    ld a,$00
    adc a,h
    ld h,a
    dec c
    jr nz,loc_42de
    ld hl,$e3ff
    ld bc,$03c0
    push bc
    call copy_even_pattern_banks
    pop bc
    call copy_odd_pattern_banks
    ret

copy_even_pattern_banks:
    ld d,b
    ld e,c
    push bc
    ld bc,$0040
    call vdp_copy_keep_hl_bc
    pop bc
    ex de,hl
    ld hl,$1000
    add hl,bc
    ex de,hl
    push bc
    ld bc,$0040
    call vdp_copy_keep_hl_bc
    pop bc
    ex de,hl
    ld hl,$2000
    add hl,bc
    ex de,hl
    ld bc,$0040
    jp vdp_copy_keep_hl_bc

copy_odd_pattern_banks:
    ex de,hl
    ld hl,$0800
    add hl,bc
    ex de,hl
    push bc
    ld bc,$0040
    call vdp_copy_keep_hl_bc
    pop bc
    ex de,hl
    ld hl,$1800
    add hl,bc
    ex de,hl
    push bc
    ld bc,$0040
    call vdp_copy_keep_hl_bc
    pop bc
    ex de,hl
    ld hl,$2800
    add hl,bc
    ex de,hl
    ld bc,$0040
    jp vdp_copy_keep_hl_bc

set_actor_sprite_colours:
    ld hl,$e0c4

loc_4350:
    ld de,$0004

loc_4353:
    ld (hl),a
    add hl,de
    ld (hl),c
    add hl,de
    djnz loc_4353
    ret

sub_435a:
    ld a,$09
    ld c,$0f
    ld b,$02
    call set_actor_sprite_colours
    ld a,$02
    ld c,$0f
    ld b,$02
    call loc_4350
    ld hl,shared.patterns_9e6e

sub_436f:
    push hl
    ld bc,$0340
    call copy_even_pattern_banks
    ld de,$e3ff
    ldir
    ld b,$02
    call mirror_sprite_patterns
    ld hl,$e3ff
    ld bc,$0380
    call copy_even_pattern_banks
    pop hl
    ld de,$0040
    add hl,de
    ld bc,$0340
    call copy_odd_pattern_banks
    ld de,$e3ff
    ldir
    ld b,$02
    call mirror_sprite_patterns
    ld hl,$e3ff
    ld bc,$0380
    call copy_odd_pattern_banks
    call sub_5b18
    ld hl,$e3ff
    ld bc,$03c0
    call copy_even_pattern_banks
    ld bc,$03c0
    call copy_odd_pattern_banks
    ld bc,$0400
    call copy_even_pattern_banks
    ld bc,$0400
    jp copy_odd_pattern_banks

sub_43c5:
    ld a,$02
    ld c,$0f
    ld b,$04
    call set_actor_sprite_colours
    ld hl,shared.patterns_9fae
    jr sub_436f

sub_43d3:
    ld a,$0f
    ld c,$01
    ld b,$04
    call set_actor_sprite_colours
    ld hl,shared.patterns_a02e
    call sub_436f
    ld hl,shared.patterns_a0ae
    ld bc,$03c0
    call copy_even_pattern_banks
    ld bc,$03c0
    jp copy_odd_pattern_banks

set_secondary_sprite_colours:
    ld hl,$e0e4
    jp loc_4350

sub_43f7:
    ld a,$0f
    ld c,$0c
    ld b,$01
    call set_secondary_sprite_colours
    ld c,$08
    ld b,$01
    call loc_4350
    ld a,$0f
    ld c,$0c
    ld b,$01
    call loc_4350
    ld c,$08
    ld b,$01
    jp loc_4350

sub_4417:
    call sub_43f7
    ld hl,shared.patterns_9bee
    call sub_4513
    ld hl,shared.patterns_9c6e
    call sub_4551
    jr loc_4437

sub_4428:
    call sub_43f7
    ld hl,shared.patterns_9d6e
    call sub_4513
    ld hl,shared.patterns_9dee
    call sub_4551

loc_4437:
    ld hl,$e3ff
    ld d,h
    ld e,l
    inc de
    ld bc,$02ff
    ld (hl),$00
    ldir
    ld hl,$e3ff
    ld bc,$05c0
    call copy_even_pattern_banks
    ld bc,$05c0
    call copy_odd_pattern_banks
    ld hl,shared.patterns_9cee
    ld bc,$0600
    call copy_even_pattern_banks
    ld hl,shared.patterns_9d2e
    ld bc,$0600
    call copy_odd_pattern_banks
    ld hl,shared.patterns_a66e
    ld bc,$0540
    call copy_even_pattern_banks
    ld hl,shared.patterns_a6ee
    ld bc,$0540
    call copy_odd_pattern_banks
    ld hl,shared.patterns_a6ae
    ld bc,$0580
    push bc
    call copy_odd_pattern_banks
    pop bc
    jp copy_even_pattern_banks

sub_4485:
    ld hl,shared.patterns_a0ee
    call sub_4513
    ld hl,shared.patterns_a16e
    call sub_4551
    ld hl,shared.patterns_a0ee
    call sub_44b5
    ld hl,shared.patterns_a5ee
    jp loc_44ed

sub_449d:
    ld hl,shared.patterns_9eee
    call sub_4513
    ld hl,shared.patterns_9eee
    call sub_4551
    ld hl,shared.patterns_9eee
    call sub_44b5
    ld hl,shared.patterns_9f6e
    jp loc_44ed

sub_44b5:
    push hl
    ld de,$e3ff
    ld bc,$0040
    ldir
    call sub_5b18
    ld hl,$e3ff
    ld bc,$0600
    push bc
    call copy_even_pattern_banks
    pop bc
    call copy_odd_pattern_banks
    pop hl
    ld de,$0040
    add hl,de
    ld de,$e3ff
    ld bc,$0040
    ldir
    call sub_5b18
    ld hl,$e3ff
    ld bc,$05c0
    push bc
    call copy_even_pattern_banks
    pop bc
    jp copy_odd_pattern_banks

loc_44ed:
    ld bc,$0540
    push bc
    call copy_even_pattern_banks
    pop bc
    call copy_odd_pattern_banks
    ld de,$e3ff
    ld bc,$0040
    ldir
    ld b,$02
    call mirror_sprite_patterns
    ld hl,$e3ff
    ld bc,$0580
    push bc
    call copy_even_pattern_banks
    pop bc
    jp copy_odd_pattern_banks

sub_4513:
    push hl
    ld bc,$0440
    call copy_even_pattern_banks
    ld de,$e3ff
    ld bc,$0040
    ldir
    ld b,$02
    call mirror_sprite_patterns
    ld hl,$e3ff
    ld bc,$04c0
    call copy_even_pattern_banks
    pop hl
    ld de,$0040
    add hl,de
    ld bc,$0480
    call copy_even_pattern_banks
    ld de,$e3ff
    ld bc,$0040
    ldir
    ld b,$02
    call mirror_sprite_patterns
    ld hl,$e3ff
    ld bc,$0500
    jp copy_even_pattern_banks

sub_4551:
    push hl
    ld bc,$0440
    call copy_odd_pattern_banks
    ld de,$e3ff
    ld bc,$0040
    ldir
    ld b,$02
    call mirror_sprite_patterns
    ld hl,$e3ff
    ld bc,$04c0
    call copy_odd_pattern_banks
    pop hl
    ld de,$0040
    add hl,de
    ld bc,$0480
    call copy_odd_pattern_banks
    ld de,$e3ff
    ld bc,$0040
    ldir
    ld b,$02
    call mirror_sprite_patterns
    ld hl,$e3ff
    ld bc,$0500
    jp copy_odd_pattern_banks

load_castle_patterns:
    ld hl,shared.patterns_a3ee
    ld de,$0440
    ld bc,$0100
    call vdp_copy_keep_hl_bc
    ld de,$1440
    call vdp_copy_keep_hl_bc
    ld de,$2440
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_a4ee
    ld de,$0c40
    call vdp_copy_keep_hl_bc
    ld de,$1c40
    call vdp_copy_keep_hl_bc
    ld de,$2c40
    call vdp_copy_keep_hl_bc
    ld de,$e3ff
    ldir
    ld b,$08
    call mirror_sprite_patterns
    ld hl,$e3ff
    ld bc,$0100
    ld de,$0540
    call vdp_copy_keep_hl_bc
    ld de,$1540
    call vdp_copy_keep_hl_bc
    ld de,$2540
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_a3ee
    ld de,$e3ff
    ld bc,$0100
    ldir
    ld b,$08
    call mirror_sprite_patterns
    ld hl,$e3ff
    ld de,$0d40
    ld bc,$0100
    call vdp_copy_keep_hl_bc
    ld de,$1d40
    call vdp_copy_keep_hl_bc
    ld de,$2d40
    call vdp_copy_keep_hl_bc
    ld a,$08
    ld c,$0b
    ld b,$04
    call set_actor_sprite_colours
    ld b,$04
    ld c,$0f
    ld a,$02
    call set_secondary_sprite_colours
    ld hl,shared.patterns_a5ee
    call sub_436f
    ld hl,shared.patterns_a62e
    ld bc,$0340
    jp copy_even_pattern_banks

sub_4627:
    ld hl,shared.patterns_a26e
    ld de,$1340
    ld bc,$0080
    call vdp_copy_keep_hl_bc
    ld de,$2340
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_a2ee
    ld de,$1b40
    call vdp_copy_keep_hl_bc
    ld de,$2b40
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_a36e
    ld de,$0340
    ld bc,$0040
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_a3ae
    ld de,$0b40
    call vdp_copy_keep_hl_bc
    ld hl,shared.patterns_a1ee
    ld bc,$03c0
    push bc
    call copy_even_pattern_banks
    pop bc
    call copy_odd_pattern_banks
    ld hl,shared.patterns_a22e
    ld bc,$0400
    push bc
    call copy_even_pattern_banks
    pop bc
    call copy_odd_pattern_banks
    ld hl,shared.patterns_a76e
    ld bc,$0740
    push bc
    call copy_even_pattern_banks
    pop bc
    call copy_odd_pattern_banks
    ld hl,shared.patterns_a7ae
    ld bc,$0780
    push bc
    call copy_even_pattern_banks
    pop bc
    jp copy_odd_pattern_banks

init_stage_01:
    ld a,$a0
    ld (player_y),a
    call load_common_patterns
    call sub_4281
    call sub_4417
    xor a
    call start_music
    ld de,$0601
    call set_sprite_pair_colours

loc_46ad:
    ld b,$20
    call prime_scroll_columns
    ld hl,scroll_column
    ld (hl),$1f
    inc hl
    ld (hl),$00

loc_46ba:
    xor a
    ld (suppress_map_upload),a
    inc a
    ld (scroll_request),a
    call load_stage_colours
    call scroll_one_column
    ld a,$0a
    ld (player_x),a
    ld (actors_enabled),a
    ld hl,$e087
    ld d,h
    ld e,l
    inc de
    ld bc,$0012
    ld (hl),$dc
    ldir
    ld a,(player_big)
    and a
    call nz,sub_55cd
    call hide_sprites
    call switch_sprite_bank
    jp game_loop

prime_scroll_columns:
    push bc
    call scroll_one_column
    ld a,$01
    ld (scroll_request),a
    pop bc
    djnz prime_scroll_columns
    ret

init_stage_02:
    call sub_4627
    call play_stage_intro
    call load_common_patterns
    call sub_4281
    call sub_4417
    xor a
    inc a
    call start_music
    ld a,$a0
    ld (player_y),a
    jr loc_46ad

intro_sprite_attributes:
    db $90, $b0, $e8, $02, $90, $b0, $ec, $0c, $a0, $b0, $f0, $02, $a0, $b0, $f4, $0c  ; $4715

bonus_sprite_attributes:
    db $8f, $d0, $e8, $02, $8f, $d0, $ec, $0c, $9f, $d0, $f0, $02, $9f, $d0, $f4, $0c  ; $4725

play_stage_intro:
    ld de,sprite_attributes
    ld hl,intro_sprite_attributes
    ld bc,$0010
    ldir
    ld hl,colours_1_1
    ld b,(hl)
    ld c,$07
    call vdp_write_register
    ld de,$3700
    ld bc,$0020
    call vdp_copy
    ld de,shared.stage_screen_b
    ld b,$20
    call load_screen_columns
    call upload_playfield
    xor a
    call start_music
    ld hl,$40a0
    ld (player_y),hl
    ld a,$02
    ld (player_pose),a
    ld b,$6c

loc_476e:
    ld hl,(player_y)
    inc h
    ld (player_y),hl
    ld a,h
    ld (player_anim),a
    push bc
    call draw_player
    ld a,$09
    call busy_wait
    pop bc
    ld a,b
    cp $10
    jr nz,loc_478d
    ld a,$0b
    call shared.sound_effect

loc_478d:
    djnz loc_476e
    call hide_sprites
    call fade_music
    ld a,$50
    call busy_wait
    ld de,$0501

set_sprite_pair_colours:
    ld hl,$e104
    ld bc,$0004
    ld (hl),d
    add hl,bc
    ld (hl),e
    add hl,bc
    ret

init_stage_03:
    call sub_4428
    call sub_4281
    call load_common_patterns

loc_47b1:
    ld de,shared.stage_screen_b
    ld b,$12
    call load_screen_columns

loc_47b9:
    ld de,current_layout
    ld b,$0e
    call prime_scroll_columns
    ld hl,scroll_column
    ld (hl),$0e
    inc hl
    ld (hl),$00
    ld a,$a0
    ld (player_y),a
    ld de,$0601
    call set_sprite_pair_colours
    xor a
    call start_music
    jp loc_46ba

init_stage_04:
    call load_castle_patterns
    ld a,$48
    ld (player_y),a
    ld a,$01
    call start_music
    jp loc_46ad

init_stage_05:
    call sub_4281
    call sub_4417
    call load_common_patterns

loc_47f4:
    ld de,shared.stage_screen_a
    ld b,$12
    call load_screen_columns
    ld a,$a0
    ld (player_y),a
    jp loc_47b9

init_stage_06:
    call sub_435a
    call sub_4428
    call load_common_patterns
    jp loc_47b1

init_stage_07:
    call sub_4428
    call sub_435a
    call load_common_patterns
    jp loc_47b1

init_stage_08:
    call load_common_patterns
    call load_castle_patterns
    ld a,$48
    ld (player_y),a
    ld a,$01
    call start_music
    jp loc_46ad

init_stage_09:
    call sub_4417
    call load_common_patterns
    call sub_43d3
    jp loc_47f4

init_stage_10:
    call sub_4428
    call sub_43c5
    call load_common_patterns
    jp loc_47b1

init_stage_11:
    call sub_4417
    call sub_4281
    jp loc_47b1

init_stage_12:
    call load_castle_patterns
    ld a,$01
    call start_music
    ld a,$30
    ld (player_y),a
    jp loc_46ad

init_stage_13:
    call sub_43c5
    call sub_449d
    call load_common_patterns
    jp loc_47f4

init_stage_14:
    call sub_4627
    call play_stage_intro
    call load_common_patterns
    call sub_43d3
    call sub_4417
    ld a,$a0
    ld (player_y),a
    ld a,$01
    call start_music
    jp loc_46ad

init_stage_15:
    call sub_43c5
    call sub_4428
    call load_common_patterns
    jp loc_47b1

init_stage_16:
    call load_castle_patterns
    ld a,$40
    ld (player_y),a
    ld a,$01
    call start_music
    jp loc_46ad

loc_48a4:
    ld ix,pad_held
    ld a,($e387)
    cp $07
    call nc,sub_48c0
    call loc_49ee
    ld a,($e387)
    dec a
    ld ($e387),a
    ret nz

loc_48bb:
    xor a
    ld ($e386),a
    ret

sub_48c0:
    call probe_ceiling
    jr nz,loc_48bb
    ld hl,(player_y)
    dec l
    ld (player_y),hl
    ret

; IX points at the pad byte; the following bytes hold speeds and jump state.
update_player:
    ld ix,pad_held
    ld a,($e386)
    and a
    jp nz,loc_48a4
    ld a,(player_can_shoot)
    and a
    jp z,loc_491c
    ld a,(ix+$00)
    ld hl,$e388
    ld b,a
    and $20
    ld c,(hl)
    ld (hl),a
    xor c
    ld a,b
    jr z,loc_491c
    ld a,($e080)
    and a
    jr nz,loc_491c
    ld a,(player_facing)
    ld ($e3fa),a
    ld a,(player_y)
    cp $30
    jr c,loc_491c
    sub $10
    ld ($e097),a
    ld ($e3fc),a
    ld a,(player_x)
    add a,$08
    ld ($e098),a
    ld de,$e080
    ld hl,$e3f8
    ld bc,$0007
    ldir

loc_491c:
    ld a,(ix+$00)
    ld b,a
    and a
    jp z,loc_49d9
    bit 0,(ix+$05)
    jr nz,loc_4935
    ld a,($e259)
    inc a
    ld ($e259),a
    ifdef QOL
    and $01             ; accept air steering every other update
    jr nz,loc_4979
    else
    and $03
    jr nz,loc_4979
    endif

loc_4935:
    ld a,b
    bit 2,a
    jr z,loc_4950
    ifdef QOL
    ld a,(ix+1)
    call shared.accelerate
    ld (ix+1),a
    ds $494e - $, 0
    else
    ld a,(ix+$01)
    bit 5,(ix+$00)
    jr z,loc_4947
    cp $32
    jr loc_4949

loc_4947:
    cp $1f

loc_4949:
    jr nc,loc_4979
    inc (ix+$01)
    endif
    jr loc_4979

loc_4950:
    bit 3,a
    jr z,loc_496a
    ifdef QOL
    ld a,(ix+2)
    call shared.accelerate
    ld (ix+2),a
    ds $4968 - $, 0
    else
    ld a,(ix+$02)
    bit 5,(ix+$00)
    jr z,loc_4961
    cp $32
    jr loc_4963

loc_4961:
    cp $1f

loc_4963:
    jr nc,loc_4979
    inc (ix+$02)
    endif
    jr loc_4979

loc_496a:
    bit 0,(ix+$05)
    jr z,loc_4979
    bit 1,a
    jr z,loc_4979
    ld a,$04
    ld (player_pose),a

loc_4979:
    bit 4,(ix+$00)
    jr z,loc_49d9
    bit 1,(ix+$05)
    jr nz,loc_49d9
    call probe_ceiling
    jr nz,loc_49d9
    inc (ix+$04)
    ld a,(ix+$04)
    ld b,a
    and $01
    jr nz,loc_49ee
    inc (ix+$03)
    ld a,(ix+$03)
    cp $01
    jr nz,loc_49b6
    res 0,(ix+$05)
    ex af,af'
    ld a,(player_big)
    and a
    ld a,$01
    jr z,loc_49ae
    ld a,$02

loc_49ae:
    call shared.sound_effect
    xor a
    ld (player_pose),a
    ex af,af'

loc_49b6:
    cp $40
    jr nc,loc_49d9
    ld hl,jump_steps
    add a,l
    ld l,a
    ld a,$00
    adc a,h
    ld h,a
    ld e,(hl)
    ld a,(player_y)
    sub e
    cp $d9
    jr z,loc_49ee
    cp $da
    jr z,loc_49ee
    cp $db
    jr z,loc_49ee
    ld (player_y),a
    jr loc_49ee

loc_49d9:
    ld (ix+$03),$ff
    set 1,(ix+$05)
    ld a,($e258)
    and (ix+$00)
    ld ($e258),a
    xor a
    ld ($e386),a

loc_49ee:
    ld a,(ix+$01)
    and a
    jp z,loc_4a51
    call probe_left
    jp nz,loc_4a4e
    ld hl,(player_y)
    ld a,h
    cp $09
    jp c,loc_4a48
    ld a,(ix+$02)
    and a
    jr z,loc_4a1c
    dec (ix+$02)
    dec (ix+$01)
    ld hl,player_pose
    ld (hl),$03
    inc hl
    ld a,$01
    ld (hl),a
    jp loc_4ae2

loc_4a1c:
    ifdef QOL
    ld a,(ix+1)
    call shared.pixel_step
    jr c,loc_4a2b
    ds $4a2a - $, 0
    else
    ld a,(ix+$01)
    cp $20
    jr nc,loc_4a2a
    ld a,(frame_counter)
    and $01
    jr z,loc_4a2b
    endif

loc_4a2a:
    dec h

loc_4a2b:
    ld (player_y),hl
    bit 0,(ix+$05)
    jr z,loc_4a39
    ld a,$01
    ld (player_facing),a

loc_4a39:
    ld a,($e257)
    inc a
    ld ($e257),a
    and $07
    jr nz,loc_4a48
    ld hl,player_anim
    inc (hl)

loc_4a48:
    bit 2,(ix+$00)
    jr nz,loc_4a51

loc_4a4e:
    ifdef QOL
    call shared.brake_left
    else
    dec (ix+$01)
    endif

loc_4a51:
    ld a,(ix+$02)
    and a
    jp z,loc_4ae2
    call probe_right
    jp nz,loc_4add
    ld hl,(player_y)
    ld a,(ix+$01)
    and a
    jr z,loc_4a78
    dec (ix+$01)
    dec (ix+$02)
    ld hl,player_pose
    ld (hl),$03
    inc hl
    xor a
    ld (hl),a
    jp loc_4ae2

loc_4a78:
    ifdef QOL
    ld a,(ix+2)
    call shared.pixel_step
    jr c,loc_4a87
    ds $4a86 - $, 0
    else
    ld a,(ix+$02)
    cp $20
    jr nc,loc_4a86
    ld a,(frame_counter)
    and $01
    jr z,loc_4a87
    endif

loc_4a86:
    inc h

loc_4a87:
    bit 0,(ix+$05)
    jr z,loc_4a91
    xor a
    ld (player_facing),a

loc_4a91:
    ld a,(scroll_at_end)
    and a
    jr z,loc_4aa9
    ld a,h
    cp $f5
    jr c,loc_4ac0
    ld a,(round_index)
    cp $03
    jr nz,loc_4ac3
    push hl
    ld a,$fa
    jp loc_4d80

loc_4aa9:
    ld a,h
    cp $64
    jr c,loc_4ac0
    ld a,($e244)
    inc a
    ld ($e244),a
    and $07
    cp $07
    jr nz,loc_4ac3
    ld (scroll_request),a
    jr loc_4ac3

loc_4ac0:
    ld (player_y),hl

loc_4ac3:
    ld a,($e257)
    inc a
    ld ($e257),a
    and $07
    jr nz,loc_4ad2
    ld hl,player_anim
    inc (hl)

loc_4ad2:
    bit 3,(ix+$00)
    jr nz,loc_4ae2

loc_4ad8:
    ifdef QOL
    call shared.brake_right
    else
    dec (ix+$02)
    endif
    jr loc_4ae2

loc_4add:
    dec (ix+$02)
    jr nz,loc_4ad8

loc_4ae2:
    call apply_gravity
    jp apply_gravity

apply_gravity:
    call probe_floor
    jr z,loc_4b0e
    ld a,($e258)
    bit 4,a
    jr nz,loc_4afd
    ld a,$10
    ld ($e258),a
    ld (ix+$05),$01

loc_4afd:
    ifdef QOL
    call shared.grounded_pose
    nop
    nop
    else
    ld a,$02
    ld (player_pose),a
    endif
    ld a,(ix+$01)
    add a,(ix+$02)
    ret nz
    inc a
    ld (player_pose),a
    ret

loc_4b0e:
    ifdef QOL
    jp shared.fall_if_released
    ds $4b28 - $, 0
    else
    bit 1,(ix+$05)
    ret z
    dec (ix+$04)
    ld hl,player_y
    ld a,(ix+$04)
    and $01
    jr z,loc_4b21
    inc (hl)

loc_4b21:
    ld a,$d2
    cp (hl)
    ret nz
    jp hurt_player
    endif

probe_floor:
    ld hl,(player_y)
    inc h
    ld a,$08
    add a,l
    ld l,a
    call tile_at_pixel
    ld a,(hl)
    cp $3b
    jr z,loc_4b4d
    cp $3c
    jr z,loc_4b4d
    call coin_or_solid
    ret nz
    inc hl
    ld a,(hl)
    cp $3b
    jr z,loc_4b4d
    cp $3c
    jr z,loc_4b4d
    jp coin_or_solid

loc_4b4d:
    inc hl
    ld a,(hl)
    cp $3b
    jr z,loc_4b4d
    cp $3c
    jr z,loc_4b4d
    dec hl
    ld b,$00

loc_4b5a:
    dec hl
    inc b
    ld a,(hl)
    cp $3b
    jr z,loc_4b5a
    cp $3c
    jr z,loc_4b5a
    inc hl
    ld a,(hl)
    push hl
    ld c,b
    ld b,a
    push bc
    xor a
    ld b,c
    call fill_tile_run
    pop bc
    pop hl
    ld a,b
    ld b,$00
    cp $3c
    jr nc,loc_4b91
    inc a
    push hl
    push bc
    ld b,c
    call fill_tile_run
    pop bc
    pop hl
    ld a,$3d

loc_4b84:
    ld de,$0020
    add hl,de
    ld b,c
    call fill_tile_run
    call upload_playfield
    inc a
    ret

loc_4b91:
    ld a,$3b
    jr loc_4b84

fill_tile_run:
    ld (hl),a
    inc hl
    djnz fill_tile_run
    ret

loc_4b9a:
    xor a
    ld (hl),a
    push hl
    ld de,$0020
    add hl,de
    ld (hl),a
    call award_coin

loc_4ba5:
    xor a
    pop hl
    ret
    inc a  ; fall-through fragment, no known caller
    ret

loc_4baa:
    xor a
    ld (hl),a
    push hl
    ld de,$0020
    sbc hl,de
    ld (hl),a
    call award_coin
    pop hl
    jr loc_4ba5

award_coin:
    call upload_playfield
    call increment_score
    ld a,$07
    call shared.sound_effect
    ld a,(coins_bcd)
    add a,$01
    daa
    ld (coins_bcd),a
    ld b,a
    and $f0
    rrca
    rrca
    rrca
    rrca
    add a,$d8
    ld hl,$342d
    call vdp_write_byte
    inc hl
    ld a,b
    and $0f
    add a,$d8
    call vdp_write_byte
    ld a,b
    and a
    jp z,award_extra_life
    ret

increment_score:
    ld hl,(score_bcd)
    ld a,l
    add a,$01
    daa
    ld l,a
    cp $00
    jr nz,loc_4bfc
    ld a,h
    add a,$01
    daa
    ld h,a

loc_4bfc:
    ld (score_bcd),hl
    jp draw_score

probe_ceiling:
    ld a,($e24c)
    and a
    ret nz
    ld hl,(player_y)
    inc h
    dec l
    call tile_at_pixel
    ld a,(player_big)
    and a
    jr z,loc_4c1a
    ld de,$0040
    sbc hl,de

loc_4c1a:
    ld a,(hl)
    call check_head_tile
    ret nz
    inc hl
    ld a,(hl)
    jp check_head_tile

check_head_tile:
    cp $2a
    jr z,loc_4c37
    cp $2b
    jr z,loc_4c37
    cp $35
    jr z,loc_4c46
    cp $36
    jr z,loc_4c46
    jp coin_or_solid

loc_4c37:
    pop bc
    ld a,r
    ld b,a
    ld a,(frame_counter)
    add a,b
    and $0f
    jp nz,loc_4cd6
    jr loc_4c87

loc_4c46:
    pop bc
    call sub_5c53
    ld a,(player_big)
    and a
    ld a,$05
    jr z,loc_4c54
    ld a,$04

loc_4c54:
    call shared.sound_effect
    push de
    ld de,$e24c
    ld bc,$e252
    ld a,(de)
    and a
    jr nz,loc_4c84
    ld ($e087),hl
    ld a,(player_big)
    and a
    ld a,$10
    jr z,loc_4c6f
    ld a,$1f

loc_4c6f:
    ld (de),a
    ld (bc),a
    pop hl
    xor a
    ld (hl),a
    inc hl
    ld (hl),a
    ld bc,$0021
    sbc hl,bc
    ld (hl),a
    inc hl
    ld (hl),a
    call upload_playfield

loc_4c81:
    xor a
    inc a
    ret

loc_4c84:
    pop de
    jr loc_4c81

loc_4c87:
    ld a,(scroll_column)
    and a
    ld b,$01
    jp pe,loc_4c98
    ld b,$02
    cp $1e
    jr nz,loc_4c98
    ld b,$03

loc_4c98:
    ld a,($e251)
    and a
    jr nz,loc_4cd6
    ld a,b
    ld ($e251),a
    ld a,$06
    call shared.sound_effect
    call sub_5c77
    push hl
    ld a,l
    sub $10
    ld l,a
    ld ($e089),hl
    ld hl,$e04f
    ld (hl),$10
    inc hl
    ld (hl),$00
    inc hl
    ld a,(player_big)
    and a
    ld a,$00
    jr nz,loc_4cc5
    ld a,$02

loc_4cc5:
    ld (hl),a
    xor a
    inc hl
    ld (hl),a
    inc hl
    ld (hl),a
    inc hl
    ld (hl),a
    inc hl
    ld (hl),a
    pop hl
    call sub_4cf3
    jp upload_playfield

loc_4cd6:
    call sub_5c77
    ld bc,$e248
    ld a,(bc)
    and a
    ret nz
    ld a,$04
    add a,h
    ld h,a
    ld a,l
    sub $08
    ld l,a
    ld (sprite_attributes),hl
    ld a,$19
    ld (bc),a
    call sub_4cf3
    jp award_coin

sub_4cf3:
    ex de,hl
    ld a,$62
    ld (hl),a
    inc hl
    inc a
    ld (hl),a
    ld bc,$0021
    xor a
    ld a,$60
    sbc hl,bc
    ld (hl),a
    inc hl
    inc a
    ld (hl),a
    ret

probe_left:
    ld hl,(player_y)
    dec l
    dec h
    call tile_at_pixel
    ld a,(hl)
    call check_exit_tile
    call coin_or_solid
    ret nz

loc_4d17:
    ld de,$0020
    add hl,de
    ld a,(hl)
    call check_exit_tile
    call coin_or_solid
    ret nz
    ld a,(player_big)
    and a
    ret z
    ld de,$0040
    sbc hl,de
    ld a,(hl)
    call check_exit_tile
    call coin_or_solid
    ret nz
    ld de,$0020
    add hl,de
    ld a,(hl)
    call check_exit_tile
    jp coin_or_solid

probe_right:
    ld hl,(player_y)
    dec l
    ld a,$10
    add a,h
    ld h,a
    call tile_at_pixel
    ld a,(hl)
    call check_exit_tile
    call coin_or_solid
    ret nz
    jr loc_4d17

stage_init_table:
    dw init_stage_01, init_stage_02, init_stage_03, init_stage_04
    dw init_stage_05, init_stage_06, init_stage_07, init_stage_08
    dw init_stage_09, init_stage_10, init_stage_11, init_stage_12
    dw init_stage_13, init_stage_14, init_stage_15, init_stage_16

; Side probes call this before testing solidity. Exits discard both probe return addresses.
check_exit_tile:
    cp $15
    jr z,loc_4d80
    cp $17
    jr z,loc_4d80
    cp $a4
    ret nz

loc_4d80:
    pop hl
    pop hl
    push af
    xor a
    ld (actors_enabled),a
    call fade_music
    call hide_sprites
    pop af
    cp $a4
    jp z,enter_bonus_area
    jp nc,castle_exit

loc_4d96:
    call draw_player
    call increment_score
    ld a,$02
    call busy_wait
    ld hl,(player_y)
    ld a,$91
    cp l
    jr c,loc_4db9
    inc l
    ld a,l
    and $01
    ld (player_anim),a
    xor a
    ld (player_pose),a
    ld (player_y),hl
    jr loc_4d96

loc_4db9:
    xor a
    ld (player_facing),a
    call switch_sprite_bank
    ld a,(round_index)
    ld de,shared.stage_screen_b
    cp $02
    jr nz,loc_4dcd
    ld de,shared.stage_screen_a

loc_4dcd:
    ld b,$11
    ld hl,(player_y)
    ld a,$10
    add a,l
    ld l,a
    ld a,$08
    add a,h
    ld h,a
    ld (player_y),hl
    ld a,$02
    ld (player_pose),a

loc_4de2:
    push bc
    push de
    ld b,$01
    call load_screen_columns
    call upload_playfield
    ld hl,(player_y)
    dec h
    dec h
    ld (player_y),hl
    ld a,h
    rrca
    ld (player_anim),a
    call draw_player
    ld a,$09
    call busy_wait
    pop hl
    ld bc,$0016
    add hl,bc
    ex de,hl
    pop bc
    djnz loc_4de2
    ld a,$cd
    ld (player_y),a
    call draw_player
    xor a
    call busy_wait
    jp finish_stage

enter_bonus_area:
    call sub_4627
    ld de,sprite_attributes
    ld hl,bonus_sprite_attributes
    ld bc,$0010
    ldir
    ld a,$0b
    call shared.sound_effect
    ld b,$10

loc_4e2e:
    push bc
    ld hl,(player_y)
    inc h
    ld (player_y),hl
    ld a,h
    ld (player_anim),a
    call draw_player
    ld a,$07
    call busy_wait
    pop bc
    djnz loc_4e2e
    call hide_sprites
    ld hl,stage_layouts
    ld de,current_layout
    ld bc,$0110
    ldir
    ld hl,colours_1_1
    ld b,(hl)
    ld c,$07
    call vdp_write_register
    ld de,$3700
    ld bc,$0020
    call vdp_copy
    ld hl,$00d0
    ld (scroll_column),hl
    inc a
    ld (suppress_map_upload),a
    ld b,$2b

loc_4e71:
    push bc
    ld a,$01
    ld (scroll_request),a
    call scroll_one_column
    pop bc
    djnz loc_4e71
    xor a
    ld (suppress_map_upload),a
    ld (scroll_at_end),a
    inc a
    ld (scroll_request),a
    call scroll_one_column
    ld de,$0601
    call set_sprite_pair_colours
    ld hl,$4080
    ld (player_y),hl
    xor a
    call start_music
    di
    ld sp,$f300
    ei
    jp game_loop

castle_exit:
    ld hl,current_layout
    ld de,$e25c
    ld bc,$0028
    ld (hl),$ba
    ldir
    ld hl,$0000
    ld (scroll_column),hl
    ld (scroll_at_end),hl
    ld a,$02
    ld (player_pose),a
    ld a,$a0
    ld (player_y),a
    ld b,$20

loc_4ec5:
    push bc
    ld a,$07
    ld (scroll_request),a
    call busy_wait
    call scroll_one_column
    call draw_player
    ld hl,(player_y)
    dec h
    dec h
    dec h
    dec h
    dec h
    ld (player_y),hl
    ld de,player_pose
    ld a,$02
    ld (de),a
    inc de
    xor a
    ld (de),a
    ld a,h
    and $03
    inc de
    ld (de),a
    pop bc
    djnz loc_4ec5
    ld a,(world_index)
    cp $03
    ld hl,text_ending
    jr z,loc_4efd
    ld hl,text_castle

loc_4efd:
    ld de,$3528
    ld bc,$0010
    call vdp_copy
    xor a
    call busy_wait
    jp finish_stage

text_castle:
    abyte $a1 "SORRY"
    db $00, $00
    abyte $a1 "NOTHING"
    db $00, $00
text_ending:
    abyte $a1 "TO"
    db $00
    abyte $a1 "BE"
    db $00
    abyte $a1 "CONTINUED"
    db $00

award_extra_life:
    ld a,$09
    call shared.sound_effect
    ld a,(lives_bcd)
    add a,$01
    daa
    ld (lives_bcd),a
    xor a
    ret

animate_hit_block:
    ld a,($e24c)
    and a
    ret z
    ld ix,$e101
    ld hl,$e087
    ld bc,$e252
    cp $10
    jp z,loc_4fce
    ld a,(bc)
    ld e,(hl)
    inc hl
    ld d,(hl)
    dec hl
    cp $14
    jr nc,loc_4f7a
    cp $10
    jr nc,loc_4f76
    cp $0c
    jr nc,loc_4f73
    cp $07
    jr nc,loc_4f6a
    inc e
    inc e
    jr loc_4f81

loc_4f6a:
    inc e
    and a
    jp pe,loc_4f70
    inc e

loc_4f70:
    dec d
    jr loc_4f81

loc_4f73:
    dec d
    jr loc_4f81

loc_4f76:
    dec e
    dec d
    jr loc_4f81

loc_4f7a:
    dec e
    and a
    jp po,loc_4f80
    dec e

loc_4f80:
    dec d

loc_4f81:
    ld (hl),e
    inc hl
    ld (hl),d
    dec hl
    push de
    exx
    pop de
    ld b,a
    ld a,$1f
    sub b
    rlca
    ld c,a
    ld (ix+$00),e
    ld a,e
    sub c
    ld (ix+$04),a
    ld a,d
    add a,c
    ld e,a
    ld l,d
    ld a,(frame_counter)
    and $01
    jr z,loc_4fa2
    ex de,hl

loc_4fa2:
    ld a,d
    cp $fa
    jr nc,loc_4faf
    ld (ix+$01),e
    ld (ix+$05),e
    jr loc_4fb7

loc_4faf:
    ld (ix+$00),$dc
    ld (ix+$04),$dc

loc_4fb7:
    exx
    ld a,(bc)
    dec a
    jr z,loc_4fc1
    ld (bc),a
    ld a,(hl)
    cp $cc
    ret nz

loc_4fc1:
    ld a,$dc
    ld (ix+$00),a
    ld (ix+$04),a
    xor a
    ld ($e24c),a
    ret

loc_4fce:
    ld a,(bc)
    cp $08
    jr c,loc_4fd6
    dec (hl)
    jr loc_4fd7

loc_4fd6:
    inc (hl)

loc_4fd7:
    ex af,af'
    ld a,(hl)
    ld (ix+$00),a
    ld (ix+$04),a
    inc hl
    ld a,(hl)
    dec hl
    ld (ix+$01),a
    ld (ix+$05),a
    ex af,af'
    dec a
    ld (bc),a
    and a
    ret nz
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    call tile_at_pixel
    ld a,$35
    ld (hl),a
    inc a
    inc hl
    ld (hl),a
    ld de,$0020
    add hl,de
    ld (hl),a
    dec hl
    dec a
    ld (hl),a
    push bc
    call upload_playfield
    pop bc
    ld a,$cd
    ld (ix+$00),a
    ld (ix+$04),a
    xor a
    ld ($e24c),a
    ret

sub_5014:
    ld a,($e248)
    and a
    ret z
    ld hl,sprite_attributes
    dec (hl)
    dec (hl)
    dec a
    and a
    ld ($e248),a
    ret nz
    ld a,$dc
    ld (hl),a
    ret
    db $01, $00, $02, $00, $00, $00, $00  ; $5028

loc_502f:
    ex de,hl
    inc (hl)
    inc (hl)
    inc (hl)
    inc (hl)
    ld a,(hl)
    cp $c8
    jp c,loc_5147
    ld (hl),$dc
    xor a
    dec de
    ld (de),a
    jp loc_5147

update_actors_irq:
    ld a,($e080)
    and a
    jp z,loc_50fe
    ld de,$e097
    ld hl,$e080
    ld a,(hl)
    cp $0b
    jr z,loc_50cb
    inc hl
    inc hl
    bit 0,(hl)
    ex de,hl
    ld a,$08
    jr z,loc_505f
    ld a,$f8

loc_505f:
    inc hl
    add a,(hl)
    ld (hl),a
    dec hl
    cp $f3
    jp c,loc_5072

loc_5068:
    ld (hl),$dc
    xor a
    ex de,hl
    dec hl
    dec hl
    ld (hl),a
    jp loc_50d8

loc_5072:
    ex de,hl
    inc hl
    bit 0,(hl)
    ex de,hl
    ld a,$04
    jr z,loc_507d
    ld a,$fc

loc_507d:
    add a,(hl)
    ld (hl),a
    cp $c3
    jr nc,loc_5068
    ex de,hl
    ld a,(hl)
    inc hl
    cp $02
    jr z,loc_508f
    dec (hl)
    jr nz,loc_50af
    jr loc_509e

loc_508f:
    exx
    ld hl,($e0ba)
    call tile_at_pixel
    ld a,(hl)
    call is_solid_tile
    exx
    ex de,hl
    jr z,loc_50af

loc_509e:
    ld d,h
    ld e,l
    inc hl
    inc hl
    ld a,(hl)
    ld (de),a
    ex de,hl
    dec hl
    bit 0,(hl)
    ld a,$02
    jr nz,loc_50ae
    ld a,$01

loc_50ae:
    ld (hl),a

loc_50af:
    cp $02
    jr z,loc_50d8
    ld hl,($e097)
    call tile_at_pixel
    ld a,(hl)
    call is_solid_tile
    jr z,loc_50d8
    ld a,$0b
    ld ($e080),a
    ld a,$08
    ld ($e084),a
    jr loc_50d8

loc_50cb:
    ld hl,$e084
    dec (hl)
    jr nz,loc_50d8
    xor a
    ld ($e080),a
    ld a,$dc
    ld (de),a

loc_50d8:
    ld hl,($e097)
    ld de,$e111
    ex de,hl
    ld (hl),e
    inc hl
    ld (hl),d
    inc hl
    inc hl
    inc hl
    ld (hl),e
    inc hl
    ld (hl),d
    ld a,($e080)
    cp $0b
    ld a,$d8
    jr z,loc_50f3
    ld a,$d0

loc_50f3:
    ld de,$e113
    ld (de),a
    add a,$04
    inc de
    inc de
    inc de
    inc de
    ld (de),a

loc_50fe:
    ld a,(round_index)
    cp $03
    jp z,loc_52d4
    ld hl,$e04f
    ld a,(hl)
    and a
    jr z,loc_511c
    ld a,(player_big)
    and a
    jp z,loc_511c
    ld a,(frame_counter)
    and $0f
    ld ($e0c0),a

loc_511c:
    ld de,$e089
    ld b,$07

loc_5121:
    push bc
    push de
    push hl
    inc (hl)
    dec (hl)
    jr z,loc_5147
    inc hl
    ld a,(hl)
    cp $02
    jp z,loc_5227
    cp $01
    jp z,loc_5216
    cp $05
    jp z,loc_502f
    inc hl
    ld a,(hl)
    and a
    push hl
    call nz,sub_5236
    pop hl
    inc hl
    ld a,(hl)
    and a
    call nz,sub_52a2

loc_5147:
    pop hl
    ld de,$0007
    add hl,de
    pop de
    pop bc
    inc de
    inc de
    djnz loc_5121
    ld hl,$e089
    ld de,$e0b9
    ld b,$05

loc_515a:
    call sub_5205
    inc de
    ex de,hl
    djnz loc_515a
    ld hl,$e093
    ld de,$e0e1
    ld b,$02

loc_5169:
    ld a,(hl)
    sub $10
    call sub_5206
    add a,$10
    call sub_5209
    inc de
    ex de,hl
    djnz loc_5169
    ld de,$e0c3
    ld hl,$e056
    ld b,$04

loc_5180:
    dec (hl)
    inc (hl)
    jp z,loc_51af
    push hl
    inc hl
    ld a,(hl)
    and a
    jr nz,loc_51a3
    inc hl
    ld a,(hl)
    cp $01
    ld c,$1a
    jr nz,loc_5195
    ld c,$1c

loc_5195:
    ld a,c
    rlca
    rlca
    ld (de),a
    push de
    inc de
    inc de
    inc de
    inc de
    add a,$04
    ld (de),a
    jr loc_51ad

loc_51a3:
    ld c,$1e
    cp $05
    jr nz,loc_5195
    ld c,$20
    jr loc_5195

loc_51ad:
    pop de
    pop hl

loc_51af:
    push bc
    ld bc,$0007
    add hl,bc
    ex de,hl
    ld bc,$0008
    add hl,bc
    ex de,hl
    pop bc
    djnz loc_5180
    ld de,$e0e3
    ld hl,$e072
    ld b,$02

loc_51c5:
    dec (hl)
    inc (hl)
    jp z,loc_51f6
    push hl
    inc hl
    ld a,(hl)
    and a
    jr nz,loc_51f0
    inc hl
    ld a,(hl)
    cp $01
    ld c,$22
    jr nz,loc_51da
    ld c,$26

loc_51da:
    ld a,c
    rlca
    rlca
    ld (de),a
    push de
    push bc
    ld bc,$0004
    ex de,hl
    add hl,bc
    add a,c
    ld (hl),a
    add hl,bc
    add a,c
    ld (hl),a
    add hl,bc
    add a,c
    ld (hl),a
    pop bc
    jr loc_51f4

loc_51f0:
    ld c,$2e
    jr loc_51da

loc_51f4:
    pop de
    pop hl

loc_51f6:
    push bc
    ld bc,$0007
    add hl,bc
    ex de,hl
    ld bc,$0010
    add hl,bc
    ex de,hl
    pop bc
    djnz loc_51c5
    ret

sub_5205:
    ld a,(hl)

sub_5206:
    inc hl
    ld c,(hl)
    ex de,hl

sub_5209:
    ld (hl),a
    inc hl
    ld (hl),c
    inc hl
    inc hl
    inc hl
    ld (hl),a
    inc hl
    ld (hl),c
    inc hl
    inc hl
    inc hl
    ret

loc_5216:
    inc hl
    inc hl
    inc hl
    dec (hl)
    jp nz,loc_5147
    ld a,$d2
    ld (de),a
    pop hl
    push hl
    ld (hl),$00
    jp loc_5147

loc_5227:
    inc hl
    inc hl
    inc hl
    dec (hl)
    jp nz,loc_5147
    dec hl
    dec hl
    dec hl
    ld (hl),$00
    jp loc_5147

sub_5236:
    ex de,hl
    bit 0,a
    jr nz,loc_5254
    inc hl
    inc (hl)
    ld a,(hl)
    dec hl
    ld l,(hl)
    ld b,$10
    add a,b
    ld h,a
    push de
    call tile_at_pixel
    ld a,(hl)
    call is_solid_tile
    pop de
    jr z,loc_5268
    ld a,$01
    ld (de),a
    jr loc_5268

loc_5254:
    inc hl
    dec (hl)
    ld b,(hl)
    dec hl
    ld l,(hl)
    ld h,b
    push de
    call tile_at_pixel
    ld a,(hl)
    call is_solid_tile
    pop de
    jr z,loc_5268
    ld a,$02
    ld (de),a

loc_5268:
    inc de
    ld a,(de)
    and a
    ret nz
    ld bc,$0020
    add hl,bc
    ld a,(hl)
    push de
    call is_solid_tile
    pop hl
    ret nz
    inc hl
    inc hl
    dec (hl)
    inc (hl)
    jr nz,loc_5294
    pop bc
    pop hl
    pop de
    pop hl
    push hl
    push de
    inc (hl)
    inc (hl)
    ld c,(hl)
    ld a,$c0
    cp c
    jp nc,loc_5147
    ld (hl),$dc
    ex de,hl
    ld (hl),$00
    jp loc_5147

loc_5294:
    dec hl
    dec hl
    dec hl
    ld a,(hl)
    cp $01
    ld a,$02
    jr z,loc_52a0
    ld a,$01

loc_52a0:
    ld (hl),a
    ret

sub_52a2:
    pop bc
    pop de
    pop hl
    push hl
    push de
    push bc
    cp $01
    jr nz,loc_52c0
    dec (hl)
    dec (hl)
    ex de,hl
    inc hl
    inc hl
    inc hl
    inc hl
    dec (hl)
    ret nz
    ld d,h
    ld e,l
    inc hl
    inc hl
    ld a,(hl)
    ex de,hl
    ld (hl),a
    dec hl
    ld (hl),$02
    ret

loc_52c0:
    inc (hl)
    inc (hl)
    ex de,hl
    inc hl
    inc hl
    inc hl
    inc hl
    dec (hl)
    ret nz
    ld d,h
    ld e,l
    inc hl
    inc hl
    ld a,(hl)
    ex de,hl
    ld (hl),a
    dec hl
    ld (hl),$01
    ret

loc_52d4:
    ld hl,$e04f
    ld de,$e089
    ld b,$07

loc_52dc:
    push de
    push hl
    ld a,(hl)
    and a
    jr z,loc_5317
    ld c,a
    inc hl
    inc hl
    inc hl
    ld a,(hl)
    cp $01
    jr nz,loc_530c
    ex de,hl
    dec (hl)
    dec (hl)
    ld a,c
    cp $09
    jr z,loc_52f4
    dec (hl)

loc_52f4:
    ex de,hl
    inc hl
    dec (hl)
    jr nz,loc_5317
    ld d,h
    ld e,l
    inc hl
    inc hl
    ld a,(hl)
    ex de,hl
    ld (hl),a
    dec hl
    ld a,$02
    bit 0,(hl)
    jr nz,loc_5309
    ld a,$01

loc_5309:
    ld (hl),a
    jr loc_5317

loc_530c:
    ex de,hl
    inc (hl)
    inc (hl)
    ld a,c
    cp $09
    jr z,loc_52f4
    inc (hl)
    jr loc_52f4

loc_5317:
    pop hl
    ld de,$0007
    add hl,de
    pop de
    inc de
    inc de
    djnz loc_52dc
    ld hl,$e089
    ld de,$e0b9
    ld b,$05

loc_5329:
    ld a,(hl)
    inc hl
    ld c,(hl)
    ex de,hl
    ld (hl),a
    inc hl
    ld (hl),c
    inc hl
    inc hl
    inc hl
    ld (hl),a
    inc hl
    ld (hl),c
    inc hl
    inc hl
    inc hl
    inc de
    ex de,hl
    djnz loc_5329
    ld a,($e072)
    and a
    jp z,loc_53a6
    ld de,$e093
    inc de
    ld a,(de)
    dec de
    ld b,a
    ld a,(player_x)
    cp b
    ld a,$02
    ld c,$01
    jr nc,loc_535b
    jr z,loc_5365
    ld a,$01
    ld c,$ff

loc_535b:
    ld ($e074),a
    ld a,($e094)
    add a,c
    ld ($e094),a

loc_5365:
    ld bc,$0003
    ld hl,$e0e1
    ld a,(de)
    ex af,af'
    inc de
    ld a,(de)
    ld d,a
    ex af,af'
    ld e,a
    call sub_53dc
    ld a,($e074)
    cp $02
    jr z,loc_5381
    ld a,$10
    add a,d
    jr loc_5384

loc_5381:
    ld a,d
    sub $10

loc_5384:
    ld d,a
    ld a,e
    sub $08
    ld e,a
    call sub_53dc
    ld a,($e074)
    ld hl,$e0e3
    cp $01
    ld a,$22
    jr nz,loc_539a
    ld a,$2a

loc_539a:
    add a,a
    add a,a
    ld de,$0004
    ld b,$08

loc_53a1:
    ld (hl),a
    add hl,de
    add a,e
    djnz loc_53a1

loc_53a6:
    ld de,$e0c3
    ld hl,$e056
    ld b,$04

loc_53ae:
    dec (hl)
    inc (hl)
    jp z,loc_53cd
    push hl
    inc hl
    inc hl
    inc hl
    bit 0,(hl)
    ld c,$1a
    jr nz,loc_53bf
    ld c,$20

loc_53bf:
    ld a,c
    rlca
    rlca
    ld (de),a
    push de
    inc de
    inc de
    inc de
    inc de
    add a,$04
    ld (de),a
    pop de
    pop hl

loc_53cd:
    push bc
    ld bc,$0007
    add hl,bc
    ex de,hl
    ld bc,$0008
    add hl,bc
    ex de,hl
    pop bc
    djnz loc_53ae
    ret

sub_53dc:
    call sub_53e7
    ld a,$10
    add a,e
    ld e,a
    call sub_53e7
    ret

sub_53e7:
    ld (hl),e
    inc hl
    ld (hl),d
    add hl,bc
    ld (hl),e
    inc hl
    ld (hl),d
    add hl,bc
    ret

check_actor_pairs:
    ld a,$07
    ld ix,$e097
    ld hl,$e080

loc_53f9:
    push af
    di
    dec (hl)
    inc (hl)
    ei
    jp z,loc_549c
    ld d,h
    ld e,l
    push ix
    pop iy
    dec iy
    dec iy
    and a
    ld bc,$0007
    sbc hl,bc
    ex de,hl
    dec a

loc_5413:
    push af
    ld a,(de)
    and a
    jp z,loc_548b
    ld a,(ix+$01)
    sub (iy+$01)
    jr nc,loc_5423
    neg

loc_5423:
    cp $10
    jp nc,loc_548b
    ld a,(ix+$00)
    sub (iy+$00)
    jr nc,loc_5432
    neg

loc_5432:
    cp $10
    jp nc,loc_548b
    ld a,(hl)
    cp $0a
    jr nz,loc_546a
    ld a,(de)
    cp $03
    jr z,loc_5458
    cp $08
    jr z,loc_5458
    cp $09
    jr z,loc_5458
    push de
    inc de
    ld a,$05
    ld (de),a
    ld a,$20
    inc de
    inc de
    inc de
    ld (de),a
    inc de
    inc de
    ld (de),a
    pop de

loc_5458:
    ld a,$0a
    call shared.sound_effect
    push hl
    ld (hl),$0b
    inc hl
    inc hl
    inc hl
    inc hl
    ld (hl),$08
    pop hl
    jp loc_548b

loc_546a:
    inc hl
    inc hl
    ld a,(hl)
    cp $01
    jr c,loc_5478
    ld a,$01
    jr nz,loc_5477
    ld a,$02

loc_5477:
    ld (hl),a

loc_5478:
    dec hl
    dec hl
    inc de
    inc de
    ld a,(de)
    and a
    jr z,loc_5489
    cp $01
    ld a,$01
    jr nz,loc_5488
    ld a,$02

loc_5488:
    ld (de),a

loc_5489:
    dec de
    dec de

loc_548b:
    dec iy
    dec iy
    ex de,hl
    and a
    ld bc,$0007
    sbc hl,bc
    ex de,hl
    pop af
    dec a
    jp nz,loc_5413

loc_549c:
    dec ix
    dec ix
    ld bc,$0007
    and a
    sbc hl,bc
    pop af
    dec a
    cp $01
    jp nz,loc_53f9
    ret

loc_54ae:
    ld (hl),$dc
    ld (ix+$00),$00
    jp loc_5537

check_player_actor_collisions:
    ld a,(round_index)
    cp $03
    jr nz,loc_54e6
    ld de,$e072
    ld a,(de)
    and a
    jr z,loc_54e6
    ld hl,$e093
    ld a,(player_y)
    ld b,a
    ld a,(hl)
    add a,$14
    sub b
    jr nc,loc_54d4
    neg

loc_54d4:
    cp $14
    ret nc
    inc hl
    ld a,(player_x)
    sub (hl)
    jr nc,loc_54e0
    neg

loc_54e0:
    cp $0d
    ret nc
    jp hurt_player

loc_54e6:
    ld hl,$e089
    ld ix,$e04f
    ld b,$07

loc_54ef:
    ld a,(ix+$00)
    and a
    jr z,loc_5537
    ld a,(ix+$01)
    cp $01
    jr z,loc_5537
    cp $05
    jr z,loc_5537
    ld a,(player_x)
    ld d,a
    inc hl
    ld a,(hl)
    dec hl
    cp $fe
    jr nc,loc_54ae
    cp $07
    jr c,loc_54ae
    ld e,$00
    sub d
    jr nc,loc_5518
    ld e,$01
    neg

loc_5518:
    cp $0f
    jr nc,loc_5537
    ld a,(player_y)
    ld d,a
    sub (hl)
    jr nc,loc_5525
    neg

loc_5525:
    cp $0d
    jr c,loc_5548
    ld a,d
    add a,$0d
    cp (hl)
    jr z,loc_5574
    inc a
    cp (hl)
    jr z,loc_5574
    inc a
    cp (hl)
    jr z,loc_5574

loc_5537:
    inc hl
    inc hl
    push hl
    push ix
    pop hl
    ld de,$0007
    add hl,de
    push hl
    pop ix
    pop hl
    djnz loc_54ef
    ret

loc_5548:
    ld a,($e377)
    and a
    jr z,loc_5565

loc_554e:
    ld (ix+$01),$05
    ld a,$0a
    call shared.sound_effect
    ld a,$dc
    ld (sprite_attributes),a
    ld a,(hl)
    sub $08
    ld (hl),a
    and $7f
    ld c,a
    jr loc_559a

loc_5565:
    ld a,(ix+$00)
    cp $10
    jp z,loc_55b2
    ld (ix+$01),$05
    jp hurt_player

loc_5574:
    ld a,(ix+$00)
    cp $10
    jr z,loc_55b2
    cp $01
    jr z,loc_5596
    cp $04
    jr z,loc_5548
    cp $08
    jr c,loc_554e
    jp z,hurt_player
    cp $09
    jp z,hurt_player
    ld (ix+$00),$00
    jp hurt_player

loc_5596:
    ld (ix+$01),$01

loc_559a:
    ld ($e386),a
    ld a,$28
    ld ($e387),a
    ld a,(motion_flags)
    res 1,a
    ld (motion_flags),a
    ld a,$03
    call shared.sound_effect
    jp loc_5537

loc_55b2:
    ld a,$00
    ld (ix+$00),a
    ld (hl),$dc
    ld a,(player_big)
    and a
    jr z,loc_55c2
    ld (player_can_shoot),a

loc_55c2:
    ld a,$10
    ld (player_big),a
    call sub_55cd
    jp loc_5537

sub_55cd:
    ld a,($e103)
    ld ($e107),a
    ld a,($e104)
    ld ($e108),a
    ld a,$02
    ld ($e0bc),a
    ret

; Three-byte records in RAM. $ff ends; $01 dispatches a repeating generator.
spawn_for_column:
    ld de,spawn_list
    ld a,(spawn_index)
    ld b,a
    add a,a
    add a,b
    add a,e
    ld e,a
    ld a,$00
    adc a,d
    ld d,a
    ld a,(de)
    cp $ff
    ret z
    cp $01
    jp z,loc_569a
    ld c,a
    ld a,(scroll_column)
    cp c
    ret nz
    ld a,b
    inc a
    ld (spawn_index),a
    inc de
    inc de
    ld a,(de)
    cp $08
    jr z,loc_560d
    cp $05
    jr nc,loc_5618

loc_560d:
    ld hl,$e056
    ld ix,$e08b
    ld b,$04
    jr loc_5621

loc_5618:
    ld ix,$e093
    ld hl,$e072
    ld b,$02

loc_5621:
    inc (hl)
    dec (hl)
    jr nz,loc_5647
    dec de
    ld b,a
    ld a,(de)
    di
    ld (ix+$00),a
    ld (ix+$01),$f0
    ld a,b
    add a,a
    ld c,a
    add a,a
    add a,c
    add a,b
    ex de,hl
    ld hl,object_defaults_01 - 7
    add a,l
    ld l,a
    ld a,$00
    adc a,h
    ld h,a
    ld bc,$0007
    ldir
    ei
    ret

loc_5647:
    push bc
    ld bc,$0007
    add hl,bc
    inc ix
    inc ix
    pop bc
    djnz loc_5621
    ret

; Seven-byte initial state copied into an actor slot when spawned.
object_defaults_01:
    db $01, $00, $01, $00, $14, $00, $14
object_defaults_02:
    db $02, $00, $02, $01, $50, $00, $50
object_defaults_03:
    db $03, $00, $01, $00, $1e, $00, $1e
object_defaults_04:
    db $04, $00, $01, $00, $1e, $00, $1e
object_defaults_05:
    db $05, $00, $01, $00, $14, $01, $14
object_defaults_06:
    db $06, $00, $01, $01, $1e, $00, $1e
object_defaults_07:
    db $07, $00, $01, $01, $01, $00, $01
object_defaults_08:
    db $08, $00, $00, $01, $24, $00, $24
object_defaults_09:
    db $09, $00, $00, $01, $10, $00, $10
object_defaults_10:
    db $04, $00, $02, $00, $1e, $00, $1e

loc_569a:
    ld a,(scroll_column)
    cp $28
    ret c
    cp $f0
    ret nc
    inc de
    inc de
    ld a,(de)
    cp $0a
    jr z,loc_56fd
    cp $0b
    jr z,loc_5717
    ld a,($e001)
    inc a
    ld ($e001),a
    and $07
    ret nz
    ld de,object_defaults_07
    ld b,$01
    ld a,$11
    ld c,$f0
    call sub_56d8
    ld a,($e094)
    ld c,a
    ld de,object_defaults_10
    ld a,$31

loc_56cd:
    ld hl,$e056
    ld ix,$e08b
    ld b,$04
    jr loc_56df

sub_56d8:
    ld ix,$e093
    ld hl,$e072

loc_56df:
    inc (hl)
    dec (hl)
    jr nz,loc_56f0
    ld (ix+$00),a
    ld (ix+$01),c
    ld bc,$0007
    ex de,hl
    ldir
    ret

loc_56f0:
    push bc
    ld bc,$0007
    add hl,bc
    inc ix
    inc ix
    pop bc
    djnz loc_56df
    ret

loc_56fd:
    ld a,($e001)
    inc a
    ld ($e001),a
    and $03
    ret nz
    ld de,object_defaults_02
    ld a,r
    ld c,a
    ld a,(frame_counter)
    add a,c
    rlca
    ld c,a
    ld a,$b4
    jr loc_56cd

loc_5717:
    call loc_56fd
    ld de,object_defaults_06
    ld a,$60
    ld c,$f5
    ld b,$01
    jp sub_56d8
    ret  ; $5726

coin_or_solid:
    cp $98
    jp z,loc_4b9a
    cp $99
    jp z,loc_4baa

; Returns NZ for a blocking tile, Z for the low/high ranges or a table match.
is_solid_tile:
    cp $d8
    push hl
    jr nc,loc_5749
    cp $12
    jr c,loc_5749
    ld hl,passable_tiles
    ld b,$29

loc_573f:
    cp (hl)
    jr z,loc_5747
    inc hl
    djnz loc_573f
    xor a
    inc a

loc_5747:
    pop hl
    ret

loc_5749:
    sub a
    jr loc_5747

passable_tiles:
    db $18, $19, $1a, $1b, $1c, $1d, $1e, $1f, $20, $34, $37, $57, $5b, $74, $75, $76  ; $574c
    db $77, $78, $79, $7a, $7b, $81, $82, $83, $94, $95, $a8, $a9, $aa, $ab, $b0, $b1  ; $575c
    db $b2, $b4, $b5, $b8, $c0, $c1, $c2, $d1, $16  ; $576c

tick_stage_clock:
    ld a,(frame_counter)
    inc a
    ld (frame_counter),a
    ld b,a
    and $07
    cp $07
    jp z,switch_sprite_bank
    ld a,b
    cp $20
    ret nz
    ld a,($e384)
    ld ($fa25),a
    ld ($fa45),a
    ld ($fa65),a
    xor a
    ld (frame_counter),a
    ld (timer_drawn),a
    ld hl,(timer_bcd)
    ld a,l
    sub $01
    daa
    ld l,a
    cp $99
    jr nz,loc_57ac
    ld a,h
    sub $01
    daa
    ld h,a

loc_57ac:
    ld (timer_bcd),hl
    ld a,h
    and a
    jp z,loc_5943
    ret

hurt_player:
    ld a,(demo_active)
    and a
    jp nz,exit_demo
    ld a,(player_big)
    and a
    jp z,death_animation
    ld a,$01
    ld ($e107),a
    ld ($e108),a
    ld a,$08
    ld ($e0bb),a
    ld a,$dc
    ld ($e0b1),a
    ld ($e0b5),a
    xor a
    ld (player_big),a
    ld (player_can_shoot),a
    ld a,$0b
    call shared.sound_effect
    call switch_sprite_bank
    jp draw_player

death_animation:
    ld hl,$0005
    ld (player_pose),hl
    ld a,$0b
    call shared.sound_effect
    ld a,$0a
    call busy_wait

loc_57fa:
    ld a,$02
    call busy_wait
    call draw_player
    ld a,(player_y)
    inc a
    ld (player_y),a
    cp $d2
    jr c,loc_57fa

lose_life:
    call hide_sprites
    call upload_other_sprites
    ld a,(lives_bcd)
    dec a
    jp z,game_over
    ld (lives_bcd),a
    ld a,$80
    call busy_wait
    jp loc_5d44

sub_5825:
    inc hl
    ld a,(bc)
    ld c,a
    rlca
    add a,c
    add a,(hl)
    ld (hl),a
    inc hl
    ld a,(de)
    ld c,a
    rlca
    add a,c
    add a,(hl)
    ld (hl),a
    ret
    db $0a, $0e, $0f, $0f, $0b, $06, $00, $fa, $f4, $f1, $f0, $f1, $f4, $fa, $00, $06  ; $5834
    db $0a, $0e, $0f, $0f  ; $5844

draw_score:
    ld hl,(score_bcd)
    call format_bcd_tiles
    ld hl,$e22a
    ld de,$3423
    ld bc,$0006
    jp vdp_copy

format_bcd_tiles:
    ld de,$e22a
    ld a,h
    and $f0
    rrca
    rrca
    rrca
    rrca
    add a,$d8
    ld (de),a
    ld a,h
    and $0f
    add a,$d8
    inc de
    ld (de),a
    ld a,l
    and $f0
    rrca
    rrca
    rrca
    rrca
    add a,$d8
    inc de
    ld (de),a
    ld a,l
    and $0f
    add a,$d8
    inc de
    ld (de),a
    ret

draw_coins:
    ld a,(coins_bcd)
    ld b,a
    and $f0
    rrca
    rrca
    rrca
    rrca
    add a,$d8
    ld hl,$342d
    call vdp_write_byte
    ld a,b
    and $0f
    add a,$d8
    inc hl
    jp vdp_write_byte

draw_timer:
    ld a,(timer_drawn)
    and a
    ret nz
    cpl
    ld (timer_drawn),a
    ld hl,(timer_bcd)
    call format_bcd_tiles
    ld hl,$e22b
    ld de,$343b
    ld bc,$0003
    jp vdp_copy

; Only run on request. Shift the 32 x 22 playfield and decode the next column.
scroll_one_column:
    ld a,(scroll_request)
    and a
    ret z
    ld hl,$e088
    ld b,$0a

loc_58c1:
    ld a,(hl)
    sub $08
    ld (hl),a
    inc hl
    inc hl
    djnz loc_58c1
    xor a
    ld (scroll_request),a
    ld de,current_layout
    ld hl,(scroll_column)
    inc hl
    ld a,h
    cp $01
    jr nz,loc_58e2
    ld a,$10
    cp l
    jr nz,loc_58e2
    ld (scroll_at_end),a
    ret

loc_58e2:
    ld (scroll_column),hl
    push de
    ld hl,$e840
    ld d,h
    ld e,l
    dec de
    ld bc,$02c0
    ldir
    ld hl,(scroll_column)
    pop de
    add hl,de
    ld a,(hl)
    ld l,a
    ld h,$00
    add hl,hl
    ld b,h
    ld c,l
    add hl,hl
    ld d,h
    ld e,l
    add hl,hl
    add hl,hl
    add hl,de
    add hl,bc
    ld de,map_columns
    add hl,de
    ex de,hl
    ld hl,$e85e
    call unpack_column
    ld a,(suppress_map_upload)
    and a
    ret nz
    call upload_playfield
    jp spawn_for_column

unpack_column:
    ld b,$16

loc_591c:
    ld a,(de)
    ld (hl),a
    ld a,$20
    add a,l
    ld l,a
    ld a,$00
    adc a,h
    ld h,a
    inc de
    djnz loc_591c
    ret

load_screen_columns:
    push bc
    ld hl,$e85f
    call unpack_column
    push de
    ld hl,$e840
    ld d,h
    ld e,l
    dec de
    ld bc,$02c0
    ldir
    pop de
    pop bc
    djnz load_screen_columns
    ret
    ret  ; $5942

loc_5943:
    ld a,l
    and a
    jp z,time_over
    ld a,($e384)
    dec a
    cp $48
    ret c
    ld ($e384),a
    ret

jump_steps:
    ifdef QOL
    ; A held jump rises quickly, then tapers to its apex. Release cuts the rise.
    db 3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2
    db 2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1
    db 1,1,1,1,1,1,1,1,1,0,1,0,1,0,1,0
    db 1,0,1,0,1,0,1,0,0,0,0,0,0,0,0,0
    ds 8, 0
    else
    db $03, $02, $03, $02, $03, $02, $02, $02, $03, $02, $02, $02, $01, $02, $01, $02  ; $5953
    db $01, $02, $01, $01, $02, $01, $01, $02, $01, $01, $01, $02, $01, $01, $00, $01  ; $5963
    db $01, $01, $01, $01, $00, $01, $01, $01, $01, $00, $01, $01, $01, $00, $01, $01  ; $5973
    db $00, $00, $00, $01, $00, $01, $00, $00, $01, $00, $00, $01, $00, $00, $00, $01  ; $5983
    db $00, $00, $00, $00, $ff, $00, $00, $ff  ; $5993
    endif

sub_599b:
    ld hl,$e3ff
    ld d,h
    ld e,l
    inc de
    xor a
    ld (hl),a
    ld bc,$0200
    ldir
    ld de,$e4ff
    call sub_5a09
    call sub_5a17
    call sub_5a12
    call sub_5a17
    call sub_5a09
    call sub_5a09
    call sub_5a17
    call sub_5a09
    call sub_5a17
    call sub_5a12
    call sub_5a12
    call sub_5a17
    call sub_5a17
    call sub_5a12
    call sub_5a12
    call sub_5a1f
    call sub_5a17
    call sub_5a24
    call sub_5a17
    call sub_5a1f
    call sub_5a12
    call sub_5a24
    call sub_5a17
    call sub_5a12
    call sub_5a12
    call sub_5a17
    call sub_5a17
    call sub_5a12
    call sub_5a09
    call sub_5a17
    call sub_5a09
    ret

sub_5a09:
    ld bc,$0004

loc_5a0c:
    ld hl,$e3ff

loc_5a0f:
    ldir
    ret

sub_5a12:
    ld bc,$0008
    jr loc_5a0c

sub_5a17:
    ld hl,blank_pattern_1

loc_5a1a:
    ld bc,$0008
    jr loc_5a0f

sub_5a1f:
    ld hl,blank_pattern_2
    jr loc_5a1a

sub_5a24:
    ld hl,blank_pattern_3
    jr loc_5a1a

text_game_over_wide:
    abyte $a1 "GAME"
    db $00, $00
    abyte $a1 "OVER"
text_copyright:
    db $fc, $00
    abyte $a8 "1989"
    db $00
    abyte $a1 "ZEMINA"
text_push_space:
    ifdef QOL
    abyte $a1 "PRESS"
    db $00
    abyte $a8 "1"
    ds 3, 0
    else
    abyte $a1 "PUSH"
    db $00
    abyte $a1 "SPACE"
    endif
blank_pattern_1:
    db $00, $00, $00, $00, $00, $00, $00, $00
blank_pattern_2:
    db $00, $00, $00, $00, $00, $00, $00, $00
blank_pattern_3:
    db $00, $00, $00, $00, $00, $00, $00, $00
text_score:
    abyte $a1 "SCORE"
text_coin:
    abyte $a1 "COIN"
text_world:
    abyte $a1 "WORLD"
text_time:
    abyte $a1 "TIME"

draw_hud:
    call draw_score
    call draw_coins
    ld hl,text_score
    ld de,$3403
    ld bc,$0005
    call vdp_copy
    ld hl,text_coin
    ld de,$340c
    ld bc,$0004
    call vdp_copy
    ld hl,text_world
    ld de,$3413
    ld bc,$0005
    call vdp_copy
    ld hl,text_time
    ld de,$341a
    ld bc,$0004
    jp vdp_copy

switch_sprite_bank:
    ld c,$06
    ld a,($e374)
    cpl
    ld ($e374),a
    and $01
    ld b,a
    ld a,(player_big)
    and a
    jr nz,loc_5ac2
    xor a
    add a,b
    ld b,a
    jp vdp_write_register

loc_5ac2:
    ld a,(player_facing)
    and a
    jr z,loc_5acf
    ld a,$02
    add a,b
    ld b,a
    jp vdp_write_register

loc_5acf:
    ld a,$04
    add a,b
    ld b,a
    jp vdp_write_register

mirror_sprite_patterns:
    xor a

loc_5ad7:
    push bc
    push af
    ld l,a
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,$e3ff
    add hl,de
    push hl
    ld de,$e70f
    ld bc,$0010
    ldir
    pop hl
    push hl
    ld bc,$0010
    add hl,bc
    ld de,$e6ff
    ldir
    ld hl,$e6ff
    pop de
    ld b,$20

loc_5aff:
    push bc
    ld b,$08
    xor a

loc_5b03:
    rlc (hl)
    jr nc,loc_5b09
    set 0,a

loc_5b09:
    rrca
    djnz loc_5b03
    ld (de),a
    pop bc
    inc hl
    inc de
    djnz loc_5aff
    pop af
    inc a
    pop bc
    djnz loc_5ad7
    ret

sub_5b18:
    ld hl,$e3ff
    ld de,$e40e
    call reverse_16_bytes
    ld hl,$e40f
    ld de,$e41e
    call reverse_16_bytes
    ld hl,$e41f
    ld de,$e42e
    call reverse_16_bytes
    ld hl,$e42f
    ld de,$e43e

reverse_16_bytes:
    ld b,$08

loc_5b3b:
    ld c,(hl)
    ld a,(de)
    ld (hl),a
    ld a,c
    ld (de),a
    inc hl
    dec de
    djnz loc_5b3b
    ret

upload_first_sprites:
    ld hl,sprite_attributes
    ld de,$3000
    ld bc,$0020
    jp loc_5b6c

upload_other_sprites:
    ld hl,$e0b9
    ld de,$e119
    ld bc,$0060
    ldir
    ld a,(sprite_overflow)
    and a
    jp nz,loc_5b6f
    ld hl,$e0b9

loc_5b66:
    ld de,$3020
    ld bc,$0060

loc_5b6c:
    jp vdp_copy

loc_5b6f:
    ld hl,$e371
    inc (hl)
    ld a,(hl)
    and $07
    add a,a
    add a,a
    add a,a
    ld hl,$e0b9
    add a,l
    ld l,a
    ld a,$00
    adc a,h
    ld h,a
    jr loc_5b66

init_video:
    ld c,$00
    ld b,c
    call vdp_write_register
    ld b,$e2
    ld c,$01
    call vdp_write_register
    ld c,$02
    ld b,$0d
    call vdp_write_register
    ld c,$03
    ld b,$dc
    call vdp_write_register
    ld c,$04
    ld b,$07
    call vdp_write_register
    ld c,$05
    ld b,$60
    call vdp_write_register
    ld c,$06
    ld b,$00
    call vdp_write_register
    xor a
    ld hl,$0000
    ld bc,$4000
    call vdp_fill
    ld hl,shared.background_patterns
    ld de,$3800
    ld bc,$0800
    call vdp_copy
    ld hl,shared.sprite_patterns
    ld de,$2000
    ld bc,$0340
    push bc
    push hl
    call vdp_copy
    pop hl
    pop bc
    ld de,$2800
    push hl
    push bc
    call vdp_copy
    pop bc
    pop hl
    ld de,$e3ff
    ldir
    ld b,$1a
    call mirror_sprite_patterns
    ld hl,$e3ff
    ld de,$1000
    ld bc,$0340
    push hl
    push bc
    call vdp_copy
    pop bc
    pop hl
    ld de,$1800
    call vdp_copy
    ld hl,shared.patterns_978e
    ld de,$0000
    ld bc,$0180
    push hl
    push bc
    call vdp_copy
    pop bc
    pop hl
    ld de,$0800
    push hl
    push bc
    call vdp_copy
    pop bc
    pop hl
    ld de,$e3ff
    ldir
    ld b,$0c
    call mirror_sprite_patterns
    ld hl,$e3ff
    ld de,$0180
    ld b,d
    ld c,e
    push hl
    push bc
    call vdp_copy
    pop bc
    pop hl
    ld de,$0980
    call vdp_copy
    ld hl,shared.patterns_990e
    ld de,$0300
    ld bc,$0040
    push hl
    push bc
    call vdp_copy
    pop bc
    pop hl
    ld de,$0b00
    jp vdp_copy

sub_5c53:
    cp $35
    jr z,loc_5c58
    dec hl

loc_5c58:
    push hl
    xor a
    ld bc,$1c1f
    sbc hl,bc
    ld a,h
    add a,a
    add a,a
    add a,a
    add a,a
    add a,a
    add a,a
    ld d,a
    ld a,l
    and $1f
    rlca
    rlca
    rlca
    ld h,a
    ld a,l
    and $e0
    rrca
    rrca
    add a,d
    ld l,a
    pop de
    ret

sub_5c77:
    ld a,(hl)
    cp $2a
    jr z,loc_5c7d
    dec hl

loc_5c7d:
    jp loc_5c58

; Input H=X, L=Y. HL returns playfield - 32 + (Y >> 3)*32 + (X >> 3).
tile_at_pixel:
    ld a,h
    srl a
    srl a
    srl a
    ld e,a
    ld a,l
    srl a
    srl a
    srl a
    ld l,a
    ld h,$00
    ld d,h
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,de
    ld de,$e81f
    add hl,de
    ret

read_controller:
    in a,($dc)
    cpl
    and $3f
    ld b,a
    ld a,(demo_active)
    and a
    jr nz,loc_5caf
    ld a,b
    ld (pad_held),a
    ret

loc_5caf:
    ld a,b
    and a
    jp nz,exit_demo
    ld a,(demo_record)
    ld b,a
    add a,a
    add a,b
    ld hl,demo_buffer
    add a,l
    ld l,a
    ld a,$00
    adc a,h
    ld h,a
    ld e,(hl)
    inc hl
    ld d,(hl)
    dec de
    ld (hl),d
    dec hl
    ld (hl),e
    ld a,e
    or d
    jr nz,loc_5cd9
    ld a,(demo_record)
    inc a
    cp $24
    jr nc,exit_demo
    ld (demo_record),a

loc_5cd9:
    inc hl
    inc hl
    ld a,(hl)
    ld (pad_held),a
    ret

exit_demo:
    call fade_music
    ld a,$50
    call busy_wait
    ld hl,title_screen_entry
    ld sp,$f300
    ex (sp),hl
    xor a
    ld (pad_held),a
    ld (demo_active),a
    ld (demo_record),a
    call advance_stage
    reti

read_keyboard_row:
    ld l,a
    in a,($aa)
    and $f0
    or l
    out ($aa),a
    in a,($a9)
    ret

load_stage_colours:
    ld hl,(stage_index)
    inc l
    ld h,$00
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld de,stage_colours
    add hl,de
    ld de,$3700
    ld b,(hl)
    push bc
    ld bc,$0020
    call vdp_copy
    pop bc
    ld c,$07
    jp vdp_write_register

busy_wait:
    push bc

loc_5d2a:
    ld b,$00

loc_5d2c:
    ex (sp),hl
    ex (sp),hl
    djnz loc_5d2c
    dec a
    jr nz,loc_5d2a
    pop bc
    ret

upload_playfield:
    ld hl,playfield
    ld de,$3440
    ld bc,$02c0
    jp vdp_copy

finish_stage:
    call advance_stage

loc_5d44:
    di
    ld sp,$f300
    ei
    jp load_stage

; Little-endian pair: L=world, H=round. Each wraps modulo four.
advance_stage:
    ld hl,(world_index)
    inc h
    ld a,h
    and $03
    jr nz,loc_5d5b
    inc l
    ld h,a
    ld a,l
    and $03
    ld l,a

loc_5d5b:
    ld (world_index),hl
    ret

irq_update:
    in a,($bf)
    and $40
    ld (sprite_overflow),a
    xor a
    cpl
    ld (frame_ready),a
    call shared.sound_tick
    call read_controller
    ld a,(actors_enabled)
    and a
    ret z
    ld a,(frame_counter)
    and $01
    jp z,update_actors_irq
    ret

draw_player:
    ld hl,player_facing
    ld de,$e0a9
    ld b,$00
    ld a,(player_big)
    and a
    jr nz,loc_5dd7
    ld a,(hl)
    and a
    jr z,loc_5d93
    ld b,$0c

loc_5d93:
    dec hl
    ld a,(hl)
    cp $02
    jr nc,loc_5db2
    rlca

loc_5d9a:
    ld hl,(player_y)
    ex de,hl
    ld (hl),e
    inc hl
    ld (hl),d
    inc hl
    add a,b
    rlca
    rlca
    ld (hl),a
    inc hl
    inc hl
    ld (hl),e
    inc hl
    ld (hl),d
    add a,$04
    inc hl
    ld (hl),a
    jp upload_first_sprites

loc_5db2:
    jr nz,loc_5dca
    inc hl
    inc hl
    bit 0,(hl)
    jr z,loc_5dc3
    xor a
    bit 1,(hl)
    jr z,loc_5dc5
    ld a,$01
    jr loc_5dc5

loc_5dc3:
    ld a,$02

loc_5dc5:
    rlca
    add a,$04
    jr loc_5d9a

loc_5dca:
    cp $04
    ret z
    jr nc,loc_5dd3
    ld a,$0a
    jr loc_5d9a

loc_5dd3:
    ld a,$18
    jr loc_5d9a

loc_5dd7:
    dec hl
    ld a,(hl)
    cp $02
    jr nc,loc_5e0d
    rlca
    rlca

loc_5ddf:
    rlca
    rlca
    ld hl,(player_y)
    ex de,hl
    ld c,a
    ld a,e
    sub $10
    ld (hl),a
    inc hl
    ld (hl),d
    inc hl
    ld (hl),c
    inc hl
    inc hl
    ld (hl),a
    inc hl
    ld (hl),d
    ld a,c
    add a,$04
    inc hl
    ld (hl),a
    inc hl
    inc hl
    ld (hl),e
    inc hl
    ld (hl),d
    inc hl
    add a,$04
    ld (hl),a
    inc hl
    inc hl
    ld (hl),e
    inc hl
    ld (hl),d
    inc hl
    add a,$04
    ld (hl),a
    jp upload_first_sprites

loc_5e0d:
    jr nz,loc_5e26
    inc hl
    inc hl
    bit 0,(hl)
    jr z,loc_5e1e
    xor a
    bit 1,(hl)
    jr z,loc_5e20
    ld a,$01
    jr loc_5e20

loc_5e1e:
    ld a,$02

loc_5e20:
    rlca
    rlca
    add a,$08
    jr loc_5ddf

loc_5e26:
    cp $04
    jr z,loc_5e2e
    ld a,$14
    jr loc_5ddf

loc_5e2e:
    ld a,$18
    jr loc_5ddf
