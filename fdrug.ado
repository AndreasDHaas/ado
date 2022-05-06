capture program drop fdrug
program define fdrug
* version 2.0  AH 22 April 2022 
	capture gen med_id ="" // generate med_id to trick syntax checking (if variable has to exist)
	syntax newvarname using if , [ MINAGE(integer 0) MINDATE(string) MAXDATE(string) LABel(string) N Y LIST(integer 9999) listall(integer 9999)]
	drop med_id
	* confirm newvarname does not exist 
	capture confirm variable `varlist'_d
	if !_rc {
		display in red "`varlist' already exists"
		exit 198
	}
	qui preserve
	qui use `using', clear
	* generate indicator variable sepcified in newvarname
	qui gen `varlist'_y = 1
	* select relevant medications 
	marksample touse
	qui drop if !`touse'
	* list 
	if "`listall'" !="9999" {
		di " --- listall start ---"
		listif patient med_sd med_id quantity nappi_code nappi_suffix nappi_description, id(patient) sort(patient med_sd) n(`list')  sepby(pat) 
		di " --- listall end ---"
	}
	* drop medication that was returned or zero quant
	qui bysort patient med_sd nappi_code: egen quantity1 = total(quantity)
	qui replace quantity = quantity1
	qui drop quantity1
	qui drop if quantity <=0 
	* select age 
	qui capture mmerge patient using "$clean/BAS", ukeep(birth_d) unmatched(master)
	if "`minage'" !="" qui drop if floor((med_sd - birth_d)/365) < `minage'
	qui drop birth_d 
	* select time 
	if "`mindate'" != "" qui drop if med_sd < `mindate'
	if "`maxdate'" != "" qui drop if med_sd > `maxdate'
	if "`list'" !="9999" {
		di " --- list start ---"
		listif patient med_sd med_id quantity nappi_code nappi_suffix nappi_description, id(patient) sort(patient med_sd) n(`list')  sepby(pat) 
		di " --- list end ---"
	}
	* Number of claims 
	qui bysort patient med_sd: keep if _n ==1
	qui bysort patient (med_sd): gen `varlist'_n =_N
	
	* select first medicaton event 
	qui bysort patient (med_sd): keep if _n ==1
	* clean
	qui keep patient med_sd `varlist'_y `varlist'_n
	* event date 
	qui rename med_sd `varlist'_d
	* label 
    if "`label'" != "" {
		label define  `varlist'_y 1 "`label'" 
		lab val `varlist'_y `varlist'_y
	}
	* order and apply n and y options
	order patient `varlist'_d `varlist'_y `varlist'_n
    if "`n'" == "" drop `varlist'_n
    if "`y'" == "" drop `varlist'_y	
	* save events
	qui tempfile events
	qui save `events'
	* merge events to original dataset 
	restore 
	qui merge 1:1 patient using `events', keep(match master) nogen
	if "`y'" != "" qui replace `varlist'_y = 0 if `varlist'_y ==. 
end
