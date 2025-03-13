.data
    newline:       .asciiz "\n"
    enq_msg:       .asciiz "Enqueueing floor: "
    deq_msg:       .asciiz "Dequeuing floor...\n"
    queue_state:   .asciiz "Queue state: "
    curr_floor_msg:.asciiz "Current floor: "
    direction_msg: .asciiz "Direction: "
    up_msg:        .asciiz "UP\n"
    down_msg:      .asciiz "DOWN\n"
    idle_msg:      .asciiz "IDLE\n"

.text
    #.globl main

main:
    # Initialize queue
    jal queue_init

    # Enqueue a few floors
    li $a0, 3
    jal enq
    #jal print_queue_status

    li $a0, 5
    jal enq
    #jal print_queue_status

    li $a0, 1
    jal enq
    jal print_queue_status 			# Should be 1,3,5

    # Dequeue a floor
    jal deq
    jal print_queue_status			# 3,5

    # Enqueue more floors
    li $a0, 4
    jal enq
    #jal print_queue_status
						# 3,4,5 -- not printed
    li $a0, 2
    jal enq
    jal print_queue_status
						# 3,4,5,2
    # Dequeue again
    jal deq
    #jal print_queue_status

    li $a0, 1
    jal enq
    #jal print_queue_status
    
    li $a0, 6
    jal enq
    jal print_queue_status
    						# 4,5,6,2,1
    jal deq
    jal deq
    jal deq
    #jal print_queue_status
    jal deq
    jal deq
    jal print_queue_status			# MT
    
    # Finish
    li $v0, 10
    syscall

# ===========================================
# Print the current queue status
# ===========================================
print_queue_status:
    # Print current floor
    li $v0, 4
    la $a0, curr_floor_msg
    syscall

    lw $a0, current_floor
    li $v0, 1
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
    li $v0, 4
    la $a0, newline
    syscall
    jr $ra
