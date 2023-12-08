    org 200h
    call init

    ; quick'n'dirty rainbow color clear
    call access_colors_1
    call clear_rainbow
    call access_pixels_1

    ld hl,kc854_str
    ld de,4000h
    ld b,17
    call copy8x16xN

.repeat:
    ld de,8410h
    ld b,D0h
.loop:
    push de
    push bc
    ld hl,3FFEh
    ld b,17
    call blit8x16xN
    ld hl,3FFEh
    ld b,17
    call blit8x16xN
    pop bc
    pop de
    inc e
    djnz .loop

    ld de,84E0h
    ld b,D0h
.loop1
    push de
    push bc
    ld hl,4000h
    ld b,17
    call blit8x16xN
    ld hl,4000h
    ld b,17
    call blit8x16xN
    pop bc
    pop de
    dec e
    djnz .loop1

    jr .repeat

init:
    ; clear screen to black
    ld a,60h        ; bright green
    call cls_1
    call display_1
    ret

kc854_str:
    dw CHR_SPACE, CHR_H, CHR_E, CHR_L, CHR_L, CHR_O, CHR_SPACE
    dw CHR_K, CHR_C, CHR_8, CHR_5, CHR_SLASH, CHR_4
    dw CHR_EXCL, CHR_EXCL, CHR_EXCL, CHR_SPACE

    include "irm.asm"
    include "blit.asm"

clear_rainbow:
    ld hl,8000h
    ; clear one column
    ld b,40
.loop_outer
    push bc
    ld b,15
    ld c,8
    ld a,8
.loop_inner:
    ld e,a
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    ld (hl),a
    inc l
    add a,c
    and 7fh
    cp 0
    jr z, .skip_black
    cp 40h
    jr z, .skip_black
.continue
    and 7fh
    djnz .loop_inner
    inc h
    pop bc
    djnz .loop_outer
    ret

.skip_black:
    add a,c
    jr .continue
