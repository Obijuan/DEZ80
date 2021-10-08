;;-- Desafio. DIFICULTAD 1

org #4000
run main

;;=============
;; VARIABLES
;;=============

;;-- Posicion del personaje
hero_pos:
db 0

;;-- Orientacion del persona
;;  1: Mirando a la derecha
;; -1: Mirando a la izquierda
hero_dir:
db 0

;;-- Posiciones de los barriles
barril1_pos:
db 0

barril2_pos:
db 0

barril3_pos:
db 0

barril4_pos:
db 0

tecla_reset:
  db 50  ;;-- 50: Tecla R

tecla_derecha:
  db  27 ;; Tecla P

tecla_izquierda:
  db 34  ;; Tecla O

tecla_patada:
  db 47   ;;-- 47:Spacio

;;============
;; MAIN
;;============
main:
  ;;-- Inicializar variables
  ld a, 20
  ld (hero_pos), a 

  ;;-- Personaje mirando hacia la derecha
  ld a, 1
  ld (hero_dir),a

  ;;-- Posiciones iniciales de los barriles
  ld a,10
  ld (barril1_pos),a
  ld a,17
  ld (barril2_pos),a
  ld a,50
  ld (barril3_pos),a
  ld a,60
  ld (barril4_pos),a

   ;;-- Borrar el escenario anterior
   call borrar_escenario

   ;; Dibujar el suelo
   call dibujar_suelo

   ;; Dibujar personaje
   call dibujar_hero

   ;; Dibujar barriles
   call dibujar_barriles

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

     ;;-- Comprobar la tecla para dar una patada
     ld a, (tecla_patada)
     call #BB1E
     jr nz, dar_patada

     jr main_loop

   ;;-- Dar patada
   dar_patada:
     call dibujar_hero_patada

     ld b,#20  ;;-- Wait
     call wait

     ;; Dibujar personaje
     call dibujar_hero
     
     jr main_loop

    ;;-- Mover a la izquierda
    mover_izquierda:
      
      ;;-- Establecer nueva orientacion
      ld a,-1
      ld (hero_dir),a

      ;;-- Comprobar si personaje esta en posicion inicial
      ;;-- Si es asi no se permite su movimiento
      ld a,(hero_pos)
      cp 0
      jr z, main_loop

      ;-- Mover a la izquierda
      call mover_hero
      jr main_loop

    ;;-- Tecla: Ir a la derecha
    mover_derecha:

      ;;-- Establecer nueva orientacion: hacia la derecha
      ld a,1
      ld (hero_dir),a

      ;;-- Comprobar si personaje esta en posicion final
      ;;-- Si es asi, no se permite su movimiento
      ld a,(hero_pos)
      cp 79
      jr z, main_loop

      ;;-- Mover a la derecha
      call mover_hero
      jr main_loop


;;=============================================
;;  Dibujar todos los barriles a partir de sus variables
;;  * barril1_pos
;;  * barril2_pos
;;  * barril3_pos
;;  * barril4_pos
;;=============================================
dibujar_barriles:

  ;;-- Barril 1
  ld a,(barril1_pos)
  call calcular_pos
  call dibujar_barril

  ;;-- Barril 2
  ld a,(barril2_pos)
  call calcular_pos
  call dibujar_barril

;;-- Barril 3
  ld a,(barril3_pos)
  call calcular_pos
  call dibujar_barril

;;-- Barril 4
  ld a,(barril4_pos)
  call calcular_pos
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


;;========================================
;; Dibujar el personaje segun el estado indicado por 
;; sus variables:
;;  * hero_pos: Indica la posicion (0-79)
;;  * hero_dir: Indica la orientacion (-1, 1)
;; MODIFICA:
;;
;;=========================================
dibujar_hero:
  ;;-- Obtener posicion del personaje y calcular su direccion
  ;;-- de video en HL
  ld a,(hero_pos)
  call calcular_pos

  ;;-- Leer su orientacion
  ld a,(hero_dir)
  
  ;;-- Segun su orientacion se dibuja mirando hacia un lado
  ;;-- u otro
  dec a
  jr z, orientacion_derecha  ;;-- Si A=1, Pintar mirando a la derecha

  ;;-- Pintar mirando a la izquierda
  call dibujar_hero_izq
  jr fin_dibujar_hero

  ;;-- Pintar mirando a la derecha
  orientacion_derecha:
  call dibujar_hero_der  

  fin_dibujar_hero:
  ret

;;========================================
;; Dibujar el personaje danto una patada segun el estado indicado por 
;; sus variables:
;;  * hero_pos: Indica la posicion (0-79)
;;  * hero_dir: Indica la orientacion (-1, 1)
;; MODIFICA:
;;
;;=========================================
dibujar_hero_patada:
  ;;-- Obtener posicion del personaje y calcular su direccion
  ;;-- de video en HL
  ld a,(hero_pos)
  call calcular_pos

  ;;-- Leer su orientacion
  ld a,(hero_dir)
  
  ;;-- Segun su orientacion se dibuja mirando hacia un lado
  ;;-- u otro
  dec a
  jr z, orientacion_pat_derecha  ;;-- Si A=1, Pintar mirando a la derecha

  ;;-- Pintar mirando a la izquierda
  call dibujar_hero_patada_izq
  jr fin_dibujar_hero_pat

  ;;-- Pintar mirando a la derecha
  orientacion_pat_derecha:
  call dibujar_hero_patada_der  

  fin_dibujar_hero_pat:
  ret

;;========================================
;; Mover Personaje 4 pixeles a la izquierda o la derecha
;; Se actualiza su posicion y se dibuja segun su orientacion
;;
;; MODIFICA:
;;   HL, B, A
;;========================================
mover_hero:

    ;;-- Borrar personaje anterior
    ld a,(hero_pos)
    call calcular_pos
    call borrar_sprite_4x8

    ;;-- Actualizar posicion personaje
    ;;-- hero_pos = hero_pos + hero_dir
    ld a,(hero_dir)
    ld b,a
    ld a,(hero_pos)
    add b
    ld (hero_pos),a
    
    ;;-- Dibujar personaje
    call dibujar_hero

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

;-------------------------------------------------------------
;; Dibujar personaje dando una patada hacia  
;; la izquierda. Se coloca en la posicion indicada
;; en el registro HL
;;
;; ENTRADA:
;;    HL: Memoria de video del personaje
;;
;; MODIFICA: 
;; -HL, A
;;--------------------------------------------------------------
dibujar_hero_patada_izq:

  ;;-- Fila 1
  ld (hl), #FF 

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#17
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #1D

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #71

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #02
 
  ;;-- Fila 6
  ld h, #EC
  ld (hl), #B8

  ;;-- Fila 7
  ld h, #F4  
  ld (hl), #FE
  
  ;;-- Fila 8
  ld h, #FC 
  ld (hl), #11
  ret

;;-------------------------------------------------------------
;; Dibujar personaje dando una patada hacia  
;; la derecha. Se coloca en la posicion indicada
;; en el registro HL
;;
;; ENTRADA:
;;    HL: Memoria de video del personaje
;;
;; MODIFICA: 
;; -HL, A
;;--------------------------------------------------------------
dibujar_hero_patada_der:

  ;;-- Fila 1
  ld (hl), #FF 

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#8E
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #8B

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #E8

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #04
 
  ;;-- Fila 6
  ld h, #EC
  ld (hl), #D1 

  ;;-- Fila 7
  ld h, #F4  
  ld (hl), #F7
  
  ;;-- Fila 8
  ld h, #FC 
  ld (hl), #88 
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
  ld a, 80
  borrar_next:

    ;;-- Borrar la posicion actual
    call borrar_sprite_4x8:

    ;;-- Incrementar hl para apuntar al siguiente sprinte
    inc hl

    dec a
    jr nz, borrar_next

  ret

;;-----------------------------------------------------------
;; Borrar el sprite 4x8 situado en la posicion dada
;; por HL
;;
;; ENTRADAS: 
;;   HL: Posicion donde borrar (Memoria video)
;;
;; MODIFICA:
;; -
;;------------------------------------------------------------
borrar_sprite_4x8:

   ;;-- Fila 1
  ld (hl), #00  
  
  ;;-- Fila 2
  ld h,#CC
  ld (hl),#00 
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #00  

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #00  

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #00 

  ;;-- Fila 6
  ld h, #EC
  ld (hl), #00  
  ;;-- Fila 7
  ld h, #F4  
  ld (hl), #00
  
  ;;-- Fila 8
  ld h, #FC  
  ld (hl), #00

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


