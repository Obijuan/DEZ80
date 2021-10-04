;; Reto 1.2: Sprite de la vagoneta  

org #4000
run #4000

;;-- Fila 12. Posicion 1: #C410

;-- Dibujar 8x4 pixeles izquierdos
ld hl,#C420
ld (hl), #88

ld h,#CC
ld (hl), #F8

ld h,#D4
ld (hl), #FE

ld h, #DC
ld (hl), #FF

ld h, #E4
ld (hl), #BB

ld h, #EC
ld (hl), #15

ld h, #F4
ld (hl), #4A

ld h, #FC
ld (hl), #04

;;-- Dibujar 8x4 pixeles derechos

inc hl

ld h,#C4
ld (hl), #11

ld h,#CC
ld (hl), #F1

ld h,#D4
ld (hl), #F7

ld h, #DC
ld (hl), #FF

ld h, #E4
ld (hl), #DD

ld h, #EC
ld (hl), #8A

ld h, #F4
ld (hl), #25

ld h, #FC
ld (hl), #02


;--- Terminar
jr $
