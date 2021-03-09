	#Troy Clendenen
	#binarytree.asm
	#a recursive binary tree program.

	.data

root:	 .space 4 #stores the address of the root node

prompt:	 .asciiz "Enter a value for the root node: "
mright:	 .asciiz "You moved right\n"
mleft:	 .asciiz "You moved left\n"
complete:	 .asciiz "Tree insertion complete\n"
number:	 .asciiz "Number of data items inserted: "
size:	 .space 4
rnode:	 .asciiz "Root node is at location: "
newline:	 .asciiz "\n"
space:	 .asciiz "	"
titles:	 .asciiz "Root	      Left Child	Right Child       Value\n"

	.text

main:	 #main program that takes in a number for the root and initializes root address and value
	li $s7 1 #counter for how many data items we have

	la $a0, prompt #load prompt
	li $v0, 4 #op number for printing string
	syscall

	li $v0, 5 #op number for read integer
	syscall
	move $t0, $v0

	beqz $t0, quit

	#create node struct
	li $a0, 12 #load 12 bytes for node
	li $v0, 9 #op number for sbrk
	syscall

	sw $v0, root #store address of created node

	lw $t1, root
	sw $t0, 8($t1) #move our int input into our root

	#b print

loop:	 #loops through input from the user
	li $v0, 5 #op number for read integer
	syscall

	beq $v0, $zero, tinit #if the input is a zero, we have finished input

	#move our values into arguments for the insert function

	lw $a0, root #moves root address into $a0
	move $a1, $v0 #moves value into $a1

	jal insert #go to insert the node

	add $s7, $s7, $v0 #adds one or zero to our counter depending on if we added something or not

	#print return value
	#move $a0, $v0
	#li $v0, 1
	#syscall
	#jal pnewline
	b loop

insert:	 #insert a node into the tree
	#arguments:
	# $a0: pointer to a tree node (address of node)
	# $a1: data value to be added
	#return values:
	# $v0: 1 if something was added, 0 if nothing was added

	subi  $sp, $sp, 20
	sw $fp, 16($sp)
	sw $ra, 12($sp)
	sw $s0, 8($sp)
	sw $s1, 4($sp)
	sw $s2, 0($sp)
	addi $fp, $sp, 20

	lw $s0, 8($a0) #loads the value of the current node into $s0
	lw $s1, ($a0) #load the address of the left subtree
	lw $s2, 4($a0) #load the address of the right subtree

	beq $a1, $s0, rvzero #if the values are equal, we don't need to insert into the tree
	blt $a1, $s0, less #if the insert value is less than the current node, go to the left subtree
	bgt $a1, $s0, greater #if the insert value is greater than the current node, go to the right subtree

greater:
	bnez $s2, zright #if the right subtree address doesn't equal zero

	move $s1, $a0 #move the address of the current node into a temp value

	#make node using sbrk
	la $a0, 12
	li $v0, 9
	syscall

	sw $v0, 4($s1) #store the address of the new node into the right address of the current node
	lw $s2, 4($s1) #load the new node into $s2
	sw $a1, 8($s2) #store the new value into the number slot of the new node

	b rvone #set return value to 1

less:
	bnez $s1, zleft #if the left subtree address doesn't equal zero

	move $s2, $a0 #move the address of the current node into a temp value

	#make node using sbrk
	la $a0, 12
	li $v0, 9
	syscall

	sw $v0, ($s2) #store the address of the new node into the right address of the current node
	lw $s1, ($s2) #load the new node int0 $s1
	sw $a1, 8($s1) #store the new value into the number slot of the new node

	b rvone #set return value to 1

zright:	 #make a node in the corresponding right subtree
	move $a0, $s2 #set the address argument to be the right subtree
	jal insert #go back to recursion
	b rvmult

zleft:	 #make a node in the corresponding left subtree
	move $a0, $s1 #set the address argument to be the left subtree
	jal insert #go back to recursion
	b rvmult

rvzero:
	li $v0, 0 #set return value to 0
	b ireturn

rvone:
	li $v0, 1 #set return value to 1
	b ireturn

rvmult:	 #multiply return value by one. Essentially keeps it the same as it was
	li $s0, 1 #load one into $s0
	mul $v0, $v0, $s0 #multiply $v0 by 1

ireturn:	 #deallocate stack frames, then return to loop function
	lw $fp, 16($sp)
	lw $ra, 12($sp)
	lw $s0, 8($sp)
	lw $s1, 4($sp)
	lw $s2, 0($sp)
	addi $sp, $sp, 20

	jr $ra #return to caller


	################################################################################################################
	#This is the part in the program where we will traverse the tree and print the appropriate data values
	################################################################################################################


tinit:
	#prints out info messages
	jal pnewline
	jal pcomplete
	jal pnumber
	jal pamount
	jal pnewline
	jal pnewline
	jal ptitles

	##############

	lw $a0, root #loads the root of the tree into $a0

	jal traverse

	b quit

traverse:
	#traverses the tree and prints out each node
	#arguments:
	# $a0: pointer to a node (address of node)
	subi  $sp, $sp, 20
	sw    $fp, 16($sp)
	sw    $ra, 12($sp)
	sw    $s0, 8($sp)
	sw    $s1, 4($sp)
	sw    $s2, 0($sp)
	addi  $fp, $sp, 20

	lw $s0, ($a0) #load the address of the left subtree
	lw $s1, 4($a0) #load the address of the right subtree
	move $s2, $a0 #load value into $s2

	beqz $s0, tprint #immediately return when $a0 is zero

	move $a0, $s0 #recurse on the left subtree
	jal traverse
	b tprint

tprint:
	#print address of current node
	move $a0, $s2
	li $v0, 34 #op number for print hex
	syscall

	#print space
	la $a0, space
	li $v0, 4
	syscall

	#print address of left child
	move $a0, $s0 #loads left subtree address
	li $v0, 34 #op number for print hex
	syscall

	#print space
	la $a0, space
	li $v0, 4
	syscall

	#print address of right child
	move $a0, $s1 #loads right subtree address
	li $v0, 34 #op number for print hex
	syscall

	#print space
	la $a0, space
	li $v0, 4
	syscall

	#print value stored in node
	lw $a0, 8($s2) #loads value stored
	li $v0, 1 #op number for print integer
	syscall

	#print newline
	la $a0, newline
	li $v0, 4
	syscall

	beqz $s1, treturn #if the right is zero, we are done with printing
	move $a0, $s1 #else recurse on the right subtree
	jal traverse

treturn:
	lw    $fp, 16($sp)
	lw    $ra, 12($sp)
	lw    $s0, 8($sp)
	lw    $s1, 4($sp)
	lw    $s2, 0($sp)
	addi  $sp, $sp, 20
	jr    $ra

print:	 #prints the root of our tree

	lw $t0, root

	#print address of root
	lw $a0, root
	li $v0, 34
	syscall

	jal pspace

	#print address of left child
	lw $a0, ($t0)
	li $v0, 34
	syscall

	jal pspace

	#print address of right child
	lw $a0, 4($t0)
	li $v0, 34
	syscall

	jal pspace

	#print value stored in node
	lw $a0, 8($t0)
	li $v0, 1
	syscall

	b quit

pspace:	 #prints a space
	la $a0, space
	li $v0, 4
	syscall

	jr $ra

pnewline:	 #prints a newline character
	la $a0, newline
	li $v0, 4
	syscall

	jr $ra

pcomplete:	 #print the complete prompt
	la $a0, complete
	li $v0, 4
	syscall

	jr $ra

pnumber:	 #print number prompt
	la $a0, number
	li $v0, 4
	syscall

	jr $ra

pamount:	 #print the amount of numbers
	sw $s7, size
	lw, $a0, size
	li $v0, 1
	syscall

	jr $ra

ptitles:	 #print the titles prompt
	la $a0, titles
	li $v0, 4
	syscall

	jr $ra

quit:
	li $v0, 10 #quit program
	syscall
	
