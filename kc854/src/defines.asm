; global variables at address 0
COLOR_FRAME_COUNT  = 0000h      ; scrolling color effect frame counter
VSYNC_STATE        = 0001h      ; bit zero gets set by vsync ISR
SCROLL_STR_START   = 0002h      ; start address of zero-terminated ASCII string
SCROLL_STR_NEXT    = 0004h      ; pointer to next character, rewinds to str_start on zero-character
SCROLL_FRAME_COUNT = 0006h      ; frame counter (only low 3 bits relevant
SCROLL_RB_TAIL     = 0008h      ; current ringbuffer tail 10-bit offset
SCROLL_RB_HEAD     = 000Ah      ; current ringbuffer head 10-bit offset, increments by 16 every 8 frames, wraps around at 400h
SCROLL_RB_PREV     = 000Ch      ; offset of the current character (head-1)

; constants
FONT_BASE = 1000h
SHIFT_MATRIX_BASE = 3F00h
RINGBUFFER_BASE = 4000h

; IO port 84h bit definitions
IO84_SEL_VIEW_IMG   = (1<<0)
IO84_SEL_CPU_COLOR  = (1<<1)
IO84_SEL_CPU_IMG    = (1<<2)
IO84_HICOLOR        = (1<<3)
IO84_SEL_RAM8       = (1<<4)
IO84_BLOCKSEL_RAM8  = (1<<5)

; background colors
BG_BLACK        = 0
BG_BLUE         = 1
BG_RED          = 2
BG_PINK         = 3
BG_GREEN        = 4
BG_TEAL         = 5
BG_YELLOW       = 6
BG_GREY         = 7

; foreground colors (can be or'ed with background colors)
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

    macro ldi8
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    endm
