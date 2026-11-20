/* Minimal libretro frontend for the all-stages controller recording.
 * No cheats, RAM writes, serialize/unserialize or stage selection. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libretro.h"

static uint16_t pad;
static bool picture, check_scroll;
static uint16_t floor_line[160], captions[192];
static bool environment(unsigned cmd, void *data) {
    if (cmd == RETRO_ENVIRONMENT_GET_INPUT_BITMASKS) return true;
    if (cmd == RETRO_ENVIRONMENT_SET_PIXEL_FORMAT)
        return *(enum retro_pixel_format *)data == RETRO_PIXEL_FORMAT_RGB565;
    if (cmd == RETRO_ENVIRONMENT_GET_VARIABLE) {
        struct retro_variable *option = data;
        /* On auto/NTSC-J this core powers RAM up at $f0. The game enables
         * IRQs before clearing it, and can skip part of init_video. */
        option->value = !strcmp(option->key, "genesis_plus_gx_region_detect") ? "ntsc-u" : NULL;
        return option->value != NULL;
    }
    return false;
}
static void poll(void) {}
static int16_t input(unsigned port, unsigned device, unsigned index, unsigned id) {
    if (port || device != RETRO_DEVICE_JOYPAD || index) return 0;
    if (id == RETRO_DEVICE_ID_JOYPAD_MASK) return (int16_t)pad;
    return id < 16 && (pad & (1u << id));
}
static void video(const void *d, unsigned w, unsigned h, size_t pitch) {
    /* Sample the playfield, not just the HUD. Stage progression in RAM is
     * not enough: a wrong VDP initialization can leave the picture blank. */
    picture = false;
    if (!d || h <= 24 || w < 32) return;
    if (check_scroll && w == 256 && h == 192) {
        memcpy(floor_line, (const uint8_t *)d + pitch * 187 + 2 * 40, sizeof floor_line);
        memcpy(captions, (const uint8_t *)d + pitch * 4 + 2 * 24, sizeof captions);
    }
    const uint16_t *first_row = (const uint16_t *)((const uint8_t *)d + 24 * pitch);
    uint16_t first = first_row[16];
    for (unsigned y = 24; y < h; y += 4) {
        const uint16_t *row = (const uint16_t *)((const uint8_t *)d + y * pitch);
        for (unsigned x = 16; x < w; x += 4) {
            if (row[x] != first) { picture = true; return; }
        }
    }
}
static void audio(int16_t l, int16_t r) { (void)l; (void)r; }
static size_t batch(const int16_t *d, size_t n) { (void)d; return n; }

static int replay(FILE *movie, const uint8_t *ram) {
    unsigned frame = 0, clears = 0;
    int count, stage = -1;
    bool stage_visible = false;
    char buttons[8];
    int fields;
    while ((fields = fscanf(movie, "%d %7s", &count, buttons)) == 2) {
        if (count <= 0 || count > 40000) return 1;
        pad = 0;
        for (const char *p = buttons; *p; ++p) {
            switch (*p) {
            case '-': break;
            case 'L': pad |= 1u << RETRO_DEVICE_ID_JOYPAD_LEFT; break;
            case 'R': pad |= 1u << RETRO_DEVICE_ID_JOYPAD_RIGHT; break;
            case '1': pad |= 1u << RETRO_DEVICE_ID_JOYPAD_B; break;
            case '2': pad |= 1u << RETRO_DEVICE_ID_JOYPAD_A; break;
            default: return 1;
            }
        }
        while (count--) {
            retro_run();
            ++frame;
            /* Start checking once the title screen has started a real game.
             * Offsets in the $e000 RAM mirror; see src/ram.asm. */
            if (stage < 0) {
                if (ram[0x46] || ram[0x43] != 5 || ram[0x376] != 10 || ram[0x383]) continue;
                stage = 0;
            }
            if (ram[0x383] || ram[0x43] != 5) {
                fprintf(stderr, "Demo or life count changed at frame %u\n", frame);
                return 1;
            }
            if (ram[0x46] != stage) {
                if (!stage_visible || ram[0x46] != ((stage + 1) & 15)) {
                    fprintf(stderr, "Missing picture or unexpected stage %u at frame %u\n", ram[0x46], frame);
                    return 1;
                }
                printf("%d-%d cleared at frame %u\n", stage / 4 + 1, stage % 4 + 1, frame);
                ++clears;
                stage = ram[0x46];
                stage_visible = false;
            } else if (ram[0x376] && picture) {
                stage_visible = true;
            }
        }
    }
    if (fields != EOF || ferror(movie) || clears != 16 || stage != 0) {
        fprintf(stderr, "Replay stopped after %u clears (%u frames)\n", clears, frame);
        return 1;
    }
    printf("All 16 stages cleared, back at 1-1: %u frames, five lives.\n", frame);
    return 0;
}

/* A separate cold boot: enter 1-1, then leave the pad untouched. Exercise
 * the failure path not taken by the all-clear movie. Read-only observations. */
static int idle_test(const uint8_t *ram) {
    int expected_lives = 5, expired = 0;
    bool had_time = false, restarted = false;
    for (unsigned frame = 1; frame <= 50000; ++frame) {
        pad = frame > 140 && frame <= 218 ? (1u << RETRO_DEVICE_ID_JOYPAD_B) : 0;
        retro_run();
        if (frame < 218) continue;
        if (restarted && ram[0x383] && ram[0x376] && picture) {
            puts("Five timeouts, game over, and visible attract-mode play verified.");
            return 0;
        }
        if (ram[0x49] || ram[0x4a]) had_time = true;
        if (had_time && !ram[0x49] && !ram[0x4a]) {
            ++expired;
            had_time = false;
        }
        if (expired == 5 && expected_lives == 1) {
            /* The restart clears the RAM mirror, then writes five lives. */
            if (ram[0x43] == 5) { restarted = true; expected_lives = 5; }
            continue;
        }
        if (ram[0x43] != expected_lives) {
            --expected_lives;
            if (ram[0x43] != expected_lives || expired != 5 - expected_lives)
                break;
        }
    }
    fprintf(stderr, "Idle test did not reach the expected game-over/demo sequence\n");
    return 1;
}

static void hold(unsigned mask, unsigned frames) {
    pad = mask;
    while (frames--) retro_run();
}

/* No state loads or RAM writes. Exercise the acceleration and two jump arcs
 * on the safe starting platform before trying the longer campaign replay. */
static int qol_controls(const uint8_t *ram) {
    const unsigned jump = 1u << RETRO_DEVICE_ID_JOYPAD_B;
    const unsigned right = 1u << RETRO_DEVICE_ID_JOYPAD_RIGHT;
    hold(0, 140); hold(jump, 1); hold(0, 100);
    if (!picture || ram[0x376] != 10 || ram[0x383]) return 1;
    unsigned floor = ram[0x36c], heights[2];
    for (unsigned j = 0; j < 2; ++j) {
        unsigned apex = floor;
        for (unsigned i = 0; i < 150; ++i) {
            hold(i < (j ? 65u : 6u) ? jump : 0, 1);
            if (ram[0x36c] < apex) apex = ram[0x36c];
        }
        heights[j] = floor - apex;
        if (ram[0x36c] != floor) return 1;
    }
    hold(right, 4);
    if (!ram[0x23b] || ram[0x23b] >= 16) return 1;
    hold(right, 16);
    if (ram[0x23b] != 16) return 1;
    hold(right | (1u << RETRO_DEVICE_ID_JOYPAD_A), 16);
    if (ram[0x23b] != 32) return 1;
    hold(0, 10);
    if (ram[0x23b] || !heights[0] || heights[1] <= heights[0] + 32) return 1;
    printf("Walk/run/braking pass. Tap jump %u px, held jump %u px.\n", heights[0], heights[1]);
    return 0;
}

/* Measure displayed pixels, not just camera RAM: when walking the patterned
 * floor moves left by exactly one pixel while the captions remain fixed. */
static int deluxe_camera(const uint8_t *ram) {
    check_scroll = true;
    hold(0, 140); hold(1u << RETRO_DEVICE_ID_JOYPAD_B, 1); hold(0, 120);
    if (!picture || ram[0x376] != 10 || ram[0x383]) return 1;
    uint16_t hud[192], old[160];
    memcpy(hud, captions, sizeof hud);
    if (!memcmp(hud, hud+1, sizeof hud-sizeof *hud)) return 1;
    unsigned steps = 0, phases = 0;
    for (unsigned i = 0; i < 176; ++i) {
        memcpy(old, floor_line, sizeof old);
        hold(1u << RETRO_DEVICE_ID_JOYPAD_RIGHT, 1);
        if (memcmp(hud, captions, sizeof hud)) return 1;
        if (memcmp(floor_line, old, sizeof old) &&
            !memcmp(floor_line, old+1, sizeof old-sizeof *old)) {
            ++steps;
            phases |= 1u << (ram[0xb11] & 7);
        }
    }
    printf("Measured %u single-pixel frames; fine-scroll phases %02x; HUD fixed.\n", steps, phases);
    return steps < 48 || phases != 255;
}

int main(int argc, char **argv) {
    if (argc != 3) { fprintf(stderr, "usage: %s rebuilt.sms movie.pad|--idle|--qol-controls|--deluxe-camera\n", argv[0]); return 2; }
    FILE *rom = fopen(argv[1], "rb");
    if (!rom) { perror(argv[1]); return 1; }
    static uint8_t bytes[262144];
    size_t size = fread(bytes, 1, sizeof bytes, rom);
    if ((size != 49152 && size != sizeof bytes) || fgetc(rom) != EOF) {
        fprintf(stderr, "Expected a 48 or 256 KiB ROM\n"); return 1;
    }
    fclose(rom);
    bool idle = !strcmp(argv[2], "--idle");
    bool controls = !strcmp(argv[2], "--qol-controls");
    bool camera = !strcmp(argv[2], "--deluxe-camera");
    FILE *movie = idle || controls || camera ? NULL : fopen(argv[2], "r");
    if (!idle && !controls && !camera && !movie) { perror(argv[2]); return 1; }
    retro_set_environment(environment);
    retro_set_video_refresh(video);
    retro_set_audio_sample(audio);
    retro_set_audio_sample_batch(batch);
    retro_set_input_poll(poll);
    retro_set_input_state(input);
    retro_init();
    struct retro_game_info game = { argv[1], bytes, size, NULL };
    if (!retro_load_game(&game)) { fprintf(stderr, "Core rejected ROM\n"); return 1; }
    const uint8_t *ram = retro_get_memory_data(RETRO_MEMORY_SYSTEM_RAM);
    int result = !ram || retro_get_memory_size(RETRO_MEMORY_SYSTEM_RAM) < 8192 ||
                 (camera ? deluxe_camera(ram) : controls ? qol_controls(ram) : idle ? idle_test(ram) : replay(movie, ram));
    retro_unload_game();
    retro_deinit();
    return result;
}
