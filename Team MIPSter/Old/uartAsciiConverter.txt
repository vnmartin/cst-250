# main source file

.org 0x10000000

#######################
# Team MIPSter        #
# UART ascii converter        #
# Programmer: Tyler   #
#######################

# Reads in a number from the UART.
# Outputs numbers in one of four formats depending on the following switch configuration...
# 00 - ASCII
# 01 - HEX
# 10 - DECIMAL 
# 11 - OCTAL

############################################
#                SETUP                     #
############################################
li $s0, 0xf0000000 # UART
# base address of byte array: 0x00000010
li $s3, 0x00000010
lw $s1, 0($zero) # offset register for byte array
li $s2, 0xf0100000 # switches
############################################
############################################
#               PROGRAM                    #
############################################
read:
and $s1, $s1, $zero # needs to be cleared...
read_RB:
 lw $t0, 4($s0) # load UART status
 andi $t0, $t0, 0x02 # mask for ready-bit 
 beq $t0, $zero, read_RB
 nop
 lw $t1, 8($s0) # read receive buffer
 sw $t0, 0($s0) # clear ready-bit
 sw $t1, 0x0010($s1) # add byte to byte array
 addiu $s1, $s1, 4 # increment offset
 li $t2, 8
 beq $s1, $t2, reset_offset # stop reading
 nop
 j read_RB
 nop
 # end read_RB [$a0 = contents(RB)]

reset_offset:
 lw $s1, 0($zero) # reset offset
conversion:
 lw $a0, 0($s3) # get s[0]
 lw $a1, 4($s3) # get s[1]
 andi $a0, $a0, 0x000000F # mask out m. sig 28 bits
 andi $a1, $a1, 0x000000F
 sw $a0, 0($s3) # store new s[0]
 sw $a1, 4($s3) # store new s[1]
 bne $a0, $zero, mul # if first byte low nibble isnt zero..
 nop
 j add
 nop

mul:
and $t1, $t1, $zero # reset counter
 tens: 
  addiu $a2, $a2, 10 # inc by ten
  addiu $t1, $t1 0x01 # inc counter
  beq $t1, $a0, add # jump to add if done..
  nop
  j tens
  nop

add:
 and $v0, $v0, $zero # clear $v0 (trust me...)
 addu $v0, $a1, $a2 # [$v0 = result]
 sw $v0, 8($s3) # store $v0 s[3]
 j format
 nop
# end conversion
############################################
############################################
format:
 # note: $s1 = 8
 lw $t0, 0($s2) # load switches
 beq $t0, $zero, ascii # output is ascci (00)
 nop
 li $t1, 0x01
 beq $t0, $t1, hex # output is hex (01)
 and $s1, $s1, $zero # reset offset
 li $t1, 0x02
 beq $t0, $t1, decimal #output is decimal (10)
 nop
 li $t1, 0x03
 beq $t0, $t1, octal #output is octal (11)
 nop
############################################
############################################
 ascii:
 and $a0, $a0, $zero
 and $a1, $a1, $zero
 and $a2, $a2, $zero
 and $s1, $s1, $zero
 lw $v1, 8($s3)

 write_ascii:
 lw $t0, 4($s0) # load UART status
 andi $t0, $t0, 0x01 # mask for cts-bit
 beq $t0, $zero, write_ascii
 nop
 sw $v1, 12($s0) # write to send buffer
 sw $t0, 0($s0) # init send
 j read # get next byte
 nop
 # end write_SB
 # end ascii
############################################
############################################
 hex:
 lw $a0, 8($s3) # get hex number
 srl $a1, $a0, 4 # [ $a1 = upper] 
 andi $a2, $a0, 0x0F # [ $a2 = lower]
 li $t1, 0x0A
 slt $t3, $a1, $t1 # if less than 10..
 slt $t4, $a2, $t1
 check_1:
 li $t2, 0x01
 beq $t3, $t2, num1 
 nop
 letter1:
 # take difference [ $a1 - 0x09 ]
 li $t1, 0x09 
 subu $a1, $a1, $t1
 li $t5, 0x04
 sll $t5, $t5, 4 # [$t5 = 0x01000000 ]
 or $a1, $a1, $t5
 sw $a1, 12($s3)
 j check_2
 nop
 num1:
 li $t5, 0x03
 sll $t5, $t5, 4 # [$t5 = 0x00110000 ]
 or $a1, $a1, $t5
 sw $a1, 12($s3)

 check_2:
 li $t2, 0x01
 beq $t4, $t2, num2 
 nop
 letter2:
 # take difference [ $a2 - 0x09 ]
 li $t1, 0x09 
 subu $a2, $a2, $t1
 li $t5, 0x04
 sll $t5, $t5, 4 # [$t5 = 0x01000000 ]
 or $a2, $a2, $t5
 sw $a2, 16($s3)
 j write_hex
 nop
 num2:
 li $t5, 0x03
 sll $t5, $t5, 4 # [$t5 = 0x00110000 ]
 or $a2, $a2, $t5
 sw $a2, 16($s3)

 write_hex:
 and $a0, $a0, $zero
 and $a1, $a1, $zero
 and $a2, $a2, $zero
 li $s1, 12
 write:
 lw $t0, 4($s0) # load UART status
 andi $t0, $t0, 0x01 # mask for cts-bit
 beq $t0, $zero, write
 nop
 lw $v0, 0x0010($s1) #get next byte
 sw $v0, 12($s0) # write to send buffer
 sw $t0, 0($s0) # init send
 li $t1, 16
 beq $s1, $t1, read # all done!
 nop
 addiu $s1, $s1, 4 
 j write # get next byte
 nop
 # end write_SB
############################################
############################################
 decimal:
 # prepend 0011 on a1 and a2
 and $a0, $a0, $zero
 and $a1, $a1, $zero
 and $a2, $a2, $zero
 and $s1, $s1, $zero

 write_decimal:
 lw $t0, 4($s0) # load UART status
 andi $t0, $t0, 0x01 # mask for cts-bit
 beq $t0, $zero, write_decimal
 nop
 sw $v1, 12($s0) # write to send buffer
 sw $t0, 0($s0) # init send
 j read # get next byte
 nop
 # end write_SB
############################################
############################################
 octal:
 and $a0, $a0, $zero
 and $a1, $a1, $zero
 and $a2, $a2, $zero
 and $s1, $s1, $zero
 
 write_octal:
 lw $t0, 4($s0) # load UART status
 andi $t0, $t0, 0x01 # mask for cts-bit
 beq $t0, $zero, write_octal
 nop
 sw $v1, 12($s0) # write to send buffer
 sw $t0, 0($s0) # init send
 j read # get next byte
 nop
 # end write_SB
############################################
############################################


################# END ######################
############################################
#         REGISTER USAGE SUMMARY           #
############################################
# $s0: UART
# $s1: offset register used throughout the program
# $s2: switches
# $a0: holds first byte for processing
# $a1: holds second byte for processing
# $a2: multiplier
# $v0: processed input
# $v1: formatted output
############################################









