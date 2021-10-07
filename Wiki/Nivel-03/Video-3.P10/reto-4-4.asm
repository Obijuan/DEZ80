;;-- Reto 4.4: Colision con los barriles

org #4000
run main


;;===================
;;  VARIABLES
;;===================

;; Posicion de la vagoneta (0 - 79)
vagoneta_pos:
  db 0

barril1_pos:
  db 0

barril2_pos:
  db 0

tecla_start:
  db 47   ;;-- 47:Spacio

tecla_reset:
  db 50  ;;-- 50: Tecla R

tecla_derecha:
  db  27 ;; Tecla P

tecla_izquierda:
  db 34  ;; Tecla O

;;====================
;; MAIN
;;====================
main:

   ;;-- Inicializar variables
   ld a, 40
   ld (vagoneta_pos), a

   ld a, 12
   ld (barril1_pos),a
 
   ld a,60
   ld (barril2_pos),a

   ;;-- Borrar el escenario anterior
   call borrar_escenario

   ;; Dibujar el suelo
   call dibujar_suelo

   ;; Dibujar vagoneta
   call dibujar_vagoneta

   ;;-- Dibujar barriles
   call dibujar_barril1
   call dibujar_barril2

   ;;-- Bucle principal
  bucle_main:
    
     ;;-- Comprobar las teclas pulsadas
     call leer_teclas

     ;;-- Comprobar colisiones
     ;;  vagoneta_pos == barril1_pos?
     ld a, (barril1_pos)
     ld b, a
     ld a, (vagoneta_pos)
     cp b
     jr z, colision

     ;; vagoneta_pos == barril2_pos?
     ld a, (barril2_pos)
     ld b, a
     ld a, (vagoneta_pos)
     cp b
     jr z, colision

     jr bucle_main

colision:
     
  ;;-- Inicializar HL con la posicion 0
  ld hl, #C410

  ;;-- Calcular la direccion de video sumando la posicion
  ld a, (vagoneta_pos)
  add l
  ld l,a  ;;-- L = L + barril1_pos
  call animacion_explosion
    
muerto:

  ;;-- Comprobar tecla de reinicio
  ld a, (tecla_reset)
  call #BB1E
  jr nz, main

   jr muerto

;;========================================
;;  Rutina de teclado. Comprobar que teclas se han pulsado  
;; y llamar a las rutinas correspondientes
;;========================================
leer_teclas:

     ;;-- Comprobar tecla ir a la derecha
     ld a, (tecla_derecha)
     call #BB1E
     jr nz, mover_derecha

     ;;-- Comprobar tecla ir a la izquierda
     ld a, (tecla_izquierda)
     call #BB1E
     jr nz, mover_izquierda

     ;;-- Terminar
     jr leer_teclas_fin


  ;;-- Mover a la izquierda
  mover_izquierda:
    ld b,#FF  ;;  (b=-1)
    call mover_vagoneta
    jr leer_teclas_fin

  ;;-- Mover a la derecha
  mover_derecha:
     ld b,1
     call mover_vagoneta

  ;;-- Fin de la rutina
leer_teclas_fin:

  ret

;;========================================
;; Mover la vagoneta 4 pixeles a la izquierda o la derecha
;;
;; ENTRADA:
;;   B: Incremento a aplicar:  1 (derecha). -1 (izquierda)
;;
;; MODIFICA:
;;   HL, B, A
;;========================================
mover_vagoneta:

    ;;-- Borrar la vagoneta
    call borrar_vagoneta

    ;;-- Incrementar la posicion de la vagoneta
    ld a, (vagoneta_pos)
    add b
    ld (vagoneta_pos), a

    ;;-- Dibujar la vagoneta en la nueva posicion
    call dibujar_vagoneta

    ;;-- Esperar
    ld b, #6
    call wait

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

;========================================
;; Animacion explosion
;;
;; ENTRADAS:
;;   HL: posicion memoria video donde dibujar
;;
;; MODIFICA:
;;
;;========================================
animacion_explosion:
  
  ;;-- Fotograma 1
  call dibujar_explosion_1

  ld b,#20
  call wait

  ;;-- Fotograma 2
  call dibujar_explosion_2

  ld b,#20
  call wait

  ;;-- Fotograma 3
  call dibujar_explosion_3

  ld b,#20
  call wait

  ;;-- Fotograma 4 (Blanco)
  call borrar_sprite_8x8

  ret


;;========================================
;; Dibujar fotograma 3 explosion
;;
;;========================================
dibujar_explosion_3:
  ;;-- Fila 1
  ld (hl), #77  ;;-- Izquierdo
  inc hl
  ld (hl), #EE  ;;-- Derecho

  ;;-- Fila 2
  ld h, #CC
  ld (hl), #55  ;;-- Derecho
  dec hl
  ld (hl), #AA  ;;-- Izquierdo

  ;;-- Fila 3
  ld h, #D4
  ld (hl), #CC  ;;-- Izquierdo
  inc hl
  ld (hl), #33  ;;-- Derecho

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #11  ;;-- Derecho
  dec hl
  ld (hl), #88  ;;-- Izquierdo

 ;;-- Fila 5
  ld h, #E4
  ld (hl), #88 ;;-- Izquierdo
  inc hl
  ld (hl), #11  ;;-- Derecho

  ;;-- Fila 6
  ld h, #EC
  ld (hl), #33  ;;-- Derecho
  dec hl
  ld (hl), #CC  ;;-- Izquierdo

  ;;-- Fila 7
  ld h, #F4
  ld (hl), #AA  ;;-- Izquierdo
  inc hl
  ld (hl), #55  ;;-- Derecho

  ;;-- Fila 8
  ld h, #FC
  ld (hl), #EE  ;;-- Derecho
  dec hl
  ld (hl), #77  ;;-- Izquierdo

  ;;-- Volver a fila 1
  ld h, #C4

  ret



;;========================================
;; Dibujar fotograma 2 explosion
;;
;;========================================
dibujar_explosion_2:
  ;;-- Fila 1
  ld (hl), #F8  ;;-- Izquierdo
  inc hl
  ld (hl), #F1  ;;-- Derecho

  ;;-- Fila 2
  ld h, #CC
  ld (hl), #FA  ;;-- Derecho
  dec hl
  ld (hl), #F5  ;;-- Izquierdo

  ;;-- Fila 3
  ld h, #D4
  ld (hl), #D1  ;;-- Izquierdo
  inc hl
  ld (hl), #B8  ;;-- Derecho

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #76  ;;-- Derecho
  dec hl
  ld (hl), #E6  ;;-- Izquierdo

 ;;-- Fila 5
  ld h, #E4
  ld (hl), #E6 ;;-- Izquierdo
  inc hl
  ld (hl), #76  ;;-- Derecho

  ;;-- Fila 6
  ld h, #EC
  ld (hl), #B8  ;;-- Derecho
  dec hl
  ld (hl), #D1  ;;-- Izquierdo

  ;;-- Fila 7
  ld h, #F4
  ld (hl), #F5  ;;-- Izquierdo
  inc hl
  ld (hl), #FA  ;;-- Derecho

  ;;-- Fila 8
  ld h, #FC
  ld (hl), #F1  ;;-- Derecho
  dec hl
  ld (hl), #F8  ;;-- Izquierdo

  ;;-- Volver a fila 1
  ld h, #C4

  ret

;;========================================
;; Dibujar fotograma 1 explosion
;;
;;========================================
dibujar_explosion_1:
  ;;-- Fila 1
  ld (hl), #80  ;;-- Izquierdo
  inc hl
  ld (hl), #10  ;;-- Derecho

  ;;-- Fila 2
  ld h, #CC
  ld (hl), #E2  ;;-- Derecho
  dec hl
  ld (hl), #74  ;;-- Izquierdo

  ;;-- Fila 3
  ld h, #D4
  ld (hl), #72  ;;-- Izquierdo
  inc hl
  ld (hl), #E4  ;;-- Derecho

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #E8  ;;-- Derecho
  dec hl
  ld (hl), #71  ;;-- Izquierdo

 ;;-- Fila 5
  ld h, #E4
  ld (hl), #71  ;;-- Izquierdo
  inc hl
  ld (hl), #E8  ;;-- Derecho

  ;;-- Fila 6
  ld h, #EC
  ld (hl), #E4  ;;-- Derecho
  dec hl
  ld (hl), #72  ;;-- Izquierdo

  ;;-- Fila 7
  ld h, #F4
  ld (hl), #74  ;;-- Izquierdo
  inc hl
  ld (hl), #E8  ;;-- Derecho

  ;;-- Fila 8
  ld h, #FC
  ld (hl), #10  ;;-- Derecho
  dec hl
  ld (hl), #80  ;;-- Izquierdo

  ;;-- Volver a fila 1
  ld h, #C4
  ret

;========================================
;; Dibujar barril1 
;;
;; MODIFICA:
;;
;; HL, A
;;========================================
dibujar_barril1:
   ;;-- Inicializar HL con la posicion 0
  ld hl, #C410

  ;;-- Calcular la direccion de video sumando la posicion
  ld a, (barril1_pos)
  add l
  ld l,a  ;;-- L = L + barril1_pos

  ;-- Dibujar el sprite del barril
  call dibujar_barril
  ret

;========================================
;; Dibujar barril2
;;
;; MODIFICA:
;;
;; HL, A
;;========================================
dibujar_barril2:
   ;;-- Inicializar HL con la posicion 0
  ld hl, #C410

  ;;-- Calcular la direccion de video sumando la posicion
  ld a, (barril2_pos)
  add l
  ld l,a  ;;-- L = L + barril2_pos

  ;-- Dibujar el sprite del barril
  call dibujar_barril
  ret

;========================================
;; Dibujar barril en la memoria de video indicada por HL
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


;;-------------------------------------------------------------
;; Borrar la vagoneta
;;
;; MODIFICA: 
;; -HL, A
;;--------------------------------------------------------------
borrar_vagoneta:
    ;;-- Inicializar HL con la posicion 0
  ld hl, #C410

  ;;-- Calcular la direccion de video sumando la posicion
  ld a, (vagoneta_pos)
  add l
  ld l,a  ;;-- L = L + vagoneta_pos

  call borrar_sprite_8x8
  ret

;;-------------------------------------------------------------
;; Dibujar Vagoneta en la posicion indicada
;;  por su variable de posicion: 
;;   vagoneta_pos
;;
;; MODIFICA: 
;; -HL, A
;;--------------------------------------------------------------
dibujar_vagoneta:

  ;;-- Inicializar HL con la posicion 0
  ld hl, #C410

  ;;-- Calcular la direccion de video sumando la posicion
  ld a, (vagoneta_pos)
  add l
  ld l,a  ;;-- L = L + vagoneta_pos
  
  ;;-- Dibujar la vagoneta en esa posicion

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

  ret

;;=====================================
;; Borrar escenario: todo lo que esta encima del suelo
;;
;; MODIFICA:
;;   hl,A
;;=====================================
borrar_escenario:
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

;;-----------------------------------------------------------
;; Borrar el sprite 8x8 situado en la posicion dada
;; por HL
;;
;; ENTRADAS: 
;;   HL: Posicion donde borrar (Memoria video)
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

  ld hl, #C460  ;; Posicion inicial del suelo (Memoria video)

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
;;     (en memoria de video)
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


