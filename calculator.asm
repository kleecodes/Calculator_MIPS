	.data 
	
int_greet: .asciiz "\nPlease enter an integer: "
op_greet:  .asciiz "\nPlease enter an operation(+,-,*,/): "
thank:     .asciiz "\nThank you. "
over:	   .asciiz "\nThat's going to overflow! Try again."
zero:	   .asciiz "\nNo division by zero. Try again."

	.text
	
main:	
	jal get_int		#retrieve an int from user
	move $s1, $v0		#store the input as arg0
	jal get_op		#retrieve an operator from user
	move $s0, $v0		#store the operator as s0
	jal get_int		#retrieve an int from user
	move $s2, $v0		#store the input as arg1
	beq $s0,'+',add		#branch if add operation 
	beq $s0,'-',subtract	#branch if subtract operation
	beq $s0,'*',multiply	#branch if multiply operation
	beq $s0,'/',divide	#branch if division operation
	j end
	
add:	#function call for addition that checks for overflow first then does the operation
	jal add_overflow	#check for overflow
	add $s3,$s1,$s2		#does operation if no overflow
	j print			#print operation
	
	
add_overflow: #function call for addition overflow detection
	addu $t0,$s1,$s2	
	xor $t3,$s1,$s2
	bltz $t3,no_overflow
	xor $t3,$t0,$s1
	bge $t3,$zero,no_overflow
	move $s4,$ra
	jal overflow
	move $ra,$s4
	jr $ra
	
subtract: #function call for subtraction that checks for overflow first then does operation
	jal sub_overflow
	sub $s3,$s1,$s2
	j print
	
sub_overflow: #function call for checking for subtraction overflow
	subu $t0,$s1,$s2	#subtracting numbers with the same sign, no overflow
	xor $t3,$s1,$s2		
	bgt $t3,$zero,no_overflow	#if signs are the same(1) then no overflow
	bltz $t3,overflow

multiply: #function call for multiplication and checks for overflow
	jal mult_overflow
	mult $s1,$s2
	mflo $s3
	j print
	
mult_overflow: #checks for multiplication overflow
	multu $s1,$s2
	mfhi $t0	#load from hi
	mflo $a1	#load from lo
	xor $t3,$t0,$t0 #check hi to see if bits are all the same(0)
	beqz $t3,mult_checklo
	j overflow
	
mult_checklo:
	sra $t1,$a1,31  #check sign bit of lo
	mfhi $t0
	sra $t0,$t0,31
	beq $t0,$t1,no_overflow
	j overflow
	
divide:	beqz $s2, div_zero
	jal div_overflow
	div $s1,$s2
	mflo $t1
	mfhi $t2
	
	li $v0,1
	la $a0,($s1)
	syscall
	
	li $a0,'/'
	la $v0,11
	syscall
	
	li $v0,1
	la $a0,($s2)
	syscall
	
	li $a0,'='
	la $v0,11
	syscall
	
	li $v0,1
	la $a0,($t1)
	syscall
	
	li $a0,'r'
	la $v0,11
	syscall
	
	li $v0,1
	la $a0,($t2)
	syscall
	
	j main

div_zero:
	li $v0,4
	la $a0,zero
	syscall
	j main
	
div_overflow:
	div $s1,$s2
	mflo $t0
	sra $t0,$t0,31
	sra $t1,$s2,31
	beq $t0,$t1,overflow
	jr $ra
	
	
overflow: #function to handle an overflow situation
	li $v0,4	#print string
	la $a0,over
	syscall
	j main
	
no_overflow: #function to handle no overflow situation
	li $v0,4	#print string
	la $a0,thank
	syscall
	
	jr $ra
	
print:	#function call to print the current calculation and its results
	li $v0,1 	#print int
	la $a0,($s1)	#print the first int input
	syscall
	li $a0,' '	#adds space between outputs
	la $v0,11
	syscall
	li $v0,11	#print char
	la $a0,($s0)	#print the given operator
	syscall
	li $a0,' '
	la $v0,11
	syscall
	li $v0,1	#print int
	la $a0,($s2)	#print the second int input
	syscall
	li $a0,' '
	la $v0,11
	syscall
	li $a0, '='
	li $v0, 11   	# print_character
	syscall
	li $a0,' '
	la $v0,11
	syscall
	li $v0,1	#print int
	la $a0,($s3)	#print the sum
	syscall
	j main
	
get_int:#function call to get and set user input int
	li $v0,4		#syscall for printing a string
	la $a0, int_greet	#print the string at get_int
	syscall			#printing
	
	li $v0,5		#awaits user input and store at v0
	syscall
	
	jr $ra
	
get_op:	#function call to get and set user input operation
	li $v0,4		#syscall for printing a string
	la $a0, op_greet 	#print the string at op_greet
	syscall
	
	li $v0,12		#take char 
	syscall
	
	jr $ra

end:	li $v0,10
	syscall
	
	
