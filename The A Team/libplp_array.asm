# Damon Cost
# 2/28/2013
# Functions to perform on arrays
# All functions require top of array to be in $ao
# First element must be at 'top' of array
# Some functions use stack make sure top is in $sp

# return array length
libplp_array_length:
	and $v0, $v0, $0 # clear destination

	length_loop:
	lw $t0, 0($a0) # first char of array
	beq $t0, $0, return_length # if null
	nop #else
	addiu $a0, $a0, -4 #goto next element 
	addiu $v0, $v0, 1 #incriment index count
	j length_loop
	nop
	return_length:
	jr $31
	nop

# returns location of FIRST instance of element
# element must be in $a1
# memory location of element returned in $v0
# index of element returned in $v1
# if not in array $v0 = null, $v1 = -1
libplp_array_first_index_element:
	sw $a0, 0($sp) #store array top
	move $t9, $31 #store return address
	jal libplp_array_length
	nop
	move $t0, $v0 #array length in $t0
	lw $a0, 0($sp) #restore array top
	and $v0, $v0, $0 #clear destinations
	and $v1, $v1, $0

	first_index_element_loop:
	#if length is 0 return null
	beq $t0, $0, return_not_in_array
	nop
	lw $t1, 0($a0) #get first char
	#if char == argument
	beq $t1, $a1, return_first_index_element
	nop
	#else 
	
	addiu $a0, $a0, -4 #goto next element
	addiu $v1, $v1, 1 #incriment index
	addiu $t0, $t0, -1 #length counter
	j first_index_element_loop
	nop
	return_first_index_element:
	move $v0, $a0
	jr $t9
	nop
	return_not_in_array:
	and $v0, $v0, $0
	and $v1, $v1, $0
	addiu $v1, $v1, -1
	jr $t9
	nop

# takes an array loaded with an number in decimal
# format (xx.xx) and splits it into two registers
# for processing. Left side of decimal in $v0
# right side in $v1, (padded to 9 digits)
# skips neg if there is a value in $a1
lib_plp_array_split_decimal:
	bne $a1, $0, skip_neg
	nop
	j no_skip
	nop
	skip_neg:
	addiu $a0, $a0, -4
	#left side
	no_skip:
	and $v0, $v0, $0 #clear destination
	li $t0, 10 
	li $t1, 0x2e #ASCII '.'
	process_left_loop:
	lw $t2, 0($a0) #get left digit
	#if '.' is readched
	beq $t2, $t1, process_right
	nop
	addiu $t2, $t2, -48 # get decimal value
	mullo $v0, $v0, $t0 # current x 10
	addu $v0, $v0, $t2 # add next ones digit
	addiu $a0, $a0, -4 # next index
	j process_left_loop
	nop
	
	process_right:
	and $v1, $v1, $0 #clear destination
	addiu $a0, $a0, -4 #skip over decimal
	and $t1, $t1, $0 #counter for # digits
	process_right_loop:
	lw $t2, 0($a0) # next digit
	# if end of array
	beq $t2, $0, pad_right
	nop
	addiu $t1, $t1, 1 # digit counter
	addiu $t2, $t2, -48 #get decimal value
	mullo $v1, $v1, $t0 #current x 10
	addu $v1, $v1, $t2 #add next ones digit
	addiu $a0, $a0, -4 # next index
	j process_right_loop
	nop

	pad_right:
	li $t2, 9 #pad to 9 digits
	beq $t1, $t2, done #if 9 digits
	nop
	mullo $v1, $v1, $t0 #pad with 0
	addiu $t1, $t1, 1 #incriment counter
	nop
	j pad_right
 	nop

	done:
	jr $31
	nop

#Checks first location of array to determine if it
#the '-' ascii char. Returns a 1 if '-' and a 0 else
libplp_array_check_neg:
	and $v0, $v0, $0 # clear 
	li $t0, 0x2d # '-' ascii
	lw $t1, 0($a0) 
	beq $t0, $t1, negative
	nop
	j done
	nop
	negative:
	addiu $v0, $v0, 1
	
	jr $31
	nop

