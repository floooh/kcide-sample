    org 200h

    ld a,60h
    call cls_1
    call display_1
    call vsync_init
    ld hl,scroll_text
    call scroll_init

.frame_loop:
    call scroll_begin
    ld e,C0h
    call scroll_draw_16
    call scroll_end

    call vsync_wait
    jr .frame_loop

    include "irm.asm"
    include "vsync.asm"
    include "scroll.asm"

scroll_text:
    db "THE KC85 WAS A SERIES OF 8-BIT COMPUTERS BUILT IN EAST GERMANY DURING THE 1980'S. "
    db "KC MEANS 'KLEINCOMPUTER' OR 'SMALL COMPUTER', THIS WAS AN UMBRELLA NAME FOR 6 DIFFERENT COMPUTER MODELS "
    db "WITH PARTIALLY VERY DIFFERENT HARDWARE FROM 2 DIFFERENT MANUFACTURERS."
    db 0
