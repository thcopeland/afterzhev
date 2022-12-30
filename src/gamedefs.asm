.equ CONTROLS_DOWN = 0
.equ CONTROLS_RIGHT = 1
.equ CONTROLS_UP = 2
.equ CONTROLS_LEFT = 3
.equ CONTROLS_SPECIAL1 = 4
.equ CONTROLS_SPECIAL2 = 5
.equ CONTROLS_SPECIAL3 = 6
.equ CONTROLS_SPECIAL4 = 7

.equ CAMERA_VERTICAL_PADDING = 18
.equ CAMERA_HORIZONTAL_PADDING = 24

.equ TRANSPARENT = 0xc7 ; magenta

; must be non-decreasing order
.equ END_UPPER_LEFT_BLOCKING_IDX = 7
.equ END_LOWER_RIGHT_BLOCKING_IDX = 15
.equ END_LOWER_LEFT_BLOCKING_IDX = 23
.equ END_UPPER_RIGHT_BLOCKING_IDX = 30
.equ END_FULL_BLOCKING_IDX = 164

.equ NO_NPC = 0
.equ NO_SHOP = 0
.equ NO_ITEM = 0
.equ NO_HANDLER = 0

.equ MODE_STARTUP = 0
.equ MODE_ABOUT = 1
.equ MODE_HELP = 2
.equ MODE_CHARACTER = 3
.equ MODE_STORY = 4
.equ MODE_EXPLORE = 5
.equ MODE_INVENTORY = 6
.equ MODE_SHOPPING = 7
.equ MODE_CONVERSATION = 8
.equ MODE_UPGRADE = 9
.equ MODE_GAMEOVER = 10

.equ GAME_OVER_DEAD = 0
.equ GAME_OVER_POISONED = 1
.equ GAME_OVER_WIN = 2

.equ DIRECTION_DOWN = 0 ; ordering is convenient for reusing sprites and bitwise checks, do not change lightly
.equ DIRECTION_RIGHT = 1
.equ DIRECTION_UP = 2
.equ DIRECTION_LEFT = 3

.equ CLASS_PALADIN = 0
.equ CLASS_ROGUE = 1
.equ CLASS_MAGE = 2

.equ LEVEL_1_XP = 100
.equ LEVEL_2_XP = 600
.equ LEVEL_3_XP = 3600

.equ UPGRADE_1_POINTS = 8
.equ UPGRADE_2_POINTS = 8
.equ UPGRADE_3_POINTS = 6

.equ CHARACTER_MAN = 0
.equ CHARACTER_HALFLING = 1
.equ CHARACTER_ELF = 2
.equ CHARACTER_CHILD = 3
.equ CHARACTER_BANDIT = 4
.equ CHARACTER_GHOUL = 5
.equ CHARACTER_ZHEV = 6
.equ CHARACTER_FOX = 7

.equ NPC_ENEMY = 0
.equ NPC_SHOPKEEPER = 1
.equ NPC_TALKER = 2
.equ NPC_SPECIAL = 3

.equ NPC_DEFAULT_DEFENSE = 5 ; used for shops and talkers

.equ NPC_NPC_REPULSION = 4
.equ NPC_PLAYER_REPULSION = 4

.equ NPC_MOVE_FRICTION = 0x01   ; affected by friction
.equ NPC_MOVE_REBOUND  = 0x02   ; bounce off sector boundaries and obstacles
.equ NPC_MOVE_LOOKAT   = 0x04   ; face some position
.equ NPC_MOVE_GOTO     = 0x08   ; move within striking distance of some position
.equ NPC_MOVE_FALLOFF  = 0x10   ; only move towards or face position if within some distance
.equ NPC_MOVE_ATTACK   = 0x20   ; whether to attack
.equ NPC_MOVE_RETURN   = 0x40   ; return to starting point if beyond some distance
.equ NPC_MOVE_POLTROON = 0x80   ; move away from the player if health is low

.equ NPC_INTEREST_DISTANCE = 48 ; NPC_MOVE_FALLOFF distance
.equ NPC_FLEE_HEALTH = 10       ; NPC_MOVE_POLTROON health

.equ RUN_FRAME_DURATION_MASK = 0x3
.equ WALK_FRAME_DURATION_MASK = 0x7
.equ IDLE_MAX_SPEED = 40
.equ RUN_MIN_SPEED = 100
.equ ATTACK_FRAME_DURATION_MASK = 0x7
.equ DASH_FRAME_DURATION_MASK = 0x3
.equ DASH_DURATION = 4

.equ STRIKING_DISTANCE = 10 ; base striking distance, scaled by individual weapons
.equ DIRECTION_BIAS = 3
.equ ATTACK_DAMAGE_FRAME = 1
.equ RANGED_LAUNCH_FRAME = 1

; used for character-character collisions only
.equ CHARACTER_COLLIDER_WIDTH = 8
.equ CHARACTER_COLLIDER_HEIGHT = 2

; used for character-world collisions only
.equ CHARACTER_COLLIDER_OFFSET_X = CHARACTER_SPRITE_WIDTH/2
.equ CHARACTER_COLLIDER_OFFSET_Y = CHARACTER_SPRITE_HEIGHT-2

.equ ACTION_IDLE = 0
.equ ACTION_WALK = 1
.equ ACTION_DASH = 2
.equ ACTION_ATTACK = 3

.equ NPC_HEALTH_BAR_LENGTH = 12

.equ EFFECT_DAMAGE = 1
.equ EFFECT_DAMAGE_DURATION = 4
.equ EFFECT_DAMAGE_FRAME_DURATION_MASK = 0x07
.equ EFFECT_ARROW = 2
.equ EFFECT_ATTACK_FIRE = 3
.equ EFFECT_ATTACK_FIRE_DURATION = 6
.equ EFFECT_ATTACK_FIRE_FRAME_DURATION_MASK = 0x3

; used for ranged NPC attacks
.equ EFFECT_ARROW_RANGE_ESTIMATE = 80
.equ EFFECT_DEFAULT_RANGE_ESTIMATE = 40

.equ EFFECT_ROLE_DAMAGE_NONE = 0 ; order is convenient for bitwise stuff
.equ EFFECT_ROLE_DAMAGE_NPCS = 1
.equ EFFECT_ROLE_DAMAGE_PLAYER = 2
.equ EFFECT_ROLE_DAMAGE_ALL = 3

.equ EFFECT_DAMAGE_DISTANCE = 8
.equ EFFECT_DEFAULT_DAMAGE = 4

.equ SHOP_INVENTORY_SIZE = 12
.equ PLAYER_INVENTORY_SIZE = 12
.equ PLAYER_EFFECT_COUNT = 2

.equ ITEM_WIELDABLE = 0
.equ ITEM_RANGED = 1
.equ ITEM_WEARABLE = 2
.equ ITEM_USABLE = 3

.equ ITEM_HIGH_LEVEL_INTELLECT = 20

.equ SECTOR_FLAG_FOLLOW_DOWN = 0x01
.equ SECTOR_FLAG_FOLLOW_RIGHT = 0x02
.equ SECTOR_FLAG_FOLLOW_UP = 0x04
.equ SECTOR_FLAG_FOLLOW_LEFT = 0x08
.equ SECTOR_FLAG_FOLLOW_PORTAL = 0x10
.equ SECTOR_FLAG_FOLLOW_ALL = SECTOR_FLAG_FOLLOW_DOWN|SECTOR_FLAG_FOLLOW_RIGHT|SECTOR_FLAG_FOLLOW_UP|SECTOR_FLAG_FOLLOW_LEFT|SECTOR_FLAG_FOLLOW_LEFT

.equ STATS_STRENGTH_COLOR = 0x22
.equ STATS_VITALITY_COLOR = 0x0e
.equ STATS_DEXTERITY_COLOR = 0x26
.equ STATS_INTELLECT_COLOR = 0x94

.equ SAVEPOINT_FRAME_MASK = 0x07
.equ SAVEPOINT_DISTANCE = 10
.equ SAVEPOINT_MAGIC = 42

.equ PORTAL_DISTANCE = 8

.equ FEATURE_CHAIR_DOWN = 1
.equ FEATURE_CHAIR_UP = 2
.equ FEATURE_CHAIR_RIGHT = 3
.equ FEATURE_CHAIR_LEFT = 4
.equ FEATURE_CAMPFIRE = 5
.equ FEATURE_BUSH = 6
.equ FEATURE_ARMCHAIR_RIGHT = 7
.equ FEATURE_ARMCHAIR_LEFT = 8
.equ FEATURE_WINDOW = 9
.equ FEATURE_SHUTTERS = 10
.equ FEATURE_STOOL = 11
.equ FEATURE_BARREL = 12
.equ FEATURE_BLOOD_BONE = 13
.equ FEATURE_BONE = 14
.equ FEATURE_INVISIBLE = 15
.equ FEATURE_DOOR_CLOSED = 16
.equ FEATURE_DOOR_OPEN = 17
.equ FEATURE_LADDER = 18

.equ MAX_FEATURE_COLLIDE_IDX = 15
.equ FEATURE_COLLIDE_RANGE = 7

.equ ADD_NPC_MAX_X_DISTANCE = DISPLAY_WIDTH/TILE_WIDTH
.equ ADD_NPC_MAX_Y_DISTANCE = DISPLAY_HEIGHT/TILE_HEIGHT

.equ FOLLOWER_DELAY = 20
.equ FOLLOWER_DISTANCE = NPC_INTEREST_DISTANCE-1 ; should be less than interest distance
.equ FOLLOWER_SPEED = 10 ; should be nonzero, or non-enemy NPCs will follow

.include "names.asm"
.include "quests.asm"
