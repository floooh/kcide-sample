    org 200h
    call init

.loop:
    call scroll_next_frame
    call vsync_wait
    jr .loop

    ; prepare string pixel data for fast copying
;    ld hl,kc854_str
;    ld de,4000h
;    ld b,NUM_CHARS
;    call copy8x8xN

    ; brain dump:
    ; - input text of arbitrary length
    ; - scroll ring buffer of 64 8x8 tiles = 512 bytes
    ; - ...at 8 scroll positions = 4096 bytes
    ; - append the next pre-scrolled character every 8 frames:
    ;   => scroll 0: every 8 frames, append next byte at src[1]
    ;   => scroll 1: dst[0] |= (src[0]<<1).carry
    ;   =>           dst[1] = (src[0]<<1)|(src[1]<<1).carry
    ;
    ;   => 7x dst[-1] |= (src<<1).carry
    ;         dst = (src<<1)
    ;
    ;  `00000000|11111111`
    ;  `00000001|11111110`
    ;  `00000011|11111100`
    ;  `00000111|11111000`
    ;  `00001111|11110000`
    ;  `00011111|11100000`
    ;  `00111111|11000000`
    ;  `01111111|10000000`
    ;  `11111111|00000000`

    ; create 8 copies, left-shifted by 1 pixel
;    ld b,7
;    ld hl,4000h
;    ld de,4100h
;.loop8:
;    push bc
;    push de
;    push hl
;    ld b,NUM_CHARS
;    call lshift8x8xN
;    pop hl
;    pop de
;    pop bc
;    inc h
;    inc d
;    djnz .loop8

;.repeat:
;    ld de,A780h
;    ld b,28h + NUM_CHARS
;.outer:
;    push bc
;    push de
;    ld hl,4000h
;    ld b,8
;.inner:
;    push bc
;    push de
;    push hl
;    ld b,NUM_CHARS
;    call blit8x8xN
;    pop hl
;    pop de
;    pop bc
;    inc h
;    call vsync_wait
;    djnz .inner
;    pop de
;    pop bc
;    dec d
;    djnz .outer
;    jr .repeat

init:
; clear screen to bright green foreground and black background
    ld a,60h
    call cls_1
    call display_1
    call vsync_init
    ld hl,scroll_text
    call scroll_init
    ret

    include "irm.asm"
    include "blit.asm"
    include "vsync.asm"
    include "scroll.asm"

scroll_text:
    db '!!! HELLO KC85/4 !!!',0
