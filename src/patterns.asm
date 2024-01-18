*=$4000
; A pair of arrays together consituting a list of pointers
; to positions in memory containing X position data.
; (i.e. $097C, $0E93,$0EC3, $0F07, $0F23, $0F57, $1161, $11B1)
pixelXPositionLoPtrArray .BYTE <patternXPosArray,<diffusedXPosArray,<laLlamitaXPosArray
                         .BYTE <trickyPattern0XPosArray
                         .BYTE <starTwoXPosArray,<deltoidXPosArray,<theTwistXPosArray
                         .BYTE <trickyPattern1XPosArray
                         .BYTE <multicrossXPosArray,<pulsarXPosArray
                         .BYTE <trickyPattern2XPosArray
                         .BYTE <customPattern0XPosArray,<customPattern1XPosArray
                         .BYTE <trickyPattern3XPosArray
                         .BYTE <customPattern2XPosArray,<customPattern3XPosArray
                         .BYTE <trickyPattern4XPosArray
                         .BYTE <customPattern4XPosArray,<customPattern7XPosArray
                         .BYTE <trickyPattern5XPosArray
                         .BYTE <customPattern6XPosArray,<customPattern5XPosArray
                         .BYTE <trickyPattern6XPosArray

pixelXPositionHiPtrArray .BYTE >patternXPosArray,>diffusedXPosArray,>laLlamitaXPosArray
                         .BYTE >trickyPattern0XPosArray
                         .BYTE >starTwoXPosArray,>deltoidXPosArray,>theTwistXPosArray
                         .BYTE >trickyPattern1XPosArray
                         .BYTE >multicrossXPosArray,>pulsarXPosArray
                         .BYTE >trickyPattern2XPosArray
                         .BYTE >customPattern0XPosArray,>customPattern1XPosArray
                         .BYTE >trickyPattern3XPosArray
                         .BYTE >customPattern2XPosArray,>customPattern3XPosArray
                         .BYTE >trickyPattern4XPosArray
                         .BYTE >customPattern4XPosArray,>customPattern7XPosArray
                         .BYTE >trickyPattern5XPosArray
                         .BYTE >customPattern6XPosArray,>customPattern5XPosArray
                         .BYTE >trickyPattern6XPosArray

; A pair of arrays together consituting a list of pointers
; to positions in memory containing Y position data.
; (i.e. $097C, $0E93,$0EC3, $0F07, $0F23, $0F57, $1161, $11B1)
pixelYPositionLoPtrArray .BYTE <patternYPosArray,<diffusedYPosArray,<laLlamitaYPosArray
                         .BYTE <trickyPattern0YPosArray
                         .BYTE <starTwoYPosArray,<deltoidYPosArray,<theTwistYPosArray
                         .BYTE <trickyPattern1YPosArray
                         .BYTE <multicrossYPosArray,<pulsarYPosArray
                         .BYTE <trickyPattern2YPosArray
                         .BYTE <customPattern0YPosArray,<customPattern1YPosArray
                         .BYTE <trickyPattern3YPosArray
                         .BYTE <customPattern2YPosArray,<customPattern3YPosArray
                         .BYTE <trickyPattern4YPosArray
                         .BYTE <customPattern4YPosArray,<customPattern7YPosArray
                         .BYTE <trickyPattern5YPosArray
                         .BYTE <customPattern6YPosArray,<customPattern5YPosArray
                         .BYTE <trickyPattern6YPosArray
pixelYPositionHiPtrArray .BYTE >patternYPosArray,>diffusedYPosArray,>laLlamitaYPosArray
                         .BYTE >trickyPattern0YPosArray
                         .BYTE >starTwoYPosArray,>deltoidYPosArray,>theTwistYPosArray
                         .BYTE >trickyPattern1YPosArray
                         .BYTE >multicrossYPosArray,>pulsarYPosArray
                         .BYTE >trickyPattern2YPosArray
                         .BYTE >customPattern0YPosArray,>customPattern1YPosArray
                         .BYTE >trickyPattern3YPosArray
                         .BYTE >customPattern2YPosArray,>customPattern3YPosArray
                         .BYTE >trickyPattern4YPosArray
                         .BYTE >customPattern4YPosArray,>customPattern7YPosArray
                         .BYTE >trickyPattern5YPosArray
                         .BYTE >customPattern6YPosArray,>customPattern5YPosArray
                         .BYTE >trickyPattern6YPosArray

patternTxt
        .TEXT 'BATALYX '
        .TEXT 'DIFFUSED'
        .TEXT 'LLAMITA '
        .TEXT 'TRICKY  '
        .TEXT 'STAR TWO'
        .TEXT 'DELTOIDS'
        .TEXT 'TWIST   '
        .TEXT 'DODGY   '
        .TEXT 'CROSS   '
        .TEXT 'PULSAR  '
        .TEXT 'NAUGHTY '
        .TEXT 'CND     '
        .TEXT 'CND2    '
        .TEXT 'SILLY   '
        .TEXT 'TREE    '
        .TEXT 'CAMELY  '
        .TEXT 'BLOODY  '
        .TEXT 'BIG STAR'
        .TEXT 'SPREADY '
        .TEXT 'BUGGER  '
        .TEXT 'THING   '
        .TEXT 'JEFFIE  '
        .TEXT 'BOLSHY  '

; The pattern array data.
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

salaciousXPosArray  .BYTE $00,$55       
                    .BYTE $01,$02,$55  
                    .BYTE $01,$02,$03,$55
                    .BYTE $01,$02,$03,$04,$55
                    .BYTE $00,$00,$00,$55   
                    .BYTE $FF,$FE,$55      
                    .BYTE $FF,$55         
                    .BYTE $55
salaciousYPosArray  .BYTE $FF,$55
                    .BYTE $FF,$FE,$55
                    .BYTE $00,$00,$00,$55
                    .BYTE $01,$02,$03,$04,$55
                    .BYTE $01,$02,$03,$55
                    .BYTE $01,$02,$55
                    .BYTE $00,$55
                    .BYTE $55

starOneXPosArray  .BYTE $00,$01,$01,$01,$00,$FF,$FF,$FF,$55       ;        5       
                  .BYTE $00,$02,$00,$FE,$55                       ;                
                  .BYTE $00,$03,$00,$FD,$55                       ;       4 4      
                  .BYTE $00,$04,$00,$FC,$55                       ;        3       
                  .BYTE $FF,$01,$05,$05,$01,$FF,$FB,$FB,$55       ;        2       
                  .BYTE $00,$07,$00,$F9,$55                       ;        1       
                  .BYTE $55                                       ;   4   000   4  
starOneYPosArray  .BYTE $FF,$FF,$00,$01,$01,$01,$00,$FF,$55       ; 5  3210 0123  5
                  .BYTE $FE,$00,$02,$00,$55                       ;   4   000   4  
                  .BYTE $FD,$00,$03,$00,$55                       ;        1       
                  .BYTE $FC,$00,$04,$00,$55                       ;        2       
                  .BYTE $FB,$FB,$FF,$01,$05,$05,$01,$FF,$55       ;        3       
                  .BYTE $F9,$00,$07,$00,$55                       ;       4 4      
                  .BYTE $55                                       ;                

theTwistXPosArray .BYTE $00,$55                            ;     1  
                  .BYTE $01,$02,$55                        ;   01   
                  .BYTE $01,$02,$03,$55                    ;  6 222 
                  .BYTE $01,$02,$03,$04,$55                ;  543   
                  .BYTE $00,$00,$00,$55                    ; 5 4 3  
                  .BYTE $FF,$FE,$55                        ;   4  3 
                  .BYTE $FF,$55                            ;       3
                  .BYTE $55
theTwistYPosArray .BYTE $FF,$55
                  .BYTE $FF,$FE,$55
                  .BYTE $00,$00,$00,$55
                  .BYTE $01,$02,$03,$04,$55
                  .BYTE $01,$02,$03,$55
                  .BYTE $01,$02,$55
                  .BYTE $00,$55
                  .BYTE $55

laLlamitaXPosArray  .BYTE $00,$FF,$55                    ;  0       
                    .BYTE $00,$00,$55                    ; 06      
                    .BYTE $01,$02,$55                    ;  0      
                    .BYTE $04,$05,$55                    ;  1    3 
                    .BYTE $04,$00,$55                    ;  12223 3
                    .BYTE $FF,$03,$55                    ;  22223  
                    .BYTE $00,$55                        ;  333 4  
laLlamitaYPosArray  .BYTE $FF,$00,$55                    ;  4   4  
                    .BYTE $02,$03,$55                    ; 54  54  
                    .BYTE $03,$03,$55
                    .BYTE $03,$02,$55
                    .BYTE $05,$06,$55
                    .BYTE $07,$07,$55
                    .BYTE $00,$55

starTwoXPosArray  .BYTE $FF,$55                  ;    1  
                  .BYTE $00,$55                  ;   0  2
                  .BYTE $02,$55                  ;    6  
                  .BYTE $01,$55                  ; 4     
                  .BYTE $FD,$55                  ;     3 
                  .BYTE $FE,$55                  ;  5    
                  .BYTE $00,$55
starTwoYPosArray  .BYTE $FF,$55
                  .BYTE $FE,$55
                  .BYTE $FF,$55
                  .BYTE $02,$55
                  .BYTE $01,$55
                  .BYTE $FC,$55
                  .BYTE $00,$55

deltoidXPosArray  .BYTE $00,$01,$FF,$55           ;       5      
                  .BYTE $00,$55                   ;              
                  .BYTE $00,$01,$02,$FE,$FF,$55   ;       4      
                  .BYTE $00,$03,$FD,$55           ;       3      
                  .BYTE $00,$04,$FC,$55           ;       2      
                  .BYTE $00,$06,$FA,$55           ;      202     
                  .BYTE $00,$55                   ;     20602    
deltoidYPosArray  .BYTE $FF,$00,$00,$55           ;    3     3   
                  .BYTE $00,$55                   ;   4       4  
                  .BYTE $FE,$FF,$00,$00,$FF,$55   ;              
                  .BYTE $FD,$01,$01,$55           ; 5           5
                  .BYTE $FC,$02,$02,$55
                  .BYTE $FA,$04,$04,$55
                  .BYTE $00,$55

diffusedXPosArray .BYTE $FF,$01,$55                  ; 5            
                  .BYTE $FE,$02,$55                  ;            4 
                  .BYTE $FD,$03,$55                  ;   3          
                  .BYTE $FC,$04,$FC,$FC,$04,$04,$55  ;          2   
                  .BYTE $FB,$05,$55                  ; 5   1       5
                  .BYTE $FA,$06,$FA,$FA,$06,$06,$55  ;   3    0  3  
                  .BYTE $00,$55                      ;       6      
diffusedYPosArray .BYTE $01,$FF,$55                  ;   3  0    3  
                  .BYTE $FE,$02,$55                  ; 5       1   5
                  .BYTE $03,$FD,$55                  ;    2         
                  .BYTE $FC,$04,$FF,$01,$FF,$01,$55  ;           3  
                  .BYTE $05,$FB,$55                  ;  4           
                  .BYTE $FA,$06,$FE,$02,$FE,$02,$55  ;             5
                  .BYTE $00,$55

multicrossXPosArray .BYTE $01,$01,$FF,$FF,$55                    ;
                    .BYTE $02,$02,$FE,$FE,$55                    ;   5     5  
                    .BYTE $01,$03,$03,$01,$FF,$FD,$FD,$FF,$55    ;  4       4 
                    .BYTE $03,$03,$FD,$FD,$55                    ; 5 3 2 2 3 5
                    .BYTE $04,$04,$FC,$FC,$55                    ;    1   1   
                    .BYTE $03,$05,$05,$03,$FD,$FB,$FB,$FD,$55    ;   2 0 0 2  
                    .BYTE $00,$55                                ;      6     
multicrossYPosArray .BYTE $FF,$01,$01,$FF,$55                    ;   2 0 0 2  
                    .BYTE $FE,$02,$02,$FE,$55                    ;    1   1   
                    .BYTE $FD,$FF,$01,$03,$03,$01,$FF,$FD,$55    ; 5 3 2 2 3 5
                    .BYTE $FD,$03,$03,$FD,$55                    ;  4       4 
                    .BYTE $FC,$04,$04,$FC,$55                    ;   5     5  
                    .BYTE $FB,$FD,$03,$05,$05,$03,$FD,$FB,$55    ;
                    .BYTE $00,$55


pulsarXPosArray .BYTE $00,$01,$00,$FF,$55       ;
                .BYTE $00,$02,$00,$FE,$55       ;       5      
                .BYTE $00,$03,$00,$FD,$55       ;       4      
                .BYTE $00,$04,$00,$FC,$55       ;       3      
                .BYTE $00,$05,$00,$FB,$55       ;       2      
                .BYTE $00,$06,$00,$FA,$55       ;       1      
                .BYTE $00,$55                   ;       0      
pulsarYPosArray .BYTE $FF,$00,$01,$00,$55       ; 5432106012345
                .BYTE $FE,$00,$02,$00,$55       ;       0      
                .BYTE $FD,$00,$03,$00,$55       ;       1      
                .BYTE $FC,$00,$04,$00,$55       ;       2      
                .BYTE $FB,$00,$05,$00,$55       ;       3      
                .BYTE $FA,$00,$06,$00,$55       ;       4      
                .BYTE $00,$55                   ;       5      
;
;    33033   
;  35  0  54 
; 5    6    5
; 3   020   4
;    0 2 0   
;  30  2  14 
;    54245   
;
customPattern0XPosArray
        .BYTE $00,$00,$00,$FF,$FE,$FD,$01,$02,$55
        .BYTE $00,$03,$55
        .BYTE $00,$00,$00,$00,$00,$55
        .BYTE $00,$FF,$FE,$FC,$FB,$FC,$01,$02,$55
        .BYTE $00,$04,$05,$04,$FF,$01,$55
        .BYTE $00,$FD,$FB,$03,$05,$02,$FE,$55
        .BYTE $00,$55


customPattern0YPosArray
        .BYTE $00,$FF,$FE,$01,$02,$03,$01,$02,$55
        .BYTE $00,$03,$55
        .BYTE $00,$01,$02,$03,$04,$55
        .BYTE $00,$FE,$FE,$FF,$01,$03,$FE,$FE,$55
        .BYTE $00,$FF,$01,$03,$04,$04,$55
        .BYTE $00,$FF,$00,$FF,$00,$04,$04,$55
        .BYTE $00,$55


;       3      
;    4  5  4   
;       6      
; 3     1     3
;       7      
;     21 12    
;  466     664 
;              
;              
;    3  5  3   
;-----------------
customPattern1XPosArray
        .BYTE $00,$00,$FF,$01,$55
        .BYTE $00,$FE,$02,$55
        .BYTE $00,$00,$FA,$06,$03,$FD,$55
        .BYTE $00,$FD,$03,$FB,$05,$55
        .BYTE $00,$00,$00,$55
        .BYTE $00,$00,$FC,$04,$03,$FD,$55
        .BYTE $00,$55


customPattern1YPosArray
        .BYTE $00,$FF,$01,$01,$55
        .BYTE $00,$01,$01,$55
        .BYTE $00,$FC,$FF,$FF,$05,$05,$55
        .BYTE $00,$FD,$FD,$02,$02,$55
        .BYTE $00,$05,$FD,$55
        .BYTE $00,$FE,$02,$02,$02,$02,$55
        .BYTE $00,$55



;        5       
;      8   8     
;   4         4  
;                
;                
; 3   2  9  2   3
;                
;                
;                
;        6       
;-----------------

customPattern2XPosArray
        .BYTE $00,$55
        .BYTE $00,$FD,$03,$55
        .BYTE $00,$F9,$07,$55
        .BYTE $00,$FB,$05,$55
        .BYTE $00,$00,$55
        .BYTE $00,$00,$55
        .BYTE $00,$55
        .BYTE $FE,$02,$55
        .BYTE $00,$55
        .BYTE $55

customPattern2YPosArray
        .BYTE $00,$55
        .BYTE $00,$00,$00,$55
        .BYTE $00,$00,$00,$55
        .BYTE $00,$FD,$FD,$55
        .BYTE $00,$FB,$55
        .BYTE $00,$04,$55
        .BYTE $00,$55
        .BYTE $FC,$FC,$55
        .BYTE $00,$55
        .BYTE $55


;  5    
; 66  1 
;  4 711
;   4222
;    3 2
;    3 3
;-----------------
 customPattern3XPosArray
        .BYTE $00,$01,$01,$02,$55
        .BYTE $00,$00,$01,$02,$02,$55
        .BYTE $00,$00,$00,$02,$55
        .BYTE $00,$FF,$FE,$55
        .BYTE $00,$FE,$FE,$55
        .BYTE $00,$FD,$FE,$55
        .BYTE $00,$55

customPattern3YPosArray
        .BYTE $00,$FF,$00,$00,$55
        .BYTE $00,$01,$01,$01,$02,$55
        .BYTE $00,$02,$03,$03,$55
        .BYTE $00,$01,$00,$55
        .BYTE $00,$FF,$FE,$55
        .BYTE $00,$FF,$FF,$55
        .BYTE $00,$55

        .BYTE $00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00


;                    1                    
;                                         
;                                         
;                                         
;                                         
;                    3                    
;                                         
;                                         
;                    4                    
;                                         
;                    5                    
;                    6                    
; 1    2         99 6106899          2    1
;                                         
;                                         
;                                         
;                                         
;                                         
;                                         
;                                         
;                                         
;                                         
;                                         
;                    1                    
customPattern4XPosArray
        .BYTE $00,$00,$00,$ED,$14,$55
        .BYTE $00,$F2,$0F,$55
        .BYTE $00,$00,$55
        .BYTE $00,$00,$55
        .BYTE $00,$00,$55
        .BYTE $00,$00,$FF,$01,$55
        .BYTE $00,$55
        .BYTE $02,$55
        .BYTE $00,$FC,$FD,$03,$04,$55
        .BYTE $00,$55


customPattern4YPosArray
        .BYTE $00,$0B,$F4,$00,$00,$55
        .BYTE $00,$00,$00,$55
        .BYTE $00,$F9,$55
        .BYTE $00,$FC,$55
        .BYTE $00,$FE,$55
        .BYTE $00,$FF,$00,$00,$55
        .BYTE $00,$55
        .BYTE $00,$55
        .BYTE $00,$00,$00,$00,$00,$55
        .BYTE $00,$55

;-----------------

;   44455566
;       1   
;       1   
;      1    
;      7    
;     2     
;     2     
; 3  2      
;  33       
;-----------------
customPattern5XPosArray
        .BYTE $00,$00,$01,$01,$55
        .BYTE $00,$FF,$FF,$FE,$55
        .BYTE $00,$FD,$FC,$FB,$55
        .BYTE $00,$FD,$FE,$FF,$55
        .BYTE $00,$00,$01,$02,$55
        .BYTE $00,$03,$04,$55
        .BYTE $00,$55

customPattern5YPosArray
        .BYTE $00,$FF,$FE,$FD,$55
        .BYTE $00,$01,$02,$03,$55
        .BYTE $00,$04,$04,$03,$55
        .BYTE $00,$FC,$FC,$FC,$55
        .BYTE $00,$FC,$FC,$FC,$55
        .BYTE $00,$FC,$FC,$55
        .BYTE $00,$55
        
        .BYTE $00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00
        .BYTE $00,$00,$00,$00,$00,$00,$00,$00


;      3            
;     3 3           
; 2    3            
; 2                 
;             1     
;            1      
;           8       
;    6              
;                  5
;  6   6         5  
;                   
;        44         
;        44         
;-----------------
customPattern6XPosArray
        .BYTE $00,$01,$02,$55
        .BYTE $00,$F6,$F6,$55
        .BYTE $00,$FB,$FA,$FB,$FC,$55
        .BYTE $00,$FD,$FD,$FE,$FE,$55
        .BYTE $00,$05,$07,$55
        .BYTE $00,$F9,$F7,$FB,$55
        .BYTE $00,$55
        .BYTE $00,$55

customPattern6YPosArray
        .BYTE $00,$FF,$FE,$55
        .BYTE $00,$FC,$FD,$55
        .BYTE $00,$FA,$FB,$FC,$FB,$55
        .BYTE $00,$05,$06,$06,$05,$55
        .BYTE $00,$03,$02,$55
        .BYTE $00,$01,$03,$03,$55
        .BYTE $00,$55
        .BYTE $00,$55

 customPattern7XPosArray
        .BYTE $01,$55
        .BYTE $03,$55
        .BYTE $07,$55
        .BYTE $08,$55
        .BYTE $02,$55
        .BYTE $09,$55
        .BYTE $0A,$55

customPattern7YPosArray
        .BYTE $FE,$55
        .BYTE $F3,$55
        .BYTE $02,$55
        .BYTE $F7,$55
        .BYTE $FD,$55
        .BYTE $10,$55
        .BYTE $08,$55

; Tricky patterns
trickyPattern0XPosArray
	.BYTE $E9,$55
	.BYTE $0E,$55
	.BYTE $F4,$55
	.BYTE $F6,$55
	.BYTE $F2,$55
	.BYTE $0C,$55
	.BYTE $EB,$55
trickyPattern0YPosArray
	.BYTE $F4,$55
	.BYTE $F8,$55
	.BYTE $F6,$55
	.BYTE $F6,$55
	.BYTE $05,$55
	.BYTE $F3,$55
	.BYTE $05,$55
trickyPattern1XPosArray
	.BYTE $FC,$55
	.BYTE $EE,$55
	.BYTE $FC,$55
	.BYTE $0E,$55
	.BYTE $FC,$55
	.BYTE $03,$55
	.BYTE $FD,$55
trickyPattern1YPosArray
	.BYTE $04,$55
	.BYTE $09,$55
	.BYTE $01,$55
	.BYTE $EF,$55
	.BYTE $F2,$55
	.BYTE $FC,$55
	.BYTE $0E,$55
trickyPattern2XPosArray
	.BYTE $0E,$55
	.BYTE $F1,$55
	.BYTE $01,$55
	.BYTE $F4,$55
	.BYTE $03,$55
	.BYTE $EC,$55
	.BYTE $FC,$55
trickyPattern2YPosArray
	.BYTE $02,$55
	.BYTE $0B,$55
	.BYTE $0E,$55
	.BYTE $E7,$55
	.BYTE $F5,$55
	.BYTE $EA,$55
	.BYTE $06,$55
trickyPattern3XPosArray
	.BYTE $06,$55
	.BYTE $0E,$55
	.BYTE $02,$55
	.BYTE $0C,$55
	.BYTE $EC,$55
	.BYTE $FC,$55
	.BYTE $0E,$55
trickyPattern3YPosArray
	.BYTE $F5,$55
	.BYTE $F4,$55
	.BYTE $01,$55
	.BYTE $FD,$55
	.BYTE $ED,$55
	.BYTE $F7,$55
	.BYTE $F5,$55
trickyPattern4XPosArray
	.BYTE $F5,$55
	.BYTE $F6,$55
	.BYTE $06,$55
	.BYTE $08,$55
	.BYTE $02,$55
	.BYTE $EA,$55
	.BYTE $0B,$55
trickyPattern4YPosArray
	.BYTE $E8,$55
	.BYTE $0D,$55
	.BYTE $FC,$55
	.BYTE $08,$55
	.BYTE $06,$55
	.BYTE $FC,$55
	.BYTE $F3,$55
trickyPattern5XPosArray
	.BYTE $EB,$55
	.BYTE $E7,$55
	.BYTE $E8,$55
	.BYTE $FB,$55
	.BYTE $01,$55
	.BYTE $07,$55
	.BYTE $FC,$55
trickyPattern5YPosArray
	.BYTE $E9,$55
	.BYTE $EC,$55
	.BYTE $0A,$55
	.BYTE $F4,$55
	.BYTE $0D,$55
	.BYTE $FC,$55
	.BYTE $05,$55
trickyPattern6XPosArray
	.BYTE $0E,$55
	.BYTE $06,$55
	.BYTE $ED,$55
	.BYTE $EE,$55
	.BYTE $03,$55
	.BYTE $F9,$55
	.BYTE $FA,$55
trickyPattern6YPosArray
	.BYTE $02,$55
	.BYTE $FC,$55
	.BYTE $0D,$55
	.BYTE $EF,$55
	.BYTE $EA,$55
	.BYTE $EC,$55
	.BYTE $F9,$55

