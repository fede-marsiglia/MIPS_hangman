#=================================================DATA===========================================================
.data

askIndex: 	    .asciiz "\nscegli una parola (da 1 a 5): "
invalidIndex:   .asciiz "\nindice non valido!\n"
prompt:		    .asciiz "\n\n> "
lossMessage:    .asciiz "\n\nHai perso! Vuoi giocare ancora? (0 -> no, != 0 -> si)"
winMessage:	    .asciiz "\n\nHai vinto! Vuoi giocare ancora? (0 -> no, != 0 -> si) "
repeated:	    .asciiz "\n\nHai già inserito questa lettera."

wList:		    .asciiz "l e t t i e r a"
.asciiz "c a m e r l e n g o"
.asciiz "f u r e t t o"
.asciiz "p i s t i l l o"
.asciiz "p i p i s t r e l l o"

thrown:		    .space 21

noErr:		    .asciiz "\n\n|/---\n|\n|\n|\n|____\n\n"
oneErr:		    .asciiz "\n\n|/---\n|  o\n|\n|\n|____\n\n"
twoErr:		    .asciiz "\n\n|/---\n|  o\n|  |\n|\n|____\n\n"
threeErr:	    .asciiz "\n\n|/---\n|  o\n| /|\n|\n|____\n\n"
fourErr:	    	 .asciiz "\n\n|/---\n|  o\n| /|\\n|\n|____\n\n"
fiveErr:	     	 .asciiz "\n\n|/---\n|  o\n| /|\\n| /\n|____\n\n"
dead:		     	 .asciiz "\n\n|/---\n|  o\n| /|\\n| / \\n|____\n\n"
							
#==================================================MAIN===========================================================
						.text 
																
main:					li 	 $v0,4
						la 	 $a0,askIndex
						syscall 			
							
						li 	 $v0,5
						syscall
							
						la  	 $a0,wList
						move   $a1,$v0
						jal    wordPointer
						bne    $v0,$zero,invalidIndex_
						move   $s0,$v1									# s0 = indirizzo parola da indovinare
							
						move   $a0,$s0
						jal    gameSetup
						move   $s1,$v0									# s1 = indirizzo lettere indovinate
							
						move   $s2,$zero								# s2 = numero errori
						li 	 $s3,6									# s3 = max errori

gameLoop:			move   $a0,$s2
						jal	 printHangMan
												
						beq	 $s2,$s3,loss_
						
						move   $a0,$s1
						jal    victoryCheck
						bne    $v0,$zero,win_
												
						li 	 $v0,4
						move   $a0,$s1
						syscall 
						
prompt_:				la 	 $a0,prompt
						syscall
							
						li 	 $v0,12
						syscall	
						move   $s4,$v0									# s4 = input utente	

						move   $a0,$s4
						la 	 $a1,thrown
						jal	 inputCheck
					
						bne	 $v0,$zero,repeated_
							
						move   $a0,$s0
						move   $a1,$s1
						move   $a2,$s4
						jal    wordCheck
						
						bne    $v0,$zero,gameLoop
						
						addi   $s2,$s2,1								# numero errori++
						j 	    gameLoop
							 
loss_:				li 	 $v0,4
						move   $a0,$s0
						syscall
						la     $a0,lossMessage
						syscall
						j 	    playAgain
						
win_:					li 	 $v0,4
						move   $a0,$s0
						syscall
						la 	 $a0,winMessage
						syscall
						
playAgain:			li 	 $v0,5
						syscall
						beq    $v0,$zero,endGame
						
						la 	 $a0,thrown
						jal    reset
						j 	    main
							
endGame:				li 	 $v0,10
						syscall

#============================================GESTIONE ECCEZIONI================================================
						
repeated_:			li 	 $v0,4
						la 	 $a0,repeated
						syscall
						j 	    prompt_
						
invalidIndex_:		li 	 $v0,4
						la 	 $a0,invalidIndex
						syscall
						j 	    main
							
#================================================================================================================	
# inizializza un array di underscore e spazi bianchi lungo quanto la parola da indovinare. 
# restituisce un puntatore all'array.
#================================================================================================================	 						
																
gameSetup:			addi   $sp,$sp,-4
						sw     $ra,0($sp)

						jal    stringLength
						move   $t0,$v0						
						
						move   $a0,$t0
						li 	 $v0,9
						syscall	
							
						move   $a0,$v0						
						add    $a1,$a0,$t0						
						jal    stringInit	

						lw 	 $ra,0($sp)
						addi   $sp,$sp,4
						j 	    $ra 
							
#================================================================================================================
# riceve un puntatore alla lista delle parole da indovinare e l'indice di parola scelto dall'utente.
# restituisce '0' in $v0 se l'indice è valido, 'not 0' altrimenti. 
# restituisce un puntatore alla parola scelta in $v1.
#================================================================================================================
					
wordPointer:		li	    $t0,1
						move   $v0,$zero

retry:				beq	 $t0,$a1,WPreturn						# $a1 = indice parola  
						addi 	 $a0,$a0,1 								# $a0 = puntatore a carattere
						lb	    $t1,0($a0)
						bne	 $t1,$zero,retry
						addi   $a0,$a0,1
						addi   $t0,$t0,1
						lb 	 $t1,0($a0)
						bne    $t1,$zero,retry
						not    $v0,$v0
						j 	    $ra 
						
WPreturn:			move   $v1,$a0
						j 	    $ra
					
#================================================================================================================
# riceve il numero di errori commessi e stampa a video l'impiccato sulla base di questi ultimi.
#================================================================================================================

printHangMan:		li	    $v0,4
						move   $t0,$zero
						beq    $a0,$t0,noErr_
						addi   $t0,$t0,1
						beq    $a0,$t0,oneErr_
						addi   $t0,$t0,1
						beq    $a0,$t0,twoErr_
						addi   $t0,$t0,1
						beq    $a0,$t0,threeErr_
						addi   $t0,$t0,1
						beq    $a0,$t0,fourErr_
						addi   $t0,$t0,1
						beq    $a0,$t0,fiveErr_
						j 	    dead_

noErr_:				la     $a0,noErr
						syscall
						j 	    $ra
						
oneErr_:				la     $a0,oneErr
						syscall
						j 	    $ra
						
twoErr_:				la     $a0,twoErr
						syscall
						j 	    $ra
						
threeErr_:			la     $a0,threeErr
						syscall
						j 	    $ra
						
fourErr_:			la     $a0,fourErr
						syscall
						j 	    $ra 
						
fiveErr_:			la     $a0,fiveErr
						syscall
						j 	    $ra 
						
dead_:				la     $a0,dead
						syscall
						j 	    $ra 
	
#================================================================================================================
# riceve l'indirizzo base e di fine di un array e lo inizializza con underscore e spazi bianchi.
#================================================================================================================
							
stringInit:			addi   $sp,$sp,-4					
						sw 	 $ra,0($sp)
							
						beq    $a0,$a1,SIreturn
						
						li 	 $t0,2
						div    $a0,$t0
						mfhi   $t0
						beq    $t0,$zero,underscore
							
						li	    $t0,32								# codice ascii "spazio"					
						sb	    $t0,0($a0)
						j 	    repeat		
underscore:			li 	 $t0,95								# codice ascii "underscore"
						sb 	 $t0,0($a0)
repeat:				addi   $a0,$a0,1
						jal    stringInit
							
SIreturn:			lw 	 $ra,0($sp)					
						addi   $sp,$sp,4
						j 	    $ra
							
#================================================================================================================
# riceve 2 indirizzi ad array e un carattere.
# controlla se il carattere é presente nel primo array e nel qual caso lo sostituisce nelle corrispondenti posizioni del secondo.
# restituisce 0 se il carattere è presente.
#================================================================================================================
							
wordCheck:			move   $v0,$zero
						
loop2:				lb 	 $t0,0($a0)
						beq    $t0,$zero,WCreturn
						bne    $t0,$a2,nextLetter
							
						sb 	 $t0,0($a1)
						li	 	 $v0,1				
							
nextLetter:			addi 	 $a0,$a0,1
						addi   $a1,$a1,1
						j 	    loop2
						
WCreturn:			j  	 $ra
							
#================================================================================================================
# riceve un puntatore ad una stringa.
# restituisce la lunghezza della stringa.
#================================================================================================================

stringLength:		move   $v0,$zero
							
calc:					lb 	 $t0,0($a0)			
						beq    $t0,$zero,SLreturn
						addi   $a0,$a0,1						
						addi   $v0,$v0,1						
						j 	    calc
SLreturn:			j 	    $ra 

#================================================================================================================		
# riceve un puntatore all'array di underscore e spazi bianchi.
# restituisce 1 se la parola è stata indovinata.
#================================================================================================================											
							
victoryCheck: 		lb 	 $t0,0($a0)
						beq    $t0,$zero,VCreturn
						li 	 $t1,95									# codice ascii "underscore"
						beq    $t0,$t1,notGuessed 
						addi   $a0,$a0,1
						j 	    victoryCheck
						
notGuessed:			move   $v0,$zero
						j 	    $ra

VCreturn:			li 	 $v0,1 
						j  	 $ra
						
#================================================================================================================		
# riceve in input il carattere immesso dall'utente e un puntatore all'array di caratteri già utilizzati.
# restituisce "0" se il carattere non è ancora stato utilizzato, "not 0" altrimenti.	
#================================================================================================================		

inputCheck:			move 	 $t0,$zero

loop:					lb 	 $t1,0($a1)
						beq    $t1,$a0,contained
						beq	 $t1,$zero,endCheck
						addi   $a1,$a1,1
						j 	    loop
						
contained:			not    $t0,$t0
						j	    ICreturn

endCheck:			bne	 $t0,$zero,ICreturn
						sb	    $a0,0($a1)
						
ICreturn:			move   $v0,$t0
						j 	    $ra
			
#================================================================================================================
# riceve in input un puntatore all'array di lettere già inserite dall'utente.
# setta tutte le celle dell'array a "0".
#================================================================================================================

reset:				lb	    $t0,0($a0)
						beq	 $t0,$zero,Rreturn
						sb	    $zero,0($a0)
						addi   $a0,$a0,1
						j 	    reset
Rreturn:				j	    $ra						

						
							

							
				
