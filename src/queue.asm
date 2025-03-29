.data
    .align 2 
queue:          .space 24         # Space for n floor requests (4 bytes each) 1 greater than actual
head:           .word 0           # Head index of the queue
tail:           .word 0           # Tail index of the queue
size:           .word 6           # Maximum queue size -- make sure to update init with change aswell (queue space/4) aswell as look datas
current_floor:  .word 0           # Elevator's current floor
direction:      .word 0           # 1 for up, -1 for down, 0 for idle
emergency_stop_val: .word 0
full_msg:       .asciiz "Queue is full!\n"
empty_msg:      .asciiz "Queue is empty.\n"
enq_done_msg:   .asciiz "Request added to the queue.\n"
stopped_msg:    .asciiz "Elevator is in emergency stop mode, can not process requests."
    .text
    .globl queue_init, enq, deq, q_print, is_full, is_empty, direction, current_floor, head, tail, size, queue, stopped_msg, reset_q, empty_msg

#============================================================== ENQUEUE ==============================================================
# Enqueue Function 
# Enqueue Function 
enq:
    lw $t0, emergency_stop_val      	# Check if emergency stop is active 
    bnez $t0, stopped           

    # Call is_present function to check if floor already exists in queue
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal is_present
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    beqz $v0, continue_enq  # If not present, proceed with enqueue
    jr $ra                 # If present, return immediately

continue_enq:
    lw $t1, tail           
    lw $t2, size               
    lw $t3, head      
                
    addi $t8, $t1, 1
    rem $t8, $t8, $t2
    beq $t8, $t3, q_full        	# If next tail position equals head, queue is full

    mul $t4, $t1, 4             	# Store floor request on new tail index
    la $t5, queue               
    add $t5, $t5, $t4            
    sw $a0, 0($t5)             
    
    lw $t1, tail 
    lw $t2, size 			# Update the tail index before sorting
    addi $t1, $t1, 1
    rem $t1, $t1, $t2
    sw $t1, tail

    addi $sp, $sp, -4        		
    sw $ra, 0($sp)
    jal optimize_queue			# Sort the Q after insertion
    lw $ra, 0($sp)		
    addi $sp, $sp, 4
						
    lw $t6, direction			# Handle direction after sorting
    bnez $t6, skip_direction
    lw $t7, current_floor
    blt $t7, $a0, set_up
    bgt $t7, $a0, set_down



#============================================================== BASIC FUNCTIONS ==============================================================
# Dequeue Function (Process floor request)
deq:
    addi $sp, $sp, -4       	  # Save RA and check if Q is empty 
    sw $ra, 0($sp)
    jal is_empty  
    bnez $v0, q_empty    

    lw $t1, head             
    lw $t2, size             

    mul $t3, $t1, 4         	  # Get the floor at top of the Q (head)
    la $t4, queue            
    add $t4, $t4, $t3       
    lw $a0, 0($t4)            

    sw $a0, current_floor    	  # Update current floor
 
    jal increment_head    	  # Increment head 

    jal is_empty 		  # Handle the case when queue becomes empty after dequeue 
    lw $ra, 0($sp)		
    addi $sp, $sp, 4
    bnez $v0, reset_direction 
    
    
    j direction_check 	 	  # Update direction if the Q is not empty
    
reset_direction: 
    li $t0, 0
    sw $t0, direction      	  # Reset direction if queue is empty
    jr $ra


# Update direction based on next request
direction_check:
    lw $t1, head		# Get value at the head (next floor)
    mul $t3, $t1, 4
    la $t4, queue
    add $t4, $t4, $t3
    lw $t5, 0($t4)          
    lw $t6, current_floor

    blt $t6, $t5, set_up	# Compare current floor and next floor and set direction 
    bgt $t6, $t5, set_down 
    jr $ra
    
# Initialize queue
queue_init: 
    sw $zero, head
    sw $zero, tail
    sw $zero, current_floor
    sw $zero, direction
    sw $zero, emergency_stop_val
    li $t0, 6
    sw $t0, size
    jr $ra
 
# Initialize queue
reset_q: 
    sw $zero, head
    sw $zero, tail
    sw $zero, current_floor
    sw $zero, direction 
    li $t0, 6
    sw $t0, size
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
    addi $sp, $sp, -4        # Save RA and check if Q is empty 
    sw $ra, 0($sp)
    jal is_empty  
 
    bnez $v0, q_empty  		# Save RA and check if Q is empty 
    lw $ra, 0($sp)
    addi $sp, $sp, 4 

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


# Set direction to up
set_up:
    li $t6, 1                   
    sw $t6, direction
    jr $ra

# Set direction to down
set_down:
    li $t6, -1                  
    sw $t6, direction
    jr $ra

# Returns to main
skip_direction:
    jr $ra
     
# Increments the head index for the circular Q
increment_head:
    addi $t1, $t1, 1       
    rem $t1, $t1, $t2        
    sw $t1, head    
    jr $ra
    
# Empty queue message
q_empty:
    lw $ra, 0($sp)		
    addi $sp, $sp, 4
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
    
# Handle emergency stop status true
stopped:
    li $v0, 4
    la $a0, stopped_msg
    syscall
    jr $ra
    
    
# ============================================== PRESENT CHECK ====================================
is_present:
    lw $t1, head          # Load data
    lw $t2, tail          
    lw $t3, size          
    la $t4, queue         

check_loop:
    beq $t1, $t2, not_found   

    mul $t5, $t1, 4        # Get head
    add $t6, $t4, $t5
    lw $t7, 0($t6)         

    beq $t7, $a0, found    # Match found

    addi $t1, $t1, 1       # Increment head nad continue loop
    rem $t1, $t1, $t3      
    j check_loop           

found:
    li $v0, 1              # Load v0 with 1 for found
    jr $ra

not_found:
    li $v0, 0              # Load v0 with 0 for not found
    jr $ra

