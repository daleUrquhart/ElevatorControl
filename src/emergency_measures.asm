.data
alarm_message: .asciiz "ALARM!\n" 
emergency_prompt: .asciiz "Press 'A' to cancel alarm: "
newline: .asciiz "\n" 			
stopped_msg1: .asciiz "The elevator has been stopped. Do you want to restart the elevator? (Y/N): "
.text
.globl newline, stop, sound_alarm

		

sound_alarm:
	li $t0, 0				# Initialize count = 0
	
alarm:
	move $t1, $a0				# Move argument to temporary register

	li $v0, 4 				# Load system call code for print_string
	la $a0, alarm_message			# Load address of the alarm message
	syscall 				# Execute the system call
	
	li $v0, 32				# Load system call code for wait
	li $a0, 1000				# Set delay to 1000 milliseconds
	syscall					# Execute the system call
	addi $t0, $t0, 1			# Increment count
	bne $t0, 5, alarm 			# Loop
	
	li $v0, 4 				# Load system call code for print_string
	la $a0, emergency_prompt 		# Load address of the prompt message
	syscall 				# Execute the system call
 	
	li $v0, 12 				# Load system call code for read_string
	syscall 				# Execute the system call
	move $a0, $v0 				# Move the input to $a0 

	bne $a0, 'A', sound_alarm		# While input is not equal to 'A', continue

	li $v0, 4 				# Load system call code for print_string
	la $a0, newline				# Load address of the newline
	syscall 				# Execute the system call
	syscall
												# Printing "ALARM!"
	#move $t1, $a0				# Restore the original input back to argument register
	jr $ra					# Return when input is equal to 'A'

#_____________________________________________________________________________________________

#beq $a0, 83, stop				# If input equal to 'S', call stop function 	

stop:
	jal reset_q				# Call remove queue
	li $v0, 4 				# Load system call code for print_string
	la $a0, stopped_msg1			# Load address of the stopped message
	syscall 				# Execute the system call	
	
	li $v0, 12 				# Load system call code for read_string
	syscall 				# Execute the system call
	move $a0, $v0 				# Move the input to $a0 

	beq $a0, 'Y', restart			# If input equal to 'Y', restart the program
	
	li $v0, 4 				# Load system call code for print_string
	la $a0, newline				# Load address of the newline
	syscall 				# Execute the system call
	
	j exit					# Go to exit function
	
	restart:
		li $v0, 4 				# Load system call code for print_string
		la $a0, newline				# Load address of the newline
		syscall 				# Execute the system call
		li $v0, 4 				# Load system call code for print_string
		la $a0, newline				# Load address of the newline
		syscall 				# Execute the system call
		j main				# Restart input loop
	
exit:
						# Exit the program
	li $v0, 10 				# Load system call code for exit
	syscall 				# Execute the system call 
