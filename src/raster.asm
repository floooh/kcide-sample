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
    ld b,6              ; counter for 6 rows
.loop_rows:
    ld a,(hl)           ; next raster pixel (0 for blank, 8 for filled)
    exx                 ; store HL/BC to prevent from being destroyed by LDI
    ld hl,raster_tiles
    add a,l
    ld l,a              ; HL now points to blank or filles 8x8 pixel tile
    ldi8                ; 8x LDI to render 8x8 pixel tile
    ld l,a              ; rewind HL to start of tile data
    ldi8                ; 8x LDI to render same 8x8 tile below
    exx                 ; restore HL/BC
    inc hl              ; next raster pixel
    djnz .loop_rows     ; loop
    pop bc              ; restore column counter
    exx
    inc d               ; set video RAM dst pointer to next column
    exx
    djnz .loop_columns  ; loop over columns
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
    ; blank tile
    db   0,   0,   0,   0,   0,   0,   0, 0
    ; circle tile
    db   0, 3Ch, 7Eh, 7Eh, 7Eh, 7Eh, 3Ch, 0
