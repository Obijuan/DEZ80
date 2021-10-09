.area _DATA

.area _CODE

;;===============================
;;  Main program entry
;;===============================
_main::
  ld a, #0xFF
  ld (0xC000),a

  jr .
