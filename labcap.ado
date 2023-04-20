	
capture program drop labcap
program define labcap
* version 1.0  AH 18 Apr 2023 
	syntax varname // labcap varname 
		local labname: value label `varlist'
		lab list `labname'
		levelsof `varlist'
		foreach j in `r(levels)' {
			local lab: label (`varlist') `j'
			local new = upper(substr("`lab'", 1, 1)) + lower(substr("`lab'", 2, .)) 
			lab define `labname' `j' "`new'" , modify  
		}
		lab list `labname' 
	end