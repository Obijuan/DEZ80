.area _DATA

;;===================================
;; VARIABLES
;;===================================
hero_x: .db #78  ;;-- x position (in bytes [0-79])
hero_y: .db #190 ;;-- y posicion (in pixels [0-199])

;;-- CPCtelera symbols
.globl cpct_drawSolidBox_asm
.globl cpct_getScreenPtr_asm

.area _CODE

;;===============================
;; drawHero
;;
;; DESTROYs: AF, BC, DE, 
;;===============================
drawHero:

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
  ld     a, #0x0F      ;; Cyan
  ld    bc, #0x0802    ;; Height, Width: 8x8 pixels
  call  cpct_drawSolidBox_asm
  ret

;;===============================
;;  Main program entry
;;===============================
_main::

  call drawHero  ;; Draw our Hero :)

  jr .

