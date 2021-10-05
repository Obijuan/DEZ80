;; Video 3.P04
;; Animacion de una bola

org #4000
run #4000

;; Cargar en HL direccion de la memoria de video
ld hl, #C000

repetir:
  ;; Dibujar sprite de la bola
  ;; HL debe apuntar a la primera linea

  ld (hl), %01100000            ; Sprite bola Linea 1

  ld h, #C8                     ; Siguiente linea
  ld (hl), %11110110            ; Linea 2

  ld h, #D0
  ld (hl), %11110110            ; Linea 3

  ld h, #D8
  ld (hl), %01100000            ; Linea 4

  ld h,#C0                      ; HL apunta a la primera linea

;; *** Hacer una pausa **

ld b, 16
wait:
  halt    
  dec b
  jr nz, wait

;;  **** Borrar la bola ***

ld (hl), #00     ; Sprite bola Linea 1

ld h, #C8        ; Siguiente linea
ld (hl), #00     ; Linea 2

ld h, #D0
ld (hl), #00     ; Linea 3

ld h, #D8
ld (hl), #00     ; Linea 4

ld h,#C0         ; HL apunta a la primera linea

;; Avanzar a la siguiente posicion
inc hl

jp repetir

;; Bucle infinito (Terminar)
jr $

