;; Reto 2.1: Vagoneta en movimiento. BONUS: BuenaFrenada
;; La vagoneta se mueve si A=1
;; Se mueve hasta el centro
;; Si A=0 permanece parada
;; La vagoneta NO se para bruscametne, sino que frena

org #4000
run inicio

inicio:

;; Dibujar el suelo
call dibujar_suelo

;; Dibujar vagoneta en posicion inicial
ld hl, #C410
call dibujar_vagoneta

;; Asignar un valor a A
ld a, 1  ;;  1=Se mueve. 0=Se queda parada


;;-- Comprobar el valor de A
dec a
jr nz, parar   ; Si A-1 !=0, terminar (vagoneta parada)

;;-- A vale 1. Animar vagoneta!
call animar_vagoneta2
call animar_vagoneta_freno

parar:

;; Terminar (bucle infinito)
jr $


;;------------------------------------------------------------------
;; Animar la vagoneta con frenada
;;
;; ENTRADAS:
;;  HL: Posicion actual
;;
;; MODIFICA
;;  A,B
;;--------------------------------------------------------------------
animar_vagoneta_freno:

  ld a, #B  ;;-- Posiciones a avanzar con frenada
  ld c,#8   ;;-- Retardo inicial

  ;;-- Bucle de animacion
  next_pos_freno:
    
  ;;-- Borrar la vagoneta
    call borrar_sprite_8x8

    ;;-- Incrementar la posicion
    inc hl

    ;;-- Dibujar la vagoneta en la nueva posicion
    call dibujar_vagoneta

    ;;-- Ahora el retardo es variable
    ;;-- Se va incrementando
    ld b,c
    call wait

    inc c
    inc c
    inc c
    inc c
    inc c

    ;;-- Una posicion menos
    dec a
    jr nz, next_pos_freno

  ret

;;-------------------------------------------------------------
;; Animar la vagoneta
;;
;; ENTRADAS:
;;   HL: Posicion inicial (donde esta la vagoneta)
;;
;; MODIFICA
;;  B, A
;;-------------------------------------------------------------
animar_vagoneta2:

  ;;-- Contador de repeticiones
  ld a, #1D

  ;;-- Bucle de animacion
  next_pos:

    ;;-- Borrar la vagoneta
    call borrar_sprite_8x8

    ;;-- Incrementar la posicion
    inc hl

    ;;-- Dibujar la vagoneta en la nueva posicion
    call dibujar_vagoneta

    ;;-- Esperar
    ld b, #8
    call wait

    ;;-- Una posicion menos
    dec a
    jr nz, next_pos

    ;;-- Vagoneta ha finalizado el recorrido
  ret

;;-------------------------------------------------------------
;; Dibujar Vagoneta en posicion dada en HL
;; 
;; ENTRADAS:
;;   HL: Posicion de la vagoneta
;;
;; MODIFICA:
;; -
;;--------------------------------------------------------------
dibujar_vagoneta:

  ;;-- Fila 1
  ld (hl), #88  ;-- Izquierda
  inc hl
  ld (hl), #11  ;-- Derecha

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#F1  ;-- Derecha
  dec hl
  ld (hl),#F8 ; -- Izquierda
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #FE  ;-- Izquierda
  inc hl
  ld (hl), #F7  ;-- Derecha

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #FF  ;-- Derecha
  dec hl
  ld (hl), #FF  ;-- Izquierda

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #BB  ;-- Izquierda
  inc hl
  ld (hl), #DD ;-- Derecha

  ;;-- Fila 6
  ld h, #EC
  ld (hl), #8A  ;-- Derecha
  dec hl
  ld (hl), #15  ;-- Izquierda

  ;;-- Fila 7
  ld h, #F4  ;-- Izquierda
  ld (hl), #4A
  inc hl
  ld (hl), #25  ;-- Derecha
  
  ;;-- Fila 8
  ld h, #FC  ;-- Derecha
  ld (hl), #02
  dec hl
  ld (hl), #04 ;-- Izquierda

  ;;-- Establecer la posicion de partida en HL
  ld h, #C4   
  ret

;;-------------------------------------------------------------
;; Rutina de pausa
;;
;; ENTRADAS:
;;   B: Unidades a pausar (1 unidad = 3.3ms aprox)
;;
;; MODIFICA
;;  -
;;-------------------------------------------------------------
wait:

  halt
  dec b
  jr nz, wait

  ret

;;-----------------------------------------------------------
;; Borrar el sprite 8x8 situado en la posicion dada
;; por HL
;;
;; ENTRADAS: 
;;   HL: Posicion donde borrar
;;
;; MODIFICA:
;; -
;;------------------------------------------------------------
borrar_sprite_8x8:

   ;;-- Fila 1
  ld (hl), #00  ;-- Izquierda
  inc hl
  ld (hl), #00  ;-- Derecha

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#00  ;-- Derecha
  dec hl
  ld (hl),#00 ; -- Izquierda
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #00  ;-- Izquierda
  inc hl
  ld (hl), #00  ;-- Derecha

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #00  ;-- Derecha
  dec hl
  ld (hl), #00  ;-- Izquierda

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #00  ;-- Izquierda
  inc hl
  ld (hl), #00 ;-- Derecha

  ;;-- Fila 6
  ld h, #EC
  ld (hl), #00  ;-- Derecha
  dec hl
  ld (hl), #00  ;-- Izquierda

  ;;-- Fila 7
  ld h, #F4  ;-- Izquierda
  ld (hl), #00
  inc hl
  ld (hl), #00  ;-- Derecha
  
  ;;-- Fila 8
  ld h, #FC  ;-- Derecha
  ld (hl), #00
  dec hl
  ld (hl), #00 ;-- Izquierda

  ;;-- Establecer la posicion de partida en HL
  ld h, #C4   
  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dibujar el suelo. Esta compuesto por 160 
;; tiles de suelo
;;
;; ENTRADAS:
;;  Ninguna
;;
;; MODIFICA:
;; -HL, B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dibujar_suelo:

  ld hl, #C460  ;; Posicion inicial del suelo

  ld b, #50  ;; Numero de tiles a colocar

  next_tile:
    call dibujar_tile_suelo ;; Dibujar una baldosa
    inc hl  ;; Poner la proxima en la derecha
    dec b   ;; Queda una menos
    jr nz, next_tile  ;; Repetir si todavia quedan tiles por poner

  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dibujar el Tile del suelo en la fila 12
;; ENTRADAS:
;;   HL: Contiene la posicion donde dibujar el tile
;; MODIFICA:
;;  -
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dibujar_tile_suelo:

  
  ld (hl), #5F ;; Fila 1

  ld h,#CC    ;; Fila 2
  ld (hl), #40

  ld h, #D4   ;;  Fila 3
  ld (hl), #60

  ld h, #DC   ;; Fila 4
  ld (hl), #50

  ld h, #c4  ;; Posicionar de vuelta en la fila 1
  ret

