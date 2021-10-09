;;-- Desafio. DIFICULTAD 2

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

;;-- Posicion de la llave
llave_pos:
db 0

;;-- Posicion de la puerta
puerta_pos:
db 0

;;-- Contador de barriles
contador_barriles:
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

  ;;-- Contador de barriles. Cada vez que se rompe uno
  ;;-- se decrementa el contador
  ld a,4   ;;-- 4
  ld (contador_barriles), a

  ;-- Posicion llave
  ld a,0
  ld (llave_pos), a

  ;-- Posicion puerta
  ld a,79
  ld (puerta_pos), a

  ;;-- Posiciones iniciales de los barriles
  ;;ld a,10
  ;;ld (barril1_pos),a
  ;;ld a,17
  ;;ld (barril2_pos),a
  ;;ld a,50
  ;;ld (barril3_pos),a
  ;;ld a,60
  ;;ld (barril4_pos),a

  ;;-- Posiciones iniciales de los barriles
  ld a,90
  ld (barril1_pos),a
  ld a,90
  ld (barril2_pos),a
  ld a,90
  ld (barril3_pos),a
  ld a,90
  ld (barril4_pos),a

   ;;-- Borrar el escenario anterior
   call borrar_escenario

   ;; Dibujar el suelo
   call dibujar_suelo

   ;; Dibujar personaje
   call dibujar_hero

   ;; Dibujar barriles
   call dibujar_barriles

   ;;-- Dibujar llave
   call dibujar_llave

   ;;-- Dibujar puerta
   call dibujar_puerta

    ;;-- Pausa inicial
    ld b, #80
    call wait

   ;;-- Bucle principal
   main_loop:

      ;;-- Comprobar colisiones
      call comprobar_colisiones
      jr z, estado_final

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

     ;;-- Comprobar la patada
     call comprobar_patada

     ;;-- Si Z=1, VICTORIA!
     jr z, victoria

     ;;-- Todavia quedan barriles
     ;;-- Completar la animacion y seguir

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

;;-- Estado de victoria! Dibujar el personaje en forma de victoria
;;-- y terminar
victoria:
  ld a,(hero_pos)
  call calcular_pos
  call dibujar_hero_victoria

  ;;-- Estado final: Se espera hasta que se pulse R para
  ;;-- reiniciar el juego. Aqui se llega bien porque nos han matado
  ;;-- o bien porque hemos terminado con Victoria
  estado_final:

    ;;-- Comprobar tecla de RESET
    ld a, (tecla_reset)
    call #BB1E
    jp nz, main
    
    jr estado_final


;;=======================================
;; Comprobar si la patada ha dado a un barril o no
;; SALIDA:
;;    z: 1=> Ya no quedan barriles!
;;    z=0: Quedan barriles
;;=======================================
comprobar_patada:

  ;;-- Si la posicion actual del persona le sumamos su
  ;;-- direccion (+1, -1) y es igual a la posicion de un barrill...
  ;;-- entonces ese barril debe morir!!!!

  ;;-- Leer orientacion  
  ld a,(hero_dir)
  ld b,a
  ;;-- Leer posicion actua
  ld a,(hero_pos)
  ;;-- Sumar posicion + orientacion
  add b

  ;;-- B = posicion de la patada
  ld b,a

  ;;-- Leer posicion del barril 2
  ld a,(barril2_pos)
  cp b
  jr z, romper_barril2

  ;;-- Leer posicion del barril 1
  ld a,(barril1_pos)
  cp b
  jr z, romper_barril1

  ;;-- Leer posicion del barril 3
  ld a,(barril3_pos)
  cp b
  jr z, romper_barril3

  ;;-- Leer posicion del barril 4
  ld a,(barril4_pos)
  cp b
  jr z, romper_barril4

  ;;-- Poner flag z a 0: quedan barriles todavia
  ld a,1
  or a
  jr comprobar_patada_fin

  romper_barril4:
    ld a,#90  ;-- La posicion 0x90 esta fuera de rango
    ld (barril4_pos), a
    jr romper_barril

  romper_barril3:
    ld a,#90  ;-- La posicion 0x90 esta fuera de rango
    ld (barril3_pos), a
    jr romper_barril

  romper_barril2:
    ld a,#90  ;-- La posicion 0x90 esta fuera de rango
    ld (barril2_pos), a
    jr romper_barril

  romper_barril1:
   ld a,#90
   ld (barril1_pos), a
   jr romper_barril

romper_barril:
  ;;-- Meter en a la posicion del barril
  ld a,b
  ;;-- Calcular la direccion de video
  call calcular_pos
  
  ;;-- Animacion del barril rompiendose
  ;;-- Fotograma 1
  call dibujar_barril_roto_1
  
  ld b,#20
  call wait

  call dibujar_barril_roto_2

  ld b,#20
  call wait

  call dibujar_barril_roto_3

  ld b,#20
  call wait

   call borrar_sprite_4x8

  ;;-- Decrementar el contador de barriles
  ld a,(contador_barriles)
  dec a
  ld (contador_barriles),a

  ;;-- Si todavia quedan barriles, terminar...
  jr nz, comprobar_patada_fin

  ;--- YA NO HAY BARRILES!
  ;-- Poner flag Z a 1
  xor a

comprobar_patada_fin:
  
  ret

;-------------------------------------------------------------
;; Dibujar llave 
;;--------------------------------------------------------------
dibujar_puerta:

  ld a,(puerta_pos)
  call calcular_pos

  ;;-- Fila 1
  ld (hl), #06

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#6F
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #FF

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #FF

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #F3
 
  ;;-- Fila 6
  ld h, #EC
  ld (hl), #FB

  ;;-- Fila 7
  ld h, #F4  
  ld (hl), #FF
  
  ;;-- Fila 8
  ld h, #FC 
  ld (hl), #FF
  ret

;-------------------------------------------------------------
;; Dibujar llave 
;;--------------------------------------------------------------
dibujar_llave:

  ld a,(llave_pos)
  call calcular_pos

  ;;-- Fila 1
  ld (hl), #60 

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#90
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #60

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #20

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #20
 
  ;;-- Fila 6
  ld h, #EC
  ld (hl), #60

  ;;-- Fila 7
  ld h, #F4  
  ld (hl), #20
  
  ;;-- Fila 8
  ld h, #FC 
  ld (hl), #E0
  ret


;;========================================
;; Dibujar heroe en posicion de victoria
;;
;; ENTRADA:
;;   HL: Posicion del personaje en memoria de video
;;
;; MODIFICA:
;;
;;========================================
dibujar_hero_victoria:

   ;;-- Fila 1
  ld (hl), #66

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#9F
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #98 

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #9E  

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #F0

  ;;-- Fila 6
  ld h, #EC
  ld (hl), #42  

  ;;-- Fila 7
  ld h, #F4 
  ld (hl), #24
  
  ;;-- Fila 8
  ld h, #FC
  ld (hl), #99

  ;;-- Establecer la posicion de partida en HL
  ld h, #C4   
  ret


;========================================
;; Dibujar barril roto en la memoria de video indicada por HL
;;
;; ENTRADA:
;;   HL: Posicion del barril en memoria de video
;;
;; MODIFICA:
;;
;;========================================
dibujar_barril_roto_1:

   ;;-- Fila 1
  ld (hl), #11

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#00
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #99 

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #BB  

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

;========================================
;; Dibujar barril roto en la memoria de video indicada por HL
;;
;; ENTRADA:
;;   HL: Posicion del barril en memoria de video
;;
;; MODIFICA:
;;
;;========================================
dibujar_barril_roto_2:

   ;;-- Fila 1
  ld (hl), #00

  ;;-- Fila 2
  ld h,#CC
  ld (hl),#00
  
  ;;-- Fila 3
  ld h, #D4
  ld (hl), #88 

  ;;-- Fila 4
  ld h, #DC
  ld (hl), #11  

  ;;-- Fila 5
  ld h, #E4
  ld (hl), #6C

  ;;-- Fila 6
  ld h, #EC
  ld (hl), #8A  

  ;;-- Fila 7
  ld h, #F4 
  ld (hl), #F6
  
  ;;-- Fila 8
  ld h, #FC
  ld (hl), #60

  ;;-- Establecer la posicion de partida en HL
  ld h, #C4   
  ret

;========================================
;; Dibujar barril roto en la memoria de video indicada por HL
;;
;; ENTRADA:
;;   HL: Posicion del barril en memoria de video
;;
;; MODIFICA:
;;
;;========================================
dibujar_barril_roto_3:

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
  ld (hl), #54
  
  ;;-- Fila 8
  ld h, #FC
  ld (hl), #60

  ;;-- Establecer la posicion de partida en HL
  ld h, #C4   
  ret




;;============================================
;; Comprobar si se ha chocado con algun barril. Si es asi
;; se genera la explosion
;; SALIDA:
;;   Z se pone a 1 si hay colision
;;   Z se pone a 0 si no hay colision
;;=============================================
comprobar_colisiones:
  
  ;;-- Barril 1
  ;; Si barril1_pos == hero_pos, Hay colision!
  ld a,(barril1_pos)
  ld b,a
  ld a,(hero_pos)
  cp b
  jr z, colision

  ;;-- Barril 2
  ld a,(barril2_pos)
  ld b,a
  ld a,(hero_pos)
  cp b
  jr z, colision

  ;;-- Barril 4
  ld a,(barril4_pos)
  ld b,a
  ld a,(hero_pos)
  cp b
  jr z, colision

  ;;-- Barril 3
  ld a,(barril3_pos)
  ld b,a
  ld a,(hero_pos)
  cp b
  jr z, colision

  ;;-- No hay colision con ningun barril

  ;;-- Poner z a 0
  ld a,1
  or a
  jr colision_fin

  ;;-- Ha habido una colision
  colision:

    call calcular_pos
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

    xor a ;-- Poner z a 1

  colision_fin:
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
    ld b, #8   ;;-- Modificar esto para cambiar velocidad del personaje
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


