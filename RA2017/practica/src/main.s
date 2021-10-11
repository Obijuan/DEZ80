.area _DATA

;;===================================
;; VARIABLES
;;===================================
hero_x: .db #39  ;;-- x position (in bytes [0-79])
hero_y: .db #80  ;;-- y posicion (in pixels [0-199])

;;-- CPCtelera symbols
.globl cpct_drawSolidBox_asm
.globl cpct_getScreenPtr_asm
.globl cpct_scanKeyboard_asm
.globl cpct_isKeyPressed_asm
.include "keyboard/keyboard.s"

.area _CODE

;;===============================
;; drawHero
;;
;; DESTROYs: 
;;===============================
checkUserInput:

  ;;-- Scan the whole keyboard
  call cpct_scanKeyboard_asm

  ;;-- Check for key 'D' being pressed
  ld hl, #Key_D               ;;-- hl = Key_D Keycode
  call cpct_isKeyPressed_asm
  cp #0                  ;; check A == 0
  jr z, d_not_pressed    ;;-- Jump if D is not pressed

    ;;-- D is pressed
    ;;-- Increase the hero_x value by 1 (Hero_x = Hero_x + 1)
    ld a, (hero_x)  ;;-- A =  hero_x
    inc a           ;;-- A = A + 1
    ld (hero_x),a   ;;-- hero_x = A

    ld a,#0xFF
    ld (0xC000), a
    ret

  d_not_pressed:
    ld a,#0
    ld (0xC000), a
  ret

;;===============================
;; drawHero
;;
;; DESTROYs: AF, BC, DE, HL
;;===============================
drawHero:

  ;;-- Convert the hero_x, hero_y variables into
  ;;-- the corresponding address in the Video memory
  ld   de, #0xC000  ;;-- Video initial address
  ld    a,(hero_x)
  ld    c,a         ;;-- Hero x position
  ld    a,(hero_y)
  ld    b,a         ;;-- Hero y position
  call cpct_getScreenPtr_asm

  ;; HL contains the video address
  ;; move it to the DE register
  ex de, hl

  ;; Draw a Box (our hero!)
  ld     a, #0x0F      ;; Cyan
  ld    bc, #0x0802    ;; Height, Width: 8x8 pixels
  call  cpct_drawSolidBox_asm
  ret

;;====================================
;; deleteHero
;;
;;====================================
deleteHero:

  ;;-- Convert the hero_x, hero_y variables into
  ;;-- the corresponding address in the Video memory
  ld   de, #0xC000  ;;-- Video initial address
  ld    a,(hero_x)
  ld    c,a         ;;-- Hero x position
  ld    a,(hero_y)
  ld    b,a         ;;-- Hero y position
  call cpct_getScreenPtr_asm

  ;; HL contains the video address
  ;; move it to the DE register
  ex de, hl

  ;; Draw a Box (our hero!)
  ld     a, #0x00      ;; Backgrond...
  ld    bc, #0x0802    ;; Height, Width: 8x8 pixels
  call  cpct_drawSolidBox_asm
  ret

;;===============================
;;  Main program entry
;;===============================
_main::

  call deleteHero       ;; Erase previous hero
  call checkUserInput   ;; Check if user pressed keys
  
  call drawHero         ;; Draw our Hero :)

;;  ld a, #20
;;wait:
;;  halt
;;  dec a
;;  jr nz, wait
;;
  jr _main

