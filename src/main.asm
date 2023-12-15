    include 'macros.asm'
    org 200h

SCROLL_ADDR = 80E0h

    ld a,60h
    call cls_1
    call display_1
    call write_scroller_colors
    call vsync_init
    ld hl,scroll_text
    call scroll_init
    ld hl,kc85_raster
    ld de,8740h
    ld b,6
    ld c,27
    call raster_init
    call raster_draw

.frame_loop:
    call scroll_begin_frame
    ld e,[L(SCROLL_ADDR)]
    call scroll_draw
    call scroll_end_frame

    call vsync_wait
    jr .frame_loop

write_scroller_colors:
    call access_colors_1
    ld de,SCROLL_ADDR
    ld b,28h
.loop:
    ld c,FFh        ; prevent C from underflowing during LDI
    ld hl,colors
    ldi8
    ldi8
    ldi8
    ldi7
    inc d
    ld e,[L(SCROLL_ADDR)]
    djnz .loop
    call access_pixels_1
    ret

    include "irm.asm"
    include "vsync.asm"
    include "scroll.asm"
    include "raster.asm"

colors:
    db BG_BLACK | FG_YELLOW
    db BG_BLACK | FG_YELLOW
    db BG_BLACK | FG_YELLOW
    db BG_BLACK | FG_YELLOWGREEN
    db BG_BLACK | FG_YELLOW
    db BG_BLUE  | FG_YELLOWGREEN
    db BG_BLACK | FG_GREEN
    db BG_BLUE  | FG_YELLOWGREEN
    db BG_BLACK | FG_GREEN
    db BG_BLUE  | FG_GREENBLUE
    db BG_BLUE  | FG_TEAL
    db BG_BLACK | FG_GREENBLUE
    db BG_BLUE  | FG_TEAL
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLACK | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLUE
    db BG_BLUE
    db BG_BLACK
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLACK
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE

kc85_raster:
    ; 'KC85' as 28x6 raster
    db 1,1,0,0,1,1,0,0,1,1,1,1,0,0,0,1,1,1,1,0,0,1,1,1,1,1,1
    db 1,1,0,1,1,0,0,1,1,0,0,1,1,0,1,1,0,0,1,1,0,1,1,0,0,0,0
    db 1,1,1,1,0,0,0,1,1,0,0,0,0,0,0,1,1,1,1,0,0,1,1,1,1,1,0
    db 1,1,0,1,1,0,0,1,1,0,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,1,1
    db 1,1,0,0,1,1,0,1,1,0,0,1,1,0,1,1,0,0,1,1,0,1,1,0,0,1,1
    db 1,1,0,0,0,1,1,0,1,1,1,1,0,0,0,1,1,1,1,0,0,0,1,1,1,1,0

scroll_text:
    DB "*** The KC85 was a series of 8-BIT COMPUTERS BUILT IN EAST GERMANY DURING THE 1980's. "
    DB "KC MEANS 'KLEINCOMPUTER' OR 'SMALL COMPUTER', THIS WAS AN UMBRELLA NAME FOR 6 DIFFERENT COMPUTER MODELS "
    DB "WITH PARTIALLY VERY DIFFERENT HARDWARE FROM 2 DIFFERENT MANUFACTURERS. "
    db 0

    org FONT_BASE
    include 'kc853_font.asm'
