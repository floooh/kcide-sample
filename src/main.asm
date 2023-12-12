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
    call wait_vsync
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
    call wait_vsync
    djnz .loop1

    jr .repeat

init:
; clear screen to bright green foreground and black background
    ld a,60h
    call cls_1
    call display_1
    call setup_vsync
    ret

    ; setup the vertical blank interrupt via CTC channel 2
setup_vsync:
    di
    ; set interrupt service routine for CTC channel 2
    ld hl,01ECh
    ld de,vsync_isr
    ld (hl),e
    inc hl
    ld (hl),d

    ; setup CTC channel 2 to trigger interrupt on CLK/TRG2 (vsync)

    ; load CTC2 control word
    ; bit 7 = 1: enable interrupt
    ; bit 6 = 1: counter mode
    ; bit 5 = 0: prescaler 16
    ; bit 4 = 1: rising edge
    ; bit 3 = 0: time trigger (irrelevant)
    ; bit 2 = 1: constant follows
    ; bit 1 = 0: no reset
    ; bit 0 = 1: this is a control word
    ld a,11010101b
    out (8Eh),a
    ; trigger vsync interrupt each frame
    ld a,1
    out (8Eh),a
    ei
    ret

wait_vsync:
    ld a,(vsync)
    and 1
    jr z, wait_vsync
    xor a
    ld (vsync),a
    ret

vsync_isr:
    push af
    ld a,1
    ld (vsync),a
    pop af
    ei
    reti

    include "irm.asm"
    include "blit.asm"

; data
vsync:  db 0
kc854_str:
    dw CHR_SPACE, CHR_H, CHR_E, CHR_L, CHR_L, CHR_O, CHR_SPACE
    dw CHR_K, CHR_C, CHR_8, CHR_5, CHR_SLASH, CHR_4
    dw CHR_EXCL, CHR_EXCL, CHR_EXCL, CHR_SPACE
