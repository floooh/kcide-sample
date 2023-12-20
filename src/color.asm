frame_count: db 0

; write a zig-zag line of to the color video ram
logo_colors_down:
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ret

logo_colors_up:
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ret

color_write_line:
    ld d,80h
    call logo_colors_down
    call logo_colors_up
    call logo_colors_down
    call logo_colors_up
    call logo_colors_down
    ret

color_write_block:
    ld a,c
    add a,10h
    and 7Fh
    ld c,a
    add a,14h
    ld e,a
    ld a,b
    call color_write_line
    ret

color_update_logo:
    call access_colors_1

    ld a,(frame_count)
    dec a
    ld (frame_count),a
    ld c,a

    ld b,FG_RED
    call color_write_block
    ld b,FG_PURPLE
    call color_write_block
    ld b,FG_PINK
    call color_write_block
    ld b,FG_VIOLET
    call color_write_block
    ld b,FG_BLUE
    call color_write_block
    ld b,FG_VIOLET
    call color_write_block
    ld b,FG_PINK
    call color_write_block
    ld b,FG_PURPLE
    call color_write_block

    call access_pixels_1

    ret

color_init_scroller:
    call access_colors_1
    ld de,80C4h
    ld b,28h
.loop:
    push bc
    ld bc,54
    ld hl,scroller_colors
    ldir
    inc d
    ld e,C4h
    pop bc
    djnz .loop
    call access_pixels_1
    ret

scroller_colors:
    db FG_YELLOW | BG_BLUE
    db FG_YELLOW | BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOW| BG_BLACK
    db FG_YELLOW| BG_BLACK
    db FG_YELLOW| BG_BLUE
    db FG_YELLOW| BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOWGREEN | BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOWGREEN | BG_BLUE
    db FG_YELLOWGREEN | BG_BLACK
    db FG_YELLOWGREEN | BG_BLACK
    db FG_YELLOWGREEN | BG_BLACK
    db FG_GREEN | BG_BLUE
    db FG_YELLOWGREEN | BG_BLACK
    db FG_GREEN | BG_BLACK
    db FG_GREEN | BG_BLUE
    db FG_GREEN | BG_BLACK
    db FG_GREEN | BG_BLACK
    db FG_GREENBLUE | BG_BLUE
    db FG_GREEN | BG_BLACK
    db FG_GREENBLUE | BG_BLUE
    db FG_GREENBLUE | BG_BLACK
    db FG_GREENBLUE | BG_BLUE
    db FG_GREENBLUE | BG_BLACK
    db FG_TEAL | BG_BLUE
    db FG_GREENBLUE | BG_BLUE
    db FG_TEAL | BG_BLACK
    db FG_TEAL | BG_BLUE
    db FG_TEAL | BG_BLUE
    db FG_TEAL | BG_BLACK
    db FG_BLUEGREEN | BG_BLUE
    db FG_TEAL | BG_BLUE
    db FG_BLUEGREEN | BG_BLACK
    db FG_BLUEGREEN | BG_BLUE
    db FG_BLUEGREEN | BG_BLUE
    db FG_BLUEGREEN | BG_BLUE
    db FG_BLUE | BG_BLACK
    db FG_BLUEGREEN | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLACK
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
