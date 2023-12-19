raster_hori_line:
    ld b,28h
    ld d,80h
.loop:
    ld a,FFh
    ld (de),a
    inc d
    djnz .loop
    ret

raster_draw:
    ld e,2Ch
    call raster_hori_line
    ld e,2Dh
    call raster_hori_line
    ld e,92h
    call raster_hori_line
    ld e,93h
    call raster_hori_line

    ld hl,raster_data
    exx
    ld d,81h
    exx
    ld b,38         ; 38 columns
.outer_loop
    push bc
    exx
    ld e,30h
    exx
    ld b,6          ; 6 rows
.inner_loop
    ld a,(hl)
    exx
    ld hl,raster_tiles
    add a,l
    ld l,a
    ldi8
    ld l,a
    ldi8
    exx
    inc hl
    djnz .inner_loop
    pop bc
    exx
    inc d
    exx
    djnz .outer_loop
    ret

    align 100h
raster_data:
    ; 'KC85' as 6x38 raster
    db 8,8,8,8,8,8  ; K
    db 8,8,8,8,8,8
    db 0,0,8,0,0,0
    db 0,8,8,8,0,0
    db 8,8,0,8,8,0
    db 8,0,0,0,8,8
    db 0,0,0,0,0,8

    db 0,8,8,8,8,0  ; C
    db 8,8,8,8,8,8
    db 8,0,0,0,0,8
    db 8,0,0,0,0,8
    db 8,8,0,0,8,8
    db 0,8,0,0,8,0
    db 0,0,0,0,0,0

    db 0,8,0,8,8,0  ; 8
    db 8,8,8,8,8,8
    db 8,0,8,0,0,8
    db 8,0,8,0,0,8
    db 8,8,8,8,8,8
    db 0,8,0,8,8,0
    db 0,0,0,0,0,0

    db 8,8,8,0,8,0  ; 5
    db 8,8,8,0,8,8
    db 8,0,8,0,0,8
    db 8,0,8,0,0,8
    db 8,0,8,8,8,8
    db 8,0,0,8,8,0
    db 0,0,0,0,0,0

    db 0,0,0,8,8,8  ; /
    db 8,8,8,8,8,8
    db 8,8,8,0,0,0
    db 0,0,0,0,0,0

    db 8,8,8,8,0,0  ; 4
    db 8,8,8,8,0,0
    db 0,0,0,8,0,0
    db 0,0,8,8,8,8
    db 0,0,8,8,8,8
    db 0,0,0,8,0,0

    align 100h
raster_tiles:
    db   0,   0,   0,   0,   0,   0,   0, 0
    db   0, 3Ch, 7Eh, 7Eh, 7Eh, 7Eh, 3Ch, 0
