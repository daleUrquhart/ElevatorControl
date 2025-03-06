.data
directionPrompt .asciiz "Press 'u' for UP and 'd' for DOWN?"
currentFloor .asciiz "Enter the current floor you're on. "
movingUp .asciiz "Going up : "
movingDown .asciiz "Going down : "
reachedFloor .asciiz "Arrived floor "
newline .asciiz "\n"

.include "main.asm"
.text

beq $a0, 76, moving_up			# If input is equal to 'u', initiates moving_up function
beq $a0, 64, moving_down		# If input is equal to 'd', initiates moving_down function

li $v0, 4				# Initializes the prompt for the current floor
la $a0, currentFloor			# Loads the user's input to the register
syscall					# Execute the system call
li $v0, 5				
syscall					# Execute the system call
move $t0, $v0				# Moves the input to a temporary variable

moving_up:
addi $a0, $a0, 1 			# Increments the current floor to reach the target floor
li $v0, 4				# Sets the value to the incremented floor			
la $a0, movingUp			# Shows the function of the floor getting incremented as it goes up
syscall					# Executes the system call
j moving_up

  
moving_down: 
addi $a0, $a0, -1			# Decrements the current floor to reach the target floor
li $v0, 4				# Sets the value to the decremented floor			
la $a0, movingDown			# Shows the function of the floor getting decremented as it goes up
syscall					# Executes the system call

j moving_down

reached: 


