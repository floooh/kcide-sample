    org 200h

SCROLL_ADDR = 80E0h

    ld a,60h
    call cls_1
    call display_1
    call write_colors
    call vsync_init
    ld hl,scroll_text
    call scroll_init

.frame_loop:
    call scroll_begin_frame
    ld e,[L(SCROLL_ADDR)]
    call scroll_draw
    call scroll_end_frame

    call vsync_wait
    jr .frame_loop

write_colors:
    call access_colors_1
    ld de,SCROLL_ADDR
    ld b,28h
.loop:
    push bc
    ld hl,colors
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    inc d
    ld e,[L(SCROLL_ADDR)]
    pop bc
    djnz .loop
    call access_pixels_1
    ret

    include "irm.asm"
    include "vsync.asm"
    include "scroll.asm"

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
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLACK | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLACK | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN

scroll_text:
    DB "*** The KC85 was a series of 8-bit computers built in East Germany during the 1980's. "
    DB "KC means 'Kleincomputer' or 'Small Computer', this was an umbrella name for 6 different computer models "
    DB "with partially very different hardware from 2 different manufacturers. "
    db 0
