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
.equ MIN_BLOCKING_TILE_IDX = 18 ; eventually to be 64 or so

.equ MODE_STARTUP = 0
.equ MODE_ABOUT = 1
.equ MODE_HELP = 2
.equ MODE_CHARACTER = 3
.equ MODE_STORY = 4
.equ MODE_EXPLORE = 5
.equ MODE_INVENTORY = 6
.equ MODE_SHOPPING = 7
.equ MODE_CONVERSATION = 8
.equ MODE_ENDGAME = 9

.equ DIRECTION_DOWN = 0 ; ordering is convenient for reusing sprites
.equ DIRECTION_RIGHT = 1
.equ DIRECTION_UP = 2
.equ DIRECTION_LEFT = 3

.equ CHARACTER_PALADIN = 0  ; player class 1
.equ CHARACTER_HALFLING = 1 ; player class 2
.equ CHARACTER_MAGE = 2     ; player class 3
.equ CHARACTER_ZHEV = 3     ; boss
.equ CHARACTER_BANDIT = 4   ; enemy 1
.equ CHARACTER_WARRIOR = 5  ; enemy 2
.equ CHARACTER_SNEAK = 6    ; enemy 3
.equ CHARACTER_GHOUL = 7    ; enemy 4

.equ NPC_ENEMY = 0
.equ NPC_SHOPKEEPER = 1
.equ NPC_TALKER = 2
.equ NPC_SPECIAL = 3

.equ NPC_NPC_REPULSION = 4
.equ NPC_PLAYER_REPULSION = 4

.equ RUN_FRAME_DURATION_MASK = 0x7
.equ WALK_FRAME_DURATION_MASK = 0xf
.equ IDLE_MAX_SPEED = 40
.equ RUN_MIN_SPEED = 100
.equ ATTACK_FRAME_DURATION_MASK = 0x7

.equ ATTACK1_COOLDOWN = 30
.equ ATTACK2_COOLDOWN = 90
.equ STRIKING_DISTANCE = 10
.equ DIRECTION_BIAS = 5
.equ ATTACK_DAMAGE_FRAME = 2

.equ CHARACTER_COLLIDER_WIDTH = 8
.equ CHARACTER_COLLIDER_HEIGHT = 12

.equ ACTION_IDLE = 0
.equ ACTION_WALK = 1
.equ ACTION_HURT = 2
.equ ACTION_ATTACK1 = 3
.equ ACTION_ATTACK2 = 4

.equ SHOP_INVENTORY_SIZE = 12
.equ PLAYER_INVENTORY_SIZE = 12
.equ PLAYER_EFFECT_COUNT = 4

.equ ITEM_WIELDABLE = 0
.equ ITEM_WEARABLE = 1
.equ ITEM_USABLE = 2
.equ ITEM_SPECIAL = 3

.equ EVENT_ENTER = 0
.equ EVENT_EXIT = 1
