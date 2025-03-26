# New function: optimize_queue
# Creates a temporary queue and sorts requests based on the current direction
.globl optimize_queue 
optimize_queue:
    lw $t0, direction
    li $t1, 1       # Check if direction is UP
    beq $t0, $t1, sort_descending
    li $t1, -1      # Check if direction is DOWN
    beq $t0, $t1, sort_ascending

    # Default to ascending if idle
    j sort_ascending

# Sort queue in ascending order (for going UP or IDLE)
sort_ascending:
    lw $t0, head
    lw $t1, tail
    lw $t2, size
    la $t3, queue

    # Outer loop: iterate over each element
asc_outer_loop:
    beq $t0, $t1, end_sort
    mul $t4, $t0, 4
    add $t4, $t3, $t4
    lw $t5, 0($t4)

    # Inner loop: compare and swap if needed
    move $t6, $t0
asc_inner_loop:
    addi $t6, $t6, 1
    rem $t6, $t6, $t2
    beq $t6, $t1, asc_outer_next

    mul $t7, $t6, 4
    add $t7, $t3, $t7
    lw $t8, 0($t7)

    bge $t5, $t8, asc_inner_next

    # Swap values
    sw $t8, 0($t4)
    sw $t5, 0($t7)
    move $t5, $t8

asc_inner_next:
    j asc_inner_loop

asc_outer_next:
    addi $t0, $t0, 1
    rem $t0, $t0, $t2
    j asc_outer_loop

# Sort queue in descending order (for going DOWN)
sort_descending:
    lw $t0, head
    lw $t1, tail
    lw $t2, size
    la $t3, queue

    # Outer loop
desc_outer_loop:
    beq $t0, $t1, end_sort
    mul $t4, $t0, 4
    add $t4, $t3, $t4
    lw $t5, 0($t4)

    # Inner loop
    move $t6, $t0

desc_inner_loop:
    addi $t6, $t6, 1
    rem $t6, $t6, $t2
    beq $t6, $t1, desc_outer_next

    mul $t7, $t6, 4
    add $t7, $t3, $t7
    lw $t8, 0($t7)

    ble $t5, $t8, desc_inner_next

    # Swap values
    sw $t8, 0($t4)
    sw $t5, 0($t7)
    move $t5, $t8

desc_inner_next:
    j desc_inner_loop

# Move to next outer iteration
desc_outer_next:
    addi $t0, $t0, 1
    rem $t0, $t0, $t2
    j desc_outer_loop

# Exit the sort function
end_sort:
    jr $ra
