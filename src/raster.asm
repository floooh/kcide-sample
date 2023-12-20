; renders the big KC85/4 logo pixels

; renders a horizontal line of pixels
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
    ; horizontal lines at top and bottom of logo
    ld e,2Ch
    call raster_hori_line
    ld e,2Dh
    call raster_hori_line
    ld e,92h
    call raster_hori_line
    ld e,93h
    call raster_hori_line

    ld hl,raster_data   ; load HL with start of raster data
    exx
    ld d,81h            ; DE is going to be video ram address
    exx
    ld b,38             ; counter for 38 columns
.loop_columns:
    push bc
    exx
    ld e,30h            ; E is dst Y coord
    exx
    ld a,(hl)           ; pixels for next column
    ld b,6              ; counter for 6 rows
.loop_rows:
    rla                 ; current raster pixel into carry
    jr nc,.skip_pixel   ; skip blank pixel
    exx                 ; store HL/BC to prevent from being destroyed by LDI
    ld hl,raster_tiles
    ldi8                ; 8x LDI to render 8x8 pixel tile
    ld hl,raster_tiles  ; rewind HL to start of tile data
    ldi8                ; 8x LDI to render same 8x8 tile below
    exx                 ; restore HL/BC
.continue:
    djnz .loop_rows     ; loop
    inc hl              ; next raster row
    pop bc              ; restore column counter
    exx
    inc d               ; set video RAM dst pointer to next column
    exx
    djnz .loop_columns  ; loop over columns
    ret
.skip_pixel:
    exx
    ld hl,16
    add hl,de
    ex de,hl
    exx
    jr .continue

raster_tiles:
    db   0, 3Ch, 7Eh, 7Eh, 7Eh, 7Eh, 3Ch, 0

raster_data:
    ; 'KC85' as 6x38 bit raster
    db 11111100b    ; K
    db 11111100b
    db 00100000b
    db 01110000b
    db 11011000b
    db 10001100b
    db 00000100b

    db 01111000b    ; C
    db 11111100b
    db 10000100b
    db 10000100b
    db 11001100b
    db 01001000b
    db 00000000b

    db 01011000b    ; 8
    db 11111100b
    db 10100100b
    db 10100100b
    db 11111100b
    db 01011000b
    db 00000000b

    db 11101000b    ; 5
    db 11101100b
    db 10100100b
    db 10100100b
    db 10111100b
    db 10011000b
    db 00000000b

    db 00011100b    ; /
    db 11111100b
    db 11100000b
    db 00000000b

    db 11110000b    ; 4
    db 11110000b
    db 00010000b
    db 00111100b
    db 00111100b
    db 00010000b
