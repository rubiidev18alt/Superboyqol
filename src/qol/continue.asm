; Keep the stage indices alive until the player chooses. Nothing is written
; to battery RAM. Like the stock game, unattended game-over returns to title.
continue_menu:
    xor a
    ld (actors_enabled),a
    ld hl,continue_prompt
    ld de,$3567          ; name table, row 11 column 7
    ld bc,continue_prompt_end - continue_prompt
    call vdp_copy
    ld bc,480            ; about eight seconds at 60 Hz
    ld d,0               ; require release before accepting either choice
continue_poll:
    halt
    ld a,(pad_held)
    and $30
    jr nz,continue_pressed
    ld d,1
    jr continue_wait
continue_pressed:
    bit 0,d
    jr z,continue_wait
    bit 4,a
    jr nz,continue_here
    jp loc_402e
continue_wait:
    dec bc
    ld a,b
    or c
    jr nz,continue_poll
    jp loc_402e
continue_here:
    xor a
    ld (coins_bcd),a
    ld (score_bcd),a
    ld (score_bcd+1),a
    ld (player_big),a
    ld (player_can_shoot),a
    ld a,5
    ld (lives_bcd),a
    jp loc_5d44          ; reset the stack, load the same world/round
continue_prompt:
    abyte $a8 "1"
    db 0
    abyte $a1 "RETRY"
    db 0,0
    abyte $a8 "2"
    db 0
    abyte $a1 "TITLE"
continue_prompt_end:
