; helper functions to synchronize with vertical blank

    ; setup the vertical blank interrupt via CTC channel 2
    ; the CLK/TRG2 pin of the CTC is connected to the
    ; video hardware and triggers on each vsync, programming
    ; CTC channel 2 to counter mode with a counter value
    ; of 1 can thus be used to generate an interrupt each frame
vsync_init:
    xor a
    ld (VSYNC_STATE),a
    di
    ; set interrupt service routine for CTC channel 2
    ld hl,01ECh
    ld de,vsync_isr
    ld (hl),e
    inc hl
    ld (hl),d

    ; load CTC2 control word
    ; bit 7 = 1: enable interrupt
    ; bit 6 = 1: counter mode
    ; bit 5 = 0: prescaler 16
    ; bit 4 = 1: rising edge
    ; bit 3 = 0: time trigger (irrelevant)
    ; bit 2 = 1: constant follows
    ; bit 1 = 0: no reset
    ; bit 0 = 1: this is a control word
    ld a,11010101b
    out (8Eh),a
    ; trigger vsync interrupt each frame
    ld a,1
    out (8Eh),a
    ei
    ret

; the interrupt service routine simply sets bits 1 in a memory variable
vsync_isr:
    push af
    ld a,1
    ld (VSYNC_STATE),a
    pop af
    ei
    reti

; wait until the bit 1 in (vsync) flips to 1, which means the vsync
; interrupt service routine was called, and then reset the
; bit to zero again
vsync_wait:
    ld a,(VSYNC_STATE)
    and 1
    jr z, vsync_wait
    xor a
    ld (VSYNC_STATE),a
    ret
