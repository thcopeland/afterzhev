.equ CONTROLS_UP = 0
.equ CONTROLS_DOWN = 1
.equ CONTROLS_LEFT = 2
.equ CONTROLS_RIGHT = 3

.equ CAMERA_HORIZONTAL_PADDING_L = 6
.equ CAMERA_HORIZONTAL_PADDING_H = 1
.equ CAMERA_VERTICAL_PADDING_L = 6
.equ CAMERA_VERTICAL_PADDING_H = 1

.equ TRANSPARENT = 0xc7 ; magenta
.equ MIN_BLOCKING_TILE_IDX = 1 ; eventually to be 64 or so

.equ MODE_STARTUP = 0
.equ MODE_CHARACTER = 1
.equ MODE_STORY = 2
.equ MODE_EXPLORE = 3
.equ MODE_INVENTORY = 4
.equ MODE_STORE = 5
.equ MODE_CONVERSATION = 6
.equ MODE_ENDGAME = 7

.equ CHARACTER_PALADIN = 0  ; player class 1
.equ CHARACTER_HALFLING = 1 ; player class 2 (hard, bold, and wicked!)
.equ CHARACTER_MAGE = 2     ; player class 3
.equ CHARACTER_ZHEV = 3     ; boss
.equ CHARACTER_BANDIT = 4   ; enemy 1
.equ CHARACTER_WARRIOR = 5  ; enemy 2
.equ CHARACTER_SNEAK = 6    ; enemy 3
.equ CHARACTER_GHOUL = 7    ; enemy 4

.equ ACTION_IDLE = 0
.equ ACTION_WALK = 1
.equ ACTION_STAB = 2
.equ ACTION_SLASH = 3
.equ ACTION_BIGSLASH = 4
.equ ACTION_HURT = 5
