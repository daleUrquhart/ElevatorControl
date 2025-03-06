.data 
targetFloor: .asciiz "Enter the desired floor (0-5); press 'S' to stop: "
currentFloor: .asciiz "You are on floor "
nextFloor: .asciiz "You are moving to floor "
#movingDown: .asciiz "You are moving down to: "
floorReached: .asciiz "You have reached your floor "
continue: .asciiz "Enter a floor number (0-5) if you wish to continue. Enter 'S' if you wish to stop: "
newline: .asciiz "\n"
.include "queue.asm"
.include "emergency_measures.asm"
.include "main.asm"
.text
	
moving_up:
	jal deq					# Retrieve the next desired floor
	move $t0, $v0				# Move result to $t0
	li $v0, 4				# Load system call code for print_string
	la $a0, currentFloor 			# Printing out what floor you're on
	syscall
	li $v0, 1
 	move $a0, $t1				# Print current floor number
 	syscall 			
	li $v0, 4 				# Load system call code for print_string
	la $a0, newline     			# Load address of the string
	syscall					# Execute the system call	
	li $v0, 4				# Load system call code for print_string
	la $a0, nextFloor 			# Printing out what floor you're going to
	syscall
	li $v0, 1
 	move $a0, $t0				# Print next floor number				
 	syscall 					
    Loop1:
	beq $t1, $t0, reached			# Branch to reached if current floor equals desired floor
	addi $t1, $t1, 1 			# Increment the current floor
	li $v0, 4				# Load system call code for print_string
	la $a0, currentFloor 			# Printing out what floor you're on
	syscall
	li $v0, 1
 	move $a0, $t1				# Print current floor number
 	syscall
 	li $v0, 4 				# Load system call code for print_string
	la $a0, newline     			# Load address of the string
	syscall
	j Loop1			 

moving_down:
	jal deq					# Retrieve the next desired floor
	move $t0, $v0				# Move result to $t0
	li $v0, 4				# Load system call code for print_string
	la $a0, currentFloor 			# Printing out what floor you're on
	syscall
	li $v0, 1
 	move $a0, $t1				# Print current floor number
 	syscall 			
	li $v0, 4 				# Load system call code for print_string
	la $a0, newline     			# Load address of the string
	syscall					# Execute the system call	
	li $v0, 4				# Load system call code for print_string
	la $a0, nextFloor 			# Printing out what floor you're going to
	syscall
	li $v0, 1
 	move $a0, $t0				# Print next floor number				
 	syscall 					
    Loop2:
	beq $t1, $t0, reached			# Branch to reached if current floor equals desired floor
	addi $t1, $t1, -1 			# Decrement the current floor
	li $v0, 4				# Load system call code for print_string
	la $a0, currentFloor 			# Printing out what floor you're on
	syscall
	li $v0, 1
 	move $a0, $t1				# Print current floor number
 	syscall
 	li $v0, 4 				# Load system call code for print_string
	la $a0, newline     			# Load address of the string
	syscall
	j Loop2
	
reached:
	li $v0, 4				# Load system call code for print_string
	la $a0, currentFloor			# Print current floor number
	syscall		
	li $v0, 1	
 	move $a0, $t1				# Print current floor number				
 	syscall
	li $v0, 4 				# Load system call code for print_string
	la $a0, newline     			# Load address of the string
	syscall		
	j $ra 	


