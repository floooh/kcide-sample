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
str_start:      dw 0        ; start address of zero-terminated ASCII string, each characer
str_next:       dw 0        ; pointer to next character, rewinds to str_start on zero-character
frame_count:    db 0        ; frame counter (only low 3 bits relevant)
rb_head:        dw 0        ; current rinbuffer head 9-bit offset, increments by 8 every 8 frames, wraps around at 200h
rb_prev:        dw 0        ; offset of the current character (head-1)

;   scroll_init
;
;   inputs:
;       HL: points to start of zero-terminated string data
;
scroll_init:
    ld (str_start),hl
    ld (str_next),hl
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
    jr z,.rewind_str
    sub 20h             ; space => index 0
    add a,a             ; * 2
    add a,a             ; * 4
    ld hl,EE00h         ; character table 1 (starting at space)
    ld d,0
    ld e,a
    add hl,de
    add hl,de           ; * 8, hl now points to character font data

    ld de,(rb_head)
    ld (rb_prev),de
    ld a,40h
    or d
    ld d,a              ; de now points into first ring buffer
    ldi                 ; copy 8 font pixel bytes
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ld a,1              ; turn hl back into 9-bit offset with wraparound
    and d
    ld d,a
    ld (rb_head),de
.bump_frame_count:
    ld hl,frame_count   ; bump frame counter 0..7
    ld a,(hl)
    inc a
    and 7
    ld (hl),a
    ret

.rewind_str:
    ; end of input string was reached, rewind to start and load next character
    ld hl,(str_start)
    ld (str_next),hl
    jr .frame_0

.frame_n:
    jr .bump_frame_count