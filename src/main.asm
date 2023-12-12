    org 200h
    call init

    ; prepare string pixel data for fast copying
    ld hl,kc854_str
    ld de,4000h
    ld b,NUM_CHARS
    call copy8x8xN

    ; create 8 copies, left-shifted by 1 pixel
    ld b,7
    ld hl,4000h
    ld de,4100h
.loop8:
    push bc
    push de
    push hl
    ld b,NUM_CHARS
    call lshift8x8xN
    pop hl
    pop de
    pop bc
    inc h
    inc d
    djnz .loop8

.repeat:
    ld de,A780h
    ld b,38h
.outer:
    push bc
    push de
    ld hl,4000h
    ld b,8
.inner:
    push bc
    push de
    push hl
    ld b,NUM_CHARS
    call blit8x8xN
    pop hl
    pop de
    pop bc
    inc h
    call vsync_wait
    djnz .inner
    pop de
    pop bc
    dec d
    djnz .outer
    jr .repeat

;.repeat:
;    ld de,8410h
;    ld b,D0h
;.loop:
;    push de
;    push bc
;    ld hl,3FFFh
;    ld b,NUM_CHARS
;    call blit8x8xN
;    pop bc
;    pop de
;    inc e
;    call vsync_wait
;    djnz .loop
;
;    ld de,84E0h
;    ld b,D0h
;.loop1
;    push de
;    push bc
;    ld hl,4100h
;    ld b,NUM_CHARS
;    call blit8x8xN
;    pop bc
;    pop de
;    dec e
;    call vsync_wait
;    djnz .loop1
;
;    jr .repeat

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
NUM_CHARS = 16
kc854_str:
    dw CHR_SPACE, CHR_H, CHR_E, CHR_L, CHR_L, CHR_O, CHR_SPACE
    dw CHR_K, CHR_C, CHR_8, CHR_5, CHR_SLASH, CHR_4
    dw CHR_EXCL, CHR_EXCL, CHR_EXCL
