;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; byte forever demo for zx81
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Using "model" minimal machine code skeleton, from Dr.Beep's 
;;; book: The Ulitmate 1K ZX81 coding book
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



; 12 bytes bytes from $4000 to $400b free reusable for own code

   org $4009

; in LOWRES more sysvar are used, but in tis way the shortest code over sysvar
; to start machine code. This saves 11 bytes of BASIC

; DON NOT CHANGE AFTER BASIC+3 (=DFILE)

basic    ld h,dfile/256  ; high(MSB) of dfile
         jr init1
         db 236          ; BASIC over DFILE data
         db 212, 28      ; GOTO USR 0
         db 126,143,0,18 ; short FP nr of $4009

eline    dw last
chadd    dw last-1
         db 0,0,0,0,0,0  ; x not useable
berg     db 0            ; x before loading
mem      db 0,0          ; x OVERWRITTEN ON LOAD

init1    ld l, dfile mod 256 ; low byte of dfile
         jr init2

lastk    db 255,255,255
margin   db 55

nxtlin   dw basic        ; the called BASIC-line

flagx    equ init2+2
init2    ld (basic+3),hl ; repair dfile pointer
         ld l, vars mod 256 ; lsb-end of screen
         db 0
         db 0            ; x used by ZX81
         ld h, vars/256  ; msb-end of screen

frames   db $37          ; after load: ld (hl), n
         db $e9          ; set jp (hl) as end of screen-marker
 
         xor a
         ex af, af'      ; delay interrupts
         jp demo_start  ; main code entry point

cdflag   db 64

; DO NOT CHANGE SYSVAR ABOVE!
SHAPE_CHAR_0  equ    128        ; black square
BLANK_SQUARE  equ    0          ; empty 
BOTTOM        equ    23         ; bottom row number
LINE_LENGTH   equ    32         
;VSYNCLOOP     equ    10         ; used for frame delay loop
DF_CC         equ    dfile+1
    
;; start point and anything only called once after load
demo_start            
   call fillScreenArea

;; main loop
main
    ld de, (VSYNCLOOP) 	          
    ld hl,frames
	ld a, (hl)
	sub e
wfr
    cp (hl)
	jr nz, wfr


    ;; bounce byte forever left right
    ld de, (left_byte) 
    call displayTextEveryLine_DE

    ld de, (left_byte)
    ld a, (left_byte_max)
    cp e
    jr z, check_left_p1
    jr skip_to_check_other
check_left_p1
    ld a, (left_byte_max+1)
    cp d
    jr z, reset_left

skip_to_check_other
; check not hit minimum
    ;ld de, (left_byte) ;; de already loaded with left_byte
    ld a, (left_byte_min)
    cp e
    jr z, check_left_p2
    jr skip_to_inc
check_left_p2
    ld a, (left_byte_min+1)
    cp d
    jr z, reset_right
    jr skip_to_inc

reset_left
    ld hl, -1
    ld (direction), hl
    jr skip_to_inc
reset_right
    ld hl, 1
    ld (direction), hl

    ld de,(VSYNCLOOP)
    ld a, 1
    cp e
    jr z, after_dec
    cp d
    jr z, after_dec 
    dec de
    ld (VSYNCLOOP), de
after_dec

skip_to_inc
    ld de, (left_byte)
    ld hl, (direction)
    add hl, de
    ld (left_byte),hl
    jr main 

fillScreenArea 
    ld bc, BOTTOM*LINE_LENGTH
    ld hl, line1  
    ld de, line2
    ldir           ; replicate the first line down full area    
    ret

displayTextEveryLine_DE    ; DE stores offset to dfile+1 to start printing the text

    ld hl, dfile+1
    ld  b, 24
nextLine
    push bc

    add hl, de
    push hl
    pop de
    push hl
      ld hl, byte_text
      ld bc, byte_end - byte_text
      ldir
    pop hl
    ld de, 32
    pop bc
    djnz nextLine 
    ret


vars
    db 118
byte_text
    db 8, "B"-27,"Y"-27,"T"-27,"E"-27,"F"-27,"O"-27,"R"-27,"E"-27,"V"-27,"E"-27,"R"-27,136
byte_end

left_byte 
    dw 1
left_byte_min
    dw 1
left_byte_max
    dw 18
direction
    dw 1
VSYNCLOOP
    dw 6
; The screen area is a shrunk down ZX81 display. the subroutine fillPlayerArea
; initialises tghe full screen. This keeps the assembled file to well below 
; 949 bytes which is the maximum safe to load on an unexpancded ZX81
dfile
       db 118
line1  db 118 ;0,0,0,0,0,0,0,0
       ;db 0,0,0,0,0,0,0,0
       ;db 0,0,0,0,0,0,0,0
       ;db 0,0,0,0,0,0,0,118
line2  db 118

last     equ $
end

