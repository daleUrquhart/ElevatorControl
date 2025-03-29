
.data

    menu_msg:         .asciiz "Main Menu:\n1. Request a floor\n2. Engage emergency stop\n3. Move to next floor\n4. Sound the alarm\n5. Print queue\n6. Quit\nEnter your choice: "
    prompt_floor:     .asciiz "Enter the floor to request (0-5): "
    quit_msg:         .asciiz "Exiting program...\n"
    emergency_msg:    .asciiz "Emergency stop engaged!\n"
    curr_dir_msg:  .asciiz " || Current elevator direction: "
    enq_msg:       .asciiz "Enqueueing floor: "
    deq_msg:       .asciiz "Dequeuing floor...\n"
    queue_state:   .asciiz "Queue state: "
    curr_floor_msg:.asciiz "Current floor: "
    direction_msg: .asciiz "Direction: "
    up_msg:        .asciiz "UP\n"
    down_msg:      .asciiz "DOWN\n"
    idle_msg:      .asciiz "IDLE\n"
    empty_msg:      .asciiz " Queue is empty\n\n"
    curr_dir_msg:  .asciiz " || Current elevator direction: "
 
.text
    .globl main_loop, main
    
main:
    # Initialize queue
    jal queue_init

main_loop:
    # Display the menu
    li $v0, 4                # Print string syscall
    la $a0, menu_msg
    syscall

    # Get user input for menu choice
    li $v0, 5                # Read integer syscall
    syscall
    move $t0, $v0            # Store the choice in $t0

    # Check the user choice
    beq $t0, 1, request_floor
    beq $t0, 2, emergency_stop
    beq $t0, 3, move_next_floor
    beq $t0, 4, sound_the_alarm
    beq $t0, 5, print_queue_status
    beq $t0, 6, quit_program
    # Invalid choice, loop again
    j main_loop

# Request a floor (1)
request_floor:
    li $v0, 4
    la $a0, newline
    syscall
    # Ask user for floor number
    li $v0, 4
    la $a0, prompt_floor
    syscall

    # Read the floor number
    li $v0, 5
    syscall
    move $a0, $v0  # Move the input floor to $a0 for enqueuing

    # Enqueue the floor request
    jal enq
    
    # Print a newline for formatting
    li $v0, 4
    la $a0, newline
    syscall

    # Return to menu
    j main_loop

# Engage emergency stop (2)
emergency_stop:
    li $v0, 4
    la $a0, newline
    syscall
    jal stop 
    # Return to menu
    j main_loop

# Move to the next floor (3)
move_next_floor:
    li $v0, 4
    la $a0, newline
    syscall
    # Dequeue the next floor request
    jal deq

    # Print the current floor, with formatting
    li $v0, 4
    la $a0, curr_floor_msg
    syscall
    li $v0, 1
    lw $a0, current_floor
    syscall
    li $v0, 4
    la $a0, curr_dir_msg
    syscall
    li $v0, 1 
    lw $a0, direction
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    syscall

    # Return to menu
    j main_loop

# Engage the alarm (4)
sound_the_alarm:
    li $v0, 4
    la $a0, newline
    syscall
    jal sound_alarm
    j main_loop

# Quit program (6)
quit_program:
    li $v0, 4
    la $a0, quit_msg
    syscall
    
    # Exit the program
    li $v0, 10
    syscall

# ===========================================
# Print the current queue status (5)
# ===========================================
print_queue_status:
    # set print count to 0 
    li $t9, 0
    
    li $v0, 4 				# Load system call code for print_string
    la $a0, newline			# Load address of the newline
    syscall 				# Execute the system call
		 
    # Print current floor
    li $v0, 4
    la $a0, curr_floor_msg
    syscall

    li $v0, 1
    lw $a0, current_floor
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    # Print direction
    li $v0, 4
    la $a0, direction_msg
    syscall

    lw $t0, direction
    beqz $t0, print_idle
    bltz $t0, print_down

    # Print UP
    la $a0, up_msg
    j print_dir_done

print_down:
    la $a0, down_msg
    j print_dir_done
    
print_up:
    # Print UP
    la $a0, up_msg

print_idle:
    la $a0, idle_msg

print_dir_done:
    li $v0, 4
    syscall

    # Print queue contents
    li $v0, 4
    la $a0, queue_state
    syscall

    lw $t0, head
    lw $t1, tail
    lw $t2, size
    la $t3, queue

print_queue_loop:
    beq $t0, $t1, print_done
    
    addi $t9, $t9, 1	# increment print count
    mul $t4, $t0, 4
    add $t4, $t3, $t4
    lw $a0, 0($t4)

    li $v0, 1
    syscall

    li $a0, ' '
    li $v0, 11
    syscall

    addi $t0, $t0, 1
    rem $t0, $t0, $t2
    j print_queue_loop

print_done:
    beqz $t9, empty_queue_print
    li $v0, 4
    la $a0, newline
    syscall
    syscall
    j main_loop


empty_queue_print:
    li $v0, 4		# Finish print function
    la $a0, empty_msg
    syscall
    j main_loop