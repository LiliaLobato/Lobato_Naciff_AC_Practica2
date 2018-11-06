#BNE BEQ LW SW J JR

.data
#Apartado de memoria para torres
A: .word 5
B: .word 9

.text
main:
	
	#A		
	addi $t6, $zero, 0x1001
	sll $t6, $t6, 16
	ori $t6, $t6, 0x0000
	#B		
	addi $t5, $zero, 0x1001
	sll $t5, $t5, 16
	ori $t5, $t5, 0x0004
	
	add $s2,$zero, 1
	bne $s2, 0, BNE

BNE:
	sw $s2, 0($t6)
	beq $s2,1,BEQ

BEQ:	
	lw $s1, 0($t5)
	jal JAL
	j exit
	
JAL:
	addi $s1,$s1,1
	addi $s2,$s2,1
	jr $ra
	
exit: