/* Minimal libretro frontend for the all-stages controller recording.
 * No cheats, RAM writes, serialize/unserialize or stage selection. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "libretro.h"

static uint16_t pad, block_face, block_ink;
static bool check_blocks;
static bool picture, check_scroll, check_actors;
/* Bounding boxes in RGB565 output, not game-side sprite coordinates. */
struct bounds { int left, right, top; };
static struct bounds popup, walker;
static struct bounds box(const uint8_t *data, size_t pitch, uint16_t colour,
                         int x0, int x1, int y0, int y1) {
    struct bounds b = {x1, -1, y1};
    for (int y = y0; y < y1; ++y) {
        const uint16_t *row = (const uint16_t *)(data + y * pitch);
        for (int x = x0; x < x1; ++x) if (row[x] == colour) {
            if (x < b.left) b.left = x;
            if (x > b.right) b.right = x;
            if (y < b.top) b.top = y;
        }
    }
    return b;
}
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
    if (check_blocks && w == 256 && h == 192) {
        /* Top edge of the first stationary 1-1 question block. */
        const uint16_t *row = (const uint16_t *)((const uint8_t *)d + 112*pitch);
        block_face = row[184];
        block_ink = row[185];
    }
    if (check_scroll && w == 256 && h == 192) {
        memcpy(floor_line, (const uint8_t *)d + pitch * 187 + 2 * 40, sizeof floor_line);
        if (check_actors) {
            popup = box(d, pitch, 0xfd40, 48, 123, 52, 112);
            walker = box(d, pitch, 0xaaa0, 119, 200, 161, 176);
        }
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

/* Same pad reader, with an optional short 1-1 pickup route. Coordinates are
 * world pixels so camera movement cannot masquerade as mushroom movement. */
static int replay(FILE *movie, const uint8_t *ram, bool items) {
    unsigned spawns = 0, mushroom_trip = 0, flower_ticks = 0;
    bool active = false, mushroom_collected = false;
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
            if (items) {
                bool now = ram[0x4f] == 0x10;
                if (ram[0x46]) return 1;
                if (now) {
                    unsigned x = (ram[0x235]-31)*8 + ram[0x8a];
                    unsigned rise = ram[0xb27];
                    if (!active) {
                        ++spawns;
                        if (spawns > 2 || x != (spawns == 1 ? 34u : 177u)*8 || rise != 16)
                            return 1;
                    }
                    if (!!ram[0x251] != (spawns == 2) || rise > 16 ||
                        (rise && ram[0x89] != 96 + rise)) return 1;
                    if (spawns == 1) {
                        if (ram[0x372] || x < 34*8) return 1;
                        if (x-34*8 > mushroom_trip) mushroom_trip = x-34*8;
                    } else {
                        if (!mushroom_collected || ram[0x373] || x != 177*8 ||
                            (!rise && ram[0x89] != 96)) return 1;
                        if (!rise) ++flower_ticks;
                    }
                } else if (active && spawns == 1) {
                    mushroom_collected = ram[0x372] && !ram[0x373];
                }
                active = now;
                continue;
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
    if (items) {
        if (fields != EOF || ferror(movie) || spawns != 2 || !mushroom_collected ||
            mushroom_trip < 16 || flower_ticks < 16 || active || !ram[0x373]) return 1;
        printf("Fixed 1-1 pickups: mushroom travelled %u px; flower stayed put for %u frames; fire enabled.\n",
               mushroom_trip, flower_ticks);
        return 0;
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

/* Run under the first question block. Measure camera travel by matching the
 * textured floor, not from RAM. Both the rotating coin poses must have the
 * same world centre and the enemy must not snap back across a column seam. */
static int generic_actors(const uint8_t *ram) {
    unsigned jump = 1u << RETRO_DEVICE_ID_JOYPAD_B;
    unsigned run = (1u << RETRO_DEVICE_ID_JOYPAD_RIGHT) | (1u << RETRO_DEVICE_ID_JOYPAD_A);
    check_scroll = check_actors = true;
    hold(0, 140); hold(jump, 1); hold(0, 120); hold(run, 77);
    int scroll = 0, anchor = 0, shown = 0, travel = 0, rise = 0;
    int first_scroll = 0, first_y = 0, prev_enemy = 0, first_enemy = 0;
    for (int i = 0; i < 44; ++i) {
        uint16_t old[160];
        memcpy(old, floor_line, sizeof old);
        hold(run | jump, 1);
        int dx = 0;
        while (dx <= 8 && memcmp(old+dx, floor_line, 150*sizeof *old)) ++dx;
        if (dx > 8) return 1;
        scroll += dx;
        if (popup.right < 0 || !ram[0x233]) continue;
        int centre = popup.left + popup.right + 2*scroll; /* half-pixel units */
        int enemy = walker.left + scroll;
        if (walker.right < 0) return 1;
        if (!shown) {
            anchor = centre; first_scroll = scroll; first_y = popup.top;
            first_enemy = enemy;
        } else if (centre != anchor || enemy > prev_enemy || prev_enemy-enemy > 2) {
            fprintf(stderr, "Coin drift or enemy discontinuity at tick %d\n", i);
            return 1;
        }
        prev_enemy = enemy;
        travel = scroll-first_scroll; rise = first_y-popup.top; ++shown;
    }
    printf("Block coin: %d visible frames, %d px rise, %d px scroll; enemy advanced %d px.\n",
           shown, rise, travel, first_enemy-prev_enemy);
    return shown < 16 || rise < 24 || travel < 24 || first_enemy-prev_enemy < 6;
}

static int block_cycle(void) {
    static const uint16_t ramp[] = {0xffea, 0xfd40, 0xaaa0, 0xfd40};
    check_blocks = true;
    hold(0, 140); hold(1u << RETRO_DEVICE_ID_JOYPAD_B, 1); hold(0, 120);
    /* Sync on entry to the bright phase, then check two full loops. */
    for (unsigned i = 0; i <= 32; ++i) {
        uint16_t prev = block_face;
        hold(0, 1);
        if (prev != ramp[0] && block_face == ramp[0]) break;
        if (i == 32) return 1;
    }
    for (unsigned i = 0; i < 64; ++i) {
        if (block_face != ramp[(i/8)%4] || block_ink != 0) return 1;
        hold(0, 1);
    }
    puts("Question block: two 32-frame palette cycles, ink fixed.");
    return 0;
}

/* Read-only A/B benchmark. Validate the full title and first gameplay window,
 * including the left edge retained by the stage primer, not just the HUD. */
static int opening(const uint8_t *ram, const uint8_t *rom, bool expect_polish) {
    const unsigned jump = 1u << RETRO_DEVICE_ID_JOYPAD_B;
    hold(0, 140);
    for (unsigned x = 0; x < 32; ++x) for (unsigned y = 0; y < 22; ++y)
        if (ram[0x83f+32*y+x] != rom[0x8c0e + 22*x+y]) return 1;
    unsigned elapsed = 0;
    do {
        hold(elapsed ? 0 : jump, 1);
        if (++elapsed > 120) return 1;
    } while (ram[0x376] != 10);
    for (unsigned x = 0; x < 32; ++x) for (unsigned y = 0; y < 22; ++y) {
        unsigned col = rom[0x5e8a+1+x];
        if (ram[0x83f+32*y+x] != rom[0x7700+22*col+y]) return 1;
    }
    hold(0, 60);
    hold((1u << RETRO_DEVICE_ID_JOYPAD_RIGHT) | (1u << RETRO_DEVICE_ID_JOYPAD_A), 28);
    if (ram[0x23b] != 32) return 1;
    unsigned start = ram[0x36d], peak = start, at = start, reverse = 0, overlap = 0;
    for (unsigned t = 1; t <= 30; ++t) {
        hold(1u << RETRO_DEVICE_ID_JOYPAD_LEFT, 1);
        unsigned x = ram[0x36d];
        if (x > peak) peak = x;
        if (!reverse && x < at) reverse = t;
        if (ram[0x23a] && ram[0x23b]) ++overlap;
        at = x;
    }
    printf("Start to 1-1: %u frames. Run reversal: %u px braking travel, "
           "first leftward pixel on frame %u, %u frames of opposing speeds.\n",
           elapsed, peak-start, reverse, overlap);
    return !reverse || (expect_polish && (elapsed > 24 || overlap || peak == start ||
                                           peak-start > 10 || reverse > 12));
}

int main(int argc, char **argv) {
    bool items = argc == 4 && !strcmp(argv[3], "--power-ups");
    if (argc != 3 && !items) { fprintf(stderr, "usage: %s rebuilt.sms movie.pad [--power-ups]|--idle|--qol-controls|--deluxe-camera|--generic-actors|--opening|--polish-opening|--block-cycle\n", argv[0]); return 2; }
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
    bool actors = !strcmp(argv[2], "--generic-actors");
    bool polish = !strcmp(argv[2], "--polish-opening");
    bool bench = polish || !strcmp(argv[2], "--opening");
    bool blocks = !strcmp(argv[2], "--block-cycle");
    bool test = blocks || idle || controls || camera || actors || bench;
    FILE *movie = test ? NULL : fopen(argv[2], "r");
    if (!test && !movie) { perror(argv[2]); return 1; }
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
                 (blocks ? block_cycle() : bench ? opening(ram, bytes, polish) : actors ? generic_actors(ram) : camera ? deluxe_camera(ram) : controls ? qol_controls(ram) : idle ? idle_test(ram) : replay(movie, ram, items));
    retro_unload_game();
    retro_deinit();
    return result;
}
