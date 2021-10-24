.area _DATA
.area _CODE
;;==============================================
;;==============================================
;; PRIVATE DATA
;;==============================================
;;==============================================

.include "cpctelera.h.s"
.globl _g_tileset
.globl _level0

;;-- Constants
map_width = 40
map_height = 32

;;-- Variables
viewp_ptr:  .dw #_level0  ;;-- Pointer of the viewport

;;=========================================
;; Map initialization
;;=========================================
map_initialize::

  ;;-- Draw the map
  ;;-- Configure the tileset
  ld hl,#_g_tileset
  call cpct_etm_setTileset2x4_asm

  ret

;;=========================================
;; Draw the map
;;=========================================
map_draw::

  ;;-- Draw the level0
  ld hl, (viewp_ptr)
  push hl
  ld hl,#0xC000
  push hl
  ld bc,#0x0000   ;;-- Tile 0,0
  ld de,#0x2028   ;;-- Height/Width in tiles (of the map)
  ld a,#0x28      ;;-- Number of tiles in the row
  call cpct_etm_drawTileBox2x4_asm  ;; Draw the map!!
  ret