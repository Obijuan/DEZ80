.area _DATA
.area _CODE

.include "hero.h.s"
.include "ball.h.s"
.include "obstacle.h.s"
.include "cpctelera.h.s"
.globl _sprite_palette
.globl _g_tileset
.globl _level0

;;============================================
;; GAME INITIALIZATION
;;============================================
initialize_game:
  ;;-- Disable Amstrad firmware. Needed for changing
  ;;-- the video mode
  call cpct_disableFirmware_asm

  ;;-- Change the video modeo to 0 (160x200 16 colors)
  ld c,#0
  call cpct_setVideoMode_asm

  ;;-- Change the color palette
  ld hl, #_sprite_palette
  ld de, #16
  call cpct_setPalette_asm

  ;;-- Draw the map
  ;;-- Configure the tileset
  ld hl,#_g_tileset
  call cpct_etm_setTileset2x4_asm

  ;;-- Draw the level0
  ld hl, #_level0
  push hl
  ld hl,#0xC000
  push hl
  ld bc,#0x0000   ;;-- Tile 0,0
  ld de,#0x2028   ;;-- Height/Width in tiles (of the map)
  ld a,#0x28      ;;-- Number of tiles in the row
  call cpct_etm_drawTileBox2x4_asm  ;; Draw the map!!
  ret

;;===============================
;;  Main program entry
;;===============================
_main::
  call initialize_game

  main_loop:

    call hero_erase     ;; Erase the hero
    call obstacle_erase ;; Erase the bullet
    call ball_erase     ;; Erase the ball

    call hero_update     ;; Update the Hero
    call obstacle_update ;; Update the bullet
    call ball_update     ;; Update the ball

    ;;-- Check colision
    call hero_getPtrHL
    call obstacle_checkCollision
    ld (0xC000),a        ;;-- Draw collision
    ld (0xC001),a 
    ld (0xC002),a
    ld (0xC003),a

    call hero_draw      ;;-- Draw the hero
    call obstacle_draw  ;;-- Draw the bullet
    call ball_draw      ;;-- Draw the ball
  
    ;;-- Wait for the raster to finish
    call cpct_waitVSYNC_asm
    
    jr main_loop
