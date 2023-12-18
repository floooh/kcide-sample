frame_count: db 0

color_write_line:
    ld d,80h
    ld_de_a_inc_e
    ld_de_a_dec_e
    ld_de_a_inc_e
    ld_de_a_dec_e
    ld_de_a_inc_e
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

color_draw_frame:
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