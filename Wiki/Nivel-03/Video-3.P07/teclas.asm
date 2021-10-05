org #4000

run inicio

inicio:

   ;;  Comprobar si se pulsa espacio
   ld a, 47
   call #BB1E
   jr nz, pulsada  ;  Si Z no activo (tecla pulsada), saltar a pulsada

     ;; No pulsada
     ;; Borrar la vagoneta
     ld hl, #C000
     call borrar_8x8   ;;  Dibuja un cuadrado 8x8 color fondo
     jr continuar      ;;-- Continuar la ejecucion

pulsada:
   ;; Dibujar vagoneta
   ld hl, #C000
   call dibujar_vagoneta

continuar:

  jr inicio


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Borrar los pixeles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
borrar_8x8:
  ld (hl), 00
  ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dibujar los pixeles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dibujar_vagoneta:
  ld (hl), #FF
  ret

