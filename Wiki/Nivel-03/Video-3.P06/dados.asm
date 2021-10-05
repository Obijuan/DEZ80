org #4000

run inicio

inicio:

ld a,2  ;;-- Numero de cara a dibujar
call dibuja_cara_A  ;;-- Dibujar la cara indicaa en A
jr $


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Dibujar la Cara indicada en el registro A
;;
;;  ENTRADA:
;;    A: Numero de cara a dibujar (1-6)
;;  MODIFICA:
;;    HL, A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dibuja_cara_A:

  ld hl, #C000  ;; Posicion donde dibujar la cara

  dec a           ;; Restar 1 a A
  jr z, era_un_1  ;-- Si A-1 = 0,entonces saltar

  ;;-- Comprobar si es 2
  dec a           ;;-- Restar 1 a A
  jr z, era_un_2  ; Si A-2 = 0, saltar

 ;;-- Es > 2
 ;; Comprobar si es 3
 dec a           ;; Restar 1 a A
 jr z, era_un_3  ; Si A-3 = 0, saltar

  ;; Es > 3
  ;; Comprobar si es 4
  dec a
  jr z, era_un_4

 ;; Es > 4
 ;; Comprobar si es 5
  dec a
  jr z, era_un_5

  call dibuja_cara_6
  jr fin

  era_un_5:
    call dibuja_cara_5
    jr fin

 era_un_4:
  call dibuja_cara_4
  jr fin

 era_un_3:
   call dibuja_cara_3
   jr fin

 era_un_2:
  call dibuja_cara_2
  jr fin

  era_un_1:
    call dibuja_cara_1

fin:
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dibuja un dado mostrando la cara 1, en la posicion 
;; en que se encuentra HL, asumiendo que esta en 
;; la primera fila de caracteres de pantalla (C000-C04A)
;; ENTRADA:
;;  HL: Posicion donde dibujar el dado
;; MODIFICA
;;  -
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dibuja_cara_1:

  ld (hl), #F0   ;; 4 Pixeles a la izquierda
  inc hl          ;; +1 Avanzar a la derecha
  ld (hl), #E0  ;; 4 Pixeles derecha
  ld h, #C8    ;; Bajar a fila 2

  ;; Fila 2
  ld (hl), #E0
  dec hl        ;;  -1 Retroceder a la izquierda
  ld (hl), #F0
  ld h, #D0  ; Bajar a fila 3

  ;; Fila 3
  ld (hl), #F3
  inc hl
  ld (hl), #E8
  ld h, #D8  ; Bajar a fila 4

  ;; Fila 4
  ld (hl), #E8
  dec hl
  ld (hl), #F3
  ld h, #E0  ; Bajar a fila 5

  ;; Fila 5
  ld (hl), #F3
  inc hl
  ld (hl), #E8 
  ld h, #E8  ; Bajar a fila 6

  ;; Fila 6
  ld (hl), #E0
  dec hl
  ld (hl), #F0
  ld h, #F0  ; Bajar a fila 7

  ;; Fila 7
  ld (hl), #F0
  inc hl
  ld (hl), #E0
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dibuja un dado mostrando la cara 2
;; ENTRADA:
;;  HL: Posicion donde dibujar el dado
;; MODIFICA
;;  -
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dibuja_cara_2:

ld (hl), #F0   ;; 4 Pixeles a la izquierda
inc hl          ;; +1 Avanzar a la derecha
ld (hl), #E0  ;; 4 Pixeles derecha
ld h, #C8    ;; Bajar a fila 2
ld (hl), #E0
dec hl        ;;  Retroceder a la izquierda
ld (hl), #F0
ld h, #D0  ; Bajar a fila 3
ld (hl), #F6
inc hl
ld (hl), #EC
ld h, #D8  ; Bajar a fila 4
ld (hl), #EC
dec hl
ld (hl), #F6
ld h, #E0  ; Bajar a fila 5
ld (hl), #F6
inc hl
ld (hl), #EC 
ld h, #E8  ; Bajar a fila 6
ld (hl), #E0
dec hl
ld (hl), #F0
ld h, #F0  ; Bajar a fila 7
ld (hl), #F0
inc hl
ld (hl), #E0
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dibuja un dado mostrando la cara 3
;; ENTRADA:
;;  HL: Posicion donde dibujar el dado
;; MODIFICA
;;  -
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dibuja_cara_3:

ld (hl), #F0   ;; 4 Pixeles a la izquierda
inc hl          ;; +1 Avanzar a la derecha
ld (hl), #E0  ;; 4 Pixeles derecha
ld h, #C8    ;; Bajar a fila 2
ld (hl), #EC
dec hl        ;;  Retroceder a la izquierda
ld (hl), #F6
ld h, #D0  ; Bajar a fila 3
ld (hl), #F6
inc hl
ld (hl), #EC
ld h, #D8  ; Bajar a fila 4
ld (hl), #E0
dec hl
ld (hl), #F0
ld h, #E0  ; Bajar a fila 5
ld (hl), #F1
inc hl
ld (hl), #E8 
ld h, #E8  ; Bajar a fila 6
ld (hl), #E8
dec hl
ld (hl), #F1
ld h, #F0  ; Bajar a fila 7
ld (hl), #F0
inc hl
ld (hl), #E0
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dibuja un dado mostrando la cara 4
;; ENTRADA:
;;  HL: Posicion donde dibujar el dado
;; MODIFICA
;;  -
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dibuja_cara_4:

ld (hl), #F0   ;; 4 Pixeles a la izquierda
inc hl          ;; +1 Avanzar a la derecha
ld (hl), #E0  ;; 4 Pixeles derecha
ld h, #C8    ;; Bajar a fila 2
ld (hl), #EC
dec hl        ;;  Retroceder a la izquierda
ld (hl), #F6
ld h, #D0  ; Bajar a fila 3
ld (hl), #F6
inc hl
ld (hl), #EC
ld h, #D8  ; Bajar a fila 4
ld (hl), #E0
dec hl
ld (hl), #F0
ld h, #E0  ; Bajar a fila 5
ld (hl), #F6
inc hl
ld (hl), #EC 
ld h, #E8  ; Bajar a fila 6
ld (hl), #EC
dec hl
ld (hl), #F6
ld h, #F0  ; Bajar a fila 7
ld (hl), #F0
inc hl
ld (hl), #E0
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dibuja un dado mostrando la cara 5
;; ENTRADA:
;;  HL: Posicion donde dibujar el dado
;; MODIFICA
;;  -
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dibuja_cara_5:

ld (hl), #F0   ;; 4 Pixeles a la izquierda
inc hl          ;; +1 Avanzar a la derecha
ld (hl), #E0  ;; 4 Pixeles derecha
ld h, #C8    ;; Bajar a fila 2
ld (hl), #EC
dec hl        ;;  Retroceder a la izquierda
ld (hl), #F6
ld h, #D0  ; Bajar a fila 3
ld (hl), #F0
inc hl
ld (hl), #E0
ld h, #D8  ; Bajar a fila 4
ld (hl), #E8
dec hl
ld (hl), #F1
ld h, #E0  ; Bajar a fila 5
ld (hl), #F0
inc hl
ld (hl), #E0 
ld h, #E8  ; Bajar a fila 6
ld (hl), #EC
dec hl
ld (hl), #F6
ld h, #F0  ; Bajar a fila 7
ld (hl), #F0
inc hl
ld (hl), #E0
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dibuja un dado mostrando la cara 6
;; ENTRADA:
;;  HL: Posicion donde dibujar el dado
;; MODIFICA
;;  -
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dibuja_cara_6:

ld (hl), #F0   ;; 4 Pixeles a la izquierda
inc hl          ;; +1 Avanzar a la derecha
ld (hl), #E0  ;; 4 Pixeles derecha
ld h, #C8    ;; Bajar a fila 2
ld (hl), #EC
dec hl        ;;  Retroceder a la izquierda
ld (hl), #F6
ld h, #D0  ; Bajar a fila 3
ld (hl), #F0
inc hl
ld (hl), #E0
ld h, #D8  ; Bajar a fila 4
ld (hl), #EC
dec hl
ld (hl), #F6
ld h, #E0  ; Bajar a fila 5
ld (hl), #F0
inc hl
ld (hl), #E0 
ld h, #E8  ; Bajar a fila 6
ld (hl), #EC
dec hl
ld (hl), #F6
ld h, #F0  ; Bajar a fila 7
ld (hl), #F0
inc hl
ld (hl), #E0
ret



