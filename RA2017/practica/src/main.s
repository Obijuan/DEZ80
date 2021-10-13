.area _DATA
.area _CODE

.include "hero.h.s"
.include "obstacle.h.s"
.include "cpctelera.h.s"

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
 
checkCollision_x:
  ld a,(obs_x)
  ld b,a        ;;-- B = obs_x
  ld a,(hero_x) ;;-- A = hero_x
  cp b          ;; obs_x == hero_x?
  ret z

  ;;-- No colision
  inc a  ;; A = hexo_x + 1
  cp b   ;; obs_x == hero_x + 1?
  ret

checkCollision_y:
  ld a,(obs_y)
  ld b,a         ;;-- B = obs_y
  ld a,(hero_y)  ;;-- A = hero_y
  add #4         ;;-- A = hero_y + 4
  cp b           ;;-- obs_y < hero_y+4?
  jr nc, collision1

  ;;-- No collision
  ret 

  collision1:
    ;;-- There is collision. Check the other condition
    add #-12         ;;-- obs_y > hero_y-8?
    cp b
    jr c, collision2
 
  ;;-- No collision
  ret
   
  collision2:
    ;;--  hero_y-8 < obs_y < hero_y + 4. Both conditions met
    xor a  ;;-- set z=1. There is collision!
    ret

;;========================================================
;; Check the colision between the hero and the obstacle 
;;========================================================
checkCollision:
  ;; There is colision when the collision on x is true and the colision on y is also true
  call checkCollision_x
  ret nz  ; No colision in x (no need for checking on y)

  ;;-- Collision in x. Check the y variable
  call checkCollision_y
  ret

;;===============================
;;  Main program entry
;;===============================
_main::

  ;;-- Draw the Ground
  ld a, #0xA0     ;;-- yellow pattern
  call drawGround

  main_loop:

    call hero_erase     ;; Erase the hero
    call obstacle_erase ;; Erase the bullet

    call hero_update     ;; Update the Hero
    call obstacle_update ;; Update the bullet

    ;;-- Check colision
    call checkCollision

    jr z,colission

      ;;-- No colission
      ld a,#0x00
      jr continue

    colission:
      ld a,#0xFF

    continue:
      ld (0xC000),a

    call hero_draw      ;;-- Draw the hero
    call obstacle_draw  ;;-- Draw the bullet
  
    ;;-- Wait for the raster to finish
    call cpct_waitVSYNC_asm
    
    jr main_loop
