.area _DATA

;;-- CPCtelera symbols
.globl cpct_drawSolidBox_asm

.area _CODE

;;===============================
;;  Main program entry
;;===============================
_main::

  ;; Draw a Box
  ld    de, #0xC320    ;; Location
  ld     a, #0x0F      ;; Cyan
  ld    bc, #0x0802    ;; Height, Width: 8x8 pixels
  call  cpct_drawSolidBox_asm

  jr .

