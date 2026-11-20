; NTSC SN76489 tone periods: clock / (32 * frequency).
note_a3    equ 508
note_a4    equ 254
note_b3    equ 453
note_b4    equ 226
note_c3    equ 855
note_c4    equ 428
note_c5    equ 214
note_d3    equ 762
note_d4    equ 381
note_d5    equ 190
note_e3    equ 679
note_e4    equ 339
note_e5    equ 170
note_f3    equ 641
note_f4    equ 320
note_f5    equ 160
note_fs3   equ 605
note_fs4   equ 302
note_g3    equ 571
note_g4    equ 285
note_g5    equ 143
note_gs4   equ 269

; Original PSG scores. Each staff loops independently. The lead and bass
; keep playing when an effect borrows the quieter offbeat voice (channel 3).

; Sunlit Steps — melody
track_0_ch1:
    tempo 150
    pitch_envelope 0
    volume_envelope 1
    db 8, 13
song_0_loop_0:
    ; Bar 1
    tone 0, note_g4, 8
    tone 0, note_b4, 8
    tone 0, note_d5, 4
    rest_ticks 8
    tone 0, note_b4, 8
    tone 0, note_a4, 4
    ; Bar 2
    tone 0, note_g4, 8
    rest_ticks 8
    tone 0, note_e5, 8
    tone 0, note_d5, 8
    tone 0, note_b4, 4
    tone 0, note_g4, 4
    ; Bar 3
    tone 0, note_a4, 4
    tone 0, note_c5, 8
    tone 0, note_a4, 8
    rest_ticks 8
    tone 0, note_f5, 8
    tone 0, note_e5, 4
    ; Bar 4
    tone 0, note_d5, 8
    tone 0, note_a4, 8
    tone 0, note_b4, 4
    tone 0, note_a4, 8
    rest_ticks 8
    tone 0, note_g4, 4
    ; Bar 5
    tone 0, note_b4, 8
    tone 0, note_d5, 8
    tone 0, note_g5, 4
    tone 0, note_f5, 8
    tone 0, note_e5, 8
    tone 0, note_d5, 4
    ; Bar 6
    tone 0, note_c5, 4
    rest_ticks 8
    tone 0, note_e5, 8
    tone 0, note_c5, 8
    tone 0, note_g4, 8
    tone 0, note_a4, 4
    ; Bar 7
    tone 0, note_b4, 8
    rest_ticks 8
    tone 0, note_a4, 8
    tone 0, note_g4, 8
    tone 0, note_fs4, 4
    tone 0, note_a4, 4
    ; Bar 8
    tone 0, note_g4, 4
    tone 0, note_d5, 8
    tone 0, note_b4, 8
    tone 0, note_g4, 4
    rest_ticks 4
    db $4b, $4c
    dw song_0_loop_0

; Sunlit Steps — walking bass
track_0_ch2:
    tempo 150
    pitch_envelope 0
    volume_envelope 0
    db 9, 11
song_0_loop_1:
    ; Bar 1
    tone 2, note_g3, 4
    tone 2, note_d4, 4
    tone 2, note_b3, 4
    tone 2, note_d4, 4
    ; Bar 2
    tone 2, note_e3, 4
    tone 2, note_b3, 4
    tone 2, note_g3, 4
    tone 2, note_b3, 4
    ; Bar 3
    tone 2, note_f3, 4
    tone 2, note_c4, 4
    tone 2, note_a3, 4
    tone 2, note_c4, 4
    ; Bar 4
    tone 2, note_d3, 4
    tone 2, note_a3, 4
    tone 2, note_fs3, 4
    tone 2, note_a3, 4
    ; Bar 5
    tone 2, note_g3, 4
    tone 2, note_d4, 4
    tone 2, note_b3, 4
    tone 2, note_d4, 4
    ; Bar 6
    tone 2, note_c3, 4
    tone 2, note_g3, 4
    tone 2, note_e3, 4
    tone 2, note_g3, 4
    ; Bar 7
    tone 2, note_d3, 4
    tone 2, note_a3, 4
    tone 2, note_fs3, 4
    tone 2, note_a3, 4
    ; Bar 8
    tone 2, note_g3, 4
    tone 2, note_b3, 4
    tone 2, note_d4, 4
    rest_ticks 4
    db $4b, $4c
    dw song_0_loop_1

; Sunlit Steps — offbeat harmony
track_0_ch3:
    tempo 150
    pitch_envelope 0
    volume_envelope 1
    db 10, 9
song_0_loop_2:
    ; Bar 1
    rest_ticks 8
    tone 4, note_d4, 8
    rest_ticks 4
    rest_ticks 8
    tone 4, note_g4, 8
    rest_ticks 4
    ; Bar 2
    rest_ticks 8
    tone 4, note_b3, 8
    rest_ticks 4
    rest_ticks 8
    tone 4, note_e4, 8
    rest_ticks 4
    ; Bar 3
    rest_ticks 8
    tone 4, note_c4, 8
    rest_ticks 4
    rest_ticks 8
    tone 4, note_f4, 8
    rest_ticks 4
    ; Bar 4
    rest_ticks 8
    tone 4, note_a3, 8
    rest_ticks 4
    rest_ticks 8
    tone 4, note_fs4, 8
    rest_ticks 4
    ; Bar 5
    rest_ticks 8
    tone 4, note_g4, 8
    rest_ticks 4
    rest_ticks 8
    tone 4, note_b4, 8
    rest_ticks 4
    ; Bar 6
    rest_ticks 8
    tone 4, note_e4, 8
    rest_ticks 4
    rest_ticks 8
    tone 4, note_g4, 8
    rest_ticks 4
    ; Bar 7
    rest_ticks 8
    tone 4, note_fs4, 8
    rest_ticks 4
    rest_ticks 8
    tone 4, note_a4, 8
    rest_ticks 4
    ; Bar 8
    rest_ticks 8
    tone 4, note_d4, 8
    rest_ticks 4
    tone 4, note_b3, 4
    rest_ticks 4
    db $4b, $4c
    dw song_0_loop_2

; Ember Hall — melody
track_1_ch1:
    tempo 136
    pitch_envelope 0
    volume_envelope 1
    db 8, 13
song_1_loop_0:
    ; Bar 1
    tone 0, note_a4, 8
    tone 0, note_e4, 8
    tone 0, note_c5, 4
    rest_ticks 8
    tone 0, note_b4, 8
    tone 0, note_gs4, 4
    ; Bar 2
    tone 0, note_a4, 4
    tone 0, note_c5, 8
    tone 0, note_e5, 8
    tone 0, note_d5, 4
    tone 0, note_b4, 4
    ; Bar 3
    tone 0, note_f4, 8
    tone 0, note_a4, 8
    tone 0, note_c5, 4
    tone 0, note_b4, 8
    tone 0, note_a4, 8
    tone 0, note_gs4, 4
    ; Bar 4
    tone 0, note_e4, 8
    tone 0, note_gs4, 8
    tone 0, note_b4, 4
    tone 0, note_a4, 4
    rest_ticks 4
    db $4b, $4c
    dw song_1_loop_0

; Ember Hall — walking bass
track_1_ch2:
    tempo 136
    pitch_envelope 0
    volume_envelope 0
    db 9, 11
song_1_loop_1:
    ; Bar 1
    tone 2, note_a3, 8
    rest_ticks 8
    tone 2, note_e3, 4
    tone 2, note_a3, 8
    rest_ticks 8
    tone 2, note_e3, 4
    ; Bar 2
    tone 2, note_c3, 8
    rest_ticks 8
    tone 2, note_g3, 4
    tone 2, note_d3, 8
    rest_ticks 8
    tone 2, note_a3, 4
    ; Bar 3
    tone 2, note_f3, 8
    rest_ticks 8
    tone 2, note_c4, 4
    tone 2, note_e3, 8
    rest_ticks 8
    tone 2, note_b3, 4
    ; Bar 4
    tone 2, note_e3, 4
    tone 2, note_b3, 4
    tone 2, note_a3, 4
    rest_ticks 4
    db $4b, $4c
    dw song_1_loop_1

; Ember Hall — offbeat harmony
track_1_ch3:
    tempo 136
    pitch_envelope 0
    volume_envelope 1
    db 10, 9
song_1_loop_2:
    ; Bar 1
    rest_ticks 4
    tone 4, note_c4, 4
    rest_ticks 4
    tone 4, note_b3, 4
    ; Bar 2
    rest_ticks 4
    tone 4, note_e4, 4
    rest_ticks 4
    tone 4, note_f4, 4
    ; Bar 3
    rest_ticks 4
    tone 4, note_c4, 4
    rest_ticks 4
    tone 4, note_e4, 4
    ; Bar 4
    rest_ticks 8
    tone 4, note_b3, 8
    rest_ticks 4
    tone 4, note_c4, 4
    rest_ticks 4
    db $4b, $4c
    dw song_1_loop_2
