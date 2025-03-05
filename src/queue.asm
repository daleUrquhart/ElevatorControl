.data 
floorRequest: .asciiz "Enter the desired floor you want to reach to: "
movingUp: .asciiz "You are moving up to : "
movingDown: .asciiz "You are moving down to : "
floorReached: .asciiz "You have reached your desired floor "

.text
.globl main
main:
li $v0, 4
la $a0, targetFloor
syscall
#Reading the floor
li $v0, 5
syscall
move $t0, $v0

li $v0, 4
la $a0, currentFloor
#Reading the floor
li $v0, 5
syscall
move $t1, $v0
#moving the elevator accordingly
blt $t0, $t1, moving_up
bgt,$t0, $t1, moving_down
moving_up:
	addi $t0, $t0, 1 #incrementing the floor
	li $v0, 4
	la $a0, movingUp #printing out the floor message
	syscall #issuing a systemcall

j reached #printing out the reached floor 

moving_down:
	addi $t0, $t0, -1
	li $v0, 4
	la $a0, movingDown
	syscall

j reached

reached:
	#dale's dequeue function.
	



	
#Exit:
#	 li $v0, 1
#	 move $a0, $t2
#	 syscall
#	 li $v0, 10
#	 syscall

s