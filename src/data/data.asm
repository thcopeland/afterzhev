; All game state and writable data lives here. This will be placed in SRAM, so
; we're limited to 8KB (minus stack). Everything that needs to be initialized will
; be initialized in init.asm.

    .dseg
    .org SRAM_START

framebuffer:        .byte DISPLAY_WIDTH*DISPLAY_HEIGHT

prev_controller_values: .byte 1
controller_values:  .byte 1

savedmem_start:

clock:              .byte 2
mode_clock:         .byte 2
seed:               .byte 2

game_mode:          .byte 1
current_sector:     .byte 2

camera_position_x:  .byte 1
camera_position_y:  .byte 1

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
sector_data:        .byte 4
global_data:        .byte 8

preplaced_item_presence: .byte TOTAL_PREPLACED_ITEM_COUNT>>3
npc_presence:       .byte TOTAL_NPC_COUNT>>3
conversation_over:  .byte TOTAL_CONVERSATION_COUNT>>3

savedmem_end:

savepoint_used:     .byte SAVEPOINT_COUNT>>3

sector_loose_items: .byte SECTOR_DYNAMIC_ITEM_MEMSIZE*SECTOR_DYNAMIC_ITEM_COUNT

sector_npcs:        .byte NPC_MEMSIZE*SECTOR_DYNAMIC_NPC_COUNT

savepoint_data:     .byte 1 ; [status:2][index:3][frame:3]
savepoint_progress: .byte 1

active_effects:     .byte ACTIVE_EFFECT_MEMSIZE*ACTIVE_EFFECT_COUNT

inventory_selection:
shop_selection:
selected_choice:
upgrade_selection:
gameover_state:     .byte 1

current_shop_index: .byte 1
shop_inventory:     .byte SHOP_INVENTORY_SIZE

conversation_frame: .byte 2

upgrade_points:     .byte 1

character_render:   .byte CHARACTER_MEMSIZE-3
npc_move_flags:     .byte 1
npc_move_data:      .byte 2
