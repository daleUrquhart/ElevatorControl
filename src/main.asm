<<<<<<< Updated upstream
=======
<<<<<<< Updated upstream
=======
>>>>>>> Stashed changes
.include "emergency_measures.asm"
.include "basic_logic.asm"
.include "queue.asm"
.text
.globl main

main:	
<<<<<<< Updated upstream
	
=======
  	input_loop:
		li $t1, 0				# Set current floor default to 0
		li $t2, 0				# Set boolean variable for current direction of the elevator. 0 = UP, 1 = DOWN
		li $t3, 0				# 
	
		li $v0, 4				# Load system call code for print_string
		la $a0, targetFloor			# Load address of the target floor message
		syscall					# Execute the system call
		li $v0, 5				# Load system call code for read_string
		syscall					# Execute the system call
		move $a0, $v0				# Move the input to $a0
	
 		jal enq
 	
	L1:	
		beq $t2, 0, up				# If elevator direction is up (equal to 0), call moving_up function
		jal moving_down				# Else call moving_down function
		j skip	
		up:
			jal moving_up
						
		skip:
			jal is_empty			# Check if the queue is empty to determine whether to keep moving; 1 = true, 0 = false
			move $t0, $v0			# Move result of check to $t0
			beq $t0, 1, end			# Branch to end function if queue is empty
			j L1
	
	end:
		li $v0, 4
		la $a0, continue 		# Ask the user if they'd like to continue
		syscall
		li $v0, 5			# Load system call code for read_string
		syscall				# Execute the system call
		move $t0, $v0			# Move the input to $t0
	
		beq $t0, 83, stop		# Call stop function if input equals 'S'
		beq $t0, 65, alarm		# If input equal to 'A', call alarm function
		j input_loop			# Else restart input loop 

	alarm:
		jal sound_alarm
>>>>>>> Stashed changes
>>>>>>> Stashed changes
