.area _DATA
.area _CODE
;;==============================================
;;==============================================
;; PRIVATE DATA
;;==============================================
;;==============================================

.include "cpctelera.h.s"
.include "keyboard.h.s"
.globl _g2_tileset
.globl _g2_level0

;;-- Constants
map2_width = 166  ; Map total width
map2_height = 17  ; 

;;-- Variables
viewp_ptr:  .dw #_g2_level0  ;;-- Pointer of the viewport
viewp_x  :  .db 00           ;;-- X coordinate of the viewport offset


;;=========================================
;; Checks keyboard and scrolls the map
;;=========================================
map2_update::
  ;;-- Check for key 'D' being pressed
  ld hl, #Key_D               ;;-- hl = Key_D Keycode
  call cpct_isKeyPressed_asm
  ret z

    ;;-- D is pressed
    call map2_scrollRight
  
  ret

;;=========================================
;; Scrolls the map to the right
;;=========================================
map2_scrollRight::
  ld hl, (viewp_ptr)
  inc hl
  ld (viewp_ptr), hl
  
  ret

;;=========================================
;; Map initialization
;;=========================================
map2_initialize::

  ;;-- Draw the map
  ;;-- Configure the tileset
  ld hl,#_g2_tileset
  call cpct_etm_setTileset2x4_asm

  ret

;;=========================================
;; Draw the map
;;=========================================
map2_draw::

  ;;-- Draw the level0
  ld hl, (viewp_ptr)
  push hl
  ld hl,#0xC000
  push hl
  ld bc,#0x0000   ;;-- Tile 0,0
  ld de,#0x1128   ;;-- Height/Width in tiles (of the map)
  ld a,#map2_width   ;;-- Number of tiles in the row
  call cpct_etm_drawTileBox2x4_asm  ;; Draw the map!!
  ret