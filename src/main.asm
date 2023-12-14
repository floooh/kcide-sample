    org 200h

    ld a,60h
    call cls_1
    call display_1
    call vsync_init
    ld hl,scroll_text
    call scroll_init

.frame_loop:
    call scroll_begin_frame
    ld e,C0h
    call scroll_draw
    call scroll_end_frame

    call vsync_wait
    jr .frame_loop

    include "irm.asm"
    include "vsync.asm"
    include "scroll.asm"

scroll_text:
    DB "*** The KC85 was a series of 8-bit computers built in East Germany during the 1980's. "
    DB "KC means 'Kleincomputer' or 'Small Computer', this was an umbrella name for 6 different computer models "
    DB "with partially very different hardware from 2 different manufacturers. "
    db 0
