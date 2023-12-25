; KC85/4 video system helper code

; enable CPU write access to pixel bank 0 at address 8000h
access_pixels_0:
    ld a,(ix+1)
    and ~(IO84_SEL_CPU_COLOR|IO84_SEL_CPU_IMG)
    ld (ix+1),a
    out (84h),a
    ret

; enable CPU write access to pixel bank 1 at address 8000h
access_pixels_1:
    ld a,(ix+1)
    and ~(IO84_SEL_CPU_COLOR)
    or IO84_SEL_CPU_IMG
    ld (ix+1),a
    out (84h),a
    ret

; enable CPU write access to color bank 0 at address 8000h
access_colors_0:
    ld a,(ix+1)
    and ~(IO84_SEL_CPU_IMG)
    or IO84_SEL_CPU_COLOR
    ld (ix+1),a
    out (84h),a
    ret

; enable CPU write access to color bank 1 at address 8000h
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

; clear image 0
; inputs:
;   a: background color
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
; inputs:
;   a: background color
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