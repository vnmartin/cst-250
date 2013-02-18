# main source file

.org 0x10000000

#######################
# Team MIPSter #
# UART strings #
# Lab 2 #
#######################

# Reads in a string from the UART upon interrupt.

############################################
# SETUP #
############################################
li $a0, 0xf0000000 # UART
# 0x0010 base addr. char. queue
lw $a1, 0($zero) # char. Q offset register
li $a2, 0xf0700000 # interrupt controller
li $a3, 0x2A # line delimiter
############################################
############################################
# PROGRAM #
############################################

main:
li $i0, read # ISR
li $s0, 0x05
sw $s0, 0($a2) # enable UART interrupts
j main
nop

############# QUEUE OPERATIONS ############
load:
sw $v0, 0x0010($a1) # load Q
addiu $a1, $a1, 4 # inc. Q offset
beq $v0, $a3, write # stop reading, start writing
or $s1, $a1, $zero # mask char count
nop
li $t0, 0x01
sw $t0, 4($a2) # clear interrupt status bits
sw $t0, 0($a2) #set GIE
lw $s0, 0($a2) # get mask state
jr $i1 # jump back to main, isr is done
sw $s0, 0($a2) # store mask state in delay slot of ISR return
#ISR END
nop

unload:
lw $v1, 0x0010($a1) #get next item in Q
addiu $a1, $a1, 4
beq $a1, $s1, exit # Q is empty so quit
nop
li $t0, 0x57
beq $v1, $t0, convert # if the last byte was a W
nop
jr $ra
nop

convert:
 li $t0, 0x25
 subu $v1, $v1, $t0 # make it a 2
 jr $ra # jump back as usual
 
 

############################################
############################################
# UART READ/WRITE OPERATIONS #
############################################
read:
lw $s0, 4($a2) # read interrupt status register
read_RB:
#ISR BEGIN
lw $v0, 8($a0) # [$v0 = contents(RB) ]
li $t0, 0x02
sw $t0, 0($a0) # clear ready-bit
j load
# ISR CONTINUES THRU LOAD
nop
# end read_RB

write:
li $a1, 0x00 # reset offset
write_SB:
lw $t1, 4($a0) # [$t1 = contents(SR) ]
beq $t1, $zero, write_SB # check SR CTS-bit
nop
jal unload
nop
nop
sw $v1, 12($a0) # [SB = contents $v1 ]
li $t0, 0x01
sw $t0, 0($a0) # init send
nop
j write_SB
nop
# end write_SB

exit:
li $t0, 0x01 # clear interrupt status bits
sw $t0, 4($a2)
and $a1, $a1, $zero # reset char Q offset
# fin
j main
nop
################# END ######################

############################################
# REGISTER USAGE SUMMARY #
############################################
# $a0: holds address of UART
# $a1: offset register for the character queue
# $a2: holds the address of interrupt controller
# $a3: holds the specfied delimiter used
# $s0: used for interrupt data across function calls
# $s1: character load count (varies with user input)
# $v0: last byte received
# $v1: last byte sent
############################################
