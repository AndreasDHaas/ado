	* program used in C:\Users\haas\Dropbox\Do\IeDEA\FB\v6\20_DATA_MANAGEMENT\20_12_CENTRAL_DATA_MONITORING to calculate row percentages
			capture program drop rowp 
			program define rowp
				preserve
				assert inlist(`1', 0, 1, 9) 
				count 
				if `r(N)'==0 {
					clear
					gen var = "`2'"
					gen prc0 = 0
					gen prc1 = 0
					gen prc9 = 0
					gen prc10 = 100
					gen n0 = 0
					gen n1 = 0
					gen n9 = 0
					gen n10 = 0
					save "$temp/rownp_`1'", replace
				}
				else {	
					contract  `1' var, freq(n) percent(prc) zero  format(%8.0f) 
					* Add missing categories 
					foreach j in 0 1 9 {
						count if `1' ==`j'
						if `r(N)'==0 {
							set obs `=_N+1'
							replace `1' = `j' if _n ==_N
							replace n = 0 if _n ==_N
							replace prc = 0 if _n ==_N
						}
					}
					* Add total 
					set obs `=_N+1'
					replace `1' = 10 if _n ==_N
					summarize n
					replace n = `r(sum)' in `=_N'
					summarize prc
					replace prc = `r(sum)' in `=_N'
					sort `1'
					* Reshpae
					reshape wide n prc, i(var) j(`1')
					replace var = "`2'"
					list
					save "$temp/rownp_`1'", replace
				}
					restore
			end
		