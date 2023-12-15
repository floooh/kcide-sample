raster_src:     dw 0        ; source raster data
raster_dst:     dw 0        ; video ram start address
raster_size:    dw 0        ; width/height of raster data

raster_tile: db 0, 3Ch, 7Eh, 7Eh, 7Eh, 7Eh, 3Ch, 0

;
;   Prepare a new raster blob.
;
;   inputs:
;       hl: points to start of raster data, non-zero for a filled pixel
;       de: start address in video ram
;       b:  height of the blob
;       c:  width of the blob
;
raster_init:
    ld (raster_src),hl
    ld (raster_dst),de
    ld (raster_size),bc
    ret

;
;   Draw the next frame of the current raster blob
;
raster_draw:
    ld de,(raster_dst)
    ld hl,(raster_src)
    ld bc,(raster_size)
.loop_y:
    push bc
    push de
    ld b,c
.loop_x:
    ld a,(hl)
    or a
    jr z,.skip
    push hl
    push de
    push bc
    ld hl,raster_tile
    ldi8
    ld hl,raster_tile
    ldi8
    pop bc
    pop de
    pop hl
.skip:
    inc d
    inc hl
    djnz .loop_x
    pop de
    pop bc
    ld a,e
    add a,16
    ld e,a
    djnz .loop_y
    ret
