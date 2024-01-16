soundEffectInProgress                .BYTE $00

hitEnemyWithBulletSound     
                            .BYTE $00,PLAY_SOUND,$0F,VOICE3_ATK_DEC,$00
                            .BYTE $00,PLAY_SOUND,$00,VOICE3_SUS_REL,$00
                            .BYTE $00,PLAY_SOUND,$30,VOICE3_HI,$00
                            .BYTE $00,PLAY_SOUND,$11,VOICE3_CTRL,$02
                            .BYTE $0F,DEC_AND_PLAY_FROM_BUFFER,$02,VOICE3_HI,$00
                            .BYTE $00,PLAY_SOUND,$00,VOICE3_CTRL,$00
                            .BYTE $00,LINK,<setVolumeToMax,>setVolumeToMax,$00

setVolumeToMax            .BYTE $00,PLAY_SOUND,$0F,VOLUME,$01
                          .BYTE $00,LINK,<setVolumeToMax,>setVolumeToMax,$00

soundEffectBuffer                       .BYTE $00,$94,$00,$00,$11,$0F,$00,$00
                                        .BYTE $03,$00,$00,$21,$0F,$00,$08,$03
                                        .BYTE $00,$00,$21,$0F,$00,$00,$00,$00
                                        .BYTE $02,$00,$00,$00,$00,$00,$00,$00
storedPrimarySoundEffectLoPtr           .BYTE $00
storedPrimarySoundEffectHiPtr           .BYTE $00
storedSecondarySoundEffectLoPtr         .BYTE $00
storedSecondarySoundEffectHiPtr         .BYTE $00
repetitionsForPrimarySoundEffect        .BYTE $02,$00
repetitionsForSecondarySoundEffect      .BYTE $00,$00
indexToPrimaryOrSecondarySoundEffectPtr .BYTE $02

; Five bytes loaded from the sound effect in 5 byte intervals.
soundEffectDataStructure
soundEffectDataStructure_Byte1 .BYTE $18
soundEffectDataStructure_Byte2 .BYTE $05
soundEffectDataStructure_Byte3 .BYTE $00
soundEffectDataStructure_Byte4 .BYTE $00
soundEffectDataStructure_Byte5 .BYTE $00

primarySoundEffectLoPtr     .BYTE $00
primarySoundEffectHiPtr     .BYTE $00
secondarySoundEffectLoPtr   .BYTE $00
secondarySoundEffectHiPtr   .BYTE $00
;-------------------------------------------------------
; PlaySoundEffects
;-------------------------------------------------------
PlaySoundEffects
        LDA #$00
        STA indexToPrimaryOrSecondarySoundEffectPtr
        LDA soundEffectInProgress
        BEQ DontDecrementSoundEffectProgressCounter
        DEC soundEffectInProgress
DontDecrementSoundEffectProgressCounter   
        LDA primarySoundEffectLoPtr
        STA currentSoundEffectLoPtr
        LDA primarySoundEffectHiPtr
        STA currentSoundEffectHiPtr
        JSR PlayCurrentSoundEffect

        LDA #$02
        STA indexToPrimaryOrSecondarySoundEffectPtr
        LDA secondarySoundEffectLoPtr
        STA currentSoundEffectLoPtr
        LDA secondarySoundEffectHiPtr
        STA currentSoundEffectHiPtr
        ;Falls through and plays secondary sound effect.

;-------------------------------------------------------
; PlayCurrentSoundEffect
;-------------------------------------------------------
PlayCurrentSoundEffect
        LDY #$00
FillSoundEffectDataStructureLoop   
        LDA (currentSoundEffectLoPtr),Y
        STA soundEffectDataStructure,Y
        INY
        CPY #$05
        BNE FillSoundEffectDataStructureLoop

        LDA soundEffectDataStructure_Byte2
        BNE PlayNextSoundBasedOnSequenceByte

        ; Type 00 just plays what ever is in Byte 2 into
        ; the offset of D400 given by Byte 3.
        LDA soundEffectDataStructure_Byte3
        LDX soundEffectDataStructure_Byte4
        STA soundEffectBuffer,X
        STA $D400,X  ;Voice 1: Frequency Control - Low-Byte

GetNextRecordAndMaybePlayIt
        JSR GetNextRecordInSoundEffect
        LDA soundEffectDataStructure_Byte5
        BEQ PlayCurrentSoundEffect
        CMP #$01
        BNE StorePointersAndReturn
        RTS

StorePointersAndReturn   
        LDX indexToPrimaryOrSecondarySoundEffectPtr
        LDA currentSoundEffectLoPtr
        STA storedPrimarySoundEffectLoPtr,X
        LDA currentSoundEffectHiPtr
        STA storedPrimarySoundEffectHiPtr,X
        RTS

;-------------------------------------------------------
; GetNextRecordInSoundEffect
;-------------------------------------------------------
GetNextRecordInSoundEffect
        LDA currentSoundEffectLoPtr
        CLC
        ADC #$05
        STA currentSoundEffectLoPtr
        LDX indexToPrimaryOrSecondarySoundEffectPtr
        STA primarySoundEffectLoPtr,X
        LDA currentSoundEffectHiPtr
        ADC #$00
        STA currentSoundEffectHiPtr
        STA primarySoundEffectHiPtr,X
        RTS

;-------------------------------------------------------
; PlayNextSoundBasedOnSequenceByte
;-------------------------------------------------------
PlayNextSoundBasedOnSequenceByte   
        AND #$80
        BEQ MaybeIncrementAndPlaySoundFromBuffer
        JMP MaybeSkipToLinkedRecord

MaybeIncrementAndPlaySoundFromBuffer   
        LDA soundEffectDataStructure_Byte2
        CMP #INC_AND_PLAY_FROM_BUFFER
        BNE MaybeDecrementAndPlaySoundFromBuffer

        ; Increment the value in the buffer and play it.
        LDX soundEffectDataStructure_Byte1
        LDA soundEffectBuffer,X
        CLC
        ADC soundEffectDataStructure_Byte3
        LDX soundEffectDataStructure_Byte4
        STA soundEffectBuffer,X
        STA $D400,X  ;Voice 1: Frequency Control - Low-Byte
        JMP GetNextRecordAndMaybePlayIt

MaybeDecrementAndPlaySoundFromBuffer   
        CMP #DEC_AND_PLAY_FROM_BUFFER
        BNE TrySequenceByteValueOf3

        ; Decrement the value in the buffer and play it.
        LDX soundEffectDataStructure_Byte1
        LDA soundEffectBuffer,X
        SEC
        SBC soundEffectDataStructure_Byte3

GetNextRecordInSoundEffectLoop
        LDX soundEffectDataStructure_Byte4
        STA soundEffectBuffer,X
        STA $D400,X  ;Voice 1: Frequency Control - Low-Byte
        JMP GetNextRecordAndMaybePlayIt

TrySequenceByteValueOf3   
        CMP #$03
        BNE TrySequenceByteValueOf4
        LDX soundEffectDataStructure_Byte1
        LDY soundEffectDataStructure_Byte3
        LDA soundEffectBuffer,X
        CLC
        ADC soundEffectBuffer,Y
        JMP GetNextRecordInSoundEffectLoop

TrySequenceByteValueOf4   
        CMP #$04
        BNE MaybeIsFadeOutLoop
        LDX soundEffectDataStructure_Byte1
        LDY soundEffectDataStructure_Byte3
        LDA soundEffectBuffer,X
        SEC
        SBC soundEffectBuffer,Y
        JMP GetNextRecordInSoundEffectLoop

MaybeIsFadeOutLoop   
        CMP #PLAY_LOOP
        BNE TrySequenceByteValueOf6

        ; The record is a fade out loop. Bytes 4 and 5
        ; (soundEffectDataStructure_Byte4 and soundEffectDataStructure_Byte5) contain
        ; the address of the record to loop back to.
        ; Byte 0 contains the offset to the volume switch
        ; (i.e. 18 for D418).
        ; Byte 2 (dataForSounEffectBuffer) contains the
        ; decrements to reduce the volume by. 
        LDX soundEffectDataStructure_Byte1
        LDA soundEffectBuffer,X
        SEC
        SBC soundEffectDataStructure_Byte3

StorePointersAndReturnIfZero
        STA soundEffectBuffer,X
        STA $D400,X  ;Voice 1: Frequency Control - Low-Byte
        BEQ JumpToGetNextRecordInSoundEffect
        LDA soundEffectDataStructure_Byte4
        LDX indexToPrimaryOrSecondarySoundEffectPtr
        STA primarySoundEffectLoPtr,X
        LDA soundEffectDataStructure_Byte5
        STA primarySoundEffectHiPtr,X
        RTS

JumpToGetNextRecordInSoundEffect   
        JMP GetNextRecordInSoundEffect

TrySequenceByteValueOf6   
        CMP #$06
        BNE MaybeSkipToLinkedRecord
        LDX soundEffectDataStructure_Byte1
        LDA soundEffectBuffer,X
        CLC
        ADC soundEffectDataStructure_Byte3
        JMP StorePointersAndReturnIfZero

MaybeSkipToLinkedRecord
        LDA soundEffectDataStructure_Byte2
        CMP #$80
        BNE MaybePlayStoredSoundEffect

        ; Cease playing records and point to the
        ; record to play at the next interrupt.
        LDX indexToPrimaryOrSecondarySoundEffectPtr
        LDA soundEffectDataStructure_Byte3
        STA primarySoundEffectLoPtr,X
        LDA soundEffectDataStructure_Byte4
        STA primarySoundEffectHiPtr,X
        RTS

MaybePlayStoredSoundEffect   
        CMP #REPEAT_PREVIOUS
        BNE ReturnFromGetNextRecordInSoundEffect

        ; Play a sound effect record stored previously.
        LDX indexToPrimaryOrSecondarySoundEffectPtr
        LDA repetitionsForPrimarySoundEffect,X
        BNE SoundEffectPresent
        LDA soundEffectDataStructure_Byte3
        STA repetitionsForPrimarySoundEffect,X

SoundEffectPresent   
        DEC repetitionsForPrimarySoundEffect,X
        BEQ JumpToGetNextRecordInSoundEffect_
        LDA storedPrimarySoundEffectLoPtr,X
        STA currentSoundEffectLoPtr
        LDA storedPrimarySoundEffectHiPtr,X
        STA currentSoundEffectHiPtr
        JMP PlayCurrentSoundEffect

JumpToGetNextRecordInSoundEffect_   
        JMP GetNextRecordInSoundEffect

ReturnFromGetNextRecordInSoundEffect   
        RTS

;-------------------------------------------------------
; ResetRepetitionForPrimarySoundEffect
;-------------------------------------------------------
ResetRepetitionForPrimarySoundEffect
        LDA #$00
        STA repetitionsForPrimarySoundEffect
        RTS

;-------------------------------------------------------
; ResetRepetitionForSecondarySoundEffect
;-------------------------------------------------------
ResetRepetitionForSecondarySoundEffect
        LDA #$00
        STA repetitionsForSecondarySoundEffect
b7C96   RTS

