;; Reto 1.3: Suelo de tiles  

org #4000
run #4000

;-- Dibujar Vagoneta
ld hl,#C410
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

;;-- Dibujar el rail

ld a, #50  ;; Contador para repeticion

ld l, #60  ;; Posicion inicial

repetir:
  ld h, #c4
  ld (hl), #5F

  ld h,#CC
  ld (hl), #40

  ld h, #D4
  ld (hl), #60

  ld h, #DC
  ld (hl), #50

  inc hl
  dec a
  jr nz, repetir

;--- Terminar
jr $
