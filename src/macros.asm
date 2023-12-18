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

    macro ldi7
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    endm

    macro ld_de_a_inc_e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    ld (de),a
    inc d
    inc e
    inc e
    inc e
    endm

    macro ld_de_a_dec_e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    ld (de),a
    inc d
    dec e
    dec e
    dec e
    endm
