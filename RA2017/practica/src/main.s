.area _DATA

;;===================================
;; VARIABLES
;;===================================

;;-- HERO DATA
hero_x:    .db #39  ;;-- x position (in bytes [0-79])
hero_y:    .db #80  ;;-- y posicion (in pixels [0-199])
hero_jump: .db #-1  ;;-- Are we jumping? 

;;-- Jump table
jumptable: 
  .db #-3, #-2, #-1, #-1
  .db #-1,  #0,  #0, #0
  .db #1,  #2,  #2, #3
  .db #0x80

;;-- CPCtelera symbols
.globl cpct_drawSolidBox_asm
.globl cpct_getScreenPtr_asm
.globl cpct_scanKeyboard_asm
.globl cpct_isKeyPressed_asm
.globl cpct_waitVSYNC_asm

.include "keyboard/keyboard.s"

.area _CODE

;;=============================================
;; moveHeroRight: Move the hero to the right
;;  (inside the line limits)
;;
;; DESTROYS:
;;=============================================
moveHeroRight:
  ld a, (hero_x)  ;;-- A =  hero_x

  ;;- Check if the hero_x has reached its maximum value
  cp #80-2                 ;; Check against right limit
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
  cp #0x80        ;;-- Check if it is the last position
  jr z,update_jump_index

    ;;-- NOT the last position
    ;;-- update the hero_y 
    ld a, (hero_y)  ;;-- Get the hero_y
    add b           ;;-- A = A + B (current pos)
    ld (hero_y),a   ;;-- Updated hero_y

    ;;-- Increment hero_jump index
    ld a, (hero_jump)
    inc a
    ld (hero_jump),a
    jr continue_jump

  update_jump_index:
    ld a,#-1
    ld (hero_jump),a

  continue_jump:
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

;;===============================
;; drawHero
;;
;; INPUT:
;;   A => Color Pattern
;;
;; DESTROYs: AF, BC, DE, HL
;;===============================
drawHero:

  ;;-- Store the color patter
  push af

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
  pop af               ;; Read the color pattern
  ld    bc, #0x0802    ;; Height, Width: 8x8 pixels
  call  cpct_drawSolidBox_asm
  ret

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

  ;;-- Draw the Ground in red color
  ld a, #0xF0     ;;-- Red pattern
  call drawGround

  main_loop:
    ;; Erase previous hero
    ld a,#0x00            ;; Color pattern: 0 (Background)
    call drawHero

    call jumpControl  ;;-- Do jumps
  
    call checkUserInput   ;; Check if user pressed keys
    
    ;;-- Draw the hero
    ld a,#0xFF            ;; Color pattern: Cyan
    call drawHero         
  
    ;;-- Wait for the raster to finish
    call cpct_waitVSYNC_asm
    
    jr main_loop
  
