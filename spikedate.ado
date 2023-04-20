	* Spikedate
		capture program drop spikedate
		program define spikedate
		*! version 0.1  AH 5 Jan 2021 
		*! syntax: spikedate varname [if] [in], [P(percentile) myopt tw(twoway options) ]
			version 16
			syntax varlist(numeric min=1 max=1) [if] [in] [ , P(real 99.5) MYOPT TWopts(string asis) ] 
			marksample touse
			preserve
			qui drop if !`touse'	
			tempvar cutoff
			egen `cutoff' = pctile(`varlist'), p(`p')
			local j = `cutoff'
			spikeplot `varlist', xline(`j', lcolor(black)) `twopts' subtitle("Cutoff: `: di %4.2fc `p'' th percentile = `: di %tdD_m_CY `j''") ///
			note("Black line represents `: di %4.2fc `p'' th percentile") ///
			graphregion(color(white))
		end