.data
    .align 2 
queue:          .space 24         # Space for n floor requests (4 bytes each) 1 greater than actual
head:           .word 0           # Head index of the queue
tail:           .word 0           # Tail index of the queue
size:           .word 6           # Maximum queue size -- make sure to update init with change aswell (queue space/4)
current_floor:  .word 0           # Elevator's current floor
direction:      .word 0           # 1 for up, -1 for down, 0 for idle
emergency_stop: .word 0
full_msg:       .asciiz "Queue is full!\n"
empty_msg:      .asciiz "Queue is empty.\n"
enq_done_msg:   .asciiz "Request added to the queue.\n"
deq_done_msg:   .asciiz "Request processed from the queue.\n"

    .text
    .globl queue_init, enq, deq, q_print, is_full, is_empty, prioritize, direction, emergency_stop

#============================================================== ENQUEUE ==============================================================
# Enqueue Function 
enq:
    lw $t0, emergency_stop      # Check if emergency stop is active
    bnez $t0, q_full            

    lw $t1, tail                # Load tail index
    lw $t2, size                # Load queue size
    lw $t3, head                # Load head index
    addi $t4, $t1, 1            # Increment tail index
    rem $t4, $t4, $t2           # Ensure circular queue behavior
    
    beq $t4, $t3, q_full        # If next tail position equals head, queue is full

    mul $t4, $t1, 4             # Compute byte offset
    la $t5, queue               # Load queue base address
    add $t5, $t5, $t4           # Compute target address
    sw $a0, 0($t5)              # Store floor request
    
    addi $t1, $t1, 1            # Increment tail index
    rem $t1, $t1, $t2           # Ensure circular queue wrap
    sw $t1, tail                # Update tail index

    # Update direction if idle
    lw $t6, direction
    bnez $t6, skip_direction    # Skip if already moving
    lw $t7, current_floor
    blt $t7, $a0, set_up        # If request is above, go up
    bgt $t7, $a0, set_down      # If below, go down
    j skip_direction            # Otherwise, stay idle

set_up:
    li $t6, 1                   # Set direction to up
    sw $t6, direction
    j skip_direction

set_down:
    li $t6, -1                  # Set direction to down
    sw $t6, direction

skip_direction:
    # Call prioritize
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal prioritize
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    # Print enqueue message
    li $v0, 4
    la $a0, enq_done_msg
    syscall
    jr $ra

#============================================================== BASIC FUNCTIONS ==============================================================
# Dequeue Function (Process floor request)
deq:
    addi $sp, $sp, -4		# Save RA
    sw $ra, 0($sp)
    jal is_empty
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    bnez $v0, q_empty        	# If queue is empty, print message

    lw $t1, head             	# Load head index
    lw $t2, size             	# Load queue size
    
    mul $t3, $t1, 4          # Compute byte offset
    la $t4, queue            # Load queue base address
    add $t4, $t4, $t3        # Compute target address
    lw $a0, 0($t4)           # Load request
    
    sw $a0, current_floor    # Update current floor

    addi $t1, $t1, 1         # Increment head index
    rem $t1, $t1, $t2        # Ensure circular queue behavior
    sw $t1, head             # Update head index

    # Update direction if queue becomes empty
    addi $sp, $sp, -4		# Save RA
    sw $ra, 0($sp) 
    jal is_empty
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    bnez $v0, reset_direction
    j direction_check

reset_direction:
    li $t0, 0
    sw $t0, direction
    j deq_done

# Update direction based on next request
direction_check:
    lw $t1, head
    mul $t3, $t1, 4
    la $t4, queue
    add $t4, $t4, $t3
    lw $t5, 0($t4)           # Load next request
    lw $t6, current_floor

    blt $t6, $t5, set_up
    bgt $t6, $t5, set_down

    
# Print dequeue message
deq_done:
    li $v0, 4
    la $a0, deq_done_msg
    syscall
    jr $ra

# Initialize queue
queue_init:
    li $t0, 0
    sw $t0, head
    sw $t0, tail
    sw $t0, current_floor
    sw $t0, direction
    li $t1, 6
    sw $t1, size
    jr $ra
    
# Check if queue is full
is_full:
    lw $t0, tail
    lw $t1, size
    lw $t2, head
    addi $t3, $t0, 1
    rem $t3, $t3, $t1
    seq $v0, $t3, $t2
    jr $ra

# Check if queue is empty
is_empty:
    lw $t0, head
    lw $t1, tail
    seq $v0, $t0, $t1
    jr $ra

# Print the queue
q_print:
    lw $t0, head
    lw $t1, tail
    beq $t0, $t1, q_empty

print_loop:
    mul $t4, $t0, 4
    la $t5, queue
    add $t5, $t5, $t4
    lw $a0, 0($t5)

    li $v0, 1
    syscall

    li $a0, ' '
    li $v0, 11
    syscall

    addi $t0, $t0, 1
    lw $t2, size
    rem $t0, $t0, $t2
    bne $t0, $t1, print_loop

    jr $ra

# Empty queue message
q_empty:
    li $v0, 4
    la $a0, empty_msg
    syscall
    jr $ra

# Full queue message
q_full:
    li $v0, 4
    la $a0, full_msg
    syscall
    jr $ra

#============================================================== PRIORITIZATION ==============================================================
# Prioritize the queue (Elevator Prioritization)
prioritize:
    # Load direction and check if sorting is needed
    lw $t0, direction      # Elevator direction
    lw $t1, head           # Load head index
    lw $t2, tail           # Load tail index
    lw $t3, size           # Load queue size
    beq $t1, $t2, prioritize_end   # If queue is empty, return
    beqz $t0, prioritize_end       # If idle, no need to sort

    la $t4, queue          # Load base address of queue

sort_loop:
    li $t5, 0              # Swap flag (0 = no swaps, 1 = swaps made)

    move $t6, $t1          # Start index (head)
    move $t7, $t2          # End index (tail)
    addi $t7, $t7, -1      # Adjust tail for comparisons

bubble_pass:
    mul $t8, $t6, 4        # Byte offset of queue[t6]
    add $t8, $t4, $t8      # Address of queue[t6]
    lw $t9, 0($t8)         # Load queue[t6] (current request)

    # Get next index (circular behavior)
    addi $t6, $t6, 1
    rem $t6, $t6, $t3      # Wrap around
    beq $t6, $t2, check_swaps  # Stop if we've reached tail

    mul $t8, $t6, 4        # Byte offset of queue[next]
    add $t8, $t4, $t8      # Address of queue[next]
    lw $t1, 0($t8)         # Load queue[next] (next request)

    # Sorting conditions based on direction
    bgtz $t0, check_up     # If moving up, sort ascending
    bltz $t0, check_down   # If moving down, sort descending

check_up:
    bgt $t9, $t1, swap     # Swap if out of order (smallest first)
    j bubble_pass

check_down:
    blt $t9, $t1, swap     # Swap if out of order (largest first)
    j bubble_pass

swap:
    sw $t1, -4($t8)        # Swap queue[t6-1] and queue[t6]
    sw $t9, 0($t8)         # Store new value
    li $t5, 1              # Set swap flag (indicates changes)

check_swaps:
    bnez $t5, sort_loop    # If swaps were made, do another pass

prioritize_end:
    jr $ra
