shiftKey                         = $028D
;---------------------------------------------------------------------------------
; Game 6: Psychedelia 
; 
; Well I was going to put a PAUSE mode in, but this is much better. When you need
; to, drop into SUB6 and relax. The timer stops and you can stay in the subgame
; until you've got your head together enough to play on. The controls are a
; subset of real PSYCHEDELIA, allowing S=symmetry change and C=cursor speed. You
; can also use F1 and SHIFT-F1 to change fore- and background colours. 
; 
; Design Notes: Well it's more interesting than freezing the screen. 
;---------------------------------------------------------------------------------
;--------------------------------------------------------
; LaunchPsychedelia
;--------------------------------------------------------
LaunchPsychedelia
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

;--------------------------------------------------------
; InitializePsychedelia
;--------------------------------------------------------
InitializePsychedelia   
        LDX #$00
_Loop   LDA #SPACE
        STA SCREEN_RAM + $0000,X
        DEX 
        BNE _Loop

        LDA $D016    ;VIC Control Register 2
        AND #$F0
        ORA #$08
        STA $D016    ;VIC Control Register 2

        LDA #$0A
        STA currentCharYPos

        LDA #$63
        STA currentChar

        LDA currentColorValue
        STA a06

OuterLoop   
        LDA #$00
        STA currentCharXPos

InnerLoop  
        JSR WriteCurrentCharToScreen

        LDA currentCharYPos
        PHA 
        SEC 
        SBC #$0A
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
        CMP #$28
        BNE InnerLoop

        INC currentChar
        INC currentCharYPos
        LDA currentCharYPos
        CMP #$12
        BNE OuterLoop

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

        JSR ResetSomeDataAndClearMiddleScreen

        LDX #$00
_Loop   LDA #$42
        STA SCREEN_RAM + $0140,X
        LDA currentColorValue
        STA COLOR_RAM + $0140,X
        INX 
        CPX #$50
        BNE _Loop
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

;--------------------------------------------------------
; PaintBackgroundColor
;--------------------------------------------------------
PaintBackgroundColor
        LDA currentBackgroundColor
        AND #$0F
        STA $D020    ;Border Color
        STA $D021    ;Background Color 0

        JSR s4138
        JSR s721F
        JSR WriteLinesToScreen
        JSR $FF9F ;$FF9F - scan keyboard                    
        JMP JumpToIncrementAndUpdateRaster

currentColorValue .BYTE $0B
cursorXPosition   .BYTE $15
cursorYPosition   .BYTE $0B
colorValueToWrite .BYTE $01

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

        LDA #TOP_Y_POSITION
        STA cursorYPosition

MaybeDownPressed   
        LDA lastJoystickInput
        AND #JOYSTICK_UP
        BEQ MaybeLeftPressed

DownPressed
        INC cursorYPosition
        LDA cursorYPosition
        CMP #TOP_Y_POSITION+1
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
currentColor          .BYTE $0B
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
        CMP #TOP_Y_POSITION+1
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

        LDA #TOP_Y_POSITION
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
        LDA #TOP_Y_POSITION
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
unusedVariable                .BYTE $0B
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
        STA initialPixelXPosition
        LDA currentPixelYPosition
        STA initialPixelYPosition

        JSR PaintPixelForCurrentSymmetry

        LDA currentColorIndex
        BNE PixelPaintLoop
        RTS 

PixelPaintLoop   
        LDX currentPatternIndex
        LDA patternXPosArray,X
        CMP #$55
        BEQ MoveToNextLineInPattern

        CLC 
        ADC currentPixelXPosition
        STA initialPixelXPosition

        LDA patternYPosArray,X
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

patternXPosArray             
        .BYTE $FF,$01,$55    ; 6              
        .BYTE $FE,$02,$55    ;            5   
        .BYTE $FD,$03,$55    ;   4            
        .BYTE $FC,$04,$55    ;          3     
        .BYTE $FB,$05,$55    ;     2          
        .BYTE $FA,$06,$55    ;        1       
        .BYTE $55,$55        ;                
patternYPosArray             ;      1         
        .BYTE $01,$FF,$55    ;         2      
        .BYTE $FE,$02,$55    ;    3           
        .BYTE $03,$FD,$55    ;           4    
        .BYTE $FC,$04,$55    ;  5             
        .BYTE $05,$FB,$55    ;             6 
        .BYTE $FA,$06,$55
        .BYTE $55,$55

currentColorIndex     .BYTE $07
currentPixelXPosition .BYTE $15
currentPixelYPosition .BYTE $06
sYmmetrySettingForStep
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
        BNE MaybeF1Pressed

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

MaybeF1Pressed   
        CMP #KEY_F1_F2
        BEQ CycleBackgroundColor
        JMP JumpToCheckSubGameSelection

cursorSpeed         .BYTE $02
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

        STA unusedVariable

        LDX #$00
_Loop   LDA COLOR_RAM + $0000,X
        JSR CheckCurrentBorderColor
        STA COLOR_RAM + $0000,X
        LDA COLOR_RAM + $0100,X
        JSR CheckCurrentBorderColor
        STA COLOR_RAM + $0100,X
        LDA COLOR_RAM + $01D0,X
        JSR CheckCurrentBorderColor
        STA COLOR_RAM + $01D0,X
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

currentBorderColor   .BYTE $00
;--------------------------------------------------------
; InitializeStatusDisplayText
;--------------------------------------------------------
InitializeStatusDisplayText   
        LDX #$00
_Loop   LDA statusLineOne,X
        AND #$3F
        STA SCREEN_RAM + $0320,X
        LDA #$0B
        STA COLOR_RAM + $0320,X
        INX 
        CPX #NUM_COLS
        BNE _Loop
        RTS 

statusLineOne   .TEXT "*** KLINGE MODE *** HAVE FUN- USE S,C,F1"
statusLineTwo   .TEXT "      SYMMETRY .... CURSOR SPEED 0      "
;--------------------------------------------------------
; UpdateCurrentSettingsDisplay
;--------------------------------------------------------
UpdateCurrentSettingsDisplay   
        LDX #$00
_Loop   LDA statusLineTwo,X
        AND #$3F
        STA SCREEN_RAM + $02D0,X
        LDA #$0B
        STA COLOR_RAM + $02D0,X
        INX 
        CPX #$28
        BNE _Loop

        LDA cursorSpeed
        CLC 
        ADC #$30
        STA SCREEN_RAM + $02F1

        LDA currentSymmetrySetting
        ASL 
        ASL 
        TAY 

        LDX #$00
_Loop2  LDA symmetrySettingTxt,Y
        AND #$3F
        STA SCREEN_RAM + $02DF,X
        INY 
        INX 
        CPX #$04
        BNE _Loop2

        RTS 

symmetrySettingTxt     .TEXT "NONE Y   X  X-Y QUAD"
currentBackgroundColor .BYTE $00
currentSymmetrySetting .BYTE $01,$DD
