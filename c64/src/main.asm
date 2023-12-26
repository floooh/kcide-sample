WIDTH = 24          ; sprite width
HEIGHT = 21         ; sprite height
ORIGIN_X = 24       ; top-left corner sprite x coordinate
ORIGIN_Y = 50       ; top-left corner sprite y coordinate
MAX_X = 254 - WIDTH
MAX_Y = 200


    ; C64 PRGs usually start at address $801
    org $801
    ; this is the usual C64 BASIC stub for starting the program via "RUN"
    dw .next, 10         ; next line and current line number
    db $9e, " 2064", 0  ; "SYS 2064" (2064 == $810)
.next: db 0             ; end of BASIC program
    org $810
_start:                 ; execution starts here
    jsr init_colors
    jsr init_sprites
.frame:
    jsr update_pos
    jsr set_sprite_pos
    jsr wait_raster
    jmp .frame

init_sprites:
    jsr set_sprite_pos

    ldx #(sprite0/64)   ; sprite data pointers
    stx $07f8
    inx
    stx $07f9
    inx
    stx $07fa
    inx
    stx $07fb

    lda #14             ; bright-blue color for sprites 0..2
    sta $d027
    sta $d028
    sta $d029
    lda #10             ; bright-red color for sprite 3
    sta $d02A

    lda #15
    sta $d015           ; enable sprite 0..3
;    sta $d01D           ; double width
;    sta $d017           ; double height
    sta $d01b           ; priority behind foreground
    rts

init_colors:
    lda #12             ; set border color to light grey
    sta $d020
    lda #11             ; set background color to dark grey
    sta $d021
    lda #13             ; clear char colors to light green
    ldx #0
.loop:
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $db00,x
    dex
    bne .loop
    rts

set_sprite_pos:
    clc
    lda pos_x
    sta $d000           ; sprite0 posx
    sta $d004           ; sprite2 posx
    adc #WIDTH
    sta $d002           ; sprite1 posx
    sta $d006           ; sprite3 posx
    lda pos_y
    sta $d001           ; sprite0 posy
    sta $d003           ; sprite1 posy
    adc #HEIGHT
    sta $d005           ; sprite2 posy
    sta $d007           ; sprite3 posy
    rts

update_pos:
    lda pos_x
    clc
    adc dx
    sta pos_x
    cmp #MAX_X
    beq .bounce_x
    cmp #ORIGIN_X
    beq .bounce_x
.update_y:
    lda dy_lo
    clc
    adc #$60
    sta dy_lo
    bcc .no_overflow
    inc dy_hi
.no_overflow:
    lda pos_y
    clc
    adc dy_hi
    sta pos_y
    cmp #MAX_Y
    bcs .bounce_y
.done:
    rts

.bounce_x:
    sec
    lda #0
    sbc dx
    sta dx
    jmp .update_y
.bounce_y:
    lda #0
    sta dy_lo
    sec
    sbc dy_hi
    sta dy_hi
    lda #MAX_Y
    sta pos_y
    jmp .done

wait_raster:
.loop:
    lda $d012
    cmp #$ff
    bne .loop
    rts

pos_x:  db ORIGIN_X
pos_y:  db ORIGIN_Y
dy_lo:  db 0
dy_hi:  db 0
dx:     db 2

    ; top-left quadrant
    align $40
sprite0:
    db %00000000, %00000000, %11111111
    db %00000000, %00000111, %11111111
    db %00000000, %00011111, %11111111
    db %00000000, %01111111, %11111111
    db %00000000, %11111111, %11111111
    db %00000001, %11111111, %11111111
    db %00000011, %11111111, %11111111
    db %00000111, %11111111, %11111111

    db %00001111, %11111111, %11111111
    db %00011111, %11111111, %11111111
    db %00011111, %11111111, %11111111
    db %00111111, %11111111, %10000000
    db %00111111, %11111110, %00000000
    db %01111111, %11111100, %00000000
    db %01111111, %11111000, %00000000
    db %01111111, %11110000, %00000000

    db %11111111, %11110000, %00000000
    db %11111111, %11100000, %00000000
    db %11111111, %11100000, %00000000
    db %11111111, %11100000, %00000000
    db %11111111, %11100000, %00000000

    ; top-right quadrant
    align $40
sprite1:
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000

    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %01111111, %11111111, %11100000
    db %01111111, %11111111, %11000000
    db %01111111, %11111111, %10000000
    db %01111111, %11111111, %00000000

    db %01111111, %11111110, %00000000
    db %01111111, %11111100, %00000000
    db %01111111, %11111000, %00000000
    db %01111111, %11110000, %00000000
    db %00000000, %00000000, %00000000

    ; bottom-left quadrant
    align $40
sprite2:
    db %11111111, %11100000, %00000000
    db %11111111, %11100000, %00000000
    db %11111111, %11100000, %00000000

    db %11111111, %11100000, %00000000
    db %11111111, %11110000, %00000000
    db %01111111, %11110000, %00000000
    db %01111111, %11111000, %00000000
    db %01111111, %11111100, %00000000
    db %00111111, %11111110, %00000000
    db %00111111, %11111111, %10000000
    db %00011111, %11111111, %11111111

    db %00011111, %11111111, %11111111
    db %00001111, %11111111, %11111111
    db %00000111, %11111111, %11111111
    db %00000011, %11111111, %11111111
    db %00000001, %11111111, %11111111
    db %00000000, %11111111, %11111111
    db %00000000, %01111111, %11111111
    db %00000000, %00011111, %11111111

    db %00000000, %00000111, %11111111
    db %00000000, %00000000, %11111111

    ; bottom-right quadrant
    align $40
sprite3:
    db %00000000, %00000000, %00000000
    db %01111111, %11110000, %00000000
    db %01111111, %11111000, %00000000

    db %01111111, %11111100, %00000000
    db %01111111, %11111110, %00000000
    db %01111111, %11111111, %00000000
    db %01111111, %11111111, %10000000
    db %01111111, %11111111, %11000000
    db %01111111, %11111111, %11100000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000

    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000

    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
