* Assertunique: asserts that varlist uniquely identifies records 
	capture program drop assertunique
	program define assertunique 
		syntax [varlist] [if] [in]
		marksample touse, novarlist	
		preserve
		qui drop if !`touse'
		gunique `varlist'
		assert `r(maxJ)' ==1
	end