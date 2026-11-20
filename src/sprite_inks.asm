; Logical Mode 4 sprite inks (not background CRAM bytes). Pickup art and
; legacy sprite attributes use the same indices; zero stays transparent.
spr_clear equ 0
spr_outline equ 1
; The two red indices deliberately point to the same CRAM colour. Some
; legacy poses need a one-bit index (versus two) to keep conversion timing.
sprite_coral_cram equ $17
spr_leaf_light equ 2
spr_red_single_plane equ 8
spr_red equ 9
spr_amber equ 10
spr_gold equ 11
spr_leaf equ 12
spr_white equ 15

; Keep the original immediate operands in every non-polish build. These
; aliases change no instruction lengths, spawn order or renderer timing.
    ifdef POLISH
walker_alt_ink equ spr_red_single_plane
tall_lower_ink equ spr_leaf_light
fireball_ink equ spr_red_single_plane
    else
walker_alt_ink equ 2
tall_lower_ink equ 8
fireball_ink equ 8
    endif
