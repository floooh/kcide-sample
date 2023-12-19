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

; scroller local state
;
scroll_str_start:          dw 0        ; start address of zero-terminated ASCII string
scroll_str_next:           dw 0        ; pointer to next character, rewinds to str_start on zero-character
scroll_frame_count:        db 0        ; frame counter (only low 3 bits relevant)
scroll_rb_tail:            dw 0        ; current ringbuffer tail 10-bit offset
scroll_rb_head:            dw 0        ; current ringbuffer head 10-bit offset, increments by 16 every 8 frames, wraps around at 400h
scroll_rb_prev:            dw 0        ; offset of the current character (head-1)

    align 8
scroll_masks: db 0,1,3,7,15,31,63,127  ; left/right masks for pre-rotated tile pixels

;   scroll_init
;
;   inputs:
;       HL: points to start of zero-terminated string data
;
scroll_init:
    ld (scroll_str_start),hl
    ld (scroll_str_next),hl
    ld hl,400h - 16
    ld (scroll_rb_prev),hl
    ld hl,400h - (29h * 16)
    ld (scroll_rb_tail),hl
    ret

;   Called at start of frame to append prepare scroller rendering:
;
;   Feeds the next ASCII character and updates the pre-rotate matrix.
;
;   Appends the next character to the ringbuffer that's going to be rendered next.
;
scroll_begin_frame:
    ld a,(scroll_frame_count)
    or a
    jr nz,.frame_n

.frame_0:
    ; feed next character
    ld hl,(scroll_str_next)
    ld a,(hl)           ; next ASCII character
    inc hl
    ld (scroll_str_next),hl
    or a
    jp z,.rewind_str

    ld h,0
    sub 20h             ; a is now char index into font table
    add a,a             ; * 2 (CAREFUL, MUST NOT OVERFLOW)
    ld l,a
    add hl,hl           ; * 4
    add hl,hl           ; * 8
    ex de,hl
    ld hl,font
    add hl,de           ; hl now points to start of character font pixels

    ; create pre-rotated 8x8 matrix of charater tile pixels
    ld de,SHIFT_MATRIX_BASE
    ldi8
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
    ld hl,(scroll_rb_head)
    ld (scroll_rb_prev),hl
    add hl,bc
    ld a,h
    and 3
    ld h,a
    ld (scroll_rb_head),hl

    ld hl,(scroll_rb_tail)
    add hl,bc
    ld a,h
    and 3
    ld h,a
    ld (scroll_rb_tail),hl

.frame_n:
    ; load pre-rotate left/right slice bit mask into C
    ld a,(scroll_frame_count)
    ld b,a
    ld hl,scroll_masks
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
    ld hl,(scroll_rb_prev)
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
    ld a,(scroll_frame_count)
    add a,a
    add a,a
    add a,[H(RINGBUFFER_BASE)]
    ld hl,(scroll_rb_head)
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
    ld hl,(scroll_str_start)
    ld (scroll_str_next),hl
    jp .frame_0

;   Bump the scroll frame counter.
;
scroll_end_frame:
    ld hl,scroll_frame_count   ; bump frame counter 0..7
    ld a,(hl)
    inc a
    and 7
    ld (hl),a
    ret

;
;   Draw the scroller string spanning the whole display width.
;   inputs:
;       de: points to a 64-bytes array of Y positions
;
scroll_draw:
    ld a,(scroll_frame_count)
    add a,a
    add a,a
    add a,[H(RINGBUFFER_BASE)]
    exx
    ld b,a              ; store ring buffer base high byte
    ld hl,(scroll_rb_tail)  ; source blit address
    add a,h
    ld h,a                  ; hl now source address in a ring buffer
    ld d,80h                ; d is video address start high byte
    exx

    ld b,28h                ; column counter
.loop:
    ; NOTE: don't bother trying to squash the blit into push/pop, not worth it
    ld a,(de)       ; current Y coordinate
    exx             ; swap in blit hl (src) and de (dst)
    ld e,a          ; set blit dst Y coordinate
    ld c,FFh        ; prevent underflow during LDI
    ldi8
    ldi8
    ld a,h          ; ringbuffer wraparound
    and 3
    add a,b
    ld h,a
    inc d           ; next video ram column
    exx
    inc e           ; increment Y coord buffer
    djnz .loop
    ret
