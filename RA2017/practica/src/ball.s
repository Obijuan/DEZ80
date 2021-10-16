;;==================================
;; Entity: BALL
;;==================================

.include "cpctelera.h.s"
.globl _sprite_ball

;;===========
;; BALL DATA
;;===========
ball_data:
  .db 0      ;; (+0) x position
  .db 0      ;; (+1) 1 position
  .db 2      ;; (+2) Width (in bytes)
  .db 4      ;; (+3) Height (in pixels)
  .dw #_sprite_ball  ;; (+4,+5) Pointer to the sprite
  .db 1      ;; (+6) velx
  .db 1      ;; (+7) vely

;;=================================
;;== PUBLIC FUNCTIONS
;;=================================
ball_draw::
  ld ix,#ball_data
  call entityDraw
  ret

ball_update::
  ld ix,#ball_data
  call ball_update_x
  call ball_update_y

  ret

;;======================
;; Erase the ball
;; DESTROYS: AF, BC, HL
;;=======================
ball_erase::

  ld ix,#ball_data

  ;;-- Convert the hero_x, hero_y variables into
  ;;-- the corresponding address in the Video memory
  ld   de, #0xC000  ;;-- Video initial address
  ld    a,0(ix)
  ld    c,a         ;;-- Hero x position
  ld    a,1(ix)
  ld    b,a         ;;-- Hero y position
  call cpct_getScreenPtr_asm

  ;; HL contains the video address
  ;; move it to the DE register
  ex de, hl

  ;; Draw a Box (our hero!)
  ld     a, 2(ix)
  ld     c, a          ;; c = Hero width
  ld     a, 3(ix) 
  ld     b, a          ;; b = Hero height
  ld     a, #0x00      ;; Color pattern: 0 (Black!)
  call  cpct_drawSolidBox_asm
  ret

;;================================
;;== PRIVATE FUNCTIONS
;;================================


;;==============================
;; Draw an entity
;; INPUTS:
;;   IX: Pointer to the entity
;;==============================
entityDraw:
  ;;-- Convert the entity's x and y coordinates into Video memory address
  ld a,0(IX)  
  ld c,a          ;;-- C = entity.x
  ld a,1(IX)
  ld b,a          ;;-- B = entity.y
  ld de, #0xC000  ;;-- Initial video address
  call cpct_getScreenPtr_asm

  ;; HL contains the video address
  ;; move it to the DE register
  ex de, hl

  ;;-- Draw the entity
  ld l, 4(IX)   ;;|
  ld h, 5(IX)   ;;| HL = entity.spritePtr

  ld b, 3(IX)   ;;-- B = entity.h
  ld c, 2(IX)   ;;-- B = entity.w
  call  cpct_drawSprite_asm
  ret

;;======================================
;; Update the x position
;; INPUT:
;;   ix: Pointer to the ball entity
;;======================================
ball_update_x:

  ;;-- Update the ball position: ball_x = ball_x + velx
  ld a,0(ix)  
  ld b,a      ;; B = ball_x

  ld a, 6(ix) ;; A = ball_velx
  add b       ;; A = ball_velx + ball_x

  ld 0(ix),a  ;; Update the position 

  ;;-- Check the right limit
  cp #80-2  ;;-- Right limit reached?
  jr nz, check_left    ;;-- No, check the left limit

  ;;-- Change direction to the left
  go_left:
    ld a, #-1
    ld 6(ix), a  ;;-- Change the direction
    ret
  
  ;;-- Check the left limit
  check_left:
    cp #0  ;;-- Left limit reached?
    ret nz ;;-- No, continue

  ;;-- Change the direction to the right
  ld a,#1
  ld 6(ix), a
  ret

;;======================================
;; Update the y position
;; INPUT:
;;   ix: Pointer to the ball entity
;;======================================
ball_update_y:
  ;;-- Update the ball position: ball_y = ball_y + vely
  ld a,1(ix)  
  ld b,a      ;; B = ball_y

  ld a, 7(ix) ;; A = ball_vely
  add b       ;; A = ball_velx + ball_y

  ld 1(ix),a  ;; Update the position 

  ;;-- Check the bottom limit
  cp #128-4  ;;-- bottom limit reached?
  jr nz, check_top    ;;-- No, check the top limit

  ;;-- Change direction to the top
  go_up:
    ld a, #-1
    ld 7(ix), a  ;;-- Change the direction
    ret
  
  ;;-- Check the top limit
  check_top:
    cp #0  ;;-- Top limit reached?
    ret nz ;;-- No, continue

  ;;-- Change the direction to the bottom
  ld a,#1
  ld 7(ix), a
  ret
