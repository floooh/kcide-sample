    include 'defines.asm'

    ; on the KC85/2..4, programs usually start at address 200h
    org 200h

    ; clear (hidden) video image 1 to black
    ld a,0h
    call cls_1

    ; warm up the color scrolling effect for the big KC85/4 logo
    ld b,10h
.warmup_colors:
    push bc
    call color_update_logo
    pop bc
    djnz .warmup_colors
    ; write colors for the scroller effect
    call color_init_scroller
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
    align 100h
scroll_y:
    db E0h,DEh,DCh,DAh,D8h,D7h,D5h,D3h
    db D2h,D0h,CFh,CDh,CCh,CBh,CAh,CAh
    db C9h,C8h,C8h,C8h,C8h,C8h,C8h,C9h
    db CAh,CAh,CBh,CCh,CDh,CFh,D0h,D2h
    db D3h,D5h,D7h,D8h,DAh,DCh,DEh,E0h

scroll_text:
    DB "*** The KC85 was a series of 8-BIT COMPUTERS BUILT IN EAST GERMANY DURING THE 1980's. "
    DB "KC MEANS 'KLEINCOMPUTER' OR 'SMALL COMPUTER', THIS WAS AN UMBRELLA NAME FOR 6 DIFFERENT COMPUTER MODELS "
    DB "WITH PARTIALLY VERY DIFFERENT HARDWARE FROM 2 DIFFERENT MANUFACTURERS. "
    db 0

    align 100h
font:
    include 'kc853_font.asm'
