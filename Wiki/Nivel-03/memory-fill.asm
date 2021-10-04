;; Rellenar toda la memoria de video

org #4000
run #4000

ld hl, #C000  ;; Primera direccion de la memoria de video

ld a,#7F  ;; Contador: posiciones a rellenar

repetir:

;--- Pintar 4 pixeles ojos
ld (hl), #FF

inc hl ;-- Apuntar a la siguiente posicion
dec a  ;-- Decrementar contador

jr nz, repetir

;; Terminar (Bucle infinito)
jr $

