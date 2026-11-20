; 48 KiB cartridge. Banks 0 and 2 contain identical bytes, including
; sound routines with absolute references into the $8000-$bfff window.
    include "ram.asm"
    include "music_macros.asm"
    org $0000
    ifdef DELUXE
    jp reset_handler
    ds $38 - $, 0
    jp irq_handler
    ds $66 - $, 0
    retn                      ; SMS pause NMI: no game state change
    ds $100 - $, 0
    include "deluxe/video.asm"
    ifdef GENERIC
    include "generic/actors.asm"
    include "generic/feel.asm"
    endif
    ifdef SMB_ASSETS
    include "deluxe/music.asm"
    endif
    assert $ <= $144e
    ds $144e - $, 0
    ; Fixed alias for source art while slot 2 is mapped to cartridge RAM.
    module fixed_art
    include "patterns.asm"
    endmodule
    ds $3000 - $, 0
dx_hud_font:                  ; asset packer writes the Mode 4 HUD glyphs here
    ds $800, 0
    ds $4000 - $, 0
    else
    disp $8000
    module low_copy
    include "shared.asm"
    endmodule
    ent
    endif
    assert $ == $4000

    include "game.asm"
    include "stage_tables.asm"
    include "support.asm"
    include "bank1_tail.asm"
    assert $ == $8000

    module shared
    include "shared.asm"
    endmodule
    assert $ == $c000
