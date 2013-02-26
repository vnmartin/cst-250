# main source file

.org 0x10000000


# offset 
li $s0, 0
#array
li $s1, 0x00000010
# length of array -1
li $s2, 2

li $t0, 1
sw $t0, 0($s1)
li $t0, 2
sw $t0, 4($s1)
li $t0, 3
sw $t0, 8($s1)

# array = {1,2,3}

next:
 lw, $a0, 0x00000010($s0) # get byte
 and $t1, $t1, $zero # reset counter
 move $a1, $a0
 beq $s2, $zero, add #just add if last byte
 nop
 mul:
  li $t0, 10
  mullo $a1, $a1, $t0 # mul by ten
  addiu $t1, $t1 0x01 # inc counter
  beq $t1, $s2, add # jump to add if done..
  nop
 j mul
 nop

 add:
 addu $v0, $v0, $a1 # [$v0 = result]
 addiu $s0, $s0, 4
 li $t0, 1
 subu $s2, $s2, $t0 # take one away
j next
nop

