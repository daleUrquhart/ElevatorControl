.data
alarm_message: .asciiz "ALARM!" 
prompt: .asciiz "Press 'A' to cancel alarm:"
newline: .asciiz "\n" 			
stopped: .asciiz "The elevator has been stopped. Do you want to restart the elevator? (Y/N)"
.include "main.asm"
.text


#beq $a0, 65, alarm 			# If input equal to 'A', sound alarm

#alarm:
#	jal sound_alarm
	
sound_alarm:

	# TODO: need to add stack pointer adjustments here
	move $t1, $a0				# Move argument to temporary register
	li $t0, 0				# Initialize count = 0
	li $v0, 4 				# Load system call code for print_string
	la $a0, alarm_message			# Load address of the alarm message
	syscall 				# Execute the system call
	
	li $v0, 32				# Load system call code for wait
	li $a0, 1000				# Set delay to 1000 milliseconds
	syscall					# Execute the system call
	li $v0, 4 				# Load system call code for print_string
	la $a0, newline     			# Load address of the string
	syscall					# Execute the system call
	addi $t0, 1				# Increment count
	bne $t0, 5, sound_alarm 		# Loop
	
	li $v0, 4 				# Load system call code for print_string
	la $a0, prompt 				# Load address of the prompt message
	syscall 				# Execute the system call
 	
	li $v0, 8 				# Load system call code for read_string
	syscall 				# Execute the system call
	move $a0, $v0 				# Move the input to $a0 

	bne $a0, 65, sound_alarm		# While input is not equal to 'A', continue
						# Printing "ALARM!"
	move $t1, $a0				# Restore the original input back to argument register
	j $ra					# Return when input is equal to 'A'

#_____________________________________________________________________________________________

#beq $a0, 83, stop				# If input equal to 'S', call stop function 	

stop:
	jal rmq					# Call remove queue
	li $v0, 4 				# Load system call code for print_string
	la $a0, stopped 			# Load address of the stopped message
	syscall 				# Execute the system call	
	
	beq $a0, 89, restart			# If input equal to 'Y', restart the program
	j exit					# Go to exit function
	
	restart:
		jal q_init			# Re-initialize the queue
		j input_loop			# Restart input loop
	
exit:
						# Exit the program
	li $v0, 10 				# Load system call code for exit
	syscall 				# Execute the system call 
