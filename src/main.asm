    org 200h
    call init
    ret

init:
    ; clear screen to black
    call display_1
    call access_pixels_0
    xor a
    call cls
    call access_colors_0
    xor a
    call cls
    call access_pixels_0
    call display_0
    ret

    include "irm.asm"
