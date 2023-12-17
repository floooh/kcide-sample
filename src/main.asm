    include 'macros.asm'
    org 200h

FONT_BASE = 1000h
SCROLL_POS = 80E0h

    ld a,60h
    call cls_1
    call display_1
    call write_scroller_colors
    call vsync_init
    ld hl,scroll_text
    call scroll_init

.frame_loop:
    call raster_draw
    call scroll_begin_frame
    ld de,scroll_y
    call scroll_draw
    call scroll_end_frame

    call vsync_wait
    jr .frame_loop

write_scroller_colors:
    call access_colors_1
    ld de,SCROLL_POS
    ld b,28h
.loop:
    ld c,FFh        ; prevent C from underflowing during LDI
    ld hl,colors
    ldi8
    ldi8
    ldi8
    ldi7
    inc d
    ld e,[L(SCROLL_POS)]
    djnz .loop
    call access_pixels_1
    ret

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
    ;        float dx = (M_PI) / 40.0f;
    ;        for (int i = 0; i < 40; i++) {
    ;            float s = sin(x0);
    ;            int si = 0xE0 + roundf(s * 24.0f);
    ;            x0 += dx;
    ;            printf("%02Xh,", si);
    ;        }
    ;        printf("\n");
    ;    }
    ;
scroll_y:
    db E0h,DEh,DCh,DAh,D9h,D7h,D5h,D3h
    db D2h,D0h,CFh,CEh,CDh,CCh,CBh,CAh
    db C9h,C9h,C8h,C8h,C8h,C8h,C8h,C9h
    db C9h,CAh,CBh,CCh,CDh,CEh,CFh,D0h
    db D2h,D3h,D5h,D7h,D9h,DAh,DCh,DEh

colors:
    db BG_BLACK | FG_YELLOW
    db BG_BLACK | FG_YELLOW
    db BG_BLACK | FG_YELLOW
    db BG_BLACK | FG_YELLOWGREEN
    db BG_BLACK | FG_YELLOW
    db BG_BLUE  | FG_YELLOWGREEN
    db BG_BLACK | FG_GREEN
    db BG_BLUE  | FG_YELLOWGREEN
    db BG_BLACK | FG_GREEN
    db BG_BLUE  | FG_GREENBLUE
    db BG_BLUE  | FG_TEAL
    db BG_BLACK | FG_GREENBLUE
    db BG_BLUE  | FG_TEAL
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLACK | FG_BLUEGREEN
    db BG_BLUE  | FG_BLUEGREEN
    db BG_BLUE
    db BG_BLUE
    db BG_BLACK
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLACK
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE
    db BG_BLUE

scroll_text:
    DB "*** The KC85 was a series of 8-BIT COMPUTERS BUILT IN EAST GERMANY DURING THE 1980's. "
    DB "KC MEANS 'KLEINCOMPUTER' OR 'SMALL COMPUTER', THIS WAS AN UMBRELLA NAME FOR 6 DIFFERENT COMPUTER MODELS "
    DB "WITH PARTIALLY VERY DIFFERENT HARDWARE FROM 2 DIFFERENT MANUFACTURERS. "
    db 0

    org FONT_BASE
    include 'kc853_font.asm'
