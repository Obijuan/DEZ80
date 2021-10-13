.area _DATA
.area _CODE

;;-- CPCtelera symbols
.globl cpct_waitVSYNC_asm
.globl cpct_drawSolidBox_asm
.globl cpct_getScreenPtr_asm

.include "hero.h.s"
.include "bullet.h.s"

;;===============================
;; drawGround
;;
;; INPUT:
;;   A => Color Pattern
;;
;; DESTROYs: AF, BC, DE, HL
;;===============================
drawGround:

  push AF ;;-- Save the color pattern

  ;;-- Draw the half-left side of the ground
  ld   de, #0xC000  ;;-- Video initial address
  ld   bc, #0x5800  ;;-- Position: 0,0x50
  call cpct_getScreenPtr_asm

  ex de, hl      ;;-- DE=video address for the ground
  pop AF         ;;-- Color pattern
  push AF        ;;-- Save the color pattern
  ld bc, #0x0240 ;;-- B: height (Pixels), C: width [1-64]
  call cpct_drawSolidBox_asm

  ;;-- Draw the half-right side of the ground
  ld   de, #0xC000  ;;-- Video initial address
  ld   bc, #0x5840  ;;-- Position: 0x50,0x58
  call cpct_getScreenPtr_asm

  ex de, hl      ;;-- DE=video address for the ground
  pop AF         ;;-- Color pattern
  ld bc, #0x0210 ;;-- B: height (Pixels), C: width [1-64]
  call cpct_drawSolidBox_asm

  ret

;;===============================
;;  Main program entry
;;===============================
_main::

  ;;-- Draw the Ground
  ld a, #0xA0     ;;-- yellow pattern
  call drawGround

  main_loop:

    call hero_erase   ;; Erase the hero
    call bullet_erase ;; Erase the bullet

    call hero_update   ;; Update the Hero
    call bullet_update ;; Update the bullet

    call hero_draw    ;;-- Draw the hero
    call bullet_draw  ;;-- Draw the bullet
  
    ;;-- Wait for the raster to finish
    call cpct_waitVSYNC_asm
    
    jr main_loop
