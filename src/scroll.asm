;
;   A 40 tiles wide 'infinite scroller':
;
;   - 8 ringbuffer with 64 8x16 tiles each with a 40-tile wide 'sliding window'
;     (meaning 1024 bytes per ring buffer) starting at address 4000h
;   - each ringbuffer is left-shifted by 1 pixel from previous one
;   - a frame counter which goes from 0..7
;
;   Address 3F00 contains a 8x8 byte matrix of the current character preshifted 8x.
;
;   Uses address 4000..5FFF for the ring buffers:
;
;   rb[0]:  4000
;   rb[1]:  4400
;   rb[2]:  4800
;   rb[3]:  4C00
;   rb[4]:  5000
;   rb[5]:  5400
;   rb[6]:  5800
;   rb[7]:  5C00
;

SHIFT_MATRIX_BASE = 3F00h
RINGBUFFER_BASE = 4000h
FONT_BASE_0 = EE00h         ; ASCII codes 20h..5Fh
FONT_BASE_1 = FE00h         ; ASCII codes 0..1Fh and 60h to 7Fh

; scroller local state
;
str_start:          dw 0        ; start address of zero-terminated ASCII string
str_next:           dw 0        ; pointer to next character, rewinds to str_start on zero-character
frame_count:        db 0        ; frame counter (only low 3 bits relevant)
rb_tail:            dw 0        ; current ringbuffer tail 10-bit offset
rb_head:            dw 0        ; current ringbuffer head 10-bit offset, increments by 16 every 8 frames, wraps around at 400h
rb_prev:            dw 0        ; offset of the current character (head-1)

    align 8
masks: db 0,1,3,7,15,31,63,127  ; left/right masks for pre-rotated tile pixels

;   scroll_init
;
;   inputs:
;       HL: points to start of zero-terminated string data
;
scroll_init:
    ld (str_start),hl
    ld (str_next),hl
    ld hl,400h - 16
    ld (rb_prev),hl
    ld hl,400h - (29h * 16)
    ld (rb_tail),hl
    ret

;   Called at start of frame to append prepare scroller rendering:
;
;   Feeds the next ASCII character and updates the pre-rotate matrix.
;
;   Appends the next character to the ringbuffer that's going to be rendered next.
;
scroll_begin_frame:
    ld a,(frame_count)
    cp 0
    jr nz,.frame_n

.frame_0:
    ; feed next character
    ld hl,(str_next)
    ld a,(hl)           ; next ASCII character
    inc hl
    ld (str_next),hl
    cp 0
    jp z,.rewind_str

    ; select font table
    cp 5Fh
    jr c, .find_font_0
    ; lower-case characters
    sub 40h
    ld hl,FONT_BASE_1
    jr .font_selected
.find_font_0:
    cp 1Fh
    jr c, .find_font_1
    ; upper-case characters
    sub 20h
    ld hl,FONT_BASE_0
    jr .font_selected
.find_font_1:
    ; special characters < 20h
    ld hl,FONT_BASE_0

.font_selected:         ; a is now character index in font table, hl points to font table
    add a,a             ; * 2
    add a,a             ; * 4
    ld d,0
    ld e,a
    add hl,de
    add hl,de           ; * 8, hl now points to character font data

    ; create pre-rotated 8x8 matrix of charater tile pixels
    ld de,SHIFT_MATRIX_BASE
    ldi                     ; populate first row with unrotated character pixels
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ex de,hl
    ld de,SHIFT_MATRIX_BASE
    ld b,8 * 7
.pre_rotate_loop:
    ld a,(de)
    inc e
    rlca
    ld (hl),a
    inc l
    djnz .pre_rotate_loop

    ; update ringbuffer pointers
    ld bc,16
    ld hl,(rb_head)
    ld (rb_prev),hl
    add hl,bc
    ld a,h
    and 3
    ld h,a
    ld (rb_head),hl

    ld hl,(rb_tail)
    add hl,bc
    ld a,h
    and 3
    ld h,a
    ld (rb_tail),hl

.frame_n:
    ; load pre-rotate left/right slice bit mask into C
    ld a,(frame_count)
    ld b,a
    ld hl,masks
    add a,l
    ld l,a
    ld c,(hl)

.right_slice:
    ; load the current pre-rotate row address into DE
    ld a,b          ; frame_count => a
    add a,a
    add a,a
    add a,a
    ld d,[H(SHIFT_MATRIX_BASE)]
    ld e,a
    push de         ; store for left slice part

    ; load the ring buffer location for the previous character tile into HL
    ld a,b          ; frame_count => a
    add a,a
    add a,a
    add a,[H(RINGBUFFER_BASE)]
    ld hl,(rb_prev)
    add a,h
    ld h,a

    ld b,8
.right_slice_loop:
    ld a,(de)       ; load pre-rotated pixels from pre-rotate matrix
    and c           ; mask right slice
    or (hl)         ; combine current right slice with previous character's left slice
    ld (hl),a
    inc l
    ld (hl),a       ; stretch from 8 to 16 pixels
    inc l
    inc e
    djnz .right_slice_loop

.left_slice:
    pop de          ; restore pointer into pre-rotate matrix

    ; load the ring buffer location for the current character tile into HL
    ld a,(frame_count)
    add a,a
    add a,a
    add a,[H(RINGBUFFER_BASE)]
    ld hl,(rb_head)
    add a,h
    ld h,a

    ld a,c          ; invert mask so it isolates the left-slice
    xor FFh
    ld c,a
    ld b,8
.left_slice_loop
    ld a,(de)       ; load pre-rotated value
    and c           ; mask out left slice
    ld (hl),a       ; write left slice to ring buffer
    inc l
    ld (hl),a       ; stretch from 8 to 16 pixels
    inc l
    inc e
    djnz .left_slice_loop
    ret

.rewind_str:
    ; end of input string was reached, rewind to start and load next character
    ld hl,(str_start)
    ld (str_next),hl
    jp .frame_0

;   Bump the scroll frame counter.
;
scroll_end_frame:
    ld hl,frame_count   ; bump frame counter 0..7
    ld a,(hl)
    inc a
    and 7
    ld (hl),a
    ret

;
;   Draw the scroller string spanning the whole display width.
;   inputs:
;       e: Y coordinate
;
scroll_draw:
    ld d,80h            ; de now target address in video ram
    ld a,(frame_count)
    add a,a
    add a,a
    add a,[H(RINGBUFFER_BASE)]
    ld c,a              ; store ring buffer base high byte
    ld hl,(rb_tail)
    add a,h
    ld h,a              ; hl now source address in a ring buffer

    ld b,28h
    ld a,e          ; store Y coordinate
.loop:
    ex af,af'
    push bc

    ldi             ; blit one 8x16 tile
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

    pop bc

    ld a,h          ; ringbuffer wraparound
    and 3
    add a,c
    ld h,a

    inc d           ; next column
    ex af,af'
    ld e,a          ; restore y coordinate

    djnz .loop
    ret
