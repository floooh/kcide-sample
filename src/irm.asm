; KC85/4 video system helper code

; IO port 84 bit definitions
IO84_SEL_VIEW_IMG   = (1<<0)
IO84_SEL_CPU_COLOR  = (1<<1)
IO84_SEL_CPU_IMG    = (1<<2)
IO84_HICOLOR        = (1<<3)
IO84_SEL_RAM8       = (1<<4)
IO84_BLOCKSEL_RAM8  = (1<<5)

; write to pixel bank 0
; modifies a
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
display_0:
    ld a,(ix+1)
    and ~(IO84_SEL_VIEW_IMG)
    ld (ix+1),a
    out (84h),a
    ret

; display image 1
display_1:
    ld a,(ix+1)
    or IO84_SEL_VIEW_IMG
    ld (ix+1),a
    out (84h),a
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
cls:
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