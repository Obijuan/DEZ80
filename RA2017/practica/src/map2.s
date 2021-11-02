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
videoPtr:   .dw #0xC000   ;;-- Video buffer address
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

  ld hl, #0x8000
  ld de, #0x8001
  ld (hl), #00
  ld bc, #0x4000
  ldir

  ret

;;=========================================
;; Draw the full map
;;
;; INPUTS:
;;   DE: Video memory location where to draw
;;=========================================
map2_draw::

  ;;-- Draw the level0
  ld hl, (viewp_ptr)   ;;-- Parameter for the cpct_etm_drawTileBox function
  push hl              ;;-- Insert tilemap data pointer
  push de              ;;-- Inser the videomemory location
  ld bc,#0x0000   ;;-- Tile 0,0
  ld de,#0x1128   ;;-- Height/Width in tiles (of the map)
  ld a,#map2_width   ;;-- Number of tiles in the row
  call cpct_etm_drawTileBox2x4_asm  ;; Draw the map!!
  ret

;;=========================================
;; Switches Video Buffers
;;=========================================
map2_switchBuffers::

  ;-- Self modifiyin code. It contains the address of the inmediate value 
  ;;-- to load in the l regiger
  modifier = . + 1
  ld l, #0x20  ;;-- 0x20 for memory address 0x8000, 0x30 for address 0xC0000 
  call cpct_setVideoMemoryPage_asm

  ;;-- Change the value (Next time it is called another values is used)
  ld hl, #modifier
  ld a, #0x10
  xor (hl)       ;-- Change between 0x20 and 0x30 values
  ld (modifier), a

  ;-- Change the current video pointer
  ld hl, #videoPtr+1
  ld a, #0x40
  xor (hl)
  ld (videoPtr+1), a

  ret

;;============================================
;; Returns video pointer in HL
;;
;; RETURN:
;;  HL: Pointer to the video memory
;;============================================
map2_getVieoPtr::
  ld hl, (videoPtr)
  ;ld hl, #0xC000
  ret

