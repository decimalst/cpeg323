.data
newline:.asciiz "\n"		# useful for printing commands
star:	.asciiz "*"
board1: .word 128 511 511 16 511 511 4 2 511 64 511 4 1 511 511 8 511 511 1 2 511 511 511 256 511 511 128 32 16 511 511 256 4 511 128 511 511 256 511 511 511 511 511 1 511 511 128 511 32 2 511 511 256 4 2 511 511 8 511 511 511 32 64 511 511 32 511 511 128 1 511 2 511 64 8 511 511 32 511 511 16
board2: .word 128 8 256 16 32 64 4 2 1 64 32 4 1 128 2 8 16 256 1 2 16 4 8 256 32 64 128 32 16 1 64 256 4 2 128 8 4 256 2 128 16 8 64 1 32 8 128 64 32 2 1 16 256 4 2 1 128 8 4 16 256 32 64 16 4 32 256 64 128 1 8 2 256 64 8 2 1 32 128 4 16
	
.text
#main function
main:
	sub  	$sp, $sp, 4
	sw   	$ra, 0($sp) # save $ra on stack

	# test singleton (true case)
	li	$a0, 0x010
	jal	singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 1

	# test singleton (false case)
	li	$a0, 0x10b
	jal	singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 0

	# test get_singleton 
	li	$a0, 0x010
	jal	get_singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 4

	# test get_singleton 
	li	$a0, 0x008
	jal	get_singleton
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 3

	# test board_done (true case)
	la	$a0, board2
	jal	board_done
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 1
	
	# test board_done (false case)
	la	$a0, board1
	jal	board_done
	move	$a0, $v0
	jal	print_int_and_space
	# this should print 0

	# print a newline
	li	$v0, 4
	la	$a0, newline
	syscall	

	# test print_board
	la	$a0, board1
	jal	print_board

	# should print the following:
	# 8**5**32*
	# 7*31**4**
	# 12***9**8
	# 65**93*8*
	# *9*****1*
	# *8*62**93
	# 2**4***67
	# **6**81*2
	# *74**6**5

	lw   	$ra, 0($sp) 	# restore $ra from stack
	add  	$sp, $sp, 4
	#jr $ra
	li $v0, 10 #Added so MARS works instead of jr $ra
	syscall #added for MARS
	


print_int_and_space:
	li   	$v0, 1         	# load the syscall option for printing ints
	syscall              	# print the element
#print_space:
	li   	$a0, 32        	# print a black space (ASCII 32)
	li   	$v0, 11        	# load the syscall option for printing chars
	syscall              	# print the char
	
	jr      $ra          	# return to the calling procedure

print_newline:
	li	$v0, 4		# at the end of a line, print a newline char.
	la	$a0, newline
	syscall	    
	jr	$ra

print_star:
	li	$v0, 4		# print a "*"
	la	$a0, star
	syscall
	jr	$ra
	
	
# ALL your code goes below this line.
#
# We will delete EVERYTHING above the line; DO NOT delete 
# the line.
#
# ---------------------------------------------------------------------
	
## bool singleton(int value) {  // This function checks whether
##   return (value != 0) && !(value & (value - 1));
## }
singleton:
	li $v0, 0 #Let false be zero
	beqz $a0, false_sing  #If value == zero
	li $t2, 1
	sub $t0, $a0, $t2 #Set $t0=value-1
	and $t1, $t0, $a0 # $t1 = value AND value-1)
	beqz $t1 , true_sing #If (value & value - 1) > 0, it is true
	false_sing:
	j exit_sing
	true_sing:
	addi $v0, $0, 1 #Let True be 1
	exit_sing:
	jr	$ra


## int get_singleton(int value) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 if (value == (1<<i)) {
## 		return i;
## 	 }
##   }
##   return 0;
## }
get_singleton:
	li $t0, -1 #$t0 = i = -1, since we have i++ at start of the loop
	li $t1, 1 #this is the 1 we shift to compare
	li $t2, 9 #Let $t2 = GRID_ SQUARED=9
	li $v0, 0 #Set $v0 to zero as default return value
	loop_gs: 
	add $t0, $t0, 1 #i++
	sllv $t3, $t1, $t0 # $t2 = (1 << i)
	beq $a0, $t3, return_i
	beq $t0, $t2, exit_sg
	j loop_gs #jump to loop
	return_i:
	add $v0, $0, $t0 #If we found i, set to return value
	exit_sg: jr	$ra


## bool
## board_done(int board[GRID_SQUARED][GRID_SQUARED]) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
## 		if (!singleton(board[i][j])) {
## 		  return false;
## 		}
## 	 }
##   }
##   return true;
## }

board_done:
	li $v0, 1 #Return true by default
	li $s0, -1 #Let $t0 = i = 0
	li $s1, 0 #Let $t1 = j = 0
	li $s2, 9 #Let $t2 = GRID_SQUARED = 9
	add $s3, $a0, $0 #Save address of board in $s3
	add $s4, $ra, $0 #Save return address of function call
	loop_bd_i:
	add $s0, $s0, 1 #i++
	bgt $s0, $s2, exit_bd #i must be < 9
	loop_bd_j:
	beq  $s1, $s2, loop_bd_i #j must be < 9
	mul $t2, $s2, $s0 # $t2 = i * 9 
	add $t0, $0, $t2 # Add offset of i*9
	add $t0, $t0, $s1 # Add offset of j
	li $t3, 4
	mul $t0, $t0, $t3 #Multiply by sizeof int
	add $t0, $s3, $t0 #Add offset to address of board
	lw $a0, ($t0) # load the value of the address into single parameters
	jal singleton
	beqz $v0, false_bd
	add $s1, $s1, 1 #j++
	j loop_bd_j #Jump back to start of loop
	false_bd:
	add $v0, $0, $0 #Set $v0 to zero if we find a non singleton and return it.
	exit_bd:
	add $ra, $0, $s4 #Restore original return address
	jr	$ra
	
## void
## print_board(int board[GRID_SQUARED][GRID_SQUARED]) {
##   for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
## 	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
## 		int value = board[i][j];
## 		char c = '*';
## 		if (singleton(value)) {
## 		  c = get_singleton(value) + '1';
## 		}
## 		printf("%c", c);
## 	 }
## 	 printf("\n");
##   }
## }

print_board:
	li $v0, 1 #Return true by default
	li $s0, -1 #Let $t0 = i = 0
	li $s1, 0 #Let $t1 = j = 0
	li $s2, 9 #Let $t2 = GRID_SQUARED = 9
	add $s3, $a0, $0 #Save address of board in $s3
	add $s4, $ra, $0 #Save return address of function call
	loop_pb_i:
	jal print_newline
	add $s0, $s0, 1 #i++
	beq $s0, $s2, exit_pb #i must be < 9
	add $s1, $0, $0 #Reset j to zero
	loop_pb_j:
	beq $s1, $s2, loop_pb_i #j must be < 9
	mul $t2, $s2, $s0 # $t2 = i * 9 
	add $t0, $0, $t2 # Add offset of i*9
	add $t0, $t0, $s1 # Add offset of j
	li $t3, 4
	mul $t0, $t0, $t3 #Multiply by sizeof int
	add $s5, $s3, $t0 #Add offset to address of board
	lw $a0, ($s5) # load the value of the address into single parameters
	jal singleton
	beqz $v0, printast_pb
	lw $a0, ($s5) #load value of address to call get_singleton with
	jal get_singleton
	addi $a0, $v0, 1 #c = get_singleton(value)+1
	jal print_int_and_space
	j loop_pb_conds 
	printast_pb:
	jal print_star
	jal print_space
	loop_pb_conds:
	add $s1, $s1, 1 #j++
	j loop_pb_j #Jump back to start of loop
	exit_pb:
	add $ra, $0, $s4 #Restore original return address
	jr	$ra
