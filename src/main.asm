    .data
queue:          .space 20         # Space for 5 floor requests (4 bytes each)
head:           .word 0           # Head index of the queue
tail:           .word 0           # Tail index of the queue
size:           .word 5           # Maximum size of the queue (5 items)
full_msg:       .asciiz "Queue is full!\n"
empty_msg:      .asciiz "Queue is empty.\n"
enq_done_msg:   .asciiz "Request added to the queue.\n"
deq_done_msg:   .asciiz "Request processed from the queue.\n"
prompt:         .asciiz "Enter floor request (1-5): "

    .text
    #.globl main

main:
    # Initialize system
    jal init_system

main_loop:
    # Request input from user (floor request)
    li $v0, 4                # Print string syscall
    la $a0, prompt           # Load address of the prompt string
    syscall

    li $v0, 5                # Read integer syscall
    syscall
    move $a0, $v0            # Store user input in $a0 (floor request)

    # Process floor request (enqueue)
    jal enq

    # Print the current queue contents
    jal q_print

    # Process and dequeue request
    jal deq

    # Print the current queue contents after dequeue
    jal q_print

    # Return to main loop
    j main_loop

# Initialize system
init_system:
    li $t0, 0                # Initialize head to 0
    sw $t0, head
    sw $t0, tail             # Initialize tail to 0
    li $t1, 5                # Set queue size to 5
    sw $t1, size
    jr $ra

# Enqueue Function (Add floor request to the queue)
enq:
    # Check if the queue is full
    jal is_full
    bnez $v0, q_full         # If queue is full, stop enqueue

    # Get current tail index
    lw $t1, tail
    lw $t2, size
    mul $t3, $t1, 4          # Calculate byte offset (4 bytes per floor)
    la $t4, queue            # Load base address of queue
    add $t4, $t4, $t3        # Add offset to base address
    sw $a0, 0($t4)           # Store floor request at tail position

    # Update tail index (circular)
    addi $t1, $t1, 1
    rem $t1, $t1, $t2        # Ensure tail wraps around (circular queue)
    sw $t1, tail

    # Print confirmation message
    li $v0, 4
    la $a0, enq_done_msg
    syscall

    jr $ra

# Dequeue Function (Process floor request from the queue)
deq:
    # Check if the queue is empty
    jal is_empty
    bnez $v0, q_empty        # If empty, stop dequeue

    # Get current head index
    lw $t1, head
    lw $t2, size
    mul $t3, $t1, 4          # Calculate byte offset (4 bytes per floor)
    la $t4, queue            # Load base address of queue
    add $t4, $t4, $t3        # Add offset to base address
    lw $a0, 0($t4)           # Load floor request from head position

    # Print the processed request message
    li $v0, 4
    la $a0, deq_done_msg
    syscall

    # Update head index (circular)
    addi $t1, $t1, 1
    rem $t1, $t1, $t2        # Ensure head wraps around (circular queue)
    sw $t1, head

    jr $ra

# Check if the queue is full
is_full:
    lw $t0, tail
    lw $t1, size
    lw $t2, head
    addi $t3, $t0, 1
    rem $t3, $t3, $t1
    seq $v0, $t3, $t2
    jr $ra

# Check if the queue is empty
is_empty:
    lw $t0, head
    lw $t1, tail
    seq $v0, $t0, $t1
    jr $ra

# Print the current contents of the queue
q_print:
    lw $t0, head
    lw $t1, tail
    beq $t0, $t1, q_empty     # If empty, print message

print_loop:
    mul $t4, $t0, 4           # Get byte offset for the queue
    la $t5, queue
    add $t5, $t5, $t4         # Add the offset to get the correct address
    lw $a0, 0($t5)            # Load floor number from queue

    li $v0, 1                 # Print integer syscall
    syscall

    li $a0, ' '               # Print space between numbers
    li $v0, 11
    syscall

    addi $t0, $t0, 1
    lw $t2, size
    rem $t0, $t0, $t2         # Wrap around the queue in circular fashion
    bne $t0, $t1, print_loop  # Continue printing if head != tail

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
