;; Video 3.P04
;; Animacion de una bola

org #4000
run #4000

;; Cargar en HL direccion de la memoria de video
ld hl, #C000

;; Dibujar sprite de la bola
;; HL debe apuntar a la primera linea

ld (hl), %01100000  ; Sprite bola Linea 1

ld h, #C8 ; Siguiente linea
ld (hl), %11110110 ; Linea 2


;; Bucle infinito (Terminar)
jr $