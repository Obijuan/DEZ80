.area _DATA
.area _CODE
;;==============================================
;;==============================================
;; PRIVATE DATA
;;==============================================
;;==============================================

;;-- OBSTACLE DATA
obs_x:   .db #80-1  ;;-- x position (in bytes [0-79])
obs_y:   .db #82    ;;-- y posicion (in pixels [0-199])
obs_w:   .db #1     ;;-- bytes
obs_h:   .db #4     ;;-- pixels

;;=============================================
;;=============================================
;; PUBLIC FUNCTIONS
;;=============================================
;;=============================================

;;-- CPCtelera symbols
.include "cpctelera.h.s"

;;======================
;; Updates the obstacle
;; DESTROYS: AF, BC, HL
;;=======================
obstacle_update::
  ld  a,(obs_x)      ;;-- Read the obstacle position
  dec a
  jr  nz,not_restart_x    ;;-- If (Obs_x != 0) then not restart x

    ;;-- Restart_x when it is 0
    ld a, #80-1  ;;-- A = Obs_x = 80-1

  not_restart_x:
    ld  (obs_x), a  ;;-- Update obs_x
    ret

;;================================================================
;;  Checks Collision between obstacle and another entity
;;  Input:
;;   HL: Points to the other entity with which to check collision
;;  Return:
;;   xxxxxxx
;;================================================================
obstacle_checkCollision::
  ;;
  ;; if (obs_x + obs_w <= hero_x) no collision
  ;;
  ;;  obs_x + obs_w - hero_x <= 0
  ;;

  ld a,(obs_x)
  ld c,a
  ld a,(obs_w)
  add c         ;;-- A = obs_x + obs_w
  sub (hl)      ;;-- A = obs_x + obs_w - hero_x
  jr z, no_collision
  jp m, no_collision

  ;; if (hero_x + hero_w <= obs_x)
  ;;  hero_x + hero_w - obs_x <= 0
  ld a,(hl)    ; A = hero_x
  inc hl
  inc hl       ; HL points to hero_w
  add (hl)     ; A = hero_x + hero_w
  ld c,a       ; C = hero_x + hero_w
  ld a,(obs_x) ; A = obs_x
  ld b,a       ; B = obs_x
  ld a,c       ; A = hero_x + hero_w
  sub b        ; A = hero_x + hero_w - obs_x
  jr z, no_collision
  jp m, no_collision  

  ;;-- Check collision for y-axis
  ;;-- if (hero_y + hero_h <= obs_y) no Collision
  ;;---   (hero_y + hero_h - obs_y <= 0)
  dec hl       ;-- HL points to hero_y
  ld a,(hl)    ;-- A = hero_y
  ld c,a       ;-- C = hero_y
  inc hl
  inc hl       ;-- HL points to hero_h
  ld a,(hl)    ;-- A = hero_h
  add c        ;-- A = hero_y + hero_h
  ld c,a       ;-- C = hero_y + hero_h
  ld a,(obs_y) ;-- A = obs_y
  ld b,a       ;-- B = obs_y
  ld a,c       ;-- A = hero_y + hero_h
  sub b        ;-- A = hero_y + hero_h - obs_y
  jr z, no_collision
  jp m, no_collision


  ;;-- if (obs_y + obs_h <= hero_x) no Collision 
  ;;-- This case cannot happend... no need to implement it

  ;;-- Collision
  ld a, #0xFF
  ret 

  no_collision:
    ld a, #0x00

  ret

;;======================
;; Draw the obstacle
;; DESTROYS: AF, BC, HL
;;=======================
obstacle_draw::
  ;;-- Draw the bullet
  ld a,#0xF0            ;; Color pattern: yellow
  call drawObstacle         
  ret

;;======================
;; Erase the obstacle
;; DESTROYS: AF, BC, HL
;;=======================
obstacle_erase::
  ;; Erase previous bullet
  ld a,#0x00            ;; Color pattern: 0 (Background)
  call drawObstacle
  ret

;;=============================================
;;=============================================
;; PRIVATE FUNCTIONS
;;=============================================
;;=============================================

;;===============================
;; Draw the obstacle
;;
;; INPUT:
;;   A => Color Pattern
;;
;; DESTROYs: AF, BC, DE, HL
;;===============================
drawObstacle:

  ;;-- Store the color patter
  push af

  ;;-- Convert the bullet_x, bullect_y variables into
  ;;-- the corresponding address in the Video memory
  ld   de, #0xC000  ;;-- Video initial address
  ld    a,(obs_x)
  ld    c,a         ;;-- Obs x position
  ld    a,(obs_y)
  ld    b,a         ;;-- Obs y position
  call cpct_getScreenPtr_asm

  ;; HL contains the video address
  ;; move it to the DE register
  ex de, hl

  ;; Draw a Box 
  pop af               ;; Read the color pattern
  ld    bc, #0x0401    ;; Height, Width: 4x4 pixels
  call  cpct_drawSolidBox_asm
  ret