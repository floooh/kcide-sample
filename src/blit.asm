
; copy multiple 8x8 tiles
; inputs:
;   hl: points to array of src addresses
;   de: dst address
;   b: number of tiles
copy8x8xN:
.loop
    ld a,(hl)   ; load next src address
    inc hl
    ld c,(hl)
    inc hl
    push hl
    ld l,a
    ld h,c      ; hl now src address

    ldi         ; copy 8 bytes
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi

    pop hl
    djnz .loop
    ret

; copy multiple 8x8 tiles stretched to 8x16
; inputs:
;   hl: points to array of src addresses
;   de: dst address
;   b: number of tiles
copy8x16xN:
.loop
    ld a,(hl)   ; load next src address
    inc hl
    ld c,(hl)
    inc hl
    push hl
    ld l,a
    ld h,c      ; hl now src address

    ldi         ; copy 8 into 16 bytes
    dec l
    ldi
    ldi
    dec l
    ldi
    ldi
    dec l
    ldi
    ldi
    dec l
    ldi
    ldi
    dec l
    ldi
    ldi
    dec l
    ldi
    ldi
    dec l
    ldi
    ldi
    dec l
    ldi

    pop hl
    djnz .loop
    ret

; left-shift multiple 8x16 tiles from a src- to a dst location
; inputs:
;   hl: points to start of src data, aligned to 100h
;   de: points to start of dst data, aligned to 100
;   b: number of tiles to blit (max 31)
lshift8x8xN:
    ; set hl and de to last row of last tile
    ld a,b
    add a,a     ; tile count * 8
    add a,a
    add a,a
    ld c,a
    ld a,l
    add a,c
    ld l,a      ; hl = hl + a * 8
    ld a,e
    add a,c
    ld e,a      ; de = de + a * 8

    dec hl      ; last row of last tile
    dec de
    ld c,b      ; store tile count in c

    ; outer loop: 16 pixel rows
    ; inner loop: 1 pixel row across all tiles
    ld b,8     ; row counter
.outer:
    push bc
    push de
    push hl
    ld b,c
    xor a       ; clear carry flag
.inner:
    ld a,(hl)
    rl a        ; carry <= bit7...bit0 <= carry
    ld (de),a
    ex af,af'   ; preserve carry for next shift
    ld a,l
    sub 8       ; hl = hl - 8
    ld l,a
    ld a,e
    sub 8       ; de = de - 8
    ld e,a
    ex af,af'   ; restore carry
    djnz .inner

    pop hl
    pop de
    pop bc
    dec de      ; next column
    dec hl
    djnz .outer
    ret

; blit consecutive 8x8 tiles to video ram
; inputs:
;   hl: points to start to tile data (100h aligned)
;   de: points to dst video ram address
;   b:  number of tiles to blit
blit8x8xN:
.loop:
    ld a,d      ; clip against screen boundaries
    cp 80h      ; left border
    jr c,.skip_left
    cp A8h      ; right border
    jr nc,.skip_right
    ld a,e      ; store original row
    ldi         ; copy 8 bytes
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ld e,a      ; restore original row
.skip_right
    inc d       ; next column in video mem
    djnz .loop
    ret
.skip_left:
    ld a,l
    add a,8
    ld l,a
    inc d
    djnz .loop
    ret



; blit consecutive 8x16 tiles to video ram
; inputs:
;   hl: points to start to tile data
;   de: points to dst video ram address
;   b:  number of tiles to blit
blit8x16xN:
.loop:
    ld a,e      ; store original row
    ldi         ; copy 16 bytes
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ld e,a      ; restore original row
    inc d       ; next column in video mem
    djnz .loop
    ret

CHR_SPACE      = EE00h
CHR_EXCL       = EE08h
CHR_DQUOTE     = EE10h
CHR_POUND      = EE18h
CHR_DOLLAR     = EE20h
CHR_PERCENT    = EE28h
CHR_AMPERSAND  = EE30h
CHR_APOSTROPHE = EE38h
CHR_LPAR       = EE40h
CHR_RPAR       = EE48h
CHR_ASTERISK   = EE50h
CHR_PLUS       = EE58h
CHR_COMMA      = EE60h
CHR_MINUS      = EE68h
CHR_DOT        = EE70h
CHR_SLASH      = EE78h
CHR_0          = EE80h
CHR_1          = EE88h
CHR_2          = EE90h
CHR_3          = EE98h
CHR_4          = EEA0h
CHR_5          = EEA8h
CHR_6          = EEB0h
CHR_7          = EEB8h
CHR_8          = EEC0h
CHR_9          = EEC8h
CHR_COLON      = EED0h
CHR_SEMICOLON  = EED8h
CHR_LT         = EEE0h
CHR_EQ         = EEE8h
CHR_GT         = EEF0h
CHR_QUESTION   = EEF8h
CHR_AT         = EF00h
CHR_A          = EF08h
CHR_B          = EF10h
CHR_C          = EF18h
CHR_D          = EF20h
CHR_E          = EF28h
CHR_F          = EF30h
CHR_G          = EF38h
CHR_H          = EF40h
CHR_I          = EF48h
CHR_J          = EF50h
CHR_K          = EF58h
CHR_L          = EF60h
CHR_M          = EF68h
CHR_N          = EF70h
CHR_O          = EF78h
CHR_P          = EF80h
CHR_Q          = EF88h
CHR_R          = EF90h
CHR_S          = EF98h
CHR_T          = EFA0h
CHR_U          = EFA8h
CHR_V          = EFB0h
CHR_W          = EFB8h
CHR_X          = EFC0h
CHR_Y          = EFC8h
CHR_Z          = EFD0h
CHR_QUAD       = EFD8h
CHR_PIPE       = EFE0h
CHR_NEG        = EFE8h
CHR_EXP        = EFF0h
CHR_UNDERLINE  = EFF8h
