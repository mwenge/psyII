NUM_ROWS                         = $18
NUM_COLS                         = $28

BOTTOM_Y_POSITION                = NUM_ROWS-2

PAINTED_GRID                     = $84
UNPAINTED_GRID                   = $83
GLOWING_GRID                     = $84

BLACK                            = $00
WHITE                            = $01
RED                              = $02
CYAN                             = $03
PURPLE                           = $04
GREEN                            = $05
BLUE                             = $06
YELLOW                           = $07
ORANGE                           = $08
BROWN                            = $09
LTRED                            = $0A
GRAY1                            = $0B
GRAY2                            = $0C
LTGREEN                          = $0D
LTBLUE                           = $0E
GRAY3                            = $0F

KEY_INST_DEL                     = $00
KEY_RETURN                       = $01
KEY_CRSR_LEFT_RIGHT              = $02
KEY_F7_F8                        = $03
KEY_F1_F2                        = $04
KEY_F3_F4                        = $05
KEY_F5_F6                        = $06
KEY_CRSR_UP_DOWN                 = $07
KEY_3                            = $08
KEY_W                            = $09
KEY_A                            = $0A
KEY_4                            = $0B
KEY_Z                            = $0C
KEY_S                            = $0D
KEY_E                            = $0E
KEY_UNUSED                       = $0F
KEY_5                            = $10
KEY_R                            = $11
KEY_D                            = $12
KEY_6                            = $13
KEY_C                            = $14
KEY_F                            = $15
KEY_T                            = $16
KEY_X                            = $17
KEY_7                            = $18
KEY_Y                            = $19
KEY_G                            = $1A
KEY_8                            = $1B
KEY_B                            = $1C
KEY_H                            = $1D
KEY_U                            = $1E
KEY_V                            = $1F
KEY_9                            = $20
KEY_I                            = $21
KEY_J                            = $22
KEY_0                            = $23
KEY_M                            = $24
KEY_K                            = $25
KEY_O                            = $26
KEY_N                            = $27
KEY_PLUS                         = $28
KEY_P                            = $29
KEY_L                            = $2A
KEY_MINUS                        = $2B
KEY_GT                           = $2C
KEY_SQBR                         = $2D
KEY_AT                           = $2E
KEY_TRBR                         = $2F
KEY_POUND                        = $30
KEY_ASTERISK                     = $31
KEY_RIGHTSQ                      = $32
KEY_CLR_HOME                     = $33
KEY_UNUSED2                      = $34
KEY_EQUAL                        = $35
KEY_UP                           = $36
KEY_QUESTION                     = $37
KEY_1                            = $38
KEY_LEFT                         = $39
KEY_UNUSED3                      = $3A
KEY_2                            = $3B
KEY_SPACE                        = $3C
KEY_UNUSED4                      = $3D
KEY_Q                            = $3E
KEY_RUN_STOP                     = $3F
NO_KEY_PRESSED                   = $40

JOYSTICK_FIRE                    = $10
JOYSTICK_RIGHT                   = $08
JOYSTICK_LEFT                    = $04
JOYSTICK_DOWN                    = $02
JOYSTICK_UP                      = $01

SCREEN_RAM                       = $0400
COLOR_RAM                        = $D800
CURRENT_CHAR_COLOR               = $0286
ROM_IOINIT                       = $FF84
ROM_READST                       = $FFB7
ROM_SETLFS                       = $FFBA
ROM_SETNAM                       = $FFBD
ROM_LOAD                         = $FFD5
ROM_SAVE                         = $FFD8
ROM_CLALL                        = $FFE7
RETURN_INTERRUPT                 = $EA31


; Variable modes.
COLOR_BAR_CURRENT                = $00
SMOOTHING_DELAY                  = $01
CURSOR_SPEED                     = $02
BUFFER_LENGTH                    = $03
PULSE_SPEED                      = $04
COLOR_CHANGE                     = $05
LINE_WIDTH                       = $06
SEQUENCER_SPEED                  = $07
PULSE_WIDTH                      = $08
BASE_LEVEL                       = $09

CUSTOM_PRESET_ACTIVE             = $83
SAVING_ACTIVE                    = $84
LOADING_ACTIVE                   = $85
SEQUENCER_OR_BURST_ACTIVE        = $80

CUSTOM_PRESET_MODE_ACTIVE        = $17
SAVE_PROMPT_MODE_ACTIVE          = $18

NO_SYMMETRY                      = $00
Y_AXIS_SYMMETRY                  = $01
X_Y_SYMMETRY                     = $02
X_AXIS_SYMMETRY                  = $03
QUAD_SYMMETRY                    = $04

STARONE                          = $00
THETWIST                         = $01
LALLAMITA                        = $02
STARTWO                          = $03
DELTOID                          = $04
DIFFUSED                         = $05
MULTICROSS                       = $06
PULSAR                           = $07

CUSTOMPATTERN0                   = $08
CUSTOMPATTERN1                   = $09
CUSTOMPATTERN2                   = $0A
CUSTOMPATTERN3                   = $0B
CUSTOMPATTERN4                   = $0C
CUSTOMPATTERN5                   = $0D
CUSTOMPATTERN6                   = $0E
CUSTOMPATTERN7                   = $0F

NOT_ACTIVE                       = $00
ACTIVE                           = $01
GENERIC_ACTIVE                   = $FF

COLOR_VALUES_ARRAY_LEN           = $08
PIXEL_BUFFER_LENGTH              = $40
LINE_MODE_ACTIVE                 = $80
DISPLAY_LINE_LENGTH              = $10
OFFSET_TO_COLOR_RAM              = $D4
COLON                            = $BA

OFFSET_TO_NEXT_BURST             = $03
BURST_AND_SEQUENCER_END_SENTINEL = $C0
SHIFT_PRESSED                    = $01

COLOR_MAX                        = $0F
NUM_ARRAYS                       = $07
BELOW_ZERO                       = $FF

SAVE_PARAMETERS                  = $01
SAVE_MOTIONS                     = $02
CONTINUE_SAVE                    = $03
RECORDING                        = $03
PLAYING_BACK                     = $02

BLOCK                            = $CF
CIRCLE                           = $51
HEART                            = $53
DIAMOND                          = $5A
CROSS                            = $5B
TOP_RIGHT_TRIANGLE               = $5F
DONUT                            = $57
CHECKER                          = $7F
ANDREWS_CROSS                    = $56
LEFT_HALF                        = $61
TOP_LEFT_BRACKET                 = $4F
FULL_CHECKER                     = $66
BOTTOM_RIGHT_SQUARE              = $6C
BOTTOM_RIGHT_SQUARE2             = $EC
SPACE_MAYBE                      = $A0
ASTERISK                         = $2A

SPACE                            = $20
LEFT_BAR_ONE_FIFTH               = $65
LEFT_BAR_TWO_FIFTHS              = $74
LEFT_BAR_TWO_FIFTHS2             = $75
LEFT_BAR_THREE_FIFTHS            = $61
RIGHT_BAR_ONE_FIFTHS             = $F6
RIGHT_BAR_TWO_FIFTHS             = $EA
RIGHT_BAR_TWO_FIFTHS2            = $E7

PLAY_SOUND = $00
; 'Plays' the value in Byte 2 by writing it to the SID register given
; by the offset in Byte 3.
; Byte 0 - Unused
; Byte 1 - $00 (PLAY_SOUND)
; Byte 2 - Value to write to offset to $D400 given by Byte 3.
; Byte 3 - Offset to $D400 to write to.
; Byte 4 - '00' indicates the next record should be played immediately.
;          '01' indicates should play no more records.
;          Anything else indicates the next record should be stored and
;           no more should be played for now.

INC_AND_PLAY_FROM_BUFFER = $01
; Picks a value from soundEffectBuffer using Byte 0 as an index, increments
; it with Byte 2, and then 'plays' it to the register given by Byte 3.
; Byte 0 - Address of byte to pick from soundEffectBuffer
; Byte 1 - $01 (INC_AND_PLAY_FROM_BUFFER)
; Byte 2 - Amount to increment picked byte by.
; Byte 3 - Offset to $D400 to write to.
; Byte 4 - '00' indicates the next record should be played immediately.
;          '01' indicates should play no more records.
;          Anything else indicates the next record should be stored and
;           no more should be played for now.

DEC_AND_PLAY_FROM_BUFFER = $02
; Picks a value from soundEffectBuffer using Byte 0 as an index, decrements
; it with Byte 2, and then 'plays' it to the register given by Byte 3.
; Byte 0 - Address of byte to pick from soundEffectBuffer
; Byte 1 - $02 (DEC_AND_PLAY_FROM_BUFFER)
; Byte 2 - Amount to decrement picked byte by.
; Byte 3 - Offset to $D400 to write to.
; Byte 4 - '00' indicates the next record should be played immediately.
;          '01' indicates should play no more records.
;          Anything else indicates the next record should be stored and
;           no more should be played for now.

PLAY_LOOP = $05
; Plays a sequence of records in a loop. Will use Byte 0 to pick a
; value from soundEffectBuffer, decrement Byte 2 from it, play the
; result to the offset from D400 given by Byte 0, and continue
; looping from the address given by Bytes 4 and 5
; until the picked value in soundEffectBuffer reaches zero.
; Byte 0 - Address of byte to pick from soundEffectBuffer
; Byte 1 - $05 (PLAY_LOOP)
; Byte 2 - Amount to decrement picked byte by.
; Byte 3 - Lo Ptr of next record to play
; Byte 4 - Hi Ptr of next record to play

LINK = $80
; Stops playing records and just updates primarySoundEffectLoPtr/
; primarySoundEffectHiPtr with Byes 4 and 5 that point to the record
; to be played the next time around.
; Byte 0 - Unused
; Byte 1 - $80 (LINK)
; Byte 2 - Lo Ptr of next record to play
; Byte 3 - Hi Ptr of next record to play
; Byte 4 - '00' indicates the next record should be played immediately.
;          '01' indicates should play no more records.
;          Anything else indicates the next record should be stored and
;           no more should be played for now.

REPEAT_PREVIOUS = $81
; Repeats the previous record by the number of times given in Byte 2.
; Byte 0 - Unused
; Byte 1 - $81 (REPEAT_PREVIOUS)
; Byte 2 - Number of times to play previously stored record.
; Byte 3 - Unused
; Byte 4 - '00' indicates the next record should be played immediately.
;          '01' indicates should play no more records.
;          Anything else indicates the next record should be stored and
;           no more should be played for now.
VOICE1_HI = $01
VOICE1_CTRL = $04
VOICE1_ATK_DEC = $05
VOICE1_SUS_REL = $06
VOICE2_HI = $08
VOICE2_CTRL = $0B
VOLUME = $18
VOICE3_HI = $0F
VOICE2_ATK_DEC = $0C
VOICE2_SUS_REL = $0D
VOICE3_CTRL = $12
VOICE3_ATK_DEC = $13
VOICE3_SUS_REL = $14
