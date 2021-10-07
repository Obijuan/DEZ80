;;-- Desafio. DIFICULTAD 1

org #4000
run main

;;=============
;; VARIABLES
;;=============

;;-- Posicion del personaje
hero_pos:
db 0

tecla_reset:
  db 50  ;;-- 50: Tecla R

tecla_derecha:
  db  27 ;; Tecla P

tecla_izquierda:
  db 34  ;; Tecla O

;;============
;; MAIN
;;============
main:
  ;;-- Inicializar variables
  ld a, 20
  ld (hero_pos), a 

   ;;-- Borrar el escenario anterior
   call borrar_escenario

   ;; Dibujar el suelo
   call dibujar_suelo

   ;; Dibujar personaje
   ld a,(hero_pos)
   call calcular_pos
   call dibujar_hero_der

    ;;-- Pausa inicial
    ld b, #80
    call wait

   ;;-- Bucle principal
   main_loop:

      ;;-- Comprobar tecla de RESET
      ld a, (tecla_reset)
      call #BB1E
      jr nz, main

      ;;-- Comprobar tecla ir a la derecha
      ld a, (tecla_derecha)
      call #BB1E
      jr nz, mover_derecha

      ;;-- Comprobar tecla ir a la izquierda
     ld a, (tecla_izquierda)
     call #BB1E
     jr nz, mover_izquierda

     jr main_loop

    ;;-- Mover a la izquierda
    mover_izquierda:
      
      ;;-- Comprobar si personaje esta en posicion inicial
      ;;-- Si es asi no se permite su movimiento
      ld a,(hero_pos)
      cp 0
      jr z, main_loop

      ;-- Mover a la izquierda
      ld b,#FF  ;;  (b=-1)
      call mover_hero
      jr main_loop

    ;;-- Tecla: Ir a la derecha
    mover_derecha:

      ;;-- Comprobar si personaje esta en posicion final
      ;;-- Si es asi, no se permite su movimiento
      ld a,(hero_pos)
      cp 79
      jr z, main_loop

      ;;-- Mover a la derecha
      ld b,#1
      call mover_hero
      jr main_loop


;;========================================
;; Mover Personaje 4 pixeles a la izquierda o la derecha
;;
;; ENTRADA:
;;   B: Incremento a aplicar:  1 (derecha). -1 (izquierda)
;;
;; MODIFICA:
;;   HL, B, A
;;========================================
mover_hero:

    ;;-- Borrar personaje anterior
    ld a,(hero_pos)
    call calcular_pos
    call borrar_sprite_8x8

    ;;-- Actualizar posicion personaje
    ld a, (hero_pos)
    add b
    ld (hero_pos), a

    ;;-- Dibujar el personaje mirando en la direccion correcta
    dec b
    jr z, mirar_derecha

    ;;-- Mirar izquierda
    call calcular_pos
    call dibujar_hero_izq
    jr cont

mirar_derecha:
   ;;-- Dibujar personaje en nueva posicion
   call calcular_pos
   call dibujar_hero_der

cont:
    ;;-- Esperar
    ld b, #8
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

;;===================================
;; Calcular la direccion de la memoria de VIDEO
;; a partir de la posicion x
;;
;; ENTRADA:
;;    A: Posicion x (0-79)
;;
;; SALIDA:
;;    HL: Posicion en la memoria de video
;;
;; MODIFICA
;; -
;;===================================
calcular_pos:

  ;;-- Direccion base de la memoria de video
  ld hl, #C410

  ;;-- L = L + A
  add l
  ld l,a

  ret

;;-------------------------------------------------------------
;; Dibujar personaje en la posicion indicada
;; en el registro a
;;
;; ENTRADA:
;;    A: Posicion del personaje
;;
;; MODIFICA: 
;; -HL, A
;;--------------------------------------------------------------
dibujar_hero_der:

  ;;-- Fila 1
  ld (hl), #EE 

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#9F
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #8B 

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #8F

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #AE 
 
  ;;-- Fila 6
  ld h, #EC
  ld (hl), #E0 

  ;;-- Fila 7
  ld h, #F4  
  ld (hl), #4A
  
  ;;-- Fila 8
  ld h, #FC 
  ld (hl), #AA 
  ret

;-------------------------------------------------------------
;; Dibujar personaje en la posicion indicada
;; en el registro a
;;
;; ENTRADA:
;;    A: Posicion del personaje
;;
;; MODIFICA: 
;; -HL, A
;;--------------------------------------------------------------
dibujar_hero_izq:

  ;;-- Fila 1
  ld (hl), #77 

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#9F
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #1D 

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #1F

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #57 
 
  ;;-- Fila 6
  ld h, #EC
  ld (hl), #70 

  ;;-- Fila 7
  ld h, #F4  
  ld (hl), #27
  
  ;;-- Fila 8
  ld h, #FC 
  ld (hl), #55 
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


