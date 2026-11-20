; Code in the spare space after the new songs. All public hooks return to the
; original collision / scrolling code with its original register contract.
; $eb00 immediately follows the 32x22 RAM tile window and its shift scratch.
; The window begins at $e83f and its final 1-byte lookahead is $eaff.
x_fraction equ $eb00
fall_rate equ $eb01
fall_fraction equ $eb02

safe_video_init:
    ; init_video enables IRQ before the normal startup RAM clear. Don't let
    ; garbage demo, actor or audio state take over the first interrupt.
    xor a
    ld (demo_active),a
    ld (actors_enabled),a
    ld (audio_enabled),a
    jp init_video

reset_motion:
    xor a
    ld (x_fraction),a
    ld (fall_rate),a
    ld (fall_fraction),a
    ld hl,projectile_defaults
    ret

; A = speed in 1/32 pixel units per player update (twice a frame).
accelerate:
    ld c,16             ; walk: 1 pixel per frame
    bit 5,(ix+0)
    jr z,accel_cap
    ld c,32             ; run: 2 pixels per frame
accel_cap:
    cp c
    ret z
    jr nc,reduce_speed  ; releasing run while still walking
    inc a
    ret
reduce_speed:
    dec a
    ret

pixel_step:
    ld c,a
    ld a,(x_fraction)
    add a,c
    cp 32               ; carry = no whole pixel yet
    jr c,save_fraction
    sub 32              ; clear carry: commit a collision-checked pixel
save_fraction:
    ld (x_fraction),a
    ret

brake_left:
    dec (ix+1)
    ret z
    dec (ix+1)
    ret

grounded_pose:
    xor a
    ld (fall_rate),a
    ld (fall_fraction),a
    ld a,2
    ld (player_pose),a
    ret

fall_if_released:
    bit 1,(ix+5)
    ret z               ; jump rise is still active
    ld a,(fall_rate)
    cp 32
    jr nc,fall_at_speed
    inc a
    ld (fall_rate),a
fall_at_speed:
    ld c,a
    ld a,(fall_fraction)
    add a,c
    cp 32
    jr c,fall_remainder
    sub 32
    ld (fall_fraction),a
    ld hl,player_y
    inc (hl)            ; never tunnel: one pixel per floor probe, max 4/frame
    ld a,$d2
    cp (hl)
    ret nz
    jp hurt_player
fall_remainder:
    ld (fall_fraction),a
    ret

brake_right:
    dec (ix+2)
    ret z
    bit 3,(ix+0)        ; wall probe already decelerated once
    ret nz
    dec (ix+2)
    ret
