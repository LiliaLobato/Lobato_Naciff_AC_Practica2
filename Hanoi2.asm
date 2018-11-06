#########################################
#           TORRES DE HANOI             #
# Lilia Arceli Lobato Martínez ie706937 #
# Jorge Karim Naciff Maldonnat ie708501	#
#########################################

.data
#Apartado de memoria para torres
A: .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
B: .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
C: .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

.text
main:
	#101 0000 
	#Carga de direccion de torres
	#la $a1, A		#Carga direccion to
	addi $a1, $zero, 0x1001
	sll $a1, $a1, 16		#Carga direccion to
	ori $a1, $a1, 0x0000
	#la $t6, A		#Carga direccion para llenado inicial
	addi $t6, $zero, 0x1001
	sll $t6, $t6, 16		#Carga direccion to
	ori $t6, $t6, 0x0000
	
	#la $a2, C		#Carga direccion from
	addi $a2, $zero, 0x1001
	sll $a2, $a2, 16		#Carga direccion from
	ori $a2, $a2, 0x0080
	
	#la $a3, B		#Carga direccion aux
	addi $a3, $zero, 0x1001
	sll $a3, $a3, 16		#Carga direccion aux
	ori $a3, $a3, 0x0040
	
	#Discos
	add $a0,$zero, 3	#Num. Discos
	add $s2,$zero, $a0	#Copia Num. Discos
	
	#Apuntador a tope torre
	sll $s1, $a0, 2		#Al darle un Shift Left Logical por 2 a un valor
				#es equivalente a multiplicar por 4
	add $a1, $a1, $s1	#La dirección de la última posición de la torre to se guarda
	addi $a1, $a1, -4	#Se decrementa para que apunte al último valor guardado
	
	#Llenado de Torre 1
for:	
	sw $s2, ($t6)		#Se guarda el num. actual de disco en A
	addi $t6, $t6, 4	#se avanza en posición torre A
	addi $s2, $s2, -1	#Se decrementa el valor de disco
	bne $s2, 0, for		#Si discos!=0 -> for
endFor:	
	jal hanoi
	j exit
	
	#Funcion Hanoi
hanoi:
	beq $a0,1,uno 		#Num. Discos == 1 -> uno
	
nouno:
	#Guardando apuntadores memoria + dato
	add $sp, $sp, -8	#Regresa
	sw $ra, 0($sp)		#Direccion
	sw $a0, 4($sp)		#Num Disco
	
	#Cambio apuntadores 1
	add $a0,$a0,-1		#Decrementa el Num. Discos
	add $t0,$zero,$a3	
	add $a3,$zero,$a2	#Cambio from -> aux
	add $a2,$zero,$t0	#Cambion aux -> from
	
	#Llamada Hanoi 1 
	jal hanoi
	
	#Mover disco 2
	lw $s1, 0($a1)		#Recupera el ultimo valor de la Torre from
	sw $s1, 0($a3)		#Imprime en localidad sigueinte de Torre to 
	sw $zero, 0($a1)	#Limpia valor recién movido
	
	#Cambio apuntadores 2
	add $t0, $zero, $a1
	sub $a1, $a2, 4 	#Drecrementa tamaño aux y cambio from -> to	
	addi $a2, $a3, 4	#Drecrementa tamaño aux y cambio to -> aux
	addi $a3, $t0, 0 	#Cambio aux -> from
	
	#Llamada Hanoi 2
	jal hanoi
	
	#Cambio apuntadores 3
	add $t0, $a1, $zero
	addi $a1,$a3,-4		#Decrementa tamaño aux y cambio to -> aux
	add $a3,$t0,4		#Incrementa tamaño to y cambio aux -> to
	
	#Descargar apuntadores memoria + dato
	lw $ra, 0($sp)		#Direccion
	lw $a0, 4($sp)		#Num Disco
	addi $sp, $sp, 8	#Avanza
	
	jr $ra
	
uno:
	#mover disco 1
	lw $s1, 0($a1)		#Recupera el ultimo valor de la Torre from
	sw $s1, 0($a2)		#Imprime en localidad sigueinte de Torre to 
	sw $zero, 0($a1)	#Limpia valor recién movido
	addi $a1, $a1, -4	#Decrementa el tamaño de Torre from
	addi $a2, $a2, 4	#Incrementa tamaña torre to
	
	jr $ra	

exit:
