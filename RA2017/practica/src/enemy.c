
//.macro defineEntity name, x, y, w, h, spr, spr1
//  name'_data:
//  name'_x:        .db x    ;;-- position (in bytes [0-79])
//  name'_y:        .db y    ;;-- y posicion (in pixels [0-199])
//  name'_w:        .db w    ;;-- Width in bytes
//  name'_h:        .db h    ;;-- Height in bytes
//  name'_sprite:   .dw spr  ;;-- (+4) Pointer to the sprite
//  name'_sprite_1: .dw spr1 ;;-- Secon sprite
//  name'__sn:      .db 0    ;;-- Sprite number to draw (0,1)
//  name'_cnt:      .db CNT_INI    ;;-- Animation counter
//  name'_jump:    .db #-1  ;;-- Are we jumping? 
//.endm

#include <cpctelera.h>

typedef struct {
    u8 x, y;
    u8 w, h;
    u8* spr;
    u8* spr1;
    u8 sn;
    u8 cnt;
    u8 jump;
} TEntity ;

void moveEnemy(TEntity* enemy, TEntity* myself) {

  if (myself->x < enemy->x) {
      --enemy->x;
  } else if (myself->x > enemy->x) {
      ++enemy->x;
  }
}
 
