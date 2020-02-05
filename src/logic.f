8 CONSTANT WORD_SIZE 

VARIABLE CURRENT_VALUE
VARIABLE LAST_VALUE
VARIABLE STATUS
VARIABLE OPERATION

: ADDITION  + ;
: SUBTRACTION  - ;
: MULTIPLICATION  * ;
: DIVISION 					\ There's an additional check for division by zero
	DUP 0 <> 
	IF
		OVER 0 < OVER 0 <	\ sign of the two operands
		XOR 	 				\ Checks if the two operands have differt sign
		IF
			-1
		ELSE
			1
		THEN
			ROT ABS ROT ABS /			 	\ Performs division on the absolute values
			*									\ Adjusts for sign
	ELSE
		DROP DROP -1
	THEN ;
: EQUALS -1 ;

CREATE OP_SET ' ADDITION , ' SUBTRACTION , ' MULTIPLICATION , ' DIVISION , EQUALS ,

\ Bit twiddling 
: ?OVERFLOW 
	STATUS @ SWAP
	DUP
	[ 1 WORD_SIZE 1 -  LSHIFT  1 - ] LITERAL >	\ Upper bound of interval
	SWAP
	[ 1 WORD_SIZE 1 - LSHIFT NEGATE ] LITERAL <	\ Lower bound of interval
	OR
	IF 
		1 OR  
	ELSE
		[ 1 INVERT ] LITERAL AND
	THEN 	
	STATUS ! ;

: ?NEGATIVE 
	STATUS @ SWAP
	[ 1 31 LSHIFT ]  LITERAL AND 0 <> 
	IF
		2 OR
	ELSE
		[ 2 INVERT ] LITERAL AND
	THEN
	STATUS ! ;

: TRUNCATE DUP ?OVERFLOW [ 1 WORD_SIZE LSHIFT 1 - ] LITERAL AND ;

: EXTEND_SIGN [ 1 WORD_SIZE 1 - LSHIFT ] LITERAL DUP ROT XOR SWAP - DUP ?NEGATIVE ;

: STORE_VALUE TRUNCATE EXTEND_SIGN CURRENT_VALUE ! ;

: COMPUTE_RESULT 
	LAST_VALUE @ CURRENT_VALUE @ OPERATION @ EXECUTE STORE_VALUE ;

: PREPARE_NEXT 
	CURRENT_VALUE @ LAST_VALUE ! ;



0 CURRENT_VALUE !
0 LAST_VALUE !
0 STATUS !
' ADDITION OPERATION !
