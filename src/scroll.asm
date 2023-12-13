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

; scroller local state
;
str_start:          dw 0        ; start address of zero-terminated ASCII string, each characer
str_next:           dw 0        ; pointer to next character, rewinds to str_start on zero-character
frame_count:        db 0        ; frame counter (only low 3 bits relevant)
frame_count_prev:   db 0        ; previous frame count
rb_head:            dw 0        ; current rinbuffer head 9-bit offset, increments by 8 every 8 frames, wraps around at 200h
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
    ret

scroll_next_frame:
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
    ld hl,EE00h         ; character table 1 (starting at space)
    ld d,0
    ld e,a
    add hl,de
    add hl,de           ; * 8, hl now points to character font data

    ld de,3F00h         ; create preshifted 8x8 bytes matrix of the character pixels
    ldi                 ; unrotated character pixels
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ex de,hl
    ld de,3F00h
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

    ld hl,(rb_head)
    ld (rb_prev),hl
    ld bc,8
    add hl,bc
    ld a,h
    and 1
    ld h,a
    ld (rb_head),hl

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
    ld d,3FH
    ld e,a          ; de now points into preshifted pixel matrix

    ld a,(frame_count)
    add a,a
    or 40h
    ld hl,(rb_prev)
    or h
    ld h,a          ; de now points to the ring buffer - 1

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
    ld d,3FH
    ld e,a          ; de now points into preshifted pixel matrix

    ld a,(frame_count)
    add a,a
    or 40h
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

.bump_frame_count:
    ld hl,frame_count   ; bump frame counter 0..7
    ld a,(hl)
    ld (frame_count_prev),a
    inc a
    and 7
    ld (hl),a
    ret

.rewind_str:
    ; end of input string was reached, rewind to start and load next character
    ld hl,(str_start)
    ld (str_next),hl
    jp .frame_0
