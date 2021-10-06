;; Reto 3.1: Barril 4x8

org #4000
run main


;;==============================
;; VARIABLES
;;==============================
tecla_start:
  db 47   ;;-- 47:Spacio

tecla_reset:
  db 50  ;;-- 50: Tecla R

vagoneta_home:
  dw #C410

barril_home:
  dw #C43A

main:

  ;; Borrar vagonetas: Eliminar vagonetas de la ejecucion anterior
  call borrar_vagonetas

  ;; Dibujar el suelo
  call dibujar_suelo

  ;; Dibujar vagoneta en posicion inicial
  ld hl, (vagoneta_home)
  call dibujar_vagoneta

  ;; Dibujar el barril
  ld hl, (barril_home)
  call dibujar_barril

  comprobar_teclado:

    ;;  Comprobar si se pulsa espacio
     ld a, (tecla_start)
     call #BB1E
     jr nz, espacio_pulsado  ;  Si Z no activo (tecla pulsada), saltar a pulsada

  ;;-- Tecla no pulsada. Repetir
  jr comprobar_teclado

  ;;-- Espacio pulsado! Animar vagoneta
  espacio_pulsado:

   ;;-- Recuperar posicion inicial de la vagoneta
   ld hl, (vagoneta_home)

    ;;--  Animar vagoneta!
    call animar_vagoneta

parar:

  ;; Comprobar el teclado
  ld a, (tecla_reset)
  call #BB1E
  jr nz, tecla_r_pulsada

  ;;-- Esperar a que se pulse tecla R
  jr parar

  tecla_r_pulsada:
    jr main

;;========================================
;; Dibujar barril
;;
;; ENTRADA:
;;   HL: Posicion del barril en memoria de video
;;
;; MODIFICA:
;;
;;========================================
dibujar_barril:

   ;;-- Fila 1
  ld (hl), #99

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#6F
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #9F  

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #FF  

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #6F

  ;;-- Fila 6
  ld h, #EC
  ld (hl), #9F  

  ;;-- Fila 7
  ld h, #F4 
  ld (hl), #F6
  
  ;;-- Fila 8
  ld h, #FC
  ld (hl), #60

  ;;-- Establecer la posicion de partida en HL
  ld h, #C4   
  ret

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
;;
;; MODIFICA
;;  B, 
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
    ld b, #6
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

