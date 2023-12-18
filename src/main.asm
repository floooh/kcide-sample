    include 'macros.asm'
    org 200h

FONT_BASE = 1000h

    ld a,0h
    call cls_1
    ld b,10h
.warmup_colors:
    push bc
    call color_draw_frame
    pop bc
    djnz .warmup_colors
    call raster_draw
    call write_scroller_colors
    call display_1
    call vsync_init
    ld hl,scroll_text
    call scroll_init

.frame_loop:
    call color_draw_frame
    call scroll_begin_frame
    ld de,scroll_y
    call scroll_draw
    call scroll_end_frame

    call vsync_wait
    jr .frame_loop

write_scroller_colors:
    call access_colors_1
    ld de,80C4h
    ld b,28h
.loop:
    push bc
    ld bc,54
    ld hl,colors
    ldir
    inc d
    ld e,C4h
    pop bc
    djnz .loop
    call access_pixels_1
    ret

    include "color.asm"
    include "irm.asm"
    include "vsync.asm"
    include "scroll.asm"
    include "raster.asm"

colors:
    db FG_YELLOW | BG_BLUE
    db FG_YELLOW | BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOW| BG_BLACK
    db FG_YELLOW| BG_BLACK
    db FG_YELLOW| BG_BLUE
    db FG_YELLOW| BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOWGREEN | BG_BLACK
    db FG_YELLOW | BG_BLACK
    db FG_YELLOWGREEN | BG_BLUE
    db FG_YELLOWGREEN | BG_BLACK
    db FG_YELLOWGREEN | BG_BLACK
    db FG_YELLOWGREEN | BG_BLACK
    db FG_GREEN | BG_BLUE
    db FG_YELLOWGREEN | BG_BLACK
    db FG_GREEN | BG_BLACK
    db FG_GREEN | BG_BLUE
    db FG_GREEN | BG_BLACK
    db FG_GREEN | BG_BLACK
    db FG_GREENBLUE | BG_BLUE
    db FG_GREEN | BG_BLACK
    db FG_GREENBLUE | BG_BLUE
    db FG_GREENBLUE | BG_BLACK
    db FG_GREENBLUE | BG_BLUE
    db FG_GREENBLUE | BG_BLACK
    db FG_TEAL | BG_BLUE
    db FG_GREENBLUE | BG_BLUE
    db FG_TEAL | BG_BLACK
    db FG_TEAL | BG_BLUE
    db FG_TEAL | BG_BLUE
    db FG_TEAL | BG_BLACK
    db FG_BLUEGREEN | BG_BLUE
    db FG_TEAL | BG_BLUE
    db FG_BLUEGREEN | BG_BLACK
    db FG_BLUEGREEN | BG_BLUE
    db FG_BLUEGREEN | BG_BLUE
    db FG_BLUEGREEN | BG_BLUE
    db FG_BLUE | BG_BLACK
    db FG_BLUEGREEN | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLACK
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE
    db FG_BLUE | BG_BLUE

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

    org FONT_BASE
    include 'kc853_font.asm'
