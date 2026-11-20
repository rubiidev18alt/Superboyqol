; 48 KiB cartridge. Banks 0 and 2 contain identical bytes, including
; sound routines with absolute references into the $8000-$bfff window.
    include "ram.asm"
    include "music_macros.asm"
    org $0000
    disp $8000
    module low_copy
    include "shared.asm"
    endmodule
    ent
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
