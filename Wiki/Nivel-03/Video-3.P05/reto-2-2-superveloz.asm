;; Reto 2.2. Movimiento de la vagoneta con teclas
;; BONUS: SuperVeloz
;; La vagoneta arranca con diferentes velocidades al apretar
;; las teclas 1 (lenta) - 5 (rapida)

org #4000
run main

main:

  ;; Borrar vagonetas: Eliminar vagonetas de la ejecucion anterior
  call borrar_vagonetas

  ;; Dibujar el suelo
  call dibujar_suelo

  ;; Dibujar vagoneta en posicion inicial
  ld hl, #C410
  call dibujar_vagoneta

   ;;-- Guardar posicion actual de la vagoneta
   push hl

  comprobar_teclado:

    ;;  Comprobar si se pulsa tecla 1
     ld a, 64
     call #BB1E
     jr nz, tecla_1_pulsada  ;; Tecla 1 : Velocidad lenta

    ;;-- Tecla 2?
    ld a, 65
    call #BB1E
    jr nz, tecla_2_pulsada

    ;;-- Tecla 3??
    ld a,57
    call #BB1E
    jr nz, tecla_3_pulsada

    ;;-- Tecla 4??
    ld a,56
    call #BB1E
    jr nz, tecla_4_pulsada   

    ;;-- Tecla 4??
    ld a,49
    call #BB1E
    jr nz, tecla_4_pulsada
   
    ;;-- Tecla 5??
    ld a,48
    call #BB1E
    jr nz, tecla_5_pulsada 


  ;;-- Tecla no pulsada. Repetir
  jr comprobar_teclado

  ;;-- Tecla 1: Velocidad lenta
tecla_1_pulsada:
  ld c,#40    ;;-- Establecer pausa
  jr animar   

tecla_2_pulsada:
  ld c, #30
  jr animar

tecla_3_pulsada:
  ld c, #20
  jr animar

tecla_4_pulsada:
  ld c, #10
  jr animar

tecla_5_pulsada:
  ld c, #6

animar:   
   ;;-- Recuperar posicion inicial de la vagoneta
   pop hl

    ;;--  Animar vagoneta!
    call animar_vagoneta

parar:

;; Terminar (bucle infinito)
jr $


;;=====================================
;; Borrar vagonetas. Pintar una linea de 8x8 pixeles de fondo
;; sobre el rail para eliminar vagonetas anteriores
;;
;; MODIFICA:
;;   hl,A
;;=====================================
borrar_vagonetas:
  ld hl, #C410

  ;;-- En la linea hay 40 caracteres
  ld a, 40
  borrar_next:

    ;;-- Borrar la posicion actual
    call borrar_sprite_8x8:

    ;;-- Incrementar hl en 2 para apuntar al siguiente sprinte
    inc hl
    inc hl

    dec a
    jr nz, borrar_next

  ret


;;-------------------------------------------------------------
;; Animar la vagoneta
;;
;; ENTRADAS:
;;   HL: Posicion inicial (donde esta la vagoneta)
;;   C: Pausa a realizar
;;
;; MODIFICA
;;  B, A, HL
;;-------------------------------------------------------------
animar_vagoneta:

  ;;-- Contador de repeticiones
  ld a, #28

  ;;-- Bucle de animacion
  next_pos:

    ;;-- Borrar la vagoneta
    call borrar_sprite_8x8

    ;;-- Incrementar la posicion
    inc hl

    ;;-- Dibujar la vagoneta en la nueva posicion
    call dibujar_vagoneta

    ;;-- Esperar
    ld b,c
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
