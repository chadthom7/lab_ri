	.text
#-------------------------------------------------------------------------------------------
	li 	$2,429496730	#regs(2) <= 0.1    # li is split into lui and ori when compiled
	li	$3,10		#regs(3) <= 10
	li	$4, 23456789	#user input (replace with sra) sra $11, $11, 0
	
	multu	$4,$2			#have to use mult unsigned, bc if > .5, most sig decimal bit is 1	
					#  which can be read as decimal bit  
	mfhi	$4		#regs(4) <= whole part of product
	mflo	$5		#regs(5) <= fractional part of product
	multu	$5,$3
	mfhi	$5		#regs(5 <= modulo value
	sll	$5,$5,28		
	srl	$6,$6,4
	or	$6,$6,$5

	# copy 7 more times
#-------------------------------------------------------------------------------------------
	multu	$4,$2			#have to use mult unsigned, bc if > .5, most sig decimal bit is 1	
					#  which can be read as decimal bit
					#insert srl here to output register 6 to hexdisplays
	mfhi	$4		#regs(4) <= whole part of product
	mflo	$5		#regs(5) <= fractional part of product
	multu	$5,$3
	mfhi	$5		#regs(5 <= modulo value
	sll	$5,$5,28		
	srl	$6,$6,4
	or	$6,$6,$5
#-------------------------------------------------------------------------------------------
	multu	$4,$2			#have to use mult unsigned, bc if > .5, most sig decimal bit is 1	
					#  which can be read as decimal bit
					#insert srl here to output register 6 to hexdisplays
	mfhi	$4		#regs(4) <= whole part of product
	mflo	$5		#regs(5) <= fractional part of product
	multu	$5,$3
	mfhi	$5		#regs(5 <= modulo value
	sll	$5,$5,28		
	srl	$6,$6,4
	or	$6,$6,$5
#-------------------------------------------------------------------------------------------
	multu	$4,$2			#have to use mult unsigned, bc if > .5, most sig decimal bit is 1	
					#  which can be read as decimal bit
					#insert srl here to output register 6 to hexdisplays
	mfhi	$4		#regs(4) <= whole part of product
	mflo	$5		#regs(5) <= fractional part of product
	multu	$5,$3
	mfhi	$5		#regs(5 <= modulo value
	sll	$5,$5,28		
	srl	$6,$6,4
	or	$6,$6,$5
#-------------------------------------------------------------------------------------------
	multu	$4,$2			#have to use mult unsigned, bc if > .5, most sig decimal bit is 1	
					#  which can be read as decimal bit
					#insert srl here to output register 6 to hexdisplays
	mfhi	$4		#regs(4) <= whole part of product
	mflo	$5		#regs(5) <= fractional part of product
	multu	$5,$3
	mfhi	$5		#regs(5 <= modulo value
	sll	$5,$5,28		
	srl	$6,$6,4
	or	$6,$6,$5
#-------------------------------------------------------------------------------------------
	multu	$4,$2			#have to use mult unsigned, bc if > .5, most sig decimal bit is 1	
					#  which can be read as decimal bit
					#insert srl here to output register 6 to hexdisplays
	mfhi	$4		#regs(4) <= whole part of product
	mflo	$5		#regs(5) <= fractional part of product
	multu	$5,$3
	mfhi	$5		#regs(5 <= modulo value
	sll	$5,$5,28		
	srl	$6,$6,4
	or	$6,$6,$5
#-------------------------------------------------------------------------------------------
	multu	$4,$2			#have to use mult unsigned, bc if > .5, most sig decimal bit is 1	
					#  which can be read as decimal bit
					#insert srl here to output register 6 to hexdisplays
	mfhi	$4		#regs(4) <= whole part of product
	mflo	$5		#regs(5) <= fractional part of product
	multu	$5,$3
	mfhi	$5		#regs(5 <= modulo value
	sll	$5,$5,28		
	srl	$6,$6,4
	or	$6,$6,$5
#-------------------------------------------------------------------------------------------
	multu	$4,$2			#have to use mult unsigned, bc if > .5, most sig decimal bit is 1	
					#  which can be read as decimal bit
					#insert srl here to output register 6 to hexdisplays
	mfhi	$4		#regs(4) <= whole part of product
	mflo	$5		#regs(5) <= fractional part of product
	multu	$5,$3
	mfhi	$5		#regs(5 <= modulo value
	sll	$5,$5,28		
	srl	$6,$6,4
	or	$6,$6,$5
