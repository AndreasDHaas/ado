capture program drop fdiag
program define fdiag
* version 2.0  AH 22 April 2022 
	capture gen icd10_code ="" // generate icd10_code & source to trick syntax chekcing (if variable has to exist)
	capture gen source =""
	syntax newvarname using if , [ MINAGE(integer 0) MINDATE(string) MAXDATE(string) LABel(string) N Y LIST(integer 9999) listall(integer 9999)] 
	capture drop icd10_code // drop icd10_code and source variable 
	capture drop source 
	* confirm newvarname does not exist 
	capture confirm variable `varlist'_d
	if !_rc {
		display in red "`varlist' already exists"
		exit 198
	}
	qui preserve
	use `using', clear
	* generate indicator variable sepcified in newvarname
	qui gen `varlist'_y = 1
	* select relevant diagnoses 
	marksample touse
	qui drop if !`touse'
	* list 
	if "`listall'" !="9999" {
		di " --- listall start ---"
		listif patient icd10_date icd10_code source, id(patient) sort(patient icd10_date) n(`list')  sepby(pat) 
		di " --- listall end ---"
	}
	* select age 
	capture mmerge patient using "$clean/BAS", ukeep(birth_d) unmatched(master)
	if "`minage'" !="" qui drop if floor((icd10_date - birth_d)/365) < `minage'
	qui drop birth_d 
	* select time 
	if "`mindate'" != "" qui drop if icd10_date < `mindate'
	if "`maxdate'" != "" qui drop if icd10_date > `maxdate'
	if "`list'" !="9999" {
		di " --- list start ---"
		listif patient icd10_date icd10_code source, id(patient) sort(patient icd10_date) n(`list')  sepby(pat) 
		di " --- list end ---"
	}
	* Number of diagnoses 
	qui bysort patient icd10_date: keep if _n ==1
	qui bysort patient (icd10_date): gen `varlist'_n =_N
	* select first diag event 
	qui bysort patient (icd10_date): keep if _n ==1
	* clean
	qui keep patient icd10_date `varlist'_y `varlist'_n
	* event date 
	qui rename icd10_date `varlist'_d
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
