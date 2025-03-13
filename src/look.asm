
# Reserve space for up and down partitions
.data
.align 2 
queue_up: .space 24
queue_down: .space 24

.globl look
.text
look:
    # Load necessary values
    lw $t0, direction      # Elevator direction
    lw $t1, head           # Queue head
    lw $t2, tail           # Queue tail
    lw $t3, size           # Queue size
    lw $t4, current_floor  # Current floor
    beq $t1, $t2, look_end # If queue is empty, return

    la $t5, queue          # Base address of the queue

    # Allocate space for up and down partitions
    li $t6, 0  # Up list count
    li $t7, 0  # Down list count
    la $s0, queue_up       # Base address of up queue
    la $s1, queue_down     # Base address of down queue

    # Partition requests into "up" and "down" lists
partition_loop:
    beq $t1, $t2, partition_done  # Stop when all requests are checked

    # Load current request
    mul $t8, $t1, 4
    add $t8, $t5, $t8
    lw $t9, 0($t8)

    # Compare to current floor
    blt $t9, $t4, add_down  # If below current floor, add to down list

    # Add to up list
    sw $t9, 0($s0)
    addi $s0, $s0, 4
    addi $t6, $t6, 1
    j partition_next

add_down:
    # Add to down list
    sw $t9, 0($s1)
    addi $s1, $s1, 4
    addi $t7, $t7, 1

partition_next:
    # Move to next request (circular)
    addi $t1, $t1, 1
    rem $t1, $t1, $t3
    j partition_loop

partition_done:
    # Sort up list in ascending order
    bgtz $t6, sort_up
    bgtz $t7, sort_down
    j rebuild_queue  # Skip sorting if no requests

# Bubble sort for up list (ascending)
sort_up:
    la $s0, queue_up
    addi $t6, $t6, -1
    li $t9, 0

up_sort_outer:
    bge $t9, $t6, sort_down
    li $t8, 0

up_sort_inner:
    lw $t0, 0($s0)
    lw $t1, 4($s0)
    ble $t0, $t1, no_swap_up

    # Swap values
    sw $t1, 0($s0)
    sw $t0, 4($s0)

no_swap_up:
    addi $s0, $s0, 4
    addi $t8, $t8, 1
    blt $t8, $t6, up_sort_inner

    addi $t9, $t9, 1
    la $s0, queue_up
    j up_sort_outer

# Bubble sort for down list (ascending for wrap-around)
sort_down:
    la $s1, queue_down
    addi $t7, $t7, -1
    li $t9, 0

down_sort_outer:
    bge $t9, $t7, rebuild_queue
    li $t8, 0

down_sort_inner:
    lw $t0, 0($s1)
    lw $t1, 4($s1)
    ble $t0, $t1, no_swap_down

    # Swap values
    sw $t1, 0($s1)
    sw $t0, 4($s1)

no_swap_down:
    addi $s1, $s1, 4
    addi $t8, $t8, 1
    blt $t8, $t7, down_sort_inner

    addi $t9, $t9, 1
    la $s1, queue_down
    j down_sort_outer

# Rebuild the queue in C-LOOK order
rebuild_queue:
    la $t5, queue
    la $s0, queue_up
    la $s1, queue_down

    # Add all up requests first
    li $t8, 0
rebuild_up:
    bge $t8, $t6, rebuild_down
    lw $t0, 0($s0)
    sw $t0, 0($t5)
    addi $s0, $s0, 4
    addi $t5, $t5, 4
    addi $t8, $t8, 1
    j rebuild_up

    # Add all down requests after wrap-around
rebuild_down:
    li $t8, 0
rebuild_down_loop:
    bge $t8, $t7, look_end
    lw $t0, 0($s1)
    sw $t0, 0($t5)
    addi $s1, $s1, 4
    addi $t5, $t5, 4
    addi $t8, $t8, 1
    j rebuild_down_loop

look_end:
    jr $ra
