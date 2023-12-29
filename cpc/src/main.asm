    org 4000h
_start:
    di              ; disable interrupt
.loop:
    ld bc,7fffh     ; gate array IO address
    ld a,00010000b  ; ga function 'border select'
    out (c),a
    ld a,(color)    ; next border color
    inc a
    and 00011111b   ; wraparound at 31 decimal
    ld (color),a
    or 01000000b    ; gate array function 'color selection'
    out (c),a
    jr .loop

color:  db 0