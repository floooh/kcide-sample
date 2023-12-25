;
;   A 40 tiles wide 'infinite scroller':
;
;   - 8 ringbuffer with 64 8x16 tiles each with a 40-tile wide 'sliding window'
;     (meaning 1024 bytes per ring buffer) starting at address 4000h
;   - each ringbuffer is left-shifted by 1 pixel from previous one
;   - a frame counter which goes from 0..7 and then wraps around
;
;   Address 3F00 contains a 8x8 byte matrix of the current character as
;   pre-rotated tiles.
;
;   Uses address 4000..5FFF for the pre-shifted ring-buffers
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
    align 8
scroll_masks: db 0,1,3,7,15,31,63,127  ; left/right bit masks for pre-rotated tile pixels

;   scroll_init
;
;   inputs:
;       HL: points to start of zero-terminated string data
;
scroll_init:
    ld (SCROLL_STR_START),hl
    ld (SCROLL_STR_NEXT),hl
    ld (SCROLL_FRAME_COUNT),a
    ld hl,400h - 16
    ld (SCROLL_RB_PREV),hl
    ld hl,400h - (29h * 16)
    ld (SCROLL_RB_TAIL),hl
    xor a
    ret

;   Called at start of frame to prepare scroller rendering:
;
;   Every 8th frame, the next character is taken from the scroller string,
;   and pre-rotated 8 times.
;
;   In every frame, the current pre-rotated character will be appended
;   to the ringbuffer that's going to be rendered that frame.
;
scroll_begin_frame:
    ld a,(SCROLL_FRAME_COUNT)   ; check for special 'frame 0' out of 8
    or a
    jr nz,.frame_n

.frame_0:
    ; feed next character
    ld hl,(SCROLL_STR_NEXT)
    ld a,(hl)           ; next ASCII character
    inc hl
    ld (SCROLL_STR_NEXT),hl
    or a
    jp z,.rewind_str

    ld h,0
    add a,a             ; * 2 (CAREFUL, MUST NOT OVERFLOW)
    ld l,a
    add hl,hl           ; * 4
    add hl,hl           ; * 8
    ex de,hl
    ld hl,FONT_BASE
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
    ld hl,(SCROLL_RB_HEAD)
    ld (SCROLL_RB_PREV),hl
    add hl,bc
    ld a,h
    and 3
    ld h,a
    ld (SCROLL_RB_HEAD),hl

    ld hl,(SCROLL_RB_TAIL)
    add hl,bc
    ld a,h
    and 3
    ld h,a
    ld (SCROLL_RB_TAIL),hl

.frame_n:
    ; load pre-rotate left/right slice bit mask into C
    ld a,(SCROLL_FRAME_COUNT)
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
    ld hl,(SCROLL_RB_PREV)
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
    ld a,(SCROLL_FRAME_COUNT)
    add a,a
    add a,a
    add a,[H(RINGBUFFER_BASE)]
    ld hl,(SCROLL_RB_HEAD)
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
    ld hl,(SCROLL_STR_START)
    ld (SCROLL_STR_NEXT),hl
    jp .frame_0

;   Bump the scroll frame counter.
;
scroll_end_frame:
    ld hl,SCROLL_FRAME_COUNT   ; bump frame counter 0..7
    ld a,(hl)
    inc a
    and 7
    ld (hl),a
    ret

;
;   Draw the scroller string spanning the whole display width. This
;   chooses one of the 8 pre-shifted ringbuffers in order to achieve
;   a smooth scrolling effect.
;
;   In addition the Y coordinate is offset to achieve a curved effect.
;
;   inputs:
;       de: points to a 64-bytes array of Y positions (aligned to 64-bytes)
;
scroll_draw:
    ld a,(SCROLL_FRAME_COUNT)
    add a,a
    add a,a
    add a,[H(RINGBUFFER_BASE)]
    exx
    ld b,a              ; store ring buffer base high byte
    ld hl,(SCROLL_RB_TAIL)  ; source blit address
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
    ldi8            ; copy 16 bytes
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
