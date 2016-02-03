.data
# String Buffers
GUESSED:	.space 32
WORD_SIZE:	.word  0
CHOSEN_WORD: 	.space 12
WORDS_IN_FILE: 	.space 1024

# String Table
WELCOME: 	.asciiz "Welcome to Hangman! You will have 7 tries to guess a given word.\nGuess '.' at any point to end the game.\n"
PROMPT: 	.asciiz "Please enter a word length between 4 and 11: "
YES:		.asciiz "Correct guess!\n"
NO:		.asciiz "Incorrect guess.\n"
WORD_IS:	.asciiz "The word is "
GUESSES_LEFT:	.asciiz ". Guesses left: "
GUESS_A_LETTER: .asciiz	"Guess a letter!\n"
FORFEIT:	.asciiz "**WORD FORFEITED** "
NO_GUESSES:	.asciiz "You have no more guesses.\n"
PLAY_AGAIN:	.asciiz "\nWould you like to play again (y/n)?\n"
ROUND_OVER:	.asciiz "Game over. Your final guess was: "
YOU_WIN:	.asciiz "You guessed it! The correct word was: "
CORRECT_WORD:	.asciiz "\nCorrect word was: "
.:		.asciiz ".\n"
TY:		.asciiz "Thanks for playing!"
NL:		.asciiz "\n"

# Board Stages
STAGE_0:	.asciiz "_______\n|   \n|     \n|   \n|    \n|\n|______\n"
STAGE_1:	.asciiz "_______\n|  0\n|     \n|   \n|    \n|\n|______\n"
STAGE_2:	.asciiz "_______\n|  0\n|  | \n|   \n|    \n|\n|______\n"
STAGE_3:	.asciiz "_______\n|  0\n|\\ | \n|   \n|    \n|\n|______\n"
STAGE_4:	.asciiz "_______\n|  0\n|\\ | /\n|   \n|    \n|\n|______\n"
STAGE_5:	.asciiz "_______\n|  0\n|\\ | /\n|  |\n|    \n|\n|______\n"
STAGE_6:	.asciiz "_______\n|  0\n|\\ | /\n|  |\n| /  \n|\n|______\n"
STAGE_7:	.asciiz "_______\n|  0\n|\\ | /\n|  |\n| / \\\n|\n|______\n"

# Words in File
FILE4: .asciiz "length4.txt"
FILE5: .asciiz "length5.txt"
FILE6: .asciiz "length6.txt"
FILE7: .asciiz "length7.txt"
FILE8: .asciiz "length8.txt"
FILE9: .asciiz "length9.txt"
FILE10: .asciiz "length10.txt"
FILE11: .asciiz "length11.txt"

.text
main:
	la	$a0, WELCOME			# prints welcome message
	jal 	print

initialize_game:


getWordLength:
	la	$a0, PROMPT			# prints initial prompt
	jal 	print
		
	li $v0, 5			
	syscall
	blt $v0, 4, getWordLength		#if less than 4 loop back
	bgt $v0, 11, getWordLength		#if greater than 11 loop back
	sw $v0, WORD_SIZE			#store in ChosenWordSize
	lw $t2, WORD_SIZE			#load word size in $t2 for getFile
	

getFile:					#case statement to get file for entered word length
	bne $t2, 4, len5
	la $a0, FILE4	
	j openFile
len5:	bne $t2, 5, len6
	la $a0, FILE5	
	j openFile
len6: 	bne $t2, 6, len7
	la $a0, FILE6	
	j openFile
len7: 	bne $t2, 7, len8
	la $a0, FILE7	
	j openFile
len8:	bne $t2, 8, len9
	la $a0, FILE8	
	j openFile
len9:	bne $t2, 9, len10
	la $a0, FILE9	
	j openFile
len10:	bne $t2, 10, len11
	la $a0, FILE10	
	j openFile
len11:	la $a0, FILE11	

openFile:	
	li	$v0, 13				# Open File Syscall
	li	$a1, 0				# Read-only Flag
	li	$a2, 0				# (ignored)
	syscall
	move	$s6, $v0			# Save File Descriptor
	
ReadFile:
	li	$v0, 14				# Read File Syscall
	move	$a0, $s6			# Load File Descriptor
	la	$a1, WORDS_IN_FILE 		# Load Buffer Address
	li	$a2, 1024			# Buffer Size
	syscall
	
getRandomNumber:
	xor $a0, $a0, $a0  			# Select random generator 0
	li $a1, 39				# Upper bound
	li $v0, 42   				# Random number syscall
	syscall
	
GetWordFromFile:
	mul $t4, $a0, 12			# Index of file
	li $t5, 0				# Loop Counter
	lw $t6, WORD_SIZE			# Chosen Word Size	
getNextChar:
	beq $t5, $t6, closeFile			# If equal jump to endloop
	la $a0, WORDS_IN_FILE($t4)		#load address of nth byte of string
	lb $t7, ($a0)				# load byte from byte address
	sb $t7, CHOSEN_WORD($t5)		# Store letters in Chosen Word
	addi $t5, $t5, 1			#increment loop counter
	addi $t4, $t4, 1			#increment string index
	j getNextChar		
	
closeFile:
	li	$v0, 16				# Close File Syscall
	move	$a0, $s6			# Load File Descriptor
	syscall		
 
doneGettingWord:
	la $a0, CHOSEN_WORD			#Load address of first character.
	li $a1, 32     				# allot the byte space for string

	jal 	play_round			# initiates the game

play_again:
	la	$a0, PLAY_AGAIN			# load the "play again" string
	jal	print				# print the "play again" string
	jal	prompt_char			# prompt for a reply from user
	
	beq	$v0, 121, initialize_game	# if input is == 'y', initialize new game (play again)
	bne	$v0, 110, play_again		# if not given 'y' or 'n', branch up to prompt again.
	
exit:	
	la 	$a0, TY				# loads a thank you message
	jal	print				# thanks the user for playing
	li	$v0, 10				# exits the program
	syscall
	
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#	play_round ( string )
#	Plays game round with string
#
#	$a0 = string
play_round:
	## Prologue ##
	addi	$sp, $sp, -24			# allocate 12 bytes
	sw	$ra, 0($sp)			# save return address
	sw	$a0, 4($sp)			# store current a0
	sw	$a1, 8($sp)			# store current a1
	sw	$s0, 12($sp)			# store current s0
	sw	$s1, 16($sp)			# store current s1
	sw	$s2, 20($sp)			# store current s2
	
	## Function ##
	jal	strlen				# get length, this call will be unnecessary when fully integrated
	addi	$v0, $v0, -1
	move	$s0, $v0			# store length in s0
	move	$s1, $a0			# save the string location
	
	# Set up the underscores
	la	$a0, GUESSED			# get the guessed word buffer
	move	$a1, $s0			# get the word length
	jal	fill_blanks			# fill the word with underscores
	move	$s0, $0
	addi	$s0, $s0, 7			# initialize the number of guesses (7) in s0
	
_round_loop:
	# DO WHILE ( score > 0 && underscores_present )
	beq	$s0, $0, _round_end_loop
		
	# _STATUS DISPLAY_
	la	$a0, WORD_IS			# print "The word is ___"
	jal	print
	la	$a0, GUESSED			# print the guessed word so far
	jal	print
	la	$a0, GUESSES_LEFT		# print score is
	jal	print
	move	$a0, $s0			# print actual score
	jal	print_int
	la	$a0, .				# print period
	jal	print
	
	# Output guess a letter prompt
	la	$a0, GUESS_A_LETTER		
	jal	print				# prints "Guess a letter"
	
	# Prompt for char
	jal	prompt_char			# prompt for character
	move	$s2, $v0			# save character entered in v0
	
	beq	$s2, 46, _round_forfeit		# if '.' is entered, end round
	
	# See if string contains char
	move	$a0, $s1			# move s1 (the location of the original word) into a0
	move	$a1, $s2			# move the char entered in a1
	jal	str_contains			# see if string contains character
	
	# If string does not contain the char, print NO, else print YES and update our guessed word.
	bne	$v0, $0, _round_char_found	# if return value != 0, we have success
	
	### IF Char match not found
	addi	$s0, $s0 -1			# wrong char, subtract 1 from score
	
	# Play wrong sound
	li 	$v0, 31				#syscall code for midi out
	li	$a0, 42				#pitch
	li	$a1, 500			#duration
	li	$a2, 111			#instrument
	li	$a3, 120			#volume
	syscall

	li	$v0, 32				#sleep code
	li 	$a0, 400			#sleep duration
	syscall
	li 	$v0, 31				#syscall code for midi out
	li	$a0, 41				#pitch
	li	$a1, 500			#duration
	li	$a2, 111			#instrument
	li	$a3, 110			#volume
	syscall

	li	$v0, 32				#sleep code
	li 	$a0, 400			#sleep duration
	syscall

	li 	$v0, 31				#syscall code for midi out
	li	$a0, 31				#pitch
	li	$a1, 500			#duration
	li	$a2, 111			#instrument
	li	$a3, 120			#volume
	syscall
	li	$v0, 32				#sleep code
	li 	$a0, 500			#sleep duration
	syscall

	li 	$v0, 31				#syscall code for midi out
	li	$a0, 68				#pitch
	li	$a1, 500			#duration
	li	$a2, 127			#instrument
	li	$a3, 127			#volume
	syscall
	
	# Character not found. Display "incorrect" message
	la	$a0, NO				# load "incorrect" message
	jal	print				# print "incorrect" message
 	jal	display_board			# displays current board
	beq	$s0, $0, _round_lose_end	# if guesses == 0, end round now
	
	j	_round_loop			# Guess again!
	
_round_char_found:
	# Char found, print "correct" message and update GUESSED
	
	# Play correct sound
	li 	$v0, 31				#syscall code for midi out
	li	$a0, 60				#pitch
	li	$a1, 300			#duration
	li	$a2, 12				#instrument
	li	$a3, 127			#volume
	syscall
	li	$v0, 32
	li	$a0, 150
	syscall
	li 	$v0, 31				#syscall code for midi out
	li	$a0, 62				#pitch
	li	$a1, 300			#duration
	li	$a2, 12				#instrument
	li	$a3, 127			#volume
	syscall
	li	$v0, 32
	li	$a0, 150
	syscall
	li 	$v0, 31				#syscall code for midi out
	li	$a0, 64				#pitch
	li	$a1, 300			#duration
	li	$a2, 12				#instrument
	li	$a3, 127			#volume
	syscall	
	li	$v0, 32
	li	$a0, 150
	syscall
	li 	$v0, 31				#syscall code for midi out
	li	$a0, 67				#pitch
	li	$a1, 300			#duration
	li	$a2, 12				#instrument
	li	$a3, 127			#volume
	syscall
	li	$v0, 32
	li	$a0, 150
	syscall
	li 	$v0, 31				#syscall code for midi out
	li	$a0, 72				#pitch
	li	$a1, 400			#duration
	li	$a2, 12				#instrument
	li	$a3, 127			#volume
	syscall
	
	# Update GUESSED
	la	$a0, GUESSED			# load address of GUESSED buffer
	move	$a1, $s1			# load address of the word
	move	$a2, $s2			# load the character the player just entered
	jal	update_guessed			# updated the GUESSED buffer with correct letters
	
	# If the GUESSED buffer contains underscores '_', continue
	la	$a0, GUESSED			# load GUESSED address for strcontains
	addi	$a1, $0, 95			# set a1 (the char) to 95 (the ascii value of underscore) for strcontains
	jal	str_contains			# check if GUESSED still has underscores
	beq	$v0, $0, _round_won_end	# if no underscores left in guess, user wins the round
	
	# Print yes
	la	$a0, YES			# load correct string
	jal	print				# print correct
	jal 	display_board			# displays current board

	j	_round_loop			# jump to top of loop
_round_forfeit:
	la	$a0, FORFEIT			# load forfeit message
	jal	print				# print forfeit message
	and	$s0, $s0, $0			# forfeit round? GAME OVER.
	j	_round_end_loop
_round_won_end:
	# Round victory message
	la	$a0, YOU_WIN			# displays victory message
	jal	print
	la	$a0, GUESSED			# display correct word
	jal	print
	j	_round_end_loop			# ends the game
_round_lose_end:
	la	$a0, NO_GUESSES			# load the string indicating no more guesses
	jal	print				# print that there are no more guesses
	la	$a0, ROUND_OVER			# Display round over message
	jal	print
	la	$a0, GUESSED			# display letters guessed
	jal	print
	la	$a0, CORRECT_WORD
	jal 	print	
	la	$a0, CHOSEN_WORD
	jal 	print
	
_round_end_loop:
	move	$v0, $s0			# move s0 (guesses) to v0 (return register)	
	## Return ##
	lw	$ra, 0($sp)			# load return address
	lw	$a0, 4($sp)			# load old a0
	lw	$a1, 8($sp)			# load old a1
	lw	$s0, 12($sp)			# load old s0
	lw	$s1, 16($sp)			# load old s1
	lw	$s2, 20($sp)			# load old s2
	addi	$sp, $sp, 24			# deallocate
	jr	$ra				# return
	
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#	update_guessed ( guessed, orig, char )
#	Will update the guessed word buffer with correctly guessed letters
#
#	$a0 = guessed buffer
#	$a1 = original string
#	$a2 = char
update_guessed:
	## Prologue ##
	addi	$sp, $sp, -8			# allocate 4 bytes
	sw	$a0, 0($sp)			# store old a0
	sw	$a1, 4($sp)			# store old a1
	
	## Function ##
_update_g_loop:
	lb	$t0, 0($a1)				# load char in from string
	beq	$t0, $0, _update_g_loop_end		# if we reach end of string, stop loop
	bne	$t0, $a2, _char_not_found		# if char doesn't match, branch
	sb	$a2, 0($a0)				# store passed in char in desired position.
_char_not_found:
	addi	$a0, $a0, 1				#increment guessed buffer
	addi	$a1, $a1, 1				#increment original string pos
	j	_update_g_loop

_update_g_loop_end:
	## Return ##
	lw	$a1, 4($sp)			# load old a1
	lw	$a0, 0($sp)			# load old a0
	addi	$sp, $sp, 8			# deallocate
	jr	$ra				# return
	
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#	strlen ( string )
#	gets length of string
#
#	$a0 = string	
#	
#	**** I realize this subroutine will be obsolete upon integration with Richard's code. ****
#	**** 			I only implemented it for testing purposes.		      ****
strlen:
	## Prologue ##
	addi	$sp, $sp, -4			#allocate 4 bytes
	sw	$a0, 0($sp)			# store current a0
	
	## Function ##
	and	$v0, $v0, $0			# set iterator to 0
_length_loop:
	lb	$t8, 0($a0)			# get the byte from the string	
	beq	$t8, $0, _length_loop_end	# If nul, quit loop
	
	addi	$a0, $a0, 1			# increment dest address
	addi	$v0, $v0, 1			# increment count
	
	j	_length_loop			# jump to top of loop

_length_loop_end:	
	## Return ##
	lw	$a0, 0($sp)			#load old a0
	addi	$sp, $sp, 4			#deallocate
	jr	$ra				#return
	
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#	str_contains ( string, char )
#	Checks to see if a string contains a given character
#	
#	$a0 = string
#	$a1 = char
#
#	Returns 0 if not found, 1 if found
str_contains:
	## Prologue ##
	addi	$sp, $sp, -4			# allocate 4 bytes
	sw	$a0, 0($sp)			# store old a0
	
	## Function ##
	and	$v0, $v0, $0			# set $v0 to 0 or FALSE
	
_str_contains_loop:
	lb	$t0, 0($a0)				# load char in from string
	beq	$t0, $0, _str_contains_loop_end		#if we reach end of string, stop loop
	beq	$t0, $a1, _char_found			#if char matches the passed in value, branch
	addi	$a0, $a0, 1				# increment string address to continue scanning
	j	_str_contains_loop			# jump to top of loop
_char_found:
	addi	$v0, $0, 1				# if char found, set return value = 1
_str_contains_loop_end:
	## Return ##
	lw	$a0, 0($sp)			# load old a0
	addi	$sp, $sp, 4			# deallocate
	jr	$ra				#return
	
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#	fill_blanks ( string, num )
#	Places num underscores into string
#	
#	$a0 = string
#	$a1 = num of underscores
fill_blanks:
	## Prologue ##
	addi	$sp, $sp, -8			# allocate 8 bytes
	sw	$a0, 0($sp)			# store current a0
	sw	$a1, 4($sp)			# store current a1
	
	## Function ##
	add	$a0, $a0, $a1			# a0 = address of string + length
	addi	$t1, $0, 95			# set t1 = ascii value for '_' underscore
	sb	$0, 0($a0)			# set last byte to nul
_fill_blanks_loop:
	beq	$a1, $0, _fill_blanks_loop_end	# if a1 < 0, we're done.
	addi	$a0, $a0, -1			# decrement buffer position
	addi	$a1, $a1, -1			# decrement length
	sb	$t1, 0($a0)			# store underscore
	j	_fill_blanks_loop		# back to start of loop
_fill_blanks_loop_end:
	## Return ##
	lw	$a0, 0($sp)			# load old a0
	lw	$a1, 4($sp)			# load old a1
	addi	$sp, $sp, 8			# deallocate
	jr	$ra				# return
	
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#	display_board( int )
#	Displays the current status of the board, based on int score
#	
#	$s0 = score
display_board:
	## Prologue ##
	addi	$sp, $sp, -8			# allocate 4 bytes
	sw	$ra, 0($sp)			# store old return address
	sw	$a0, 4($sp)			# store old a0
	
	## Function ##
	# Branches to the appropriate display based on number of guesses
	bge 	$s0, 7, display_zero
	beq	$s0, 6, display_one
	beq	$s0, 5, display_two
	beq	$s0, 4, display_three
	beq	$s0, 3, display_four
	beq	$s0, 2, display_five
	beq	$s0, 1, display_six
	beq	$s0, $0, display_seven
display_zero:	# Blank board
	la	$a0, STAGE_0
	jal 	print
	j	display_end
display_one:	# One limb on board
	la	$a0, STAGE_1
	jal 	print
	j	display_end
display_two:	# Two limbs on board
	la	$a0, STAGE_2
	jal 	print
	j	display_end
display_three:	# Three limbs on board
	la	$a0, STAGE_3
	jal 	print
	j	display_end
display_four:	# Four limbs on board
	la	$a0, STAGE_4
	jal 	print
	j	display_end
display_five:	# Five limbs on board
	la	$a0, STAGE_5
	jal 	print
	j	display_end
display_six:	# Six limbs on board
	la	$a0, STAGE_6
	jal 	print
	j	display_end
display_seven:	# Seven limbs on board
	la	$a0, STAGE_7
	jal 	print
	
	## Return ##
display_end:
	lw	$ra, 0($sp)			# load old return address
	lw	$a0, 4($sp)			# load old a0
	addi	$sp, $sp, 8			# deallocate
	jr	$ra				# return
	
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#	prompt_char()
#	Prompts for a character
prompt_char:
	## Prologue ##
	addi	$sp, $sp, -12			# allocate 4 bytes
	sw	$ra, 0($sp)			# store old return address
	sw	$a0, 4($sp)			# store old a0
	sw	$s0, 8($sp)			# store old s0
	
	## Function ##
	addi $v0, $0, 12			# 4 = print string syscall
	syscall					# v0 now contains a char
	move	$s0, $v0			# temporarily save char
	
	la	$a0, NL
	jal	print				# print newline
	jal	print				# print newline
	
	move	$v0, $s0			# move char back into return register
	
	## Return ##
	lw	$ra, 0($sp)			# load old return address
	lw	$a0, 4($sp)			# load old a0
	lw	$s0, 8($sp)			# load old s0
	addi	$sp, $sp, 12			# deallocate
	jr	$ra				# return
	
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#	print ( string )
#	Prints the null terminated string at given address
#	
#	$a0 = Address of string to print
print:
	## Function ##
	addi $v0, $0, 4				# 4 = print string syscall
	syscall
	
	## Return ##
	jr	$ra				#return
	
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#	print_int ( int )
#	Prints an int
#	
#	$a0 = Int to print
print_int:
	## Function ##
	addi $v0, $0, 1				# 1 = print int syscall
	syscall
	
	## Return ##
	jr	$ra				#return
