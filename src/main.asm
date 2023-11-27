    org 200h
    ld de,0
    call clear_screen
    ret

clear_screen:
    macro pde4
    push de
    push de
    push de
    push de
    endm

    di
    ld hl,0
    add hl,sp               ; store SP into HL
    ld sp,A800h             ; load SP with end of video ram
    ld b,40*4
clear_screen_loop:
    ; 64 bytes
    pde4
    pde4
    pde4
    pde4
    pde4
    pde4
    pde4
    pde4
    djnz clear_screen_loop
    ld sp,hl                ; restore SP
    ei
    ret
