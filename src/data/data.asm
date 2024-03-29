; All game state and writable data lives here. This will be placed in SRAM, so
; we're limited to 8KB (minus stack). Everything that needs to be initialized will
; be initialized in init.asm.

.dseg
.org SRAM_START

framebuffer:        .byte DISPLAY_WIDTH*DISPLAY_HEIGHT
channel1_dphase:    .byte 2
channel1_volume:    .byte 1
channel1_wave:      .byte 1 ; [waveform:1][effect:2][duration:5]
channel2_dphase:    .byte 2
channel2_volume:    .byte 1
channel2_wave:      .byte 1

music_track:        .byte 4 ; two 16-bit tracks
music_repeat:       .byte 2
sfx_track:          .byte 2 ; two 8-bit tracks

prev_controller_values: .byte 1
controller_values:  .byte 1

clock:              .byte 3

savedmem_start:

mode_clock:         .byte 1
game_mode:          .byte 1
current_sector:     .byte 2

camera_position_x:  .byte 1
camera_position_y:  .byte 1

sector_data:        .byte SECTOR_DATA_MEMSIZE
global_data:        .byte GLOBAL_DATA_MEMSIZE

preplaced_item_presence: .byte TOTAL_PREPLACED_ITEM_COUNT>>3
npc_presence:       .byte TOTAL_NPC_COUNT>>3
conversation_over:  .byte TOTAL_CONVERSATION_COUNT>>3

player_class:       .byte 1 ; [level:4][class:4]
player_position_data:
player_position_x:  .byte 1
player_subpixel_x:  .byte 1
player_velocity_x:  .byte 1
player_position_y:  .byte 1
player_subpixel_y:  .byte 1
player_velocity_y:  .byte 1
player_attack_cooldown: .byte 1
player_dash_cooldown:   .byte 1
player_dash_direction:  .byte 1
player_character:   .byte 1
player_weapon:      .byte 1
player_armor:       .byte 1
player_direction:   .byte 1
player_action:      .byte 1
player_frame:       .byte 1
player_effect:      .byte 1
player_stats:       .byte 4
player_augmented_stats: .byte 4
player_health:      .byte 1
player_gold:        .byte 2
player_xp:          .byte 2
player_effects:     .byte PLAYER_EFFECT_MEMSIZE*PLAYER_EFFECT_COUNT
player_inventory:   .byte PLAYER_INVENTORY_SIZE

savedmem_end:

sector_npcs:        .byte NPC_MEMSIZE*SECTOR_DYNAMIC_NPC_COUNT

following_spawn_x:  .byte 1
following_spawn_y:  .byte 1
following_timer:    .byte 1
following_npcs:     .byte FOLLOWING_NPC_MEMSIZE*FOLLOWING_NPC_COUNT

savepoint_used:     .byte SAVEPOINT_COUNT>>3
savepoint_data:     .byte 1 ; [status:2][index:3][frame:3]
savepoint_progress: .byte 1

sector_loose_items: .byte SECTOR_DYNAMIC_ITEM_MEMSIZE*SECTOR_DYNAMIC_ITEM_COUNT

active_effects:     .byte ACTIVE_EFFECT_MEMSIZE*ACTIVE_EFFECT_COUNT

current_shop_index: .byte 1
shop_inventory:     .byte SHOP_INVENTORY_SIZE

start_selection:
inventory_selection:
shop_selection:
selected_choice:
upgrade_selection:
npc_move_flags:     .byte 1
gameover_state:
npc_move_flags2:    .byte 1

lightning_clock:
final_time:         ; needs 3 bytes
conversation_frame: .byte 2

conversation_chars:
upgrade_points:     .byte 1

audio_state:
character_render:   .byte CHARACTER_MEMSIZE-4
subroutine_tmp:     .byte 4
end_game_allocs:

.message "Unallocated memory: ", RAMEND - end_game_allocs, " (about 0x1C needed for stack)"
