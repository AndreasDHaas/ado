capture program drop fhosp
program define fhosp
* version 2.0  AH 22 April 2022 
	* generate variables to trick syntax chekcing (if variable has to exist)
	capture gen duration = . 
	capture gen adm_date = . 
	capture gen dis_date = . 
	capture gen code_type = ""
	capture gen hosp_code =""
	capture gen code_role = . 
	* syntax 
	syntax newvarname using if , [ MINAGE(integer 0) MINDATE(string) MAXDATE(string) LABel(string) N Y LIST(integer 9999) listall(integer 9999)] 
	* drop generated variables 
	capture drop duration 
	capture drop adm_date 
	capture drop dis_date 
	capture drop code_type 
	capture drop hosp_code 
	capture drop code_role 
	* confirm newvarname does not exist 
	capture confirm variable `varlist'_d
	if !_rc {
		display in red "`varlist' already exists"
		exit 198
	}
	qui preserve
	* open using table 
	use `using', clear
	* generate indicator variable sepcified in newvarname
	qui gen `varlist'_y = 1
	* keep if selection 
	marksample touse
	qui drop if !`touse'
	* list 
	if "`listall'" !="9999" {
		di " --- listall start ---"
		listif patient adm_date dis_date duration code_type hosp_code code_role code_description, id(patient) sort(patient adm_date) n(`list')  sepby(pat) 
		di " --- listall end ---"
	}
	* select age 
	capture mmerge patient using "$clean/BAS", ukeep(birth_d) unmatched(master)
	if "`minage'" !="" qui drop if floor((adm_date - birth_d)/365) < `minage'
	qui drop birth_d 
	* select time 
	if "`mindate'" != "" qui drop if adm_date < `mindate'
	if "`maxdate'" != "" qui drop if adm_date > `maxdate'
	if "`list'" !="9999" {
		di " --- list start ---"
		listif patient adm_date dis_date duration code_type hosp_code code_role code_description, id(patient) sort(patient adm_date) n(`list')  sepby(pat) 
		di " --- list end ---"
	}
	* number of events 
	qui bysort patient adm_date: keep if _n ==1
	qui bysort patient (adm_date): gen `varlist'_n =_N
	* select first event 
	qui bysort patient (adm_date): keep if _n ==1
	* clean
	qui keep patient adm_date `varlist'_y `varlist'_n
	* event date 
	qui rename adm_date `varlist'_d
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
	* set indicator to zero if no event 
	if "`y'" != "" qui replace `varlist'_y = 0 if `varlist'_y ==. 
end
