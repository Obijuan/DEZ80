.area _DATA
.area _CODE
;;==============================================
;;==============================================
;; PRIVATE DATA
;;==============================================
;;==============================================

;;-- Data for drawing the sprite
.globl _sprite_smily

;;-- HERO DATA
hero_data:
  hero_x:   .db #39  ;;-- (+0) x position (in bytes [0-79])
  hero_y:   .db #80  ;;-- (+1) y posicion (in pixels [0-199])
  hero_w:   .db #4   ;;-- (+2) Width in bytes
  hero_h:   .db #12   ;;--(+3) Height in bytes
  hero_sprite: .dw #_sprite_smily ;;-- (+4) Pointer to the sprite
  hero_jump: .db #-1  ;;-- Are we jumping? 

hero2_data:
     .db #60  ;;-- (+0) x position (in bytes [0-79])
     .db #40  ;;-- (+1) y posicion (in pixels [0-199])
     .db #4   ;;-- (+2) Width in bytes
     .db #12   ;;--(+3) Height in bytes
     .dw #0000 ;;-- (+4) Pointer to the sprite


;;-- Jump table
jumptable: 
  .db #-3, #-3, #-2, #-2, #-1, #-1
  .db #0,  #0, #0, #0
  .db #1, #1, #2,  #2, #3, #3
  .db #0x80

;;-- CPCtelera symbols
.include "cpctelera.h.s"
.include "keyboard/keyboard.s"

;;=============================================
;;=============================================
;; PUBLIC FUNCTIONS
;;=============================================
;;=============================================

;;======================
;; Get a pointer to hero data in HL
;; DESTROYS: HL
;; RETURN:
;;   HL: Pointer to hero Data
;;=======================
hero_getPtrHL::
  ld hl,#hero_x
  ret

;;======================
;; Updates the Hero
;; DESTROYS: AF, BC, HL
;;=======================
hero_update::
  call jumpControl      ;;-- Do jumps
  call checkUserInput   ;; Check if user pressed keys
  ret

;;======================
;; Draw the hero
;; DESTROYS: AF, BC, HL
;;=======================
hero_draw::
  ld ix, #hero_data
  call entityDraw 

  ld ix, #hero2_data
  call entityDraw
  ret

;;======================
;; Erase the hero
;; DESTROYS: AF, BC, HL
;;=======================
hero_erase::

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
  ld     a, (hero_w)
  ld     c, a          ;; c = Hero width
  ld     a, (hero_h) 
  ld     b, a          ;; b = Hero height
  ld     a, #0x00      ;; Color pattern: 0 (Black!)
  call  cpct_drawSolidBox_asm
  ret


;;=============================================
;;=============================================
;; PRIVATE FUNCTIONS
;;=============================================
;;=============================================

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


;;=============================================
;; moveHeroRight: Move the hero to the right
;;  (inside the line limits)
;;
;; DESTROYS:
;;=============================================
moveHeroRight:
  ;;- Check if the hero_x has reached its maximum value
  ;;-- We should check the possition 80 - hero.width
  ld a, (hero_w)
  ld b,a
  ld a, #80
  sub b          ;;-- A = 80 - hero_w
  ld b,a         ;;-- B = 80 - hero_w

  ld a, (hero_x) ;;-- A = hero_x
  cp b                 ;; hero_x == 80-hero_w?
  jr z,do_not_move_r      

    ;;- No max reached: increase the hero_x by 1
    inc a           ;;-- A = A + 1
    ld (hero_x),a   ;;-- hero_x = A

  do_not_move_r:
  ret

;;=============================================
;; moveHeroLeft: Move the hero to the left
;;  (inside the line limits)
;;
;; DESTROYS:
;;=============================================
moveHeroLeft:
  ;;-- Decrease the hero_y value by 1 (Hero_x = Hero_x - 1)
  ;;-- (only is decreased if it is greather than 0)
  ld a, (hero_x)
  cp #0  ;;-- hero_x == 0?
  jr z, do_not_move_l   ;;-- Yes: Finish

  ;;-- Decrease the hero_x
  dec a
  ld (hero_x), a

  do_not_move_l:
  ret

;;=============================================
;; startJump
;;
;; DESTROYS:
;;=============================================
startJump:
  ld a,(hero_jump)
  cp #-1           ;; Are we already jumping?
  ret nz           ;; Yes: ret

  ld a, #0
  ld (hero_jump), a
  ret

;;=====================================
;; Control the hero jump
;;=====================================
jumpControl:
  ld a,(hero_jump)  ;; A=Hero jump status
  cp #-1            ;; Are we jumping?
  ret z             ;; No jumping, return

  ;;-- Move Hero
  ;;-- Calculate HL = jumptable[A]
  ld hl, #jumptable  ;;-- HL ponts to the jumptable
  ld b, #0
  ld c, a           ;; BC = A
  add hl,bc         ;; HL = HL + Satus. Address of the current jump position

  ;;-- Calculate the new hero_y pos
  ld b, (hl)      ;;-- Get the current jump increment
  ld a,b
  cp #0x80         ;;-- Check if it is the last position
  jr z,end_of_jump ;;-- If so, end the current jump

    ;;-- NOT the last position
    ;;-- update the hero_y 
    ld a, (hero_y)  ;;-- Get the hero_y
    add b           ;;-- A = A + B (current pos)
    ld (hero_y),a   ;;-- Updated hero_y

    ;;-- Increment hero_jump index
    ld a, (hero_jump)
    inc a
    ld (hero_jump),a

    ;;-- We are done
    ret

  ;;-- Finish the jup: write -1 in the hero_jump variable
  end_of_jump:
    ld a,#-1
    ld (hero_jump),a
    ret

;;===============================
;; checkUserInput: Read the keyboard and update the position
;; of our hero
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
    call moveHeroRight

  d_not_pressed:

  ;;-- Check for the key 'A' being pressed
  ld hl, #Key_A               ;;-- hl = Key_A Keycode
  call cpct_isKeyPressed_asm
  cp #0                       ;; check A == 0
  jr z, a_not_pressed         ;;-- Jump if D is not pressed

    ;;-- A is pressed
    call moveHeroLeft

  a_not_pressed:

  ;;-- Check for the key 'W' being pressed
  ld hl, #Key_W               ;;-- hl = Key_W Keycode
  call cpct_isKeyPressed_asm
  cp #0                       ;; check A == 0
  jr z, w_not_pressed         ;;-- Jump if D is not pressed

    ;;-- W is pressed
    call startJump

  w_not_pressed:
  ret

  

