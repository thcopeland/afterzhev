.equ DISPLAY_WIDTH = 120
.equ DISPLAY_HEIGHT = 66
.equ FOOTER_HEIGHT = 6

.equ DISPLAY_VERTICAL_STRETCH = 5
.equ DISPLAY_CLK_TOP = (VSYNC_BACK_PORCH+1)
.equ DISPLAY_CLK_BOTTOM = (HSYNC_PERIOD*DISPLAY_VERTICAL_STRETCH*DISPLAY_HEIGHT/VSYNC_PRESCALER + DISPLAY_CLK_TOP)

.equ AUDIO_SAMPLING_PERIOD = HSYNC_PERIOD*2

.equ SECTOR_DATA_MEMSIZE = 1
.equ GLOBAL_DATA_MEMSIZE = 4

.equ SECTOR_COUNT = 64
.equ SECTOR_WIDTH = 20
.equ SECTOR_HEIGHT = 15
.equ SECTOR_NPC_COUNT = 6
.equ SECTOR_PREPLACED_ITEM_COUNT = 4
.equ SECTOR_PREPLACED_ITEM_MEMSIZE = 4
.equ SECTOR_SAVEPOINT_MEMSIZE = 4
.equ SECTOR_AVENGER_PLACES_MEMSIZE = 4
.equ SECTOR_PORTAL_COUNT = 4
.equ SECTOR_PORTAL_MEMSIZE = 5
.equ SECTOR_FEATURE_COUNT = 6
.equ SECTOR_FEATURE_MEMSIZE = 3
.equ SECTOR_FLAGS_MEMSIZE = 2
.equ SECTOR_MEMSIZE = SECTOR_WIDTH*SECTOR_HEIGHT + 4 + SECTOR_NPC_COUNT + SECTOR_PREPLACED_ITEM_COUNT*SECTOR_PREPLACED_ITEM_MEMSIZE + SECTOR_SAVEPOINT_MEMSIZE + SECTOR_AVENGER_PLACES_MEMSIZE + SECTOR_PORTAL_COUNT*SECTOR_PORTAL_MEMSIZE + SECTOR_FEATURE_COUNT*SECTOR_FEATURE_MEMSIZE + SECTOR_FLAGS_MEMSIZE + 10
.equ SECTOR_AJD_OFFSET = SECTOR_WIDTH*SECTOR_HEIGHT
.equ SECTOR_NPC_OFFSET = SECTOR_AJD_OFFSET + 4
.equ SECTOR_ITEMS_OFFSET = SECTOR_NPC_OFFSET + SECTOR_NPC_COUNT
.equ SECTOR_SAVEPOINT_OFFSET = SECTOR_ITEMS_OFFSET + SECTOR_PREPLACED_ITEM_COUNT*SECTOR_PREPLACED_ITEM_MEMSIZE
.equ SECTOR_AVENGER_PLACES_OFFSET = SECTOR_SAVEPOINT_OFFSET + SECTOR_SAVEPOINT_MEMSIZE
.equ SECTOR_PORTALS_OFFSET = SECTOR_AVENGER_PLACES_OFFSET + SECTOR_AVENGER_PLACES_MEMSIZE
.equ SECTOR_FEATURES_OFFSET = SECTOR_PORTALS_OFFSET + SECTOR_PORTAL_COUNT*SECTOR_PORTAL_MEMSIZE
.equ SECTOR_FLAGS_OFFSET = SECTOR_FEATURES_OFFSET + SECTOR_FEATURE_COUNT*SECTOR_FEATURE_MEMSIZE
.equ SECTOR_UPDATE_OFFSET = SECTOR_FLAGS_OFFSET + SECTOR_FLAGS_MEMSIZE
.equ SECTOR_ON_ENTER_OFFSET = SECTOR_UPDATE_OFFSET + 2
.equ SECTOR_ON_EXIT_OFFSET = SECTOR_ON_ENTER_OFFSET + 2
.equ SECTOR_ON_CONVERSATION_OFFSET = SECTOR_ON_EXIT_OFFSET + 2
.equ SECTOR_ON_CHOICE_OFFSET = SECTOR_ON_CONVERSATION_OFFSET + 2

.equ SECTOR_ITEM_IDX_OFFSET = 0
.equ SECTOR_ITEM_PREPLACED_IDX_OFFSET = 1
.equ SECTOR_ITEM_X_OFFSET = 2
.equ SECTOR_ITEM_Y_OFFSET = 3
.equ TOTAL_PREPLACED_ITEM_COUNT = 32
.equ SECTOR_DYNAMIC_ITEM_MEMSIZE = SECTOR_PREPLACED_ITEM_MEMSIZE
.equ SECTOR_DYNAMIC_ITEM_COUNT = 6

.equ TOTAL_NPC_COUNT = 120 ; should be divisible by 8
.equ SECTOR_DYNAMIC_NPC_COUNT = SECTOR_NPC_COUNT
.equ NPC_IDX_OFFSET = 0
.equ NPC_ANIM_OFFSET = 1 ; action:3, frame:3, direction:2
.equ NPC_POSITION_OFFSET = 2
.equ NPC_HEALTH_OFFSET = 8
.equ NPC_EFFECT_OFFSET = 9
.equ NPC_MEMSIZE = 10

.equ NPC_TABLE_ENTRY_MEMSIZE = 16
.equ NPC_TABLE_TYPE_OFFSET = 0
.equ NPC_TABLE_CHARACTER_OFFSET = 1
.equ NPC_TABLE_WEAPON_OFFSET = 2
.equ NPC_TABLE_ARMOR_OFFSET = 3
.equ NPC_TABLE_DIRECTION_OFFSET = 4
.equ NPC_TABLE_HEALTH_OFFSET = 5
.equ NPC_TABLE_XPOS_OFFSET = 6
.equ NPC_TABLE_YPOS_OFFSET = 7
.equ NPC_TABLE_ENEMY_FLAGS_OFFSET = 8
.equ NPC_TABLE_ENEMY_XP_OFFSET = 9
.equ NPC_TABLE_ENEMY_ACC_OFFSET = 10
.equ NPC_TABLE_ENEMY_ATTACK_OFFSET = 11
.equ NPC_TABLE_ENEMY_DEFENSE_OFFSET = 12
.equ NPC_TABLE_ENEMY_DROPS_OFFSET = 13
.equ NPC_TABLE_ENEMY_DROPS_COUNT = 3
.equ NPC_TABLE_AVENGER_OFFSET = 8
.equ NPC_TABLE_SHOP_IDX_OFFSET = 9
.equ NPC_TABLE_TALKER_CONV1_OFFSET = 9
.equ NPC_TABLE_TALKER_CONV2_OFFSET = 12
.equ NPC_TABLE_TALKER_CONV_COUNT = 2
.equ NPC_TABLE_TALKER_REPLACEMENT_OFFSET = 15

.equ SHOP_INITIAL_INVENTORY_SIZE = 8
.equ SHOP_NAME_PTR_OFFSET = 0
.equ SHOP_PRICE_CONST_OFFSET = 2
.equ SHOP_PRICE_FACTOR_OFFSET = 3
.equ SHOP_ITEMS_OFFSET = 4
.equ SHOP_MEMSIZE = 12

.equ TOTAL_CONVERSATION_COUNT = 32
.equ CONVERSATION_TYPE_OFFSET = 0
.equ CONVERSATION_LINE_NPC_OFFSET = 1
.equ CONVERSATION_LINE_SPEAKER_OFFSET = 2
.equ CONVERSATION_LINE_STR_OFFSET = 4
.equ CONVERSATION_LINE_NEXT_OFFSET = 6
.equ CONVERSATION_BRANCH_NUM_OFFSET = 1
.equ CONVERSATION_BRANCH_CHOICE1_OFFSET = 2
.equ CONVERSATION_BRANCH_CHOICE2_OFFSET = 6
.equ CONVERSATION_BRANCH_CHOICE3_OFFSET = 10
.equ CONVERSATION_BRANCH_CHOICE4_OFFSET = 12
.equ CONVERSATION_BRANCH_CHOICE_MEMSIZE = 4

.equ TILE_WIDTH = 12
.equ TILE_HEIGHT = 12
.equ TILE_MEMSIZE = TILE_WIDTH*TILE_HEIGHT

.if TILE_WIDTH != 12 || TILE_HEIGHT != 12
.error "Collision and sector rendering assume a tile width and height of 12 (replace these occurrences of divmod12u and div12u)."
.endif

.equ DISPLAY_HORIZONTAL_TILES = DISPLAY_WIDTH/TILE_WIDTH
.equ DISPLAY_VERTICAL_TILES = (DISPLAY_HEIGHT-FOOTER_HEIGHT)/TILE_HEIGHT

.equ CLASS_MEMSIZE = 94
.equ CLASS_STATS_OFFSET = 0
.equ CLASS_NAME_OFFSET = 4
.equ CLASS_DESC_OFFSET = 12

.equ CHARACTER_MEMSIZE = 7
.equ CHARACTER_SPRITE_OFFSET = 0
.equ CHARACTER_WEAPON_OFFSET = 1
.equ CHARACTER_ARMOR_OFFSET = 2
.equ CHARACTER_DIRECTION_OFFSET = 3
.equ CHARACTER_ACTION_OFFSET = 4
.equ CHARACTER_FRAME_OFFSET = 5
.equ CHARACTER_EFFECT_OFFSET = 6

.equ CHARACTER_POSITION_MEMSIZE = 6
.equ CHARACTER_POSITION_X_H = 0
.equ CHARACTER_POSITION_X_L = 1
.equ CHARACTER_POSITION_DX = 2
.equ CHARACTER_POSITION_Y_H = 3
.equ CHARACTER_POSITION_Y_L = 4
.equ CHARACTER_POSITION_DY = 5

.equ CHARACTER_SPRITE_WIDTH = TILE_WIDTH
.equ CHARACTER_SPRITE_HEIGHT = TILE_HEIGHT
.equ CHARACTER_SPRITE_MEMSIZE = CHARACTER_SPRITE_WIDTH*CHARACTER_SPRITE_HEIGHT
.equ CHARACTER_ANIM_WALK_FRAMES = 4
.equ CHARACTER_ANIM_IDLE_FRAMES = 1
.equ CHARACTER_ANIM_WALK_FRAMES_OFFSET = 0
.equ CHARACTER_ANIM_IDLE_FRAMES_OFFSET = 4*CHARACTER_ANIM_WALK_FRAMES
.equ CHARACTER_ANIM_TOTAL_FRAMES = 4*(CHARACTER_ANIM_WALK_FRAMES+CHARACTER_ANIM_IDLE_FRAMES)
.equ CHARACTER_ANIM_MEMSIZE = CHARACTER_SPRITE_MEMSIZE*CHARACTER_ANIM_TOTAL_FRAMES

.equ WEAPON_WALK_FRAMES = 4
.equ WEAPON_WALK_TOTAL_FRAMES = 2*WEAPON_WALK_FRAMES
.equ WEAPON_WALK_OFFSET_FRAMES = 0
.equ WEAPON_IDLE_FRAMES = 1
.equ WEAPON_IDLE_TOTAL_FRAMES = 2*WEAPON_IDLE_FRAMES
.equ WEAPON_IDLE_OFFSET_FRAMES = WEAPON_WALK_OFFSET_FRAMES + WEAPON_WALK_TOTAL_FRAMES
.equ WEAPON_ATTACK_FRAMES = 4
.equ WEAPON_ATTACK_TOTAL_FRAMES = 2*WEAPON_ATTACK_FRAMES
.equ WEAPON_ATTACK_OFFSET_FRAMES = WEAPON_IDLE_OFFSET_FRAMES + WEAPON_IDLE_TOTAL_FRAMES

.equ WEARABLE_WALK_FRAMES = 4
.equ WEARABLE_WALK_TOTAL_FRAMES = 4*WEARABLE_WALK_FRAMES
.equ WEARABLE_WALK_OFFSET_FRAMES = 0
.equ WEARABLE_IDLE_FRAMES = 1
.equ WEARABLE_IDLE_TOTAL_FRAMES = 4*WEARABLE_IDLE_FRAMES
.equ WEARABLE_IDLE_OFFSET_FRAMES = WEARABLE_WALK_OFFSET_FRAMES + WEARABLE_WALK_TOTAL_FRAMES
.equ ANIMATED_ITEM_ENTRY_MEMSIZE = 80

.equ STATIC_ITEM_WIDTH = 6
.equ STATIC_ITEM_HEIGHT = 6
.equ STATIC_ITEM_MEMSIZE = STATIC_ITEM_WIDTH*STATIC_ITEM_HEIGHT

.equ ITEM_MEMSIZE = 12
.equ ITEM_NAME_PTR_OFFSET = 0
.equ ITEM_DESC_PTR_OFFSET = 2
.equ ITEM_FLAGS_OFFSET = 4
.equ ITEM_COST_OFFSET = 5
.equ ITEM_STATS_OFFSET = 7
.equ ITEM_EXTRA_OFFSET = 11

.equ FONT_KERNING = 1
.equ FONT_CHARACTER_WIDTH = 3
.equ FONT_CHARACTER_HEIGHT = 6
.equ FONT_DISPLAY_WIDTH = FONT_CHARACTER_WIDTH+FONT_KERNING
.equ FONT_DISPLAY_HEIGHT = FONT_CHARACTER_HEIGHT

.equ STATS_STRENGTH_OFFSET = 0
.equ STATS_VITALITY_OFFSET = 1
.equ STATS_DEXTERITY_OFFSET = 2
.equ STATS_INTELLECT_OFFSET = 3
.equ STATS_COUNT = 4
.equ STATS_RANGE = 60

.equ PLAYER_EFFECT_MEMSIZE = 2
.equ PLAYER_EFFECT_IDX_OFFSET = 0
.equ PLAYER_EFFECT_TIME_OFFSET = 1

.equ EFFECT_SPRITE_WIDTH = 12
.equ EFFECT_SPRITE_HEIGHT = 12
.equ EFFECT_SPRITE_MEMSIZE = EFFECT_SPRITE_WIDTH*EFFECT_SPRITE_HEIGHT

.equ ACTIVE_EFFECT_COUNT = 4
.equ ACTIVE_EFFECT_MEMSIZE = 4
.equ ACTIVE_EFFECT_DATA_OFFSET = 0
.equ ACTIVE_EFFECT_DATA2_OFFSET = 1
.equ ACTIVE_EFFECT_X_OFFSET = 2
.equ ACTIVE_EFFECT_Y_OFFSET = 3

.equ SAVEPOINT_SPRITE_WIDTH = 12
.equ SAVEPOINT_SPRITE_HEIGHT = 12
.equ SAVEPOINT_SPRITE_MEMSIZE = SAVEPOINT_SPRITE_WIDTH*SAVEPOINT_SPRITE_HEIGHT
.equ SAVEPOINT_BASE_OFFSET = 0
.equ SAVEPOINT_SAVING_OFFSET = 1
.equ SAVEPOINT_DONE_OFFSET = 4
.equ SAVEPOINT_COUNT = 8

.equ SAVEPOINT_DATA_START = 0x10

.equ FEATURE_SPRITE_WIDTH = 12
.equ FEATURE_SPRITE_HEIGHT = 12

.equ FOLLOWING_NPC_IDX_OFFSET = 0
.equ FOLLOWING_NPC_HEALTH_OFFSET = 1
.equ FOLLOWING_NPC_MEMSIZE = 2
.equ FOLLOWING_NPC_COUNT = 4
