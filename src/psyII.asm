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
a08                           = $08
a09                           = $09
currentRasterArrayIndex       = $0A
xPosLoPtr                     = $0D
xPosHiPtr                     = $0E
yPosLoPtr                     = $10
yPosHiPtr                     = $11
currentPressedKey             = $C5
indexIntoDataChars            = $D0
indexToBackgroundControlArray = $D1

shiftKey                      = $028D
screenLinesLoPtrArray         = $0340
screenLinesHiPtrArray         = $0360

.include "constants.asm"

* = $0801
;-----------------------------------------------------------------------------------
; Start program at InitializeProgram (SYS 2064)
; SYS 2064 ($0810)
;
; This is where execution starts.
; It is a short BASIC program that executes whatever is at address
; $0810 (2064 in decimal). In this case, that's InitializeProgram.
;-----------------------------------------------------------------------------------
        .BYTE $0B,$08          ; Points to EndOfProgram address below
        .BYTE $C1,$07          ; Arbitrary Line Number, in this case: 1985
        .BYTE $9E              ; SYS
        .BYTE $32,$30,$36,$34  ; 2064 ($810), which is InitializeProgram below.
        .BYTE $00              ; Null byte to terminate the line above.
        .BYTE $00,$00          ; EndOfProgram  (all zeroes)
        .BYTE $F9,$02,$F9      ; Filler bytes so that InitializeProgram is
                               ; located at $0810

;--------------------------------------------------------
; LaunchPsychedelia
;--------------------------------------------------------
LaunchPsychedelia
        JSR InitializeScreenLinePtrArray
        JSR ClearScreen
        JSR SetUpInterrupts
        SEI 
        JSR InitializePsychedelia
        JSR SetUpBackgroundPainting
        JSR InitializeColorIndexArray
        JSR InitializeStatusDisplayText
        JSR UpdateCurrentSettingsDisplay
        CLI 
PsychedeliaLoop   
        JSR MaybeUpdateFromBuffersAndPaint
        JSR CheckKeyboardInput
        JMP PsychedeliaLoop

a40D7   .BYTE $03
a4142   .BYTE $01
;---------------------------------------------------------------------------------
; SetUpInterrupts
;---------------------------------------------------------------------------------
SetUpInterrupts   
        SEI 
        LDA #$7F
        STA $DC0D    ;CIA1: CIA Interrupt Control Register
        LDA #<TitleScreenInterruptHandler
        STA $0314    ;IRQ
        LDA #>TitleScreenInterruptHandler
        STA $0315    ;IRQ
        LDA #$00
        STA currentRasterArrayIndex
        JSR UpdateRasterPosition
        JSR InitializeRasterJumpTablePtrArray

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
        LDX currentRasterArrayIndex
        LDA rasterPositionArray,X
        CMP #$FF
        BNE b4224

        LDA #$00
        STA currentRasterArrayIndex
        LDA rasterPositionArray
b4224   STA $D012    ;Raster Position
        LDA #$01
        STA $D019    ;VIC Interrupt Request Register (IRR)
        RTS 

rasterJumpTableLoPtr2=*+$01
rasterJumpTableLoPtr3=*+$02
rasterJumpTableLoPtrArray .BYTE $55,$55
                          .BYTE $22,$22,$22,$22,$46,$46,$46,$46
                          .BYTE $46,$46
rasterJumpTableHiPtr2=*+$01
rasterJumpTableHiPtr3=*+$02
rasterJumpTableHiPtrArray .BYTE $C0,$C0
                          .BYTE $C3,$C3,$C3,$C3,$42,$42,$42,$42
                          .BYTE $42,$42
rasterPositionArray       .BYTE $E0,$FF,$C0,$FF,$A0,$C0,$FF
;---------------------------------------------------------------------------------
; InitializeRasterJumpTablePtrArray
;---------------------------------------------------------------------------------
InitializeRasterJumpTablePtrArray   
        LDX #$00
b4574   LDA #$46
        STA rasterJumpTableLoPtrArray,X
        LDA #$42
        STA rasterJumpTableHiPtrArray,X
        INX 
        CPX #$0C
        BNE b4574
        RTS 

;---------------------------------------------------------------------------------
; TitleScreenInterruptHandler
;---------------------------------------------------------------------------------
TitleScreenInterruptHandler
        LDA $D019    ;VIC Interrupt Request Register (IRR)
        AND #$01
        BNE b4237
        JMP $EA31
        ; Returns

        ; After a delay calculated from the IRQ switch to the Zarjas poster
        ; and back again.
b4237   LDX currentRasterArrayIndex
        LDA rasterJumpTableLoPtrArray,X
        STA a08
        LDA rasterJumpTableHiPtrArray,X
        STA a09
        JMP ($0008)
        ;Returns

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
        LDA #WHITE
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
b414D   LDA screenLinesLoPtr
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
        BNE b414D
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

;---------------------------------------------------------------------------------
; WriteCurrentCharToScreen
;---------------------------------------------------------------------------------
WriteCurrentCharToScreen   
        JSR GetCurrentCharAddress
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
        STA $D400    ;Voice 1: Frequency Control - Low-Byte

        LDA #$04
        STA $D407    ;Voice 2: Frequency Control - Low-Byte
        LDA #$08
        STA $D40E    ;Voice 3: Frequency Control - Low-Byte

        LDA #BOTTOM_Y_POSITION - 7
        STA currentCharYPos

        LDA #$63
        STA currentChar

        LDA currentColorValue
        STA defaultColorValue

SetUpScreenLoop   
        LDA #$00
        STA currentCharXPos

InnerLoop  
        JSR WriteCurrentCharToScreen

        LDA currentCharYPos
        PHA 
        SEC 
        SBC #BOTTOM_Y_POSITION - 7
        STA currentCharYPos

        LDA currentChar
        PHA 
        CLC 
        CLC 
        ADC #$5D
        STA currentChar

        JSR WriteCurrentCharToScreen

        PLA 
        STA currentChar

        PLA 
        STA currentCharYPos

        INC currentCharXPos

        LDA currentCharXPos
        CMP #NUM_COLS
        BNE InnerLoop

        INC currentChar
        INC currentCharYPos
        LDA currentCharYPos
        CMP #BOTTOM_Y_POSITION + 1
        BNE SetUpScreenLoop

SetUpSpritesAndVoiceRegisters
        LDA $D011    ;VIC Control Register 1
        AND #$F8
        ORA #$03
        STA $D011    ;VIC Control Register 1

        LDA #$00
        STA $D015    ;Sprite display Enable
        STA a40D7
        STA a4142
        STA $D404    ;Voice 1: Control Register
        STA $D40B    ;Voice 2: Control Register
        STA $D412    ;Voice 3: Control Register

        ;JSR ResetSomeDataAndClearMiddleScreen


DrawTwoMiddleLines
        LDX #$00
_Loop   LDA #$42
        STA SCREEN_RAM + (NUM_COLS * 8),X
        LDA currentColorValue
        STA COLOR_RAM + (NUM_COLS * 8),X
        INX 
        CPX #(6 * NUM_COLS)
        BNE _Loop

        LDX #$00
_Loop2  LDA #$42
        STA SCREEN_RAM + (NUM_COLS * 14),X
        LDA currentColorValue
        STA COLOR_RAM + (NUM_COLS * 14),X
        INX 
        CPX #(3 * NUM_COLS)
        BNE _Loop2
        RTS 

;--------------------------------------------------------
; SetUpBackgroundPainting
;--------------------------------------------------------
SetUpBackgroundPainting   
        LDX #$00
b78A4   LDA psyRasterPositionArray,X
        STA rasterPositionArray,X
        LDA psyRasterJumpTableLoPtrArray,X
        STA rasterJumpTableLoPtrArray,X
        LDA psyRasterJumpTableHiPtrArray,X
        STA rasterJumpTableHiPtrArray,X
        INX 
        CPX #$03
        BNE b78A4
        RTS 

psyRasterPositionArray       .BYTE $C0,$FF,$FF
psyRasterJumpTableLoPtrArray .BYTE <PaintBackgroundColor,<PaintBackgroundColor,<PaintBackgroundColor
psyRasterJumpTableHiPtrArray .BYTE >PaintBackgroundColor,>PaintBackgroundColor,>PaintBackgroundColor

;---------------------------------------------------------------------------------
; IncrementAndUpdateRaster
;---------------------------------------------------------------------------------
IncrementAndUpdateRaster
        INC currentRasterArrayIndex
        JSR UpdateRasterPosition
        PLA 
        TAY 
        PLA 
        TAX 
        PLA 
        RTI 

;--------------------------------------------------------
; PaintBackgroundColor
;--------------------------------------------------------
PaintBackgroundColor
        LDA currentBackgroundColor
        AND #$0F
        STA $D020    ;Border Color
        STA $D021    ;Background Color 0

        JSR UpdateBackgroundData
        JSR FetchBackgroundData
        JSR WriteLinesToScreen
        JSR $FF9F ;$FF9F - scan keyboard                    
        JMP IncrementAndUpdateRaster

currentColorValue .BYTE BLACK
cursorXPosition   .BYTE $15
cursorYPosition   .BYTE $0B
colorValueToWrite .BYTE WHITE

screenRAMLoPtr = $23
screenRAMHiPtr = $24
;--------------------------------------------------------
; WriteValueToColorRAM
;--------------------------------------------------------
WriteValueToColorRAM   
        LDY cursorXPosition
        LDX cursorYPosition

        LDA screenLinesLoPtrArray,X
        STA screenRAMLoPtr

        LDA screenLinesHiPtrArray,X
        CLC 
        ADC #OFFSET_TO_COLOR_RAM
        STA screenRAMHiPtr

        LDA colorValueToWrite
        STA (screenRAMLoPtr),Y
        RTS 

;--------------------------------------------------------
; WriteLinesToScreen
;--------------------------------------------------------
WriteLinesToScreen   
        LDA currentColorValue
        STA colorValueToWrite

        JSR WriteValueToColorRAM
        JSR MaybeCheckJoystickInput

        LDA #WHITE
        STA colorValueToWrite

        JSR WriteValueToColorRAM
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
        LDX initialPixelYPosition
        LDY initialPixelXPosition
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
        LDA currentColor
        STA (colorRAMLoPtr),Y
        RTS 

colorComparisonArray   
        .BYTE ORANGE,ORANGE,WHITE,ORANGE,BLUE,PURPLE,YELLOW,CYAN
        .BYTE RED,ORANGE,ORANGE,ORANGE,ORANGE,ORANGE,GREEN,ORANGE
        .BYTE ORANGE

lastColorValue        .BYTE $07
currentColor          .BYTE BLACK
initialPixelYPosition .BYTE $0C
initialPixelXPosition .BYTE $0C

;--------------------------------------------------------
; PaintPixelForCurrentSymmetry
;--------------------------------------------------------
PaintPixelForCurrentSymmetry   
        LDA initialPixelYPosition
        AND #$80
        BEQ CanPaintPixelOnThisLine

CleanUpAndReturn   
        RTS 

CanPaintPixelOnThisLine   
        LDA initialPixelYPosition
        CMP #BOTTOM_Y_POSITION+1
        BPL CleanUpAndReturn

        LDA initialPixelXPosition
        AND #$80
        BNE CleanUpAndReturn

        LDA initialPixelXPosition
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
        SBC initialPixelXPosition
        STA initialPixelXPosition

        JSR PaintPixel

        LDA currentSymmetrySettingForStep
        CMP #Y_AXIS_SYMMETRY
        BEQ ReturnFromSymmetry

        LDA #BOTTOM_Y_POSITION
        SEC 
        SBC initialPixelYPosition
        STA initialPixelYPosition

        JSR PaintPixel

        LDA #NUM_COLS-1
        SEC 
        SBC initialPixelXPosition
        STA initialPixelXPosition

        JMP PaintPixel

HasXYSymmetry   
        LDA #BOTTOM_Y_POSITION
        SEC 
        SBC initialPixelYPosition
        STA initialPixelYPosition

        JMP PaintPixel

HasXAxisSymmetry   
        LDA #NUM_COLS-1
        SEC 
        SBC initialPixelXPosition
        STA initialPixelXPosition
        JMP HasXYSymmetry

currentSymmetrySettingForStep .BYTE $01
presetColorValuesArray        .BYTE RED,ORANGE,YELLOW,GREEN,LTBLUE,PURPLE,BLUE
emptyColor                .BYTE BLACK
currentLineInPattern          .BYTE $07
currentPatternIndex           .BYTE $13

; A pair of arrays together consituting a list of pointers
; to positions in memory containing X position data.
; (i.e. $097C, $0E93,$0EC3, $0F07, $0F23, $0F57, $1161, $11B1)
pixelXPositionLoPtrArray .BYTE <patternXPosArray,<theTwistXPosArray,<laLlamitaXPosArray
                         .BYTE <starTwoXPosArray,<deltoidXPosArray,<diffusedXPosArray
                         .BYTE <multicrossXPosArray,<pulsarXPosArray


pixelXPositionHiPtrArray .BYTE >patternXPosArray,>theTwistXPosArray,>laLlamitaXPosArray
                         .BYTE >starTwoXPosArray,>deltoidXPosArray,>diffusedXPosArray
                         .BYTE >multicrossXPosArray,>pulsarXPosArray

; A pair of arrays together consituting a list of pointers
; to positions in memory containing Y position data.
; (i.e. $097C, $0E93,$0EC3, $0F07, $0F23, $0F57, $1161, $11B1)
pixelYPositionLoPtrArray .BYTE <patternYPosArray,<theTwistYPosArray,<laLlamitaYPosArray
                         .BYTE <starTwoYPosArray,<deltoidYPosArray,<diffusedYPosArray
                         .BYTE <multicrossYPosArray,<pulsarYPosArray

pixelYPositionHiPtrArray .BYTE >patternYPosArray,>theTwistYPosArray,>laLlamitaYPosArray
                         .BYTE >starTwoYPosArray,>deltoidYPosArray,>diffusedYPosArray
                         .BYTE >multicrossYPosArray,>pulsarYPosArray

;--------------------------------------------------------
; PaintStructureAtCurrentPosition
;--------------------------------------------------------
PaintStructureAtCurrentPosition   
        LDA #$00
        STA currentPatternIndex
        STA currentLineInPattern

        LDA currentPixelXPosition
        STA initialPixelXPosition
        LDA currentPixelYPosition
        STA initialPixelYPosition

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
        STA initialPixelXPosition

        LDA (yPosLoPtr),Y
        CLC 
        ADC currentPixelYPosition
        STA initialPixelYPosition

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
; InitializeColorIndexArray
;--------------------------------------------------------
InitializeColorIndexArray   
        LDX #$00
_Loop   LDA #$08
        STA currentColorIndexArray,X
        INX 
        CPX #$40
        BNE _Loop
b7C51   RTS 

currentPatternElement .BYTE $00
patternIndex          .BYTE $00
;--------------------------------------------------------
; MaybeFirePressed
;--------------------------------------------------------
MaybeFirePressed   
        LDA lastJoystickInput
        AND #JOYSTICK_FIRE
        BNE b7C51

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
        JSR InitializeStatusDisplayText
        JSR UpdateCurrentSettingsDisplay
        RTS 

MaybeCKeyPressed   
        CMP #KEY_C
        BNE MaybeSpacePressed

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

MaybeSpacePressed
        CMP #KEY_SPACE ; Space pressed?
        BNE MaybeF1Pressed

        ; Space pressed. Selects a new pattern element. " There are eight permanent ones,
        ; and eight you can define for yourself (more on this later!). The latter eight
        ; are all set up when you load, so you can always choose from 16 shapes."
        LDA #$01
        STA processingKeyStroke
        INC currentPatternElement
        LDA currentPatternElement
        AND #$07
        STA currentPatternElement
        JMP UpdateStatusLineAndReturn

MaybeF1Pressed   
        CMP #KEY_F1_F2
        BEQ CycleBackgroundColor
        RTS

cursorSpeed         .BYTE $01
processingKeyStroke .BYTE $00

;--------------------------------------------------------
; CycleBackgroundColor   
;--------------------------------------------------------
CycleBackgroundColor   
        LDA shiftKey 
        AND #$01
        BEQ ChangeBorderColor

ChangeBackgroundColor
        INC currentBackgroundColor
        LDA #$01
        STA processingKeyStroke 
        RTS 

ChangeBorderColor
        LDA currentColorValue
        STA currentBorderColor

        SEI 

        INC currentColorValue
        LDA currentColorValue
        AND #$0F
        STA currentColorValue

        STA emptyColor

        LDX #$00
_Loop   LDA COLOR_RAM + $0000,X
        JSR CheckCurrentBorderColor
        STA COLOR_RAM + $0000,X

        LDA COLOR_RAM + $0100,X
        JSR CheckCurrentBorderColor
        STA COLOR_RAM + $0100,X

        LDA COLOR_RAM + $0200,X
        JSR CheckCurrentBorderColor
        STA COLOR_RAM + $0200,X

        LDA COLOR_RAM + $0300,X
        JSR CheckCurrentBorderColor
        STA COLOR_RAM + $0300,X
        DEX 
        BNE _Loop

        LDA #$01
        STA processingKeyStroke

        CLI 
b7D72   RTS 

;--------------------------------------------------------
; CheckCurrentBorderColor
;--------------------------------------------------------
CheckCurrentBorderColor   
        AND #$0F
        CMP currentBorderColor
        BNE b7D72
        LDA currentColorValue
        RTS 

STATUS_LINE_POSITION = NUM_COLS * 23
LOGO_LINE_POSITION   = NUM_COLS * 23
LOGO_COL_POSITION    = 1

currentBorderColor   .BYTE BLACK
;--------------------------------------------------------
; InitializeStatusDisplayText
;--------------------------------------------------------
InitializeStatusDisplayText   
        LDX #$00
_Loop   LDA statusLineOne,X
        AND #$3F
        STA SCREEN_RAM + STATUS_LINE_POSITION,X
        LDA #GRAY1
        STA COLOR_RAM + STATUS_LINE_POSITION,X
        INX 
        CPX #NUM_COLS
        BNE _Loop
        JSR DisplayLogo
        RTS 

logoLineOne .BYTE $76,$78,$7E,$80
logoLineTwo .BYTE $77,$79,$7F,$81
;--------------------------------------------------------
; DisplayLogo
;--------------------------------------------------------
DisplayLogo   
        LDX #$00
_Loop   LDA logoLineOne,X
        STA SCREEN_RAM + LOGO_LINE_POSITION+LOGO_COL_POSITION,X
        LDA logoLineTwo,X
        STA SCREEN_RAM + LOGO_LINE_POSITION + NUM_COLS+LOGO_COL_POSITION,X
        LDA #GRAY2
        STA COLOR_RAM + LOGO_LINE_POSITION+LOGO_COL_POSITION,X
        LDA #GRAY2
        STA COLOR_RAM + LOGO_LINE_POSITION + NUM_COLS+LOGO_COL_POSITION,X
        INX 
        CPX #len(logoLineOne)
        BNE _Loop

        RTS

;                      0123456789012345678901234567890123456789
statusLineOne   .TEXT "       S:          C:   P:              "
;--------------------------------------------------------
; UpdateCurrentSettingsDisplay
;--------------------------------------------------------
UpdateCurrentSettingsDisplay   

        ; Update Cursor Speed
        LDA cursorSpeed
        CLC 
        ADC #$30
        STA SCREEN_RAM + STATUS_LINE_POSITION + 22 

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

patternTxt
        .TEXT 'STAR ONE'
        .TEXT 'TWIST   '
        .TEXT 'LLAMITA '
        .TEXT 'STAR TWO'
        .TEXT 'DELTOIDS'
        .TEXT 'DIFFUSED'
        .TEXT 'CROSS   '
        .TEXT 'PULSAR  '
symmetrySettingTxt     .TEXT "NONE Y   X  X-Y QUAD"
currentBackgroundColor .BYTE $00
currentSymmetrySetting .BYTE $01,$DD

LEN_INITIAL_ARRAY = $1C
initialBackgroundUpdateControlArray   
        .BYTE $08,$08,$08,$08,$04,$04,$04,$04
        .BYTE $02,$02,$02,$02,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01,$01,$01,$01,$01
        .BYTE $01,$01,$01,$01

numberOfUpdatesToMakeToChars   
        .BYTE $01,$01,$01,$01,$02,$02,$02,$02
        .BYTE $03,$03,$03,$03,$04,$04,$04,$04
        .BYTE $05,$05,$05,$05,$06,$06,$06,$06
        .BYTE $07,$07,$07,$07,$08,$08,$08,$08

LEN_BG_CTRL_ARRAY = $10
indexArrayForBackgroundChars   
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
backgroundUpdateControlArray   
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00

;---------------------------------------------------------------------------------
; UpdateBackgroundData
;---------------------------------------------------------------------------------
UpdateBackgroundData
        DEC controlByteForUpdatingBackground
        BNE b5A10

        LDA #LEN_INITIAL_ARRAY
        STA controlByteForUpdatingBackground

        LDX #$00
_Loop   LDA backgroundUpdateControlArray,X
        BEQ b5A06
        INX 
        CPX #LEN_BG_CTRL_ARRAY
        BNE _Loop

        JMP b5A10

b5A06   LDA #$01
        STA backgroundUpdateControlArray,X
        LDA #$00
        STA indexArrayForBackgroundChars,X

b5A10   LDX #$00
b5A12   LDA backgroundUpdateControlArray,X
        BEQ b5A23
        DEC backgroundUpdateControlArray,X
        BNE b5A23

        TXA 
        PHA 
        JSR UpdateBackgroundDataCharacters

        PLA 
        TAX 
b5A23   INX 
        CPX #LEN_BG_CTRL_ARRAY
        BNE b5A12
        RTS 

NUM_HORIZON_CHARACTERS = $09
;---------------------------------------------------------------------------------
; UpdateBackgroundDataCharacters
;---------------------------------------------------------------------------------
UpdateBackgroundDataCharacters   
        LDA indexArrayForBackgroundChars,X
        STA indexIntoDataChars

        CLC 
        ROR 
        STA indexToBackgroundControlArray

        INC indexArrayForBackgroundChars,X

        LDA #$FF
        LDY indexIntoDataChars
        STA rollingHorizonCharacters,Y

        INY 
        TYA 
        STA indexIntoDataChars
        CMP #(8 * NUM_HORIZON_CHARACTERS)
        BNE ResetHorizonCharacter

        RTS 

ResetHorizonCharacter   
        LDY indexToBackgroundControlArray
        LDA initialBackgroundUpdateControlArray,Y
        STA backgroundUpdateControlArray,X

        LDX numberOfUpdatesToMakeToChars,Y
        LDY indexIntoDataChars
        LDA #$00
_Loop   INY 
        STA rollingHorizonCharacters,Y
        DEX 
        BNE _Loop
        RTS 

controlByteForUpdatingBackground   
        .BYTE $01,$63,$64,$65,$66,$67,$68,$69
        .BYTE $6A,$6B,$6C,$6D,$6E,$6F

;---------------------------------------------------------------------------------
; FetchBackgroundData
;---------------------------------------------------------------------------------
FetchBackgroundData   
        LDX #$FF
        LDY #$00
b7223   LDA rollingHorizonCharacters,Y
        STA activeBackgroundCharacters,X
        DEX 
        INY 
        CPY #$40
        BNE b7223
        RTS 

* = $2000
.include "charset.asm"
.include "patterns.asm"
