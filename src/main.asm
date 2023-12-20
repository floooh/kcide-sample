    include 'defines.asm'

    ; on the KC85/2..4, programs usually start at address 200h
    org 200h

    ; clear (hidden) video image 1 to black
    ld a,0h
    call cls_1

    ; merge font tables from ROM into a single font table in RAM
    call merge_font_tables

    ; write colors for the scroller effect
    call color_init
    ; warm up the color scrolling effect for the big KC85/4 logo
    ld b,10h
.warmup_colors:
    push bc
    call color_update_logo
    pop bc
    djnz .warmup_colors
    ; draw the big KC85/4 logo
    call raster_draw
    ; display video image 1
    call display_1
    ; initialize vertical blank interrupt
    call vsync_init
    ; initialize the text scroller
    ld hl,scroll_text
    call scroll_init

    ; per-frame code starts here
.frame_loop:
    ; update the color scrolling effect of the KC85/4 logo
    call color_update_logo
    ; update the text scrolling effect
    call scroll_begin_frame
    ld de,scroll_y
    call scroll_draw
    call scroll_end_frame
    ; wait for next vblank
    call vsync_wait
    jr .frame_loop

merge_font_tables:
    ld de, FONT_BASE
    ld hl, FE00h            ; ASCII codes 0..1Fh
    ld bc, 20h * 8
    ldir
    ld hl, EE00h            ; ASCII codes 20h..5Fh
    ld bc, 40h * 8
    ldir
    ld hl, FE00h + 20h * 8  ; ASCII codes 60h..7Fh
    ld bc, 20h * 8
    ldir
    ret

    include "color.asm"
    include "irm.asm"
    include "vsync.asm"
    include "scroll.asm"
    include "raster.asm"

    ; 64-bytes wraparound Y coordinates for sine-wave scroller
    ;
    ; generated with:
    ;
    ;    #include <math.h>
    ;    #include <stdio.h>
    ;    int main() {
    ;        float x0 = -M_PI;
    ;        float dx = (M_PI) / 39.0f;
    ;        for (int i = 0; i < 40; i++) {
    ;            float s = sin(x0);
    ;            int si = 0xE0 + roundf(s * 24.0f);
    ;            x0 += dx;
    ;            printf("%02Xh,", si);
    ;        }
    ;        printf("\n");
    ;    }
    ;
    align 64
scroll_y:
    db E0h,DEh,DCh,DAh,D8h,D7h,D5h,D3h
    db D2h,D0h,CFh,CDh,CCh,CBh,CAh,CAh
    db C9h,C8h,C8h,C8h,C8h,C8h,C8h,C9h
    db CAh,CAh,CBh,CCh,CDh,CFh,D0h,D2h
    db D3h,D5h,D7h,D8h,DAh,DCh,DEh,E0h

scroll_text:
    db "*** The KC85 is a series of 8-bit computers built from 1984 to 1990 in East Germany at the "
    db "VEB Mikroelektronikkombinat M",7Dh,"hlhausen. "
    db "The top model KC85/4 (introduced in 1988) had a 1.77 MHz U880 CPU (an unlicensed Z80 clone), 128 KB RAM and "
    db "20 KB ROM. The video hardware generated a PAL image with a resolution of "
    db "320x256 pixels in 14 foreground- and 8 background-colors with a color resolution of 40x256 "
    db "(e.g. a block of 8x1 pixels shared the same foreground and background color). "
    db "A unique feature of the KC85/4 is the 90 degrees rotated video memory. Writing "
    db "byte sequences in memory fills vertical pixel columns on screen. This vertical "
    db "arrangement simplifies video memory addressing using the Z80's 16-bit register pairs "
    db "(the high byte addresses 40 columns, and the low byte 256 rows). Apart from memory bank switching, "
    db "the KC85 video hardware was not programmable in any way. All rendering and scrolling had to be done "
    db "with the CPU. "
    db "The KC85 computers also didn't have a dedicated sound chip like many western home computers, "
    db "instead two Z80 CTC channels could be programmed in timer mode to produce simple square wave audio in stereo at "
    db "up to 16 volume levels "
    db "***                                        ", 0
