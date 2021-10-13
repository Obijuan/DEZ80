.area _DATA
.area _CODE
;;==============================================
;;==============================================
;; PRIVATE DATA
;;==============================================
;;==============================================

;;-- BULLET DATA
bullet_x:    .db #79  ;;-- x position (in bytes [0-79])
bullet_y:    .db #81  ;;-- y posicion (in pixels [0-199])

;;=============================================
;;=============================================
;; PUBLIC FUNCTIONS
;;=============================================
;;=============================================

;;-- CPCtelera symbols
.globl cpct_drawSolidBox_asm
.globl cpct_getScreenPtr_asm

;;======================
;; Updates the bullet
;; DESTROYS: AF, BC, HL
;;=======================
bullet_update::
 
  ld a,(bullet_x)   ;;-- Read the bullet position
  cp #0             ;;-- Check the limit
  jr z,start_again  ;;-- Left limit reached: start again from the right

    ;;-- No limit reached. Decrease the bullet_x variable
    dec a
    ld (bullet_x),a
    ret

  start_again:
    ld a, #79
    ld (bullet_x), a 
    ret

;;======================
;; Draw the hero
;; DESTROYS: AF, BC, HL
;;=======================
bullet_draw::
  ;;-- Draw the bullet
  ld a,#0x0F            ;; Color pattern: cyan
  call drawBullet         
  ret

;;======================
;; Erase the hero
;; DESTROYS: AF, BC, HL
;;=======================
bullet_erase::
  ;; Erase previous bullet
  ld a,#0x00            ;; Color pattern: 0 (Background)
  call drawBullet
  ret

;;=============================================
;;=============================================
;; PRIVATE FUNCTIONS
;;=============================================
;;=============================================

;;===============================
;; Draw the bullet
;;
;; INPUT:
;;   A => Color Pattern
;;
;; DESTROYs: AF, BC, DE, HL
;;===============================
drawBullet:

  ;;-- Store the color patter
  push af

  ;;-- Convert the bullet_x, bullect_y variables into
  ;;-- the corresponding address in the Video memory
  ld   de, #0xC000  ;;-- Video initial address
  ld    a,(bullet_x)
  ld    c,a         ;;-- Bullet x position
  ld    a,(bullet_y)
  ld    b,a         ;;-- Bullet y position
  call cpct_getScreenPtr_asm

  ;; HL contains the video address
  ;; move it to the DE register
  ex de, hl

  ;; Draw a Box 
  pop af               ;; Read the color pattern
  ld    bc, #0x0401    ;; Height, Width: 4x4 pixels
  call  cpct_drawSolidBox_asm
  ret