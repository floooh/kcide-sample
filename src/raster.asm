raster_next:        dw raster_order        ; next raster poiter
raster_tile_ptr:    dw raster_tiles

;
;   Draw the next frame of the current raster blob
;
raster_draw:
    ld hl,(raster_next)
    ld a,(hl)
    cp FFh
    jr nz,.store_next
    ld a,(raster_tile_ptr)
    xor 16
    ld (raster_tile_ptr),a
    ld hl,raster_order      ; rewind
    ld a,(hl)
.store_next
    inc hl
    ld e,(hl)
    inc hl
    ld d,(hl)               ; de now video ram target
    inc hl
    ld (raster_next),hl
    ld h,[H(raster_data)]
    ld l,a
    ld a,(hl)               ; a now 0 (empty) or 8 (full) tile

    ld hl,(raster_tile_ptr)
    add a,l
    ld l,a
    ldi8
    ret

    align 100h
raster_tiles:
    db 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 3Ch, 42h, 42h, 42h, 42h, 3Ch, 0
    db 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 3Ch, 7Eh, 7Eh, 7Eh, 7Eh, 3Ch, 0

    align 100h
raster_data:
    ; 'KC85' as 38x6 raster
    db 8,8,0,0,8,8,0, 0,8,8,8,8,0,0, 0,8,8,8,8,0,0, 8,8,8,8,8,8,0, 0,8,8,0, 8,8,0,0,0,0
    db 8,8,0,8,8,0,0, 8,8,0,0,8,8,0, 8,8,0,0,8,8,0, 8,8,0,0,0,0,0, 0,8,8,0, 8,8,0,0,0,0
    db 8,8,8,8,0,0,0, 8,8,0,0,0,0,0, 0,8,8,8,8,0,0, 8,8,8,8,8,0,0, 0,8,8,0, 8,8,0,8,8,0
    db 8,8,0,8,8,0,0, 8,8,0,0,0,0,0, 8,8,0,0,8,8,0, 0,0,0,0,8,8,0, 8,8,0,0, 8,8,8,8,8,8
    db 8,8,0,0,8,8,0, 8,8,0,0,8,8,0, 8,8,0,0,8,8,0, 8,8,0,0,8,8,0, 8,8,0,0, 0,0,0,8,8,0
    db 8,8,0,0,0,8,8, 0,8,8,8,8,0,0, 0,8,8,8,8,0,0, 0,8,8,8,8,0,0, 8,8,0,0, 0,0,0,8,8,0

    macro ord x0 y0 x1 y1
    db y0*38+x0
    dw 8000h + 100h*(x1+1) + (y1+8)*8
    endm

    macro ord2 z
    ord  0,z,  0,z*2,
    ord  1,z,  1,z*2,
    ord  2,z,  2,z*2,
    ord  3,z,  3,z*2,
    ord  4,z,  4,z*2,
    ord  5,z,  5,z*2,
    ord  6,z,  6,z*2,
    ord  7,z,  7,z*2,
    ord  8,z,  8,z*2,
    ord  9,z,  9,z*2,
    ord 10,z, 10,z*2,
    ord 11,z, 11,z*2,
    ord 12,z, 12,z*2,
    ord 13,z, 13,z*2,
    ord 14,z, 14,z*2,
    ord 15,z, 15,z*2,
    ord 16,z, 16,z*2,
    ord 17,z, 17,z*2,
    ord 18,z, 18,z*2,
    ord 19,z, 19,z*2,
    ord 20,z, 20,z*2,
    ord 21,z, 21,z*2,
    ord 22,z, 22,z*2,
    ord 23,z, 23,z*2,
    ord 24,z, 24,z*2,
    ord 25,z, 25,z*2,
    ord 26,z, 26,z*2,
    ord 27,z, 27,z*2,
    ord 28,z, 28,z*2,
    ord 29,z, 29,z*2,
    ord 30,z, 30,z*2,
    ord 31,z, 31,z*2,
    ord 32,z, 32,z*2,
    ord 33,z, 33,z*2,
    ord 34,z, 34,z*2,
    ord 35,z, 35,z*2,
    ord 36,z, 36,z*2,
    ord 37,z, 37,z*2,
    ord 37,z, 37,z*2+1,
    ord 36,z, 36,z*2+1,
    ord 35,z, 35,z*2+1,
    ord 34,z, 34,z*2+1,
    ord 33,z, 33,z*2+1,
    ord 32,z, 32,z*2+1,
    ord 31,z, 31,z*2+1,
    ord 30,z, 30,z*2+1,
    ord 29,z, 29,z*2+1,
    ord 28,z, 28,z*2+1,
    ord 27,z, 27,z*2+1,
    ord 26,z, 26,z*2+1,
    ord 25,z, 25,z*2+1,
    ord 24,z, 24,z*2+1,
    ord 23,z, 23,z*2+1,
    ord 22,z, 22,z*2+1,
    ord 21,z, 21,z*2+1,
    ord 20,z, 20,z*2+1,
    ord 19,z, 19,z*2+1,
    ord 18,z, 18,z*2+1,
    ord 17,z, 17,z*2+1,
    ord 16,z, 16,z*2+1,
    ord 15,z, 15,z*2+1,
    ord 14,z, 14,z*2+1,
    ord 13,z, 13,z*2+1,
    ord 12,z, 12,z*2+1,
    ord 11,z, 11,z*2+1,
    ord 10,z, 10,z*2+1,
    ord  9,z,  9,z*2+1,
    ord  8,z,  8,z*2+1,
    ord  7,z,  7,z*2+1,
    ord  6,z,  6,z*2+1,
    ord  5,z,  5,z*2+1,
    ord  4,z,  4,z*2+1,
    ord  3,z,  3,z*2+1,
    ord  2,z,  2,z*2+1,
    ord  1,z,  1,z*2+1,
    ord  0,z,  0,z*2+1,
    endm

    align 100h
raster_order:
    ord2 0
    ord2 1
    ord2 2
    ord2 3
    ord2 4
    ord2 5
    db FFh
