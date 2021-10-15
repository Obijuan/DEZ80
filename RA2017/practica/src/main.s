.area _DATA
.area _CODE

.include "hero.h.s"
.include "obstacle.h.s"
.include "cpctelera.h.s"
.globl _sprite_palette

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
  ld   bc, #0x5C00  ;;-- Position: 0,0x5C
  call cpct_getScreenPtr_asm

  ex de, hl      ;;-- DE=video address for the ground
  pop AF         ;;-- Color pattern
  push AF        ;;-- Save the color pattern
  ld bc, #0x0240 ;;-- B: height (Pixels), C: width [1-64]
  call cpct_drawSolidBox_asm

  ;;-- Draw the half-right side of the ground
  ld   de, #0xC000  ;;-- Video initial address
  ld   bc, #0x5C40  ;;-- Position: 0x40,0x5C
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

  ;;-- Disable Amstrad firmware. Needed for changing
  ;;-- the video mode
  call cpct_disableFirmware_asm

  ;;-- Change the video modeo to 0 (160x200 16 colors)
  ld c,#0
  call cpct_setVideoMode_asm

  ;;-- Change the color palette
  ld hl, #_sprite_palette
  ld de, #16
  call cpct_setPalette_asm

  ;;-- Draw the Ground
  ld a, #0xC3 ;;-- Pink (mode 0)
  call drawGround

  main_loop:

    call hero_erase     ;; Erase the hero
    call obstacle_erase ;; Erase the bullet

    call hero_update     ;; Update the Hero
    call obstacle_update ;; Update the bullet

    ;;-- Check colision
    call hero_getPtrHL
    call obstacle_checkCollision
    ld (0xC000),a        ;;-- Draw collision
    ld (0xC001),a 
    ld (0xC002),a
    ld (0xC003),a

    call hero_draw      ;;-- Draw the hero
    call obstacle_draw  ;;-- Draw the bullet
  
    ;;-- Wait for the raster to finish
    call cpct_waitVSYNC_asm
    
    jr main_loop
