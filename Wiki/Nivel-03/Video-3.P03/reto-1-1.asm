;; Reto 1.1: Pintar 4 pixeles rojos

org #4000
run #4000

;; Al almacenar #FF en la memoria de video se 
;; pintan 4 pixeles rojos
;; La memoria de video comienza en #C000

ld a, #FF
ld (#C000), a

;; Terminar (Bucle infinito)
jr $

