.area _DATA
.area _CODE

.include "hero.h.s"
.include "ball.h.s"
.include "obstacle.h.s"
.include "map2.h.s"
.include "cpctelera.h.s"

;;===============================
;; Macro: Change the border color
;; Useful for debuging
;;===============================
.macro setBorder color
    ;;-- H: Set the color
    ;;-- L: 0x10 means Border color
    ld hl, #0x'color'10  ;-- The character ' is used for concatenating elements
    call cpct_setPALColour_asm
.endm

.globl _sprite_palette
.globl _song_princess7

; -- 1 out of 12 int the music is called
play_music: .db #12
color: .db 0x10

; isr:: 
;
;  ld l, #16  ;;-- Establecer color del borde
;  ld a, (color)
;  ld h, a
;  call cpct_setPALColour_asm
;  ld a, (color)
;  inc a
;  cp #0x16
;  jr nz, continue
;    ;;-- Reset color
;    ld a, #0x10
; 
;  continue:
;    ld (color),a 
;
;  ret

isr:
  ex af, af'
  exx
  push af
  push iy
  push bc
  push de
  push hl
    ;;-- Toggle the play_music variable
    ld a,(play_music)
    dec a
    ld (play_music), a
    jr nz, volver
    
    ;;-- Update the music!
    ;;-- It is refresh at the rate speed of 25Hz
    call cpct_akp_musicPlay_asm
    ld a, #12
    ld (play_music), a
  volver:
    pop hl
    pop de
    pop bc
    pop iy
    pop af
    exx
    ex af, af'
  ret

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

  ;;-- Initialize the music
  ld DE, #_song_princess7
  call cpct_akp_musicInit_asm

  ;;-- Set ISR
  ld hl, #isr
  call cpct_setInterruptHandler_asm

  ;;-- Map initialization
  call map2_initialize

  ret

;;===============================
;;  Main program entry
;;===============================
_main::
  ;;-- Stack initialization
  ld sp, #0x8000

  call initialize_game

  main_loop:

    setBorder 1

    call hero_erase     ;; Erase the hero
    call hero_update     ;; Update the Hero
    call map2_update      ;; Update the map

    setBorder 2
    call hero_draw      ;;-- Draw the hero
    call hero_draw
    call hero_draw
    setBorder 1

    call map2_getVieoPtr
    ex de,hl       ;;-- DE=Pointer to the videoBuffer
    call map2_draw
  
    ;;-- Wait for the raster to finish
    call cpct_waitVSYNC_asm

    ;;-- Switch the buffers
    call map2_switchBuffers

    jp main_loop


;-- Old main
;_main::
;  call initialize_game
;
;  main_loop:
;
;    setBorder 0
;
;    call hero_erase     ;; Erase the hero
;    ;call obstacle_erase ;; Erase the bullet
;    ;call ball_erase     ;; Erase the ball
;
;    call hero_update     ;; Update the Hero
;    call map2_update      ;; Update the map
;
;    setBorder 2
;    ;call obstacle_update ;; Update the bullet
;    ;call ball_update     ;; Update the ball
;
;    ;;-- Check colision
;    ;call hero_getPtrHL
;    ;call obstacle_checkCollision
;    ;ld (0xC000),a        ;;-- Draw collision
;    ;ld (0xC001),a 
;    ;ld (0xC002),a
;    ;ld (0xC003),a
;
;    call hero_draw      ;;-- Draw the hero
;
;    setBorder 0
;    call map2_draw
;
;    
;    ;call obstacle_draw  ;;-- Draw the bullet
;    ;call ball_draw      ;;-- Draw the ball
;  
;    ;;-- Wait for the raster to finish
;    call cpct_waitVSYNC_asm
;
;    jp main_loop
;
;
;
;
;