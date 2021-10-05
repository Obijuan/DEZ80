;; Rellenar toda la memoria de video

org #4000
run #4000

ld hl, #C000  ;; Primera direccion de la memoria de video

ld b,#45
repetir2:

ld a,#F0  ;; Contador: posiciones a rellenar
repetir:

  ;--- Pintar 4 pixeles ojos
  ld (hl), #FF

  inc hl ;-- Apuntar a la siguiente posicion
  dec a  ;-- Decrementar contador

  jr nz, repetir

dec b
jr nz, repetir2
  
;; Terminar (Bucle infinito)
jr $

