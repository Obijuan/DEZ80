.area _DATA
.area _CODE
;;==============================================
;;==============================================
;; PRIVATE DATA
;;==============================================
;;==============================================

;;-- OBSTACLE DATA
obs_x:    .db #80-1  ;;-- x position (in bytes [0-79])
obs_y:    .db #82    ;;-- y posicion (in pixels [0-199])

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
    ld  (obs_x), a 
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