################
Team MIPSter
Seven Segment Banner using a for-loop
Programmer: Tyler

.org 0x10000000

################### SETUP ######################

# pointer to the start of a block of memory
li $a0, 0x00000010
# load address of mem. loc. of sev. seg. 
li $a1 0xf0a00000

# initialize mem. block
li $t0, 0xFF0C470C  # hex code for  P.L.P. in a[4]
sw $t0, 0($a0)
li $t0, 0x79243019  # code 0 a[0]
sw $t0, 4($a0)
li $t0, 0xFF792430  # code 1 a[8]
sw $t0, 8($a0)
li $t0, 0x19FF7924  # code 2 a[12]
sw $t0, 12($a0)
li $t0, 0x3019FF79  # code 3 a[16]
sw $t0, 16($a0)
li $t0, 0x243019FF  # code 4 a[20]
sw $t0, 20($a0)
li $t0, 0x79243019  # code 4 a[20]
sw $t0, 24($a0)

################# MAIN LOOP #####################

# flash P.L.P
lw $t0, 0($a0)
sw $t0, 0($a1)
li $t0, 0xFFFFFFFF
sw $t0, 0($a1)
lw $t0, 0($a0) 
sw $t0, 0($a1)
li $t0, 0xFFFFFFFF

reset:
# increment register cleared
lw $a3, 0($zero)

scroll:
li $t0, 0x18
# if end of mem. block then clear
beq $a3, $t0, reset
# else point to next hex code
addiu $a3, $a3, 0x04
#load next loc. in mem. block
lw $t0, 0x0010($a3)
sw $t0, 0($a1)
j scroll

###################### END #######################


