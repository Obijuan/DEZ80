;; Reto 4.2: Mover a la izquierda

org #4000
run main


;;==============================
;; VARIABLES
;;==============================
tecla_start:
  db 47   ;;-- 47:Spacio

tecla_reset:
  db 50  ;;-- 50: Tecla R

tecla_derecha:
  db  27 ;; Tecla P

tecla_izquierda:
  db 34  ;; Tecla O

vagoneta_home:
  dw #C410

barril_home:
  dw #C43A

;;-- Posicion final de la vagoneta
pos_vagoneta:
  db #28

;;-- Posicion de la vagoneta en la memoria de video
pos_vagoneta_video:
  dw 00

;;========
;; MAIN
;;========
main:

  ;; Borrar vagonetas: Eliminar vagonetas de la ejecucion anterior
  call borrar_vagonetas

  ;; Dibujar el suelo
  call dibujar_suelo

  ;; Dibujar vagoneta en posicion inicial
  ld hl, (vagoneta_home)
  call dibujar_vagoneta

  ;;-- Dibujar los barriles
  call dibujar_barriles

  ;;-- Inicializar variables
  ld a,#28
  ld (pos_vagoneta), a  ;;-- Posicion inicial vagoneta
  ld hl, (vagoneta_home)
  ld (pos_vagoneta_video), hl ;;-- Posicion vagoneta en memoria video

  ;;-- Espera incial
  ld b, #80
  call wait

  ;;-- Bucle principal
  bucle_main:
    
     ;;-- Comprobar las teclas pulsadas
     call leer_teclas
     
     ;;-- Saltar al comienzo si el flag z NO esta activado
     ;;-- (Esto ocurre cuando se aprieta la tecla de reset)
     jr nz,main
    
     ;;-- Continuar con el bucle principal
     jr bucle_main
   

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

     ;;-- Comprobar tecla de reinicio
     ld a, (tecla_reset)
     call #BB1E
     jr nz, reiniciar

     ;;-- Terminar
     jr leer_teclas_fin

  ;;-- Reiniciar el juego
  reiniciar:
    or a  ;;-- Poner flag z a 0
    jr leer_teclas_fin

  ;;-- Mover a la izquierda
  mover_izquierda:
    call vagoneta_izquierda
    jr flag_z_set

  ;;-- Mover a la derecha
  mover_derecha:
     call vagoneta_derecha

flag_z_set:
  xor a ;;-- Poner flag z a 1

  ;;-- Fin de la rutina
leer_teclas_fin:

  ret

;;========================================
;; Mover la vagoneta 4 pixeles a la izquierda
;;
;; MODIFICA:
;;   HL, B, A
;;========================================
vagoneta_izquierda:

    ;;-- Recuperar posicion de la vagoneta
    ld hl, (pos_vagoneta_video)

    ;;-- Borrar la vagoneta
    call borrar_sprite_8x8

    ;;-- Decrementar la posicion
    dec hl

    ;;-- Dibujar la vagoneta en la nueva posicion
    call dibujar_vagoneta

    ;;-- Guardar la posicion de la vagoneta
    ld (pos_vagoneta_video), hl

    ;;-- Esperar
    ld b, #6
    call wait

    ;;-- Una posicion menos
    ld a, (pos_vagoneta)
    dec a
    ld (pos_vagoneta),a

  ret


;;========================================
;; Mover la vagoneta 4 pixeles a la derecha
;;
;; MODIFICA:
;;   HL, B, A
;;========================================
vagoneta_derecha:

    ;;-- Recuperar posicion de la vagoneta
    ld hl, (pos_vagoneta_video)

    ;;-- Borrar la vagoneta
    call borrar_sprite_8x8

    ;;-- Incrementar la posicion
    inc hl

    ;;-- Dibujar la vagoneta en la nueva posicion
    call dibujar_vagoneta

    ;;-- Guardar la posicion de la vagoneta
    ld (pos_vagoneta_video), hl

    ;;-- Esperar
    ld b, #6
    call wait

    ;;-- Una posicion menos
    ld a, (pos_vagoneta)
    dec a
    ld (pos_vagoneta),a

  ret

;;========================================
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

;;========================================
;; Dibujar barriles
;; 
;; MODIFICA:
;;  HL, A
;;========================================
dibujar_barriles:

   ;;-- Obtener posicion inicial en memoria de video
   ld hl, (barril_home)

   ;;-- Contador de barriles
   ld a, #13

   dibujar_sig_barril:

     ;; Dibujar un barril
     call dibujar_barril

     ;; Apuntar a la siguiente posicion
     inc hl
     inc hl

     ;;-- Un barril menos por dibujar
     dec a
     jr nz, dibujar_sig_barril

  ret

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

