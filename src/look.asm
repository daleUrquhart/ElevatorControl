.data
.align 2 
queue_up: .space 24
queue_down: .space 24

debug_msg: .asciiz "Debug: "
newline: .asciiz "\n"

.globl look
.text
look: 
    # Debug: Entering look
    li $v0, 4
    la $a0, debug_msg
    syscall
    li $v0, 1
    li $a0, 1
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    lw $t0, direction
    lw $t1, head           
    lw $t2, tail           
    lw $t3, size           
    lw $t4, current_floor  
    beq $t1, $t2, look_end 

    la $t5, queue          

    li $t6, 0  # Up list count
    li $t7, 0  # Down list count
    la $s0, queue_up      
    la $s1, queue_down    

# Debug: Partitioning
    li $v0, 4
    la $a0, debug_msg
    syscall
    li $v0, 1
    li $a0, 2
    syscall
    li $v0, 4
    la $a0, newline
    syscall

partition_loop:
    beq $t1, $t2, partition_done   

    mul $t8, $t1, 4
    add $t8, $t5, $t8
    lw $t9, 0($t8)

    # Debug: Current request
    li $v0, 4
    la $a0, debug_msg
    syscall
    li $v0, 1
    move $a0, $t9
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    blt $t9, $t4, add_down  

    sw $t9, 0($s0)
    addi $s0, $s0, 4
    addi $t6, $t6, 1
    j partition_next

add_down:
    sw $t9, 0($s1)
    addi $s1, $s1, 4
    addi $t7, $t7, 1

partition_next: 
    addi $t1, $t1, 1
    div $t1, $t3
    mfhi $t1
    j partition_loop

partition_done: 
    bgtz $t6, sort_up
    bgtz $t7, sort_down
    j rebuild_queue

# Debug: Sorting Up
sort_up:
    li $v0, 4
    la $a0, debug_msg
    syscall
    li $v0, 1
    li $a0, 3
    syscall
    li $v0, 4
    la $a0, newline
    syscall

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

    sw $t1, 0($s0)
    sw $t0, 4($s0)

no_swap_up:
    addi $s0, $s0, 4
    addi $t8, $t8, 1
    blt $t8, $t6, up_sort_inner

    addi $t9, $t9, 1
    la $s0, queue_up
    j up_sort_outer

# Debug: Sorting Down
sort_down:
    li $v0, 4
    la $a0, debug_msg
    syscall
    li $v0, 1
    li $a0, 4
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    la $s1, queue_down
    addi $t7, $t7, -1
    li $t9, 0

down_sort_outer:
    bge $t9, $t7, rebuild_queue
    li $t8, 0

down_sort_inner:
    lw $t0, 0($s1)
    lw $t1, 4($s1)
    bge $t0, $t1, no_swap_down

    sw $t1, 0($s1)
    sw $t0, 4($s1)

no_swap_down:
    addi $s1, $s1, 4
    addi $t8, $t8, 1
    blt $t8, $t7, down_sort_inner

    addi $t9, $t9, 1
    la $s1, queue_down
    j down_sort_outer

# Rebuilding the queue after sorting
rebuild_queue:
    # Debug: Rebuilding Queue
    li $v0, 4
    la $a0, debug_msg
    syscall
    li $v0, 1
    li $a0, 6
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Rebuild the queue by copying the sorted elements back into the original queue
    la $t5, queue
    la $t6, queue_up
    la $t7, queue_down

    # Copy up queue
    li $t8, 0
rebuild_up:
    bge $t8, 6, rebuild_down
    lw $t9, 0($t6)
    sw $t9, 0($t5)
    addi $t5, $t5, 4
    addi $t6, $t6, 4
    addi $t8, $t8, 1
    j rebuild_up

rebuild_down:
    li $t8, 0
    # Copy down queue
rebuild_down_loop:
    bge $t8, 6, look_end
    lw $t9, 0($t7)
    sw $t9, 0($t5)
    addi $t5, $t5, 4
    addi $t7, $t7, 4
    addi $t8, $t8, 1
    j rebuild_down_loop

look_end:
    li $v0, 4
    la $a0, debug_msg
    syscall
    li $v0, 1
    li $a0, 5
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    jr $ra
