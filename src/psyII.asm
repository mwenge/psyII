; This is the reverse-engineered and heavily modified source code for the 'Psychedelia' module in Batalyx,
; written by Jeff Minter in 1985.
;
; The code in this file was created by disassembling a binary of the game released into
; the public domain by Jeff Minter in 2019.
;
; The original code from which this source is derived is the copyright of Jeff Minter.
;
; The original home of this file is at: https://github.com/mwenge/psyII
;
; To the extent to which any copyright may apply to the act of disassembling and reconstructing
; the code from its binary, the author disclaims copyright to this source code.  In place of
; a legal notice, here is a blessing:
;
;    May you do good and not evil.
;    May you find forgiveness for yourself and forgive others.
;    May you share freely, never taking more than you give.

RAM_ACCESS_MODE               = $01
screenLinesLoPtr              = $02
screenLinesHiPtr              = $03
currentCharXPos               = $04
currentCharYPos               = $05
defaultColorValue             = $06
currentChar                   = $07
xPosLoPtr                     = $0D
xPosHiPtr                     = $0E
yPosLoPtr                     = $10
yPosHiPtr                     = $11
enemyXPosition                = $12
enemyYPosition                = $13
tipsLoPtr                     = $14
tipsHiPtr                     = $15
encsLoPtr                     = tipsLoPtr
encsHiPtr                     = tipsHiPtr
screenRAMLoPtr                = $23
screenRAMHiPtr                = $24
currentSoundEffectLoPtr       = $30
currentSoundEffectHiPtr       = $31
rollingGridPreviousChar       = $32
frameControlCounter           = $33

currentPressedKey             = $C5
indexIntoDataChars            = $D0
indexToBackgroundControlArray = $D1

shiftKey                      = $028D
screenLinesLoPtrArray         = $0340
screenLinesHiPtrArray         = $0360

.include "constants.asm"

* = $0801
;-----------------------------------------------------------------------------------
; Start program at LaunchPsychedelia (SYS 2064)
; SYS 2064 ($0810)
;
; This is where execution starts.
; It is a short BASIC program that executes whatever is at address
; $0810 (2064 in decimal). In this case, that's LaunchPsychedelia.
;-----------------------------------------------------------------------------------
        .BYTE $0B,$08          ; Points to EndOfProgram address below
        .BYTE $C1,$07          ; Arbitrary Line Number, in this case: 1985
        .BYTE $9E              ; SYS
        .BYTE $32,$30,$36,$34  ; 2064 ($810), which is LaunchPsychedelia below.
        .BYTE $00              ; Null byte to terminate the line above.
        .BYTE $00,$00          ; EndOfProgram  (all zeroes)
        .BYTE $F9,$02,$F9      ; Filler bytes so that LaunchPsychedelia is
                               ; located at $0810

;--------------------------------------------------------
; LaunchPsychedelia
;--------------------------------------------------------
LaunchPsychedelia
        LDA #$00
        STA gameActive

        JSR InitializeScreenLinePtrArray
        JSR ClearScreen
        SEI 
        JSR InitializePsychedelia
        JSR SetUpInterrupts
        CLI 
        JSR InitializeArrays
        JSR InitializeStatusDisplayText
        JSR UpdateCurrentSettingsDisplay
        JSR UpdateLevelText

        JSR DisplayTitleScreen

        LDA #$01
        STA gameActive
PsychedeliaLoop   
        JSR MaybeUpdateFromBuffersAndPaint
        JSR CheckKeyboardInput
        JSR MaybeStartNewLevel
        JSR UpdateScoreText
        JMP PsychedeliaLoop


shouldStartNewLevel .BYTE $00
;---------------------------------------------------------------------------------
; MaybeStartNewLevel
;---------------------------------------------------------------------------------
MaybeStartNewLevel
        LDA shouldStartNewLevel
        BEQ ReturnFromStartNewLevel 
        
StartNewLevel
        LDA #$00
        STA gameActive

        LDA #$00
        STA fillCount
        STA fillCount2
        STA shouldStartNewLevel
        LDA #UNPAINTED_GRID
        STA valueUnderCursor

        JSR CycleBackgroundColor

        INC currentPatternElement
        LDA currentPatternElement
        AND #$1F
        STA currentPatternElement

        JSR ResetGrid
        JSR InitializeArrays
        JSR UpdateCurrentSettingsDisplay
        JSR UpdateLevelText
        LDA #$15
        STA cursorXPosition
        LDA #$0B
        STA cursorYPosition

        LDA #$01
        STA gameActive

ReturnFromStartNewLevel 
        RTS

;---------------------------------------------------------------------------------
; SetUpInterrupts
;---------------------------------------------------------------------------------
SetUpInterrupts   
        LDA #$7F
        STA $DC0D    ;CIA1: CIA Interrupt Control Register
        LDA #<TitleScreenInterruptHandler
        STA $0314    ;IRQ
        LDA #>TitleScreenInterruptHandler
        STA $0315    ;IRQ

        JSR UpdateRasterPosition

        LDA #$01
        STA $D01A    ;VIC Interrupt Mask Register (IMR)
        RTS 

;---------------------------------------------------------------------------------
; UpdateRasterPosition
;---------------------------------------------------------------------------------
UpdateRasterPosition   
        LDA $D011    ;VIC Control Register 1
        AND #$7F
        STA $D011    ;VIC Control Register 1

        ; Set the position of the next interrupt
        LDA #$FF
        STA $D012    ;Raster Position

        ; Acknowledge the interrupt
        LDA #$01
        STA $D019    ;VIC Interrupt Request Register (IRR)
        RTS 

;---------------------------------------------------------------------------------
; TitleScreenInterruptHandler
;---------------------------------------------------------------------------------
TitleScreenInterruptHandler
        LDA $D019    ;VIC Interrupt Request Register (IRR)
        AND #$01
        BNE RasterPositionMatchesRequestedInterrupt
        JMP $EA31
        ; Returns

RasterPositionMatchesRequestedInterrupt   

        JSR CheckJoystickAndUpdateCursor
        JSR PerformRollingGridAnimation
        JSR $FF9F ;$FF9F - scan keyboard                    

        JSR UpdateRasterPosition

        ; Sounds are turned off for now
        ;JSR PlaySoundEffects

ReturnFromInterrupt
        PLA 
        TAY 
        PLA 
        TAX 
        PLA 
        RTI 

;---------------------------------------------------------------------------------
; ClearScreen
;---------------------------------------------------------------------------------
ClearScreen   
        LDX #$00
_Loop   LDA #SPACE
        STA SCREEN_RAM,X
        STA SCREEN_RAM + $0100,X
        STA SCREEN_RAM + $0200,X
        STA SCREEN_RAM + $0300,X
        LDA #BLACK
        STA COLOR_RAM + $02F0,X
        DEX 
        BNE _Loop
        RTS 

;---------------------------------------------------------------------------------
; InitializeScreenLinePtrArray
;---------------------------------------------------------------------------------
InitializeScreenLinePtrArray   
        LDA #>SCREEN_RAM
        STA screenLinesHiPtr
        LDA #<SCREEN_RAM
        STA screenLinesLoPtr

        LDX #$00
_Loop   LDA screenLinesLoPtr
        STA screenLinesLoPtrArray,X
        LDA screenLinesHiPtr
        STA screenLinesHiPtrArray,X
        LDA screenLinesLoPtr
        CLC 
        ADC #NUM_COLS
        STA screenLinesLoPtr
        LDA screenLinesHiPtr
        ADC #$00
        STA screenLinesHiPtr
        INX 
        CPX #NUM_ROWS + 2
        BNE _Loop
        RTS 

;---------------------------------------------------------------------------------
; GetCurrentCharAddress
;---------------------------------------------------------------------------------
GetCurrentCharAddress   
        LDX currentCharYPos
        LDY currentCharXPos
        LDA screenLinesLoPtrArray,X
        STA screenLinesLoPtr
        LDA screenLinesHiPtrArray,X
        STA screenLinesHiPtr
        RTS 

fillCount  .BYTE $00
fillCount2 .BYTE $00
;---------------------------------------------------------------------------------
; IncrementFillCounter
;---------------------------------------------------------------------------------
IncrementFillCounter


        ; Sounds are turned off for now
;        LDA #<hitEnemyWithBulletSound
;        STA secondarySoundEffectLoPtr
;        LDA #>hitEnemyWithBulletSound
;        STA secondarySoundEffectHiPtr
;
;        LDA #$3C
;        STA soundEffectInProgress

        INC fillCount
        BEQ LSBReset
        RTS
LSBReset
        LDA #$00
        STA fillCount
        INC fillCount2
        BEQ IncrementFillCounter
        RTS

;---------------------------------------------------------------------------------
; WriteCurrentCharToScreen
;---------------------------------------------------------------------------------
WriteCurrentCharToScreen   
        JSR GetCurrentCharAddress
        LDA (screenLinesLoPtr),Y
        CMP #PAINTED_GRID
        BEQ ReturnFromWriteCharToScreen

WriteCharToScreen
        LDA currentChar
        STA (screenLinesLoPtr),Y
        LDA screenLinesHiPtr
        PHA 

        ; Update color of character
        CLC 
        ADC #OFFSET_TO_COLOR_RAM
        STA screenLinesHiPtr
        LDA defaultColorValue
        STA (screenLinesLoPtr),Y

        PLA 
        STA screenLinesHiPtr

        JSR IncrementFillCounter
        INC pointsEarned

        LDA fillCount2
        CMP #3
        BNE ReturnFromWriteCharToScreen
        LDA fillCount
        CMP #$98
        BNE ReturnFromWriteCharToScreen

        LDA #$01
        STA shouldStartNewLevel

ReturnFromWriteCharToScreen
        RTS 

;--------------------------------------------------------
; ClearGrid
;--------------------------------------------------------
ClearGrid
        LDX #$00
_Loop   LDA #SPACE
        STA SCREEN_RAM,X
        STA SCREEN_RAM + $0100,X
        STA SCREEN_RAM + $0200,X
        STA SCREEN_RAM + $0298,X
        LDA #BLACK
        STA COLOR_RAM,X
        STA COLOR_RAM + $0100,X
        STA COLOR_RAM + $0200,X
        STA COLOR_RAM + $0298,X
        DEX 
        BNE _Loop
        RTS 

;--------------------------------------------------------
; Wait5Seconds
;--------------------------------------------------------
Wait5Seconds   

				LDX #2
Wait1   LDY #60
Wait2   BIT $D011
				BPL Wait2
WaitVb2 BIT $D011
				BMI WaitVb2
				DEY
				BNE Wait2
				DEX
				BNE Wait1

				RTS

;                    0123456789012345678901234567890123456789
titleText     .TEXT "      PSYCHEDELIA II * A LIGHT GAME     "
titleLineOne  .TEXT "    TILE THE SCREEN AT YOUR LEISURE!   "
titleLineTwo  .TEXT "    YOU CANNOT DIE * YOU CANNOT LOSE    "
helpLineOne   .TEXT "        'S' TO CHANGE SYMMETRY..        "
helpLineTwo   .TEXT "    'SPACE' TO CHANGE CURSOR SPEED..    "
helpLineThree .TEXT "          PRESS FIRE TO START           "
HELP_LINE_POSITION = NUM_COLS * 4 
;--------------------------------------------------------
; DisplayTitleScreen
;--------------------------------------------------------
DisplayTitleScreen   
_Loop   
        LDA titleText,X
        AND #$3F
        STA SCREEN_RAM + HELP_LINE_POSITION,X

        LDA titleLineOne,X
        AND #$3F
        STA SCREEN_RAM + HELP_LINE_POSITION+(NUM_COLS*4),X

        LDA titleLineTwo,X
        AND #$3F
        STA SCREEN_RAM + HELP_LINE_POSITION+(NUM_COLS*6),X

        LDA helpLineThree,X
        AND #$3F
        STA SCREEN_RAM + HELP_LINE_POSITION+(NUM_COLS*10),X

        LDA #YELLOW
        STA COLOR_RAM + HELP_LINE_POSITION,X
        LDA #WHITE
        STA COLOR_RAM + HELP_LINE_POSITION+(NUM_COLS*4),X
        STA COLOR_RAM + HELP_LINE_POSITION+(NUM_COLS*6),X
        LDA #PURPLE
        STA COLOR_RAM + HELP_LINE_POSITION+(NUM_COLS*10),X
        INX 
        CPX #NUM_COLS
        BNE _Loop

TitleCheckFire
        LDA $DC00    ;CIA1: Data Port Register A
        AND #JOYSTICK_FIRE
        BNE TitleCheckFire

        JSR ClearGrid
        JSR DisplayIntro
        JSR DrawGrid

        RTS 

;                    0123456789012345678901234567890123456789
levelLineOne  .TEXT "YOU ARE                                 "
levelLineTwo  .TEXT "                                        "
encs
;              0123456789012345678901234567890123456789
        .TEXT "DOING V WELL THANK YOU V MUCH!!!"
        .TEXT "A VERY NICE PERSON I SEE!!!!!!!!"
        .TEXT "GOING TO BE VERY GOOD AT THIS!!!"
        .TEXT "VALUED BY EVERYONE IN YOUR LIFE!"
        .TEXT "JEFF MINTER'S FAVORITE CUSTOMER!"
        .TEXT "ONE OF THE CHAPS! ALSO THE BOYS!"
        .TEXT "NOT A BAD EGG AT ALL FOR A WALLY"
        .TEXT "A DECENT SPUD DESPITE EVERYTHING"
encs2
        .TEXT "A DAB HAND AT THIS I MUST SAY!!!"
        .TEXT "A LOVING AND ATTENTIVE PERSON!!!"
        .TEXT "A VALUABLE MEMBER OF SOCIETY!!!!"
        .TEXT "SPREADING LIGHT ALL AROUND YOU!!"
        .TEXT "MUM'S FAVOURITE BY A LONG WAY!!!"
        .TEXT "A VERY NICE PERSON INDEED I SEE!"
        .TEXT "FILLING UP ON DELICIOUS POINTS!!"
        .TEXT "A LOVELY OLD HIPPY AT HEART!!!!!"
encs3
        .TEXT "SEEN AND LOVED PLUS QUITE PRETTY"
        .TEXT "GETTING RATHER GOOD AT THIS!!!!!"
        .TEXT "UP TO ALL SORTS OF NEW TRICKS!!!"
        .TEXT "PUTTING THE REST OF US TO SHAME!"
        .TEXT "A FINE EXAMPLE FOR THE CHILDREN!"
        .TEXT "STILL PLAYING THAT'S AMAZING!!!!"
        .TEXT "A VERY NICE PERSON INDEED I SEE!"
        .TEXT "A PRAGMATIST NOT AN IDEALIST!!!!"
encs4
        .TEXT "THE SORT THAT DOESN'T GIVE UP!!!"
        .TEXT "CREATING SOME PLEASANT MEMORIES!"
        .TEXT "NOT SUCH A SILLY BILLY AFTER ALL"
        .TEXT "MUCH BETTER OFF NOT WORKING!!!!!"
        .TEXT "HOPING THERE IS A POINT TO THIS!"
        .TEXT "SAFE WITH THIS LITTLE COMPUTER!!"
        .TEXT "MORE LIKELY TO BE NICE THAN NOT!"
        .TEXT "A BIT OF A WALLY LET'S FACE IT!!"
        .TEXT "A SINGLE PERSON LIGHT MACHINE!!!"
        .TEXT "STILL PLAYING, I HOPE YOU'RE OK!"
        .TEXT "A BUBBLE ON THE SURF OF TIME!!!!"

tips
;              0123456789012345678901234567890123456789
        .TEXT " HOPE YOU LIKE PRETTY PATTERNS! "
        .TEXT "TRICKY BITS PREFER SLOWER SPEED!"
        .TEXT "CHOOSE THE APT SYMM FOR THE JOB!"
        .TEXT "TWIDDLE TO SEE THE CURSOR!!!!!!!"
        .TEXT "  SPEED IS NOT OF THE ESSENCE!  "
        .TEXT "      LESS IS ALWAYS MORE!      "
        .TEXT " MAKE PLEASANT LIGHT DISPLAYS!! "
        .TEXT "     WATCH THOSE CORNERS!!      "
tips2
        .TEXT "      HORSES FOR COURSES!       "
        .TEXT "QUAD IS GOOD FOR THE LOOSE BITS!"
        .TEXT "SWITCH ME OFF IF I STOP WORKING!"
        .TEXT "'NONE' SYM IS GOOD FOR LASTIES!!"
        .TEXT "'X' SYMM MEANS 'Y' FOR REASONS!!"
        .TEXT "CHOOSE THE APT SYMM FOR THE JOB!"
        .TEXT "TRIED GOING FASTER? TIP* DON'T!!"
        .TEXT "   THE PATTERNS CHOOSE YOU!!    "
tips3
        .TEXT " MAKE PLEASANT LIGHT DISPLAYS!! "
        .TEXT "THERE ISN'T MUCH MORE TO THIS!!!"
        .TEXT "IT JUST KEEPS GOING ON LIKE THIS"
        .TEXT "I CAN GO ON LIKE THIS FOREVER!!!"
        .TEXT "COMPUBOT SAYS: NO MORE ADVICE!!!"
        .TEXT "   LOOK I SAID I HAD NOTHING    "
        .TEXT "   ADVICE OVERFLOW ERROR 1534   "
        .TEXT "    GARBLE SYSTEMS ACTIVATED    "
tips4
        .TEXT "   GARBLE SYSTEMS NOW ONLINE!   "
        .TEXT "   GARBLE SYSTEMS ERROR LOL!!   "
        .TEXT "BACKUP GARBLE SYSTEM ACTIVATED!!"
        .TEXT "    BACKUP GARBLE NOT FOUND!    "
        .TEXT "    BACKUP GARBLE NOT FOUND!    "
        .TEXT "COMPUBOT SAYS: NO MORE ADVICE!!!"
        .TEXT "COMPUBOT SAYS: NO MORE ADVICE!!!"
        .TEXT "COMPUBOT SAYS: NO MORE ADVICE!!!"
        .TEXT "COMPUBOT SAYS: NO MORE ADVICE!!!"
        .TEXT "COMPUBOT SAYS: NO MORE ADVICE!!!"
        .TEXT "COMPUBOT SAYS: NO MORE ADVICE!!!"
        .TEXT "COMPUBOT SAYS: NO MORE ADVICE!!!"

tipsArrayLoPtr .BYTE <tips, <tips2,<tips3,<tips4
tipsArrayHiPtr .BYTE >tips, >tips2,>tips3,>tips4
encsArrayLoPtr .BYTE <encs, <encs2,<encs3,<encs4
encsArrayHiPtr .BYTE >encs, >encs2,>encs3,>encs4

INTERSTIT_LINE_POS    = NUM_COLS * 6
LEVEL_COMPLETE_TXT    = (NUM_COLS * 4)
LEVEL_COMPLETE_OFFSET = LEVEL_COMPLETE_TXT + 17
;                       0123456789012345678901234567890123456789
levelProgressTxt .TEXT "           LEVEL 000 COMPLETE!          "
;--------------------------------------------------------
; DisplayLevelInterstitial
;--------------------------------------------------------
DisplayLevelInterstitial   
_Loop   
        LDA levelProgressTxt,X
        AND #$3F
        STA SCREEN_RAM + LEVEL_COMPLETE_TXT,X

        LDA levelLineOne,X
        AND #$3F
        STA SCREEN_RAM + INTERSTIT_LINE_POS,X

        LDA levelLineTwo,X
        AND #$3F
        STA SCREEN_RAM + INTERSTIT_LINE_POS+(NUM_COLS*2),X

        LDA #PURPLE
        STA COLOR_RAM + LEVEL_COMPLETE_TXT,X
        LDA #YELLOW
        STA COLOR_RAM + INTERSTIT_LINE_POS,X
        LDA #GREEN
        STA COLOR_RAM + INTERSTIT_LINE_POS+(NUM_COLS*4),X
        INX 
        CPX #NUM_COLS
        BNE _Loop


        ; Display the level number
        LDX currentLevel
LevelLoopI   
        INC SCREEN_RAM + LEVEL_COMPLETE_OFFSET+2
        LDA SCREEN_RAM + LEVEL_COMPLETE_OFFSET+2
        CMP #$3A
        BNE NextDigitI
        LDA #$30
        STA SCREEN_RAM + LEVEL_COMPLETE_OFFSET+2
        INC SCREEN_RAM + LEVEL_COMPLETE_OFFSET+1
        LDA SCREEN_RAM + LEVEL_COMPLETE_OFFSET+1
        CMP #$3A
        BNE NextDigitI
        LDA #$30
        STA SCREEN_RAM + LEVEL_COMPLETE_OFFSET+1
        INC SCREEN_RAM + LEVEL_COMPLETE_TXT
NextDigitI
        DEX
        BNE LevelLoopI

        ; Update the tip
UpdateTipDisplay
        JSR AdjustLevelValues

        LDA tipsArrayLoPtr,X
        STA tipsLoPtr
        LDA tipsArrayHiPtr,X
        STA tipsHiPtr

        LDX #$00
_Loop2  LDA (tipsLoPtr),Y
        AND #$3F
        STA SCREEN_RAM + INTERSTIT_LINE_POS+(NUM_COLS*4)+5,X
        INY 
        INX 
        CPX #32
        BNE _Loop2

        ; Update the encouragement
UpdateEncouragementDisplay
        JSR AdjustLevelValues

        LDA encsArrayLoPtr,X
        STA encsLoPtr
        LDA encsArrayHiPtr,X
        STA encsHiPtr

        LDX #$00
_Loop3  LDA (encsLoPtr),Y
        AND #$3F
        STA SCREEN_RAM + INTERSTIT_LINE_POS + 8,X
        INY 
        INX 
        CPX #32
        BNE _Loop3

				JSR Wait5Seconds

        RTS 

;--------------------------------------------------------
; AdjustLevelValues
;--------------------------------------------------------
AdjustLevelValues   
        LDA currentLevel
        SEC
        SBC #1
        AND #$07
        .rept 5
        ASL
        .endrept
        TAY

        LDA currentLevel
        SEC
        SBC #1
        .rept 3
        LSR
        .endrept
        TAX
        RTS
;                    0123456789012345678901234567890123456789
introLineOne  .TEXT "     MAY YOU DO GOOD AND NOT EVIL!!     "
introLineTwo  .TEXT "   AND MAKE SURE YOU DON'T MISS A BIT!  "  
;--------------------------------------------------------
; DisplayIntro
;--------------------------------------------------------
DisplayIntro   
_Loop   
        LDA introLineOne,X
        AND #$3F
        STA SCREEN_RAM + INTERSTIT_LINE_POS,X

        LDA introLineTwo,X
        AND #$3F
        STA SCREEN_RAM + INTERSTIT_LINE_POS+(NUM_COLS*4),X

        LDA helpLineOne,X
        AND #$3F
        STA SCREEN_RAM + INTERSTIT_LINE_POS+(NUM_COLS*8),X

        LDA helpLineTwo,X
        AND #$3F
        STA SCREEN_RAM + INTERSTIT_LINE_POS+(NUM_COLS*10),X

        LDA #YELLOW
        STA COLOR_RAM + INTERSTIT_LINE_POS,X
        LDA #GREEN
        STA COLOR_RAM + INTERSTIT_LINE_POS+(NUM_COLS*4),X
        LDA #WHITE
        STA COLOR_RAM + INTERSTIT_LINE_POS+(NUM_COLS*8),X
        STA COLOR_RAM + INTERSTIT_LINE_POS+(NUM_COLS*10),X
        INX 
        CPX #NUM_COLS
        BNE _Loop

				JSR Wait5Seconds

        RTS 

;--------------------------------------------------------
; DrawGrid
;--------------------------------------------------------
DrawGrid

        LDX #$00
_Loop   LDA #UNPAINTED_GRID
        STA SCREEN_RAM,X
        STA SCREEN_RAM + $0100,X
        STA SCREEN_RAM + $0200,X
        STA SCREEN_RAM + $0298,X
        LDA currentColorValue
        STA COLOR_RAM,X
        STA COLOR_RAM + $0100,X
        STA COLOR_RAM + $0200,X
        STA COLOR_RAM + $0298,X
        DEX 
        BNE _Loop
        RTS

;--------------------------------------------------------
; ResetGrid
;--------------------------------------------------------
ResetGrid
				LDA #$01
        STA processingKeyStroke

        JSR ClearGrid
        JSR DisplayLevelInterstitial
        JSR DrawGrid

				LDA #$00
        STA processingKeyStroke
        RTS 

;--------------------------------------------------------
; InitializePsychedelia
;--------------------------------------------------------
InitializePsychedelia   
        LDX #$00
_Loop   LDA #SPACE
        STA SCREEN_RAM,X
        DEX 
        BNE _Loop


        LDA $D016    ;VIC Control Register 2
        AND #$F0
        ORA #$08
        STA $D016    ;VIC Control Register 2

        ; The '1' points screen memory to its default position
        ; in memory (i.e. SCREEN_RAM = $0400). The '8'
        ; selects $2000 as the location of the character set to
        ; use. $2000 = characterSetData
        LDA #$18
        STA $D018    ;VIC Memory Control Register

        LDA #BLACK
        STA $D020    ;Border Color
        STA $D021    ;Background Color 0

        LDA currentColorValue
        STA defaultColorValue

SetUpSpritesAndVoiceRegisters
        LDA $D011    ;VIC Control Register 1
        AND #$F8
        ORA #$03
        STA $D011    ;VIC Control Register 1

        LDA #$00
        STA $D015    ;Sprite display Enable

        RTS 

cursorXPosition     .BYTE $15
cursorYPosition     .BYTE $0B
colorValueForCursor .BYTE WHITE

charValueForCursor .BYTE $00
;--------------------------------------------------------
; WriteCursorValueToColorRAM
;--------------------------------------------------------
WriteCursorValueToColorRAM   
        LDY cursorXPosition
        LDX cursorYPosition

        LDA screenLinesLoPtrArray,X
        STA screenRAMLoPtr
        LDA screenLinesHiPtrArray,X
        STA screenRAMHiPtr
        LDA charValueForCursor
        STA (screenRAMLoPtr),Y

        LDA screenLinesHiPtrArray,X
        CLC 
        ADC #OFFSET_TO_COLOR_RAM
        STA screenRAMHiPtr

        LDA colorValueForCursor
        STA (screenRAMLoPtr),Y
        RTS 

valueUnderCursor .BYTE UNPAINTED_GRID
;--------------------------------------------------------
; GetValueUnderCursor
;--------------------------------------------------------
GetValueUnderCursor   
        LDY cursorXPosition
        LDX cursorYPosition

        LDA screenLinesLoPtrArray,X
        STA screenRAMLoPtr
        LDA screenLinesHiPtrArray,X
        STA screenRAMHiPtr
        LDA (screenRAMLoPtr),Y
        STA valueUnderCursor

        RTS 

gameActive .BYTE $00
;--------------------------------------------------------
; CheckJoystickAndUpdateCursor
;--------------------------------------------------------
CheckJoystickAndUpdateCursor   
        LDA gameActive
        BEQ DontDrawCursor 

        LDA currentColorValue
        STA colorValueForCursor
        LDA valueUnderCursor
        STA charValueForCursor
        JSR WriteCursorValueToColorRAM

        JSR MaybeCheckJoystickInput

        LDA #WHITE
        STA colorValueForCursor
        JSR GetValueUnderCursor
        LDA #PAINTED_GRID
        STA charValueForCursor
        JSR WriteCursorValueToColorRAM

DontDrawCursor
        RTS 

;--------------------------------------------------------
; MaybeCheckJoystickInput
;--------------------------------------------------------
MaybeCheckJoystickInput   
        DEC prevCursorSpeed
        BEQ CheckJoystickInput
        RTS 

prevCursorSpeed   .BYTE $02

;--------------------------------------------------------
; CheckJoystickInput   
;--------------------------------------------------------
CheckJoystickInput   
        LDA cursorSpeed
        STA prevCursorSpeed

        LDA $DC00    ;CIA1: Data Port Register A
        STA lastJoystickInput

MaybeUpPressed
        AND #JOYSTICK_DOWN
        BEQ MaybeDownPressed

UpPressed
        DEC cursorYPosition
        LDA cursorYPosition
        CMP #BELOW_ZERO
        BNE MaybeDownPressed

        LDA #BOTTOM_Y_POSITION
        STA cursorYPosition

MaybeDownPressed   
        LDA lastJoystickInput
        AND #JOYSTICK_UP
        BEQ MaybeLeftPressed

DownPressed
        INC cursorYPosition
        LDA cursorYPosition
        CMP #BOTTOM_Y_POSITION+1
        BNE MaybeLeftPressed

        LDA #$00
        STA cursorYPosition

MaybeLeftPressed   
        LDA lastJoystickInput
        AND #JOYSTICK_RIGHT
        BEQ MaybeRightPressed

LeftPressed
        DEC cursorXPosition
        LDA cursorXPosition
        CMP #BELOW_ZERO
        BNE MaybeRightPressed

        LDA #NUM_COLS-1
        STA cursorXPosition

MaybeRightPressed   
        LDA lastJoystickInput
        AND #JOYSTICK_LEFT
        BEQ CheckFireButton

RightPressed
        INC cursorXPosition
        LDA cursorXPosition
        CMP #NUM_COLS
        BNE CheckFireButton

        LDA #$00
        STA cursorXPosition

CheckFireButton   
        JSR MaybeFirePressed
        RTS 

lastJoystickInput   .BYTE $7F

colorRAMLoPtr = $25
colorRAMHiPtr = $26
;--------------------------------------------------------
; PaintPixel
;--------------------------------------------------------
PaintPixel   
        LDX pixelToPaintYPosition
        LDY pixelToPaintXPosition
        LDA screenLinesLoPtrArray,X
        STA colorRAMLoPtr
        LDA screenLinesHiPtrArray,X
        CLC 
        ADC #OFFSET_TO_COLOR_RAM
        STA colorRAMHiPtr
        LDA (colorRAMLoPtr),Y
        AND #$0F
        CMP currentColorValue
        BEQ ActuallyPaintPixel

        TAX 
        LDA colorComparisonArray,X
        CMP lastColorValue
        BEQ ActuallyPaintPixel
        BPL ActuallyPaintPixel
        RTS 

ActuallyPaintPixel   
        JSR DrawPainted
        LDA currentColor
        STA (colorRAMLoPtr),Y
        RTS 

colorComparisonArray   
        .BYTE ORANGE,ORANGE,WHITE,ORANGE,BLUE,PURPLE,YELLOW,CYAN
        .BYTE RED,ORANGE,ORANGE,ORANGE,ORANGE,ORANGE,GREEN,ORANGE
        .BYTE ORANGE

pixelToPaintYPosition .BYTE $0C
pixelToPaintXPosition .BYTE $0C

;--------------------------------------------------------
; PaintPixelForCurrentSymmetry
;--------------------------------------------------------
PaintPixelForCurrentSymmetry   
        LDA pixelToPaintYPosition
        AND #$80
        BEQ CanPaintPixelOnThisLine

CleanUpAndReturn   
        RTS 

CanPaintPixelOnThisLine   
        LDA pixelToPaintYPosition
        CMP #BOTTOM_Y_POSITION+1
        BPL CleanUpAndReturn

        LDA pixelToPaintXPosition
        AND #$80
        BNE CleanUpAndReturn

        LDA pixelToPaintXPosition
        CMP #NUM_COLS
        BPL CleanUpAndReturn

        LDA currentColor
        TAX 
        LDA colorComparisonArray,X
        STA lastColorValue
        DEC lastColorValue

        JSR PaintPixel

        LDA currentSymmetrySettingForStep
        BNE HasSymmetry

ReturnFromSymmetry   
        RTS 

HasSymmetry   
        CMP #X_Y_SYMMETRY
        BEQ HasXYSymmetry

        CMP #X_AXIS_SYMMETRY
        BEQ HasXAxisSymmetry

        LDA #NUM_COLS-1
        SEC 
        SBC pixelToPaintXPosition
        STA pixelToPaintXPosition

        JSR PaintPixel

        LDA currentSymmetrySettingForStep
        CMP #Y_AXIS_SYMMETRY
        BEQ ReturnFromSymmetry

        LDA #BOTTOM_Y_POSITION
        SEC 
        SBC pixelToPaintYPosition
        STA pixelToPaintYPosition

        JSR PaintPixel

        LDA #NUM_COLS-1
        SEC 
        SBC pixelToPaintXPosition
        STA pixelToPaintXPosition

        JMP PaintPixel

HasXYSymmetry   
        LDA #BOTTOM_Y_POSITION
        SEC 
        SBC pixelToPaintYPosition
        STA pixelToPaintYPosition

        JMP PaintPixel

HasXAxisSymmetry   
        LDA #NUM_COLS-1
        SEC 
        SBC pixelToPaintXPosition
        STA pixelToPaintXPosition
        JMP HasXYSymmetry

currentSymmetrySettingForStep .BYTE $01
presetColorValuesArray        .BYTE RED,ORANGE,YELLOW,GREEN,LTBLUE,PURPLE,BLUE
currentColorValue             .BYTE BLUE

currentColor                  .BYTE BLUE
lastColorValue                .BYTE $07
currentBorderColor            .BYTE BLACK
currentBackgroundColor        .BYTE BLACK

currentLineInPattern          .BYTE $07
currentPatternIndex           .BYTE $13

;--------------------------------------------------------
; PaintStructureAtCurrentPosition
;--------------------------------------------------------
PaintStructureAtCurrentPosition   
        LDA #$00
        STA currentPatternIndex
        STA currentLineInPattern

        LDA currentPixelXPosition
        STA pixelToPaintXPosition
        LDA currentPixelYPosition
        STA pixelToPaintYPosition

        JSR PaintPixelForCurrentSymmetry

        LDA currentColorIndex
        BNE CanPaint
        RTS 

CanPaint
        LDX patternIndex
        LDA pixelXPositionLoPtrArray,X
        STA xPosLoPtr
        LDA pixelXPositionHiPtrArray,X
        STA xPosHiPtr
        LDA pixelYPositionLoPtrArray,X
        STA yPosLoPtr
        LDA pixelYPositionHiPtrArray,X
        STA yPosHiPtr

PixelPaintLoop   
        LDY currentPatternIndex
        LDA (xPosLoPtr),Y
        CMP #$55
        BEQ MoveToNextLineInPattern

        CLC 
        ADC currentPixelXPosition
        STA pixelToPaintXPosition

        LDA (yPosLoPtr),Y
        CLC 
        ADC currentPixelYPosition
        STA pixelToPaintYPosition

        JSR PaintPixelForCurrentSymmetry

        INC currentPatternIndex
        JMP PixelPaintLoop

MoveToNextLineInPattern   
        INC currentPatternIndex
        INC currentLineInPattern
        LDA currentLineInPattern
        CMP currentColorIndex
        BNE PixelPaintLoop
        RTS 

currentColorIndex     .BYTE $07
currentPixelXPosition .BYTE $15
currentPixelYPosition .BYTE $06
patternIndexArray
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
symmetrySettingForStep
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
pixelXPositionArray   
        .BYTE $15,$15,$15,$15,$15,$15,$15,$15
        .BYTE $15,$15,$15,$15,$15,$15,$15,$15
        .BYTE $15,$15,$15,$15,$15,$15,$15,$15
        .BYTE $15,$15,$15,$15,$15,$15,$15,$15
        .BYTE $15,$15,$15,$15,$15,$15,$15,$15
        .BYTE $15,$15,$15,$15,$15,$14,$15,$16
        .BYTE $17,$18,$19,$1A,$1B,$1C,$1D,$1D
        .BYTE $1D,$1C,$1B,$1A,$19,$18,$17,$16
pixelYPositionArray   
        .BYTE $02,$03,$04,$05,$06,$07,$08,$09
        .BYTE $0A,$0B,$0C,$0D,$0E,$0F,$10,$11
        .BYTE $00,$01,$02,$03,$04,$05,$06,$07
        .BYTE $08,$09,$0A,$0B,$0C,$0D,$0E,$0F
        .BYTE $10,$11,$00,$01,$02,$03,$04,$05
        .BYTE $06,$07,$08,$09,$0A,$0C,$0B,$0A
        .BYTE $09,$08,$07,$06,$05,$04,$03,$02
        .BYTE $01,$00,$11,$11,$11,$11,$00,$01
smoothingDelayArray   
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$04,$07,$0A,$02,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
initialSmoothingDelayArray   
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        .BYTE $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
currentColorIndexArray   
        .BYTE $08,$08,$08,$08,$08,$08,$08,$08
        .BYTE $08,$08,$08,$08,$08,$08,$08,$08
        .BYTE $08,$08,$08,$08,$08,$08,$08,$08
        .BYTE $08,$08,$08,$08,$08,$08,$08,$08
        .BYTE $08,$08,$08,$08,$08,$08,$08,$08
        .BYTE $08,$08,$08,$08,$08,$08,$08,$08
        .BYTE $08,$08,$08,$08,$08,$08,$08,$08
        .BYTE $08,$08,$08,$08,$08,$08,$08,$08

;--------------------------------------------------------
; InitializeArrays
;--------------------------------------------------------
InitializeArrays   
        LDX #$00
_Loop   LDA #$00
        STA pixelXPositionArray,X
        STA pixelYPositionArray,X
        STA symmetrySettingForStep,X
        STA patternIndexArray,X
        LDA #$08
        STA currentColorIndexArray,X
        LDA #$0C
        STA smoothingDelayArray,X
        INX 
        CPX #$40
        BNE _Loop
b7C51
        RTS 

currentPatternElement .BYTE $00
patternIndex          .BYTE $00
;--------------------------------------------------------
; MaybeFirePressed
;--------------------------------------------------------
MaybeFirePressed   

        LDA lastJoystickInput
        AND #JOYSTICK_FIRE
        BNE b7C51

        INC pointsLost

        LDX currentIndexToBuffers
        LDA currentColorIndexArray,X
        AND #$08
        BEQ b7C82

        LDA #$00
        STA currentColorIndexArray,X

        LDA cursorXPosition
        STA pixelXPositionArray,X

        LDA cursorYPosition
        STA pixelYPositionArray,X

        LDA currentSymmetrySetting
        STA symmetrySettingForStep,X

        LDA currentPatternElement
        STA patternIndexArray,X

        LDA #$0C
        STA smoothingDelayArray,X
        STA initialSmoothingDelayArray,X

b7C82   INC currentIndexToBuffers
        LDA currentIndexToBuffers
        AND #$3F
        STA currentIndexToBuffers
        RTS 

currentIndexToBuffers   .BYTE $2D
;--------------------------------------------------------
; MaybeUpdateFromBuffersAndPaint
;--------------------------------------------------------
MaybeUpdateFromBuffersAndPaint   
        LDX lastIndexToBuffers
        LDA currentColorIndexArray,X
        AND #$08
        BNE BufferUpdateComplete

        DEC smoothingDelayArray,X
        BNE BufferUpdateComplete

        LDA initialSmoothingDelayArray,X
        STA smoothingDelayArray,X

        LDA pixelXPositionArray,X
        STA currentPixelXPosition
        LDA pixelYPositionArray,X
        STA currentPixelYPosition

        LDA patternIndexArray,X
        STA patternIndex

        LDA currentColorIndexArray,X
        STA currentColorIndex

        TAY 
        LDA symmetrySettingForStep,X
        STA currentSymmetrySettingForStep

        LDA presetColorValuesArray,Y
        STA currentColor

        INC currentColorIndexArray,X
        JSR PaintStructureAtCurrentPosition

BufferUpdateComplete   
        INC lastIndexToBuffers

        LDA lastIndexToBuffers
        AND #$3F
        STA lastIndexToBuffers
        RTS 

lastIndexToBuffers   .BYTE $01
;--------------------------------------------------------
; CheckKeyboardInput
;--------------------------------------------------------
CheckKeyboardInput   
        LDA currentPressedKey
        CMP #NO_KEY_PRESSED
        BNE KeyboardInputReceived

        LDA #$00
        STA processingKeyStroke
ReturnFromKeyboardInput   
        RTS 

KeyboardInputReceived   
        LDY processingKeyStroke
        BNE ReturnFromKeyboardInput

MaybeSKeyPressed
        CMP #KEY_S
        BNE MaybeCKeyPressed

        ; 'S' pressed. "This changes the 'symmetry'. The pattern gets reflected
        ; in various planes, or not at all according to the setting."
        ; Briefly display the new symmetry setting on the bottom of the screen.
        LDA #$01
        STA processingKeyStroke
        INC currentSymmetrySetting
        LDA currentSymmetrySetting
        CMP #$05
        BNE UpdateStatusLineAndReturn

        LDA #$00
        STA currentSymmetrySetting

UpdateStatusLineAndReturn   
        JSR UpdateCurrentSettingsDisplay
        RTS 

MaybeCKeyPressed   
        CMP #KEY_C
        BNE MaybeSpacePressed

UpdateSpeed
        ; C pressed.
        ; Cursor Speed C to activate: Just that. Gives you a slow or fast little
        ; cursor, according to setting.
        LDA #$01
        STA processingKeyStroke
        INC cursorSpeed
        LDA cursorSpeed
        CMP #$05
        BNE UpdateStatusLineAndReturn
        LDA #$01
        STA cursorSpeed
        JMP UpdateStatusLineAndReturn

        ; Not used, we don't let them select the pattern.
MaybeSpacePressed
        CMP #KEY_SPACE ; Space pressed?
        BNE NoOtherKeyPressed

        ; Space will also update speed.
        JMP UpdateSpeed

NoOtherKeyPressed
        RTS

cursorSpeed         .BYTE $02
processingKeyStroke .BYTE $00

;--------------------------------------------------------
; CycleBackgroundColor   
;--------------------------------------------------------
CycleBackgroundColor   
        LDA currentColorValue
        STA currentBorderColor

        INC currentColorValue
        LDA currentColorValue
        AND #$0F
        STA currentColorValue

        LDX #$00
_Loop   
        STA COLOR_RAM + $0000,X
        STA COLOR_RAM + $0100,X
        STA COLOR_RAM + $0200,X
        STA COLOR_RAM + $0298,X
        DEX 
        BNE _Loop

b7D72   RTS 

STATUS_LINE_POSITION = NUM_COLS * 23
LOGO_LINE_POSITION   = NUM_COLS * 23
LOGO_COL_POSITION    = 0

logoLineOne     .BYTE $76,$78,$7E,$80
logoLineTwo     .BYTE $77,$79,$7F,$81
;--------------------------------------------------------
; DisplayLogo
;--------------------------------------------------------
DisplayLogo   
        LDX #$00
_Loop   LDA logoLineOne,X
        STA SCREEN_RAM + LOGO_LINE_POSITION+LOGO_COL_POSITION,X
        LDA logoLineTwo,X
        STA SCREEN_RAM + LOGO_LINE_POSITION + NUM_COLS+LOGO_COL_POSITION,X
        LDA #GRAY3
        STA COLOR_RAM + LOGO_LINE_POSITION+LOGO_COL_POSITION,X
        LDA #GRAY3
        STA COLOR_RAM + LOGO_LINE_POSITION + NUM_COLS+LOGO_COL_POSITION,X
        INX 
        CPX #len(logoLineOne)
        BNE _Loop
        RTS

;                      0123456789012345678901234567890123456789
statusLineOne   .TEXT "     SYMM:       SPEED:                 "
statusLineTwo   .TEXT "     LEVEL: 000  SCORE:00000000000000000"
;--------------------------------------------------------
; InitializeStatusDisplayText
;--------------------------------------------------------
InitializeStatusDisplayText   
        LDX #$00
_Loop   LDA statusLineOne,X
        AND #$3F
        STA SCREEN_RAM + STATUS_LINE_POSITION,X
        LDA statusLineTwo,X
        AND #$3F
        STA SCREEN_RAM + STATUS_LINE_POSITION+NUM_COLS,X

        LDA #WHITE
        STA COLOR_RAM + STATUS_LINE_POSITION,X
        LDA #WHITE
        STA COLOR_RAM + STATUS_LINE_POSITION+NUM_COLS,X
        INX 
        CPX #NUM_COLS
        BNE _Loop

        LDX #$05
_Loop2
        LDA #YELLOW
        STA COLOR_RAM + STATUS_LINE_POSITION,X
        STA COLOR_RAM + STATUS_LINE_POSITION+12,X
        LDA #YELLOW
        STA COLOR_RAM + STATUS_LINE_POSITION+NUM_COLS,X
        STA COLOR_RAM + STATUS_LINE_POSITION+NUM_COLS+12,X
        INX 
        CPX #11
        BNE _Loop2

        LDX #27
_Loop3
        LDA #PURPLE
        STA COLOR_RAM + STATUS_LINE_POSITION,X
        INX 
        CPX #40
        BNE _Loop3

        JSR DisplayLogo
        RTS 

symmetrySettingTxt
        .TEXT "NONE Y   X  X-Y QUAD"

;--------------------------------------------------------
; UpdateCurrentSettingsDisplay
;--------------------------------------------------------
UpdateCurrentSettingsDisplay   

        ; Update Cursor Speed
        LDA cursorSpeed
        CLC 
        ADC #$30
        STA SCREEN_RAM + STATUS_LINE_POSITION + 24 

        ; Update Symmetry
        LDA currentSymmetrySetting
        ASL 
        ASL 
        TAY 

        LDX #$00
_Loop   LDA symmetrySettingTxt,Y
        AND #$3F
        STA SCREEN_RAM + STATUS_LINE_POSITION + 11,X
        INY 
        INX 
        CPX #$04
        BNE _Loop

        ; Update Symmetry
        LDA currentPatternElement
        ASL 
        ASL  
        ASL  
        TAY 

        LDX #$00
_Loop2  LDA patternTxt,Y
        AND #$3F
        STA SCREEN_RAM + STATUS_LINE_POSITION + 27,X
        INY 
        INX 
        CPX #$08
        BNE _Loop2
        RTS 

currentLevel .BYTE $00
STATUS_LINE_TWO_POSITION = NUM_COLS * 24
LEVEL_TXT_OFFSET = STATUS_LINE_TWO_POSITION + 12
;--------------------------------------------------------
; UpdateLevelText
;--------------------------------------------------------
UpdateLevelText
        LDA #$30
        STA SCREEN_RAM + LEVEL_TXT_OFFSET
        STA SCREEN_RAM + LEVEL_TXT_OFFSET+1
        STA SCREEN_RAM + LEVEL_TXT_OFFSET+2

        ; Update the current level
        INC currentLevel
        LDX currentLevel
LevelLoop   
        INC SCREEN_RAM + LEVEL_TXT_OFFSET+2
        LDA SCREEN_RAM + LEVEL_TXT_OFFSET+2
        CMP #$3A
        BNE NextDigit
        LDA #$30
        STA SCREEN_RAM + LEVEL_TXT_OFFSET+2
        INC SCREEN_RAM + LEVEL_TXT_OFFSET+1
        LDA SCREEN_RAM + LEVEL_TXT_OFFSET+1
        CMP #$3A
        BNE NextDigit
        LDA #$30
        STA SCREEN_RAM + LEVEL_TXT_OFFSET+1
        INC SCREEN_RAM + LEVEL_TXT_OFFSET
NextDigit   
        DEX
        BNE LevelLoop

        RTS

pointsEarned .BYTE $00
pointsLost   .BYTE $00
SCORE_TXT_OFFSET = STATUS_LINE_TWO_POSITION + 23
SCORE_LEN = $0F
;--------------------------------------------------------
; UpdateScoreText
;--------------------------------------------------------
UpdateScoreText
        LDA pointsEarned
        BEQ DecreaseScores

        ; Add points earned
        LDX #SCORE_LEN
IncreaseScoreLoop   
        INC SCREEN_RAM + SCORE_TXT_OFFSET,X
        LDA SCREEN_RAM + SCORE_TXT_OFFSET,X
        CMP #$3A
        BNE UpdatePointsEarned
        LDA #$30
        STA SCREEN_RAM + SCORE_TXT_OFFSET,X
        DEX
        BNE IncreaseScoreLoop

UpdatePointsEarned
        DEC pointsEarned

DecreaseScores
        LDA pointsLost
        BEQ FinishedUpdatingScores

        ; Deducts points lost
        ; Check if we're already zero.
        LDX #SCORE_LEN
_Loop
        LDA SCREEN_RAM + SCORE_TXT_OFFSET,X
        CMP #$30
        BNE DecreaseScore
        DEX
        BNE _Loop
        JMP UpdatePointsLost

DecreaseScore
        LDX #SCORE_LEN
DecreaseScoreLoop   
        DEC SCREEN_RAM + SCORE_TXT_OFFSET,X
        LDA SCREEN_RAM + SCORE_TXT_OFFSET,X
        CMP #$2F
        BNE UpdatePointsLost
        LDA #$39
        STA SCREEN_RAM + SCORE_TXT_OFFSET,X
        DEX
        BNE DecreaseScoreLoop

UpdatePointsLost
        DEC pointsLost

FinishedUpdatingScores
        RTS

currentSymmetrySetting .BYTE $01,$DD

;-------------------------------------------------------
; PutRandomByteInAccumulator
;-------------------------------------------------------
PutRandomByteInAccumulator   
randomByteAddress   =*+$01
        LDA $E199,X
        INC randomByteAddress
        RTS 

;-------------------------------------------------------
; DrawPainted
;-------------------------------------------------------
DrawPainted   
        LDA pixelToPaintXPosition
        STA currentCharXPos
        LDA pixelToPaintYPosition
        STA currentCharYPos
        LDA #PAINTED_GRID
        STA currentChar
        JSR WriteCurrentCharToScreen

ReturnFromDrawPainted
        RTS 

;-------------------------------------------------------------------------
; PerformRollingGridAnimation
;-------------------------------------------------------------------------
PerformRollingGridAnimation
        INC frameControlCounter
        LDA frameControlCounter
        AND #$01
        BEQ ScrollGrid
        RTS 

ScrollGrid
        LDA unpaintedGrid + $0007
        STA rollingGridPreviousChar
        LDX #$07
_Loop   LDA unpaintedGrid - $0001,X
        STA unpaintedGrid,X
        DEX 
        BNE _Loop

        LDA rollingGridPreviousChar
        STA unpaintedGrid

        RTS 

.include "sounds.asm"
* = $2000
.include "charset.asm"
.include "patterns.asm"

; vim: tabstop=2 shiftwidth=2 expandtab smartindent

