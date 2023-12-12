    org 200h
    call init

    ; prepare string pixel data for fast copying
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
    call vsync_wait
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
    call vsync_wait
    djnz .loop1

    jr .repeat

init:
; clear screen to bright green foreground and black background
    ld a,60h
    call cls_1
    call display_1
    call vsync_init
    ret

    include "irm.asm"
    include "blit.asm"
    include "vsync.asm"

; data
kc854_str:
    dw CHR_SPACE, CHR_H, CHR_E, CHR_L, CHR_L, CHR_O, CHR_SPACE
    dw CHR_K, CHR_C, CHR_8, CHR_5, CHR_SLASH, CHR_4
    dw CHR_EXCL, CHR_EXCL, CHR_EXCL, CHR_SPACE
