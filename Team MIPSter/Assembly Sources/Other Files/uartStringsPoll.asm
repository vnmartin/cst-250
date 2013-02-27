# main source file

.org 0x10000000

#######################
# Team MIPSter        #
# UART strings        #
# Programmer: Tyler   #
#######################

# Reads in characters from the UART by means of polling


################# SETUP ###################
li $a0, 0xf0000000 # UART
# 0x0010 base addr. char. queue
lw $a1, 0($zero) # char. Q offset register
################ LOOP #####################

poll_status:
  li $t0, 0x02
  lw $t1, 4($a0) # [$t0 = contents(SR) ]
  bne $t0, $t1, read_RB # poll SR for ready-bit
  nop
 j poll_status 
 nop

load:
  sw $v0, 0x0010($a1) # load Q
  addiu $a1, $a1, 4 # inc. Q offset
  li $t0, 0x2A # line delimiter
  beq $v0, $t0, write # if end of string, start writing
  or $a3, $a1, $zero # mask char count 
  nop
  j poll_status
  nop

unload:
  lw $v1, 0x0010($a1) #get next item in Q
  addiu $a1, $a1, 4
  beq $a1, $a3, exit # Q is empty so quit
  nop
  jr $ra
  nop

 read_RB:
  lw $v0, 8($a0) # [$v0 = contents(RB) ]
  li $t0, 0x02
  sw $t0, 0($a0) # clear ready-bit
  j load
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
  # end write_SB

exit:
 nop
################# END #####################
