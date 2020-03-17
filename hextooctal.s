
	.arch	armv7
	.cpu	cortex-a53
	.fpu	neon-fp-armv8
	.global	main
	.text

main:

st:
	@ask user to input hex 
	mov	R0, #1
	ldr	R1, =inprompt
	mov	R2, #inpromptlen
	bl	write
	
	@read  what user typed
	mov	R0, #0
	ldr	R1, =inbuff
	mov	R2, #inbufflen
	bl	read	

	/*
	  check if user typed 8 characters + return key(thats why 9).
	  if yes go to is8 function, else go to isNot8 function.
	*/
	cmp	R0, #9
	bne	isNot8

/*
  load inbuff address to R3. 
  check last one is return key, so its 8 characters not more.
  Here i am going to start a loop, tocheck if what user entered is 0-9 or a-f or A-F.
*/
is8:	
	ldr	r3, =inbuff 
	ldrb    r4,[r3,#8] @loading 9th character into r4.
	cmp     R4,#10 @checking if 9th character is return key
	bne     clearKeyboardBuffer     @if not restart 
        mov     r10,#0 @ index 0 of loop, into r10
        mov     r11, #7 @ we need to check until index 7, that goes into R11.

/*
  in first loop r10 is 0, so am loading that first byte of inbuff into R4.
  i am subtracting -48, and if it falls in 0-9 range than its correct. I branch to validationLoopUpdate
  else if its not 0-9, than i call validationloopupper to check if its A-F.
*/
validationLoopDigit:
      ldrb       r4 ,[r3,r10]  
      sub        r6,r4,#'0'
      cmp        R6, #9
      blt        validationLoopUpdate
      

/*
  here i am subtracting -65, and if it falls in 0-6 range than its correct. I branch to validationLoopUpdate
  else if its not A-F, than i call validationlooplower to check if its a-f.
*/
validationLoopUpper:
         ldrb    r4, [r3,r10]
         sub     r6,r4,#'A'
         cmp     R6, #6
         blt     validationLoopUpdate
  
/*
  here i am subtracting -32 as first step, so that I change the lowercase letter a to uppercase letter A
  and in line strb r7,[r3,r10] i am changing lowercase letter into uppercase.So in case user typed aaaaaaaa
  it is now AAAAAAAA
  i am subtracting again  -65, and if it falls in 0-6 range than its correct. I branch to validationLoopUpdate
  else if its not a-f, than i call isNotValidFormat. 
*/
validationLoopLower:
	ldrb    r6, [r3,r10] @load character at index r10 into r6.
	sub     r8,r6,#32    @ since this character is neither 0 - 9 or A - F, do minus 32. As small a = 97, 97-32 = 65 = A.
	strb    r8,[r3,r10] @ store this new in place of old character, so 'a' gets updated with being "A".
        ldrb    r4, [r3,r10] 
        sub     r6,r4,#'A'
        cmp     R6, #6
	bge     isNotValidFormat 

/*
  here I upadte the loop index and call validationloopdigit again, unless it reached its end
  if it reached end I call startCalculation.
*/
validationLoopUpdate:
	add        r10, r10, #1 @update loop index by 1.
        cmp        r10,r11 
        ble        validationLoopDigit

/*
  so first step i am going to loop over each character.
  I will call loop to do this. loop will subtract 48 from 0-9 entered, and 55 from A-F entered. 
  Note the a-f entered is now A-F, so they will be subtracted 55 too.
  after loop over, call donewithcalculation
*/
startCalculation:
        mov     r9,#7
        mov     r10,#0
        mov	R12, #0
        mov     r11, #7
        cmp     R2, #9
        beq     loop

/*
  i will call printResult to see result of calculation.
  Unless last character is not return key, i am calling done2.
*/
doneWithCalculation: 
	sub	r5, r0, #1
	b	printResult

done2:	
	mov	R5, R0	  


/*
  this function will print to user that he must enter 8 characters + return key.
  will go back to st , start of app. to ask user to enter hex again.
*/
isNot8:
	mov    r0, #1
        ldr    r1, =error
        mov    r2, #errorlen 
        bl     write
	b      st

/*
  this will clear buffer in case more than 8 characters typed.
  It will read 9 more extra characters, if not 9 characters  we call isNot8.
  If 9 characters, we load into r3. And check if last one is return key 
  if its return key we call isNot8, else we call clearKeyboardBuffer to continue clearing next part.
*/
clearKeyboardBuffer:
	mov	R0, #0
	ldr	R1, =inbuff
	mov	R2, #inbufflen
	bl	read
	cmp	R0,#9 
	bne     isNot8
	ldr	r3, =inbuff 
	ldrb    r4,[r3,#8] 
	cmp     R4,#10 
	beq     isNot8     
	b	clearKeyboardBuffer

/*
  this function will print to user that he must enter only 0-9 a-f or A-F.
  will go back to st , start of app. to ask user to enter hex again.
*/
isNotValidFormat:
	mov    r0, #1
        ldr    r1, =invalidFormatMessage
        mov    r2, #invalidFormatMessagelen 
        bl     write
        b      st

@print the final result of calculation.
printResult:
	mov	R0, #1
	ldr	R1, =answerP1
	mov	R2, #(answerlenP1+inbufflen+answerlenP2+outbufflen)
	bl	write
	mov	R0, #0
	mov	R7, #1
	swi	0

@start loop,and call subtract 48 if its between 0 - 9 , and subtract 55 if its between A-F.
loop:
        ldrb       r8 ,[r3,r10]  @load first byte of inbuff to r8   
        sub        r6,r8,#'0' @ let assume first byte is 'A'. We are doing 65-48 in that case.

	@ see if result falls below 10 , to subtract 48. else subtract 55.
        cmp        R6, #10 
        bge        subtract55

/*
  subtract 48, converting ascii character to numerical value.
  call convertTOBinary 
*/
subtract48:    
         sub        r8,r8,#'0'
         b         convertToBinary
	 
 
/*
  subtract 55, converting ascii character to numerical value.   
  call convertTOBinary  
*/
subtract55:   
         sub        r8,r8,#55

@if loop is done, go toOctal.
convertToBinary:
	/*
	   this is like multiplying by 16.lets assume user entered abababab
	   first loop we are shifting by 4. so its 0000+1010
	   second loop we shift by 4 it becomes 1010 0000. we add b to it
	   1010 0000 + 1011 = 1010 1011
	   third loop we shift by 4, it becomes
	   1011 1011 0000 we add a to it. 
	   1011 1011 0000 + 1010 = 1011 1011 1010
	   we do this until we get our hex into binary correct.
	*/
        add        r12,r8,r12,LSL#4

        add        r10, r10, #1 @update loop index
        cmp        r10,r11
        ble        loop

/*
  below 3  toOctal loopToOctal, and chOct.
  we will loop, once we are done with loop we printResult.
  We shift right by 30 bit first time to get the first 2 bits.
  then  27 shifts in next loop,then 24, 21, 18, 15,12,9,6,3,0 . the other groups of 3.
*/

toOctal:
	ldr R5, =outbuff
	mov r9,#0
	mov r10,#30
	cmp r10,r9
	beq printResult
	b chOct

loopToOctal:
	sub r10, r10, #3
        mov r11,#'0'
	cmp r10,r9
	blt printResult

chOct:
	LSR r8,r12,r10 @shift right , 30 in first loop. 27 second.24,21...0
	AND r8,r8,#0b111 @and operation
        add r8,#'0' @add 48 to this value that is between 0-7 to get the corresponding character index

	@putting  result calculated into outbuff.We increment r5 by 1 every loop, to like append result.
	strb r8,[R5],#1 

	b loopToOctal


	.data
inprompt: .ascii	"Please enter hexadecimal  string:\n"
	.equ	inpromptlen, (.-inprompt)
answerP1:	.ascii	"The hex value entered is:  "
	.equ	answerlenP1, (.-answerP1)
inbuff:	.space	9, 0
	.equ	inbufflen, (.-inbuff)
answerP2:	.ascii	"Octal equvalent is: "
	.equ	answerlenP2, (.-answerP2)
outbuff: .space	11, 0
	.ascii	"\n"
	.equ	outbufflen, (.-outbuff)
error: .ascii   "Error, should be 8 characters \n"
       .equ     errorlen, (.-error)
invalidFormatMessage: .ascii "Enter 0-9 A-F a-f only \n"
        .equ invalidFormatMessagelen, (.-invalidFormatMessage)
