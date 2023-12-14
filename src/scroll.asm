;
;   A 40 tiles wide 'infinite scroller':
;
;   - 8 ringbuffer with 64 8x8 tiles each with a 40-tile wide 'sliding window'
;     (meaning 512 bytes per ring buffer)
;   - each ringbuffer is left-shifted by 1 pixel from previous one
;   - a frame counter which goes from 0..7
;
;   frame 0: blit next tile into ringbuffer[0]
;   frame 1: left-shift last from rb[0] => rb[1]
;   frame 2: left-shift last from rb[1] => rb[2]
;   frame 3: left-shift last from rb[2] => rb[3]
;   frame 4: left-shift last from rb[3] => rb[4]
;   frame 5: left-shift last from rb[4] => rb[5]
;   frame 6: left-shift last from rb[5] => rb[6]
;   frame 7: left-shift last from rb[6] => rb[7]
;
;   Address 3F00 contains a 64 byte matrix of the
;   current character preshifted 8x.
;
;   Uses address 4000..4FFF for the ring buffers:
;
;   rb[0]:  4000
;   rb[1]:  4200
;   rb[2]:  4400
;   rb[3]:  4600
;   rb[4]:  4800
;   rb[5]:  4A00
;   rb[6]:  4C00
;   rb[7]:  4E00
;

SHIFT_MATRIX_BASE = 3F00h
RINGBUFFER_BASE = 4000h
FONT_BASE = EE00h

; scroller local state
;
str_start:          dw 0        ; start address of zero-terminated ASCII string, each characer
str_next:           dw 0        ; pointer to next character, rewinds to str_start on zero-character
frame_count:        db 0        ; frame counter (only low 3 bits relevant)
rb_tail:            dw 0        ; current ringbuffer tail 9-bit offset
rb_head:            dw 0        ; current ringbuffer head 9-bit offset, increments by 8 every 8 frames, wraps around at 200h
rb_prev:            dw 0        ; offset of the current character (head-1)

masks: db 0,1,3,7,15,31,63,127

;   scroll_init
;
;   inputs:
;       HL: points to start of zero-terminated string data
;
scroll_init:
    ld (str_start),hl
    ld (str_next),hl
    ld hl,200h - 8
    ld (rb_prev),hl
    ld hl,200h - (29h * 8)
    ld (rb_tail),hl
    ret

scroll_begin:
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
    sub 20h             ; space => index 0
    add a,a             ; * 2
    add a,a             ; * 4
    ld hl,FONT_BASE     ; character table 1 (starting at space)
    ld d,0
    ld e,a
    add hl,de
    add hl,de           ; * 8, hl now points to character font data

    ld de,SHIFT_MATRIX_BASE ; create preshifted 8x8 bytes matrix of the character pixels
    ldi                     ; unrotated character pixels
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ex de,hl
    ld de,SHIFT_MATRIX_BASE
    ld b,7

.loop_rows:
    ld a,(de)
    inc e
    rlca
    ld (hl),a
    inc l

    ld a,(de)
    inc e
    rlca
    ld (hl),a
    inc l

    ld a,(de)
    inc e
    rlca
    ld (hl),a
    inc l

    ld a,(de)
    inc e
    rlca
    ld (hl),a
    inc l

    ld a,(de)
    inc e
    rlca
    ld (hl),a
    inc l

    ld a,(de)
    inc e
    rlca
    ld (hl),a
    inc l

    ld a,(de)
    inc e
    rlca
    ld (hl),a
    inc l

    ld a,(de)
    inc e
    rlca
    ld (hl),a
    inc l

    djnz .loop_rows

    ld bc,8
    ld hl,(rb_head)
    ld (rb_prev),hl
    add hl,bc
    ld a,h
    and 1
    ld h,a
    ld (rb_head),hl

    ld hl,(rb_tail)
    add hl,bc
    ld a,h
    and 1
    ld h,a
    ld (rb_tail),hl

.frame_n:
    ld hl,masks
    ld b,0
    ld c,a
    add hl,bc
    ld c,(hl)       ; C is bit mask 0, 3, ...

.left_side:
    ld a,(frame_count)
    add a,a
    add a,a
    add a,a
    ld d,[H(SHIFT_MATRIX_BASE)]
    ld e,a          ; de now points into preshifted pixel matrix

    ld a,(frame_count)
    add a,a
    or [H(RINGBUFFER_BASE)]
    ld hl,(rb_prev)
    or h
    ld h,a          ; hl now points to the ring buffer - 1

    ld b,8
.loop_left:
    ld a,(de)       ; load pre-rotated value
    and c           ; mask out 'left' part
    or (hl)
    ld (hl),a
    inc e
    inc l
    djnz .loop_left

.right_side:
    ld a,(frame_count)
    add a,a
    add a,a
    add a,a
    ld d,[H(SHIFT_MATRIX_BASE)]
    ld e,a          ; de now points into preshifted pixel matrix

    ld a,(frame_count)
    add a,a
    or [H(RINGBUFFER_BASE)]
    ld hl,(rb_head)
    or h
    ld h,a

    ld a,c          ; invert mask
    xor FFh
    ld c,a
    ld b,8
.loop_right:
    ld a,(de)       ; load pre-rotated value
    and c           ; mask out 'right' part
    ld (hl),a
    inc e
    inc l
    djnz .loop_right
    ret

.rewind_str:
    ; end of input string was reached, rewind to start and load next character
    ld hl,(str_start)
    ld (str_next),hl
    jp .frame_0

;
;   Bump the scroll frame counter.
;
scroll_end:
    ld hl,frame_count   ; bump frame counter 0..7
    ld a,(hl)
    inc a
    and 7
    ld (hl),a
    ret

;
;   Draw the scroller string spanning the whole display width.
;   Vertically stretched to 16 pixels.
;   inputs:
;       e: Y coordinate
;
scroll_draw_16:
    ld d,80h
    ld a,(frame_count)
    add a,a
    or [H(RINGBUFFER_BASE)]
    ld c,a          ; store ring buffer base high byte
    ld hl,(rb_tail)
    or h
    ld h,a

    ld b,28h
    ld a,e          ; store Y coordinate
.loop:
    ex af,af'
    push bc

    ldi             ; blit one 8x8 tile
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
    dec hl          ; last one may overflow l
    ldi

    pop bc

    ld a,h          ; ringbuffer wraparound
    and 1
    or c
    ld h,a

    inc d           ; next column
    ex af,af'
    ld e,a          ; restore y coordinate

    djnz .loop
    ret
