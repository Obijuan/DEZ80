.area _DATA
.area _CODE
;;==============================================
;;==============================================
;; PRIVATE DATA
;;==============================================
;;==============================================

;;-- Data for drawing the sprite
.globl _sprite_smily
.globl _sprite_smily_1
.globl _moveEnemy

.equ CNT_INI, 8

.macro defineEntity name, x, y, w, h, spr, spr1
  name'_data:
  name'_x:        .db x    ;;-- position (in bytes [0-79])
  name'_y:        .db y    ;;-- y posicion (in pixels [0-199])
  name'_w:        .db w    ;;-- Width in bytes
  name'_h:        .db h    ;;-- Height in bytes
  name'_sprite:   .dw spr  ;;-- (+4) Pointer to the sprite
  name'_sprite_1: .dw spr1 ;;-- Secon sprite
  name'__sn:      .db 0    ;;-- Sprite number to draw (0,1)
  name'_cnt:      .db CNT_INI    ;;-- Animation counter
  name'_jump:    .db #-1  ;;-- Are we jumping? 
.endm

.equ Ent_x, 0
.equ Ent_y, 1
.equ Ent_w, 2
.equ Ent_h, 3
.equ Ent_spr_l, 4
.equ Ent_spr_h, 5
.equ Ent_spr_l1, 6
.equ Ent_spr_h1, 7
.equ Ent_sn, 8
.equ Ent_cnt,  9
.equ Ent_jmp, 10

;;-- HERO DATA
defineEntity hero, 39, 80, 4, 12, _sprite_smily, _sprite_smily_1
defineEntity hero2, 39, 130, 4, 12, _sprite_smily_1, _sprite_smily

;;-- Jump table
jumptable: 
  .db #-3, #-3, #-2, #-2, #-1, #-1
  .db #0,  #0, #0, #0
  .db #1, #1, #2,  #2, #3, #3
  .db #0x80

;;-- CPCtelera symbols
.include "cpctelera.h.s"
.include "keyboard.h.s"
.include "map2.h.s"

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

  ld ix, #hero_data
  call checkUserInput   ;; Check if user pressed keys

  ;;-- POner los parametros en la pila (de derecha a izquierda)
  ld hl, #hero_data
  push hl
  ld hl, #hero2_data
  push hl
  call _moveEnemy

  ;;-- Sacar parametros de la pila, porque la funci??n en C 
  ;;-- debe dejar la pila como estaba (convenci??n)
  pop af
  pop af
  ret

;;======================
;; Draw the hero
;; DESTROYS: AF, BC, HL
;;=======================
hero_draw::
  ld a,#1
  ld ix, #hero_data
  call map2_getVieoPtr
  ex de,hl
  call entityDraw 

  ld a,#1
  ld ix, #hero2_data
  ld de,#0xC000
  call entityDraw
  ret

;;======================
;; Erase the hero
;; DESTROYS: AF, BC, HL
;;=======================
hero_erase::

  ld a,#0
  ld ix, #hero_data
  call map2_getVieoPtr
  ex de,hl
  call entityDraw 

  ld a,#0
  ld ix, #hero2_data
  call map2_getVieoPtr
  ex de,hl
  call entityDraw 
  ret


;;=============================================
;;=============================================
;; PRIVATE FUNCTIONS
;;=============================================
;;=============================================

;;==============================
;; Draw an entity
;; INPUTS:
;;   A : IF a==0, the entity is erased
;;   IX: Pointer to the entity
;;   DE: Video memory location where to draw
;;==============================
entityDraw:

  push AF

  ;;-- Convert the entity's x and y coordinates into Video memory address
  ld  a ,Ent_x(IX)  
  ld  c ,a          ;;-- C = entity.x
  ld  a ,Ent_y(IX)
  ld  b ,a          ;;-- B = entity.y
  call cpct_getScreenPtr_asm

  ;; HL contains the video address
  ;; move it to the DE register
  ex  de, hl

  ld  b, Ent_h(IX)   ;;-- B = entity.h
  ld  c, Ent_w(IX)   ;;-- B = entity.w

  pop af
  cp #0   ; A==0? 
  jr z, erase_entity

  ;;-- Check the current counter
  ld a, Ent_cnt(ix)
  cp #0    ;-- Is it 0?

  ;;jr z,counter_0

  ;;-- Counter not zero. Just print
  ;;-- the current sprite

  ;;-- Decrement the counter
  ;dec Ent_cnt(ix)

  jr draw_current

  ;;-- Counter 0. Change the current sprite
  ;;counter_0:
  ;ld a, Ent_sn(ix)
  ;xor #1
  ;ld Ent_sn(ix),a
  ;ld a,#CNT_INI
  ;ld Ent_cnt(ix),a
    

  draw_current:
  ;;-- Draw the entity. Depending on the value of
  ;;-- the sn, sprite 0 or sprinte 1 is drawn
  ld a, Ent_sn(ix)      ;;-- Read the spite number to draw

  cp #0   ;;-- Is it sprite 0?
  jr z,draw_sprite_0

  ;-- It is sprite 1. Draw it!
  ld l, Ent_spr_l1(IX)   ;;|
  ld h, Ent_spr_h1(IX)   ;;| HL = entity.spritePtr
  jr draw_sprite

  ;-- It is sprite 0. Draw it
  draw_sprite_0:
    ld l, Ent_spr_l(IX)   ;;|
    ld h, Ent_spr_h(IX)   ;;| HL = entity.spritePtr
    jr draw_sprite

   draw_sprite:
    ld Ent_sn(ix), a    ;; Store the next sprite number
    call  cpct_drawSprite_asm
    ret

  erase_entity:
    call  cpct_drawSolidBox_asm
    ret


;;=========================================
;;  Update the hero counter. When it reachs  
;;  0 the sprite is changed
;;==========================================
update_cnt:
  ;;-- Check the current counter
  ld a, Ent_cnt(ix)
  cp #0    ;-- Is it 0?

  jr z,counter_0

  ;;-- Counter not zero
  ;;-- Decrement the counter
  dec Ent_cnt(ix)
  ret

  ;;-- Counter 0. Change the current sprite
  counter_0:
    ld a, Ent_sn(ix)
    xor #1
    ld Ent_sn(ix),a
    ld a,#CNT_INI
    ld Ent_cnt(ix),a
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
    call update_cnt

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
  call update_cnt

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

  

