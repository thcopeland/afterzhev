; All game state and writable data lives here. This will be placed in SRAM, so
; we're limited to 8KB (minus stack). Everything that needs to be initialized will
; be initialized in init.asm.

    .dseg
    .org SRAM_START

framebuffer:        .byte DISPLAY_WIDTH*DISPLAY_HEIGHT
vid_fbuff_offset:   .byte 2
vid_row_repeat:     .byte 1
vid_work_complete:  .byte 1
clock:              .byte 2
mode_clock:         .byte 1

prev_controller_values: .byte 1
controller_values:  .byte 1

game_mode:          .byte 1
current_sector:     .byte 2

preplaced_item_presence: .byte TOTAL_PREPLACED_ITEM_COUNT>>3
sector_loose_items: .byte SECTOR_DYNAMIC_ITEM_MEMSIZE*SECTOR_DYNAMIC_ITEM_COUNT

npc_presence:       .byte TOTAL_NPC_COUNT>>3
sector_npcs:        .byte NPC_MEMSIZE*SECTOR_DYNAMIC_NPC_COUNT
character_render:   .byte CHARACTER_MEMSIZE

camera_position_x:  .byte 2
camera_position_y:  .byte 2

player_class:       .byte 1
player_acceleration:.byte 1
player_subpixel_x:  .byte 1
player_position_x:  .byte 2
player_velocity_x:  .byte 1
player_subpixel_y:  .byte 1
player_position_y:  .byte 2
player_velocity_y:  .byte 1
player_cooldown:    .byte 1
player_character:   .byte 1
player_weapon:      .byte 1
player_armor:       .byte 1
player_direction:   .byte 1
player_action:      .byte 1
player_frame:       .byte 1
player_stats:       .byte 4
player_augmented_stats: .byte 4
player_health:      .byte 1
player_max_health:  .byte 1
player_gold:        .byte 1
player_xp:          .byte 2
player_effects:     .byte PLAYER_EFFECT_MEMSIZE*PLAYER_EFFECT_COUNT
player_inventory:   .byte PLAYER_INVENTORY_SIZE

inventory_selection: .byte 1

shop_inventory:     .byte SHOP_INVENTORY_SIZE
shop_selection:     .byte 1
