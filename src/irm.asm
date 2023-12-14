; KC85/4 video system helper code

; IO port 84 bit definitions
IO84_SEL_VIEW_IMG   = (1<<0)
IO84_SEL_CPU_COLOR  = (1<<1)
IO84_SEL_CPU_IMG    = (1<<2)
IO84_HICOLOR        = (1<<3)
IO84_SEL_RAM8       = (1<<4)
IO84_BLOCKSEL_RAM8  = (1<<5)

BG_BLACK        = 0
BG_BLUE         = 1
BG_RED          = 2
BG_PINK         = 3
BG_GREEN        = 4
BG_TEAL         = 5
BG_YELLOW       = 6
BG_GREY         = 7

FG_BLUE         = (1<<3)
FG_RED          = (2<<3)
FG_PINK         = (3<<3)
FG_GREEN        = (4<<3)
FG_TEAL         = (5<<3)
FG_YELLOW       = (6<<3)
FG_WHITE        = (7<<3)
FG_BLACK        = (8<<3)
FG_VIOLET       = (9<<3)
FG_ORANGE       = (10<<3)
FG_PURPLE       = (11<<3)
FG_GREENBLUE    = (12<<3)
FG_BLUEGREEN    = (13<<3)
FG_YELLOWGREEN  = (14<<3)
FG_WHITE2       = (15<<3)

; write to pixel bank 0
; trashes: a
access_pixels_0:
    ld a,(ix+1)
    and ~(IO84_SEL_CPU_COLOR|IO84_SEL_CPU_IMG)
    ld (ix+1),a
    out (84h),a
    ret

; write to pixel bank 1
; trashes: a
access_pixels_1:
    ld a,(ix+1)
    and ~(IO84_SEL_CPU_COLOR)
    or IO84_SEL_CPU_IMG
    ld (ix+1),a
    out (84h),a
    ret

; write to color bank 0
; trashes: a
access_colors_0:
    ld a,(ix+1)
    and ~(IO84_SEL_CPU_IMG)
    or IO84_SEL_CPU_COLOR
    ld (ix+1),a
    out (84h),a
    ret

; write to color bank 1
; trashes: a
access_colors_1:
    ld a,(ix+1)
    or IO84_SEL_CPU_COLOR|IO84_SEL_CPU_IMG
    ld (ix+1),a
    out (84h),a
    ret

; display image 0
; trashes: a
display_0:
    ld a,(ix+1)
    and ~(IO84_SEL_VIEW_IMG)
    ld (ix+1),a
    out (84h),a
    ret

; display image 1
; trashes: a
display_1:
    ld a,(ix+1)
    or IO84_SEL_VIEW_IMG
    ld (ix+1),a
    out (84h),a
    ret

; clear image 0
; inputs:
;   a: background color
; trashes: a, hl, de, b
cls_0:
    ld b,a
    call access_colors_0
    ld a,b
    call clear_irm
    call access_pixels_0
    xor a
    call clear_irm
    ret

; clear image 1
; clear image 0
; inputs:
;   a: background color
; trashes: a, hl, de, b
cls_1:
    ld b,a
    call access_colors_1
    ld a,b
    call clear_irm
    call access_pixels_1
    xor a
    call clear_irm
    ret

; fast video bank clear routine, disables interrupts, sets stack pointer
; to end of video ram, and clears video ram by pushing a 16 bit register
; inputs:
;   a: clear value
; trashes:
;   hl, de, b
    macro push_de_4
    push de
    push de
    push de
    push de
    endm
clear_irm:
    ld e,a
    ld d,a
    ld hl,0         ; store current sp in hl
    add hl,sp
    di
    ld sp,a800h     ; end of video ram
    ld b,40*4       ; loop counter 40 * 4 * 64 bytes
.loop:
    push_de_4       ; write 64 bytes
    push_de_4
    push_de_4
    push_de_4
    push_de_4
    push_de_4
    push_de_4
    push_de_4
    djnz .loop
    ld sp,hl        ; restore sp
    ei
    ret