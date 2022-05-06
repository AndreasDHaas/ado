capture program drop fdiag
program define fdiag
* version 2.1  AH 6 May 2022 
	* syntax checking enforces that variables specified in IF are included in master table. 
	* workaround: variables specified in IF and not included in master table are generate before systax checking and dropped therafter 
	* generate non-existing variables 
	local L = ""
	foreach var in patient icd10_date icd10_code source icd10_type discharge_date code_role icd10_type icd_1 icd_23 age {
	capture confirm variable `var'
		if !_rc ==0 { 
				local L = "`L'" + " " + "`var'" 
				if inlist("`var'", "patient", "icd10_code", "code_role", "icd_1")	{	
					qui gen `var' = ""
				}
				else  {
					qui gen `var' = . 
				}
		}
	}
	* syntax 
	syntax newvarname using if , [ MINAGE(integer 0) MINDATE(string) MAXDATE(string) LABel(string) N Y LIST(integer 0) listall(integer 0) LISTPATient(string) ] 
	* drop generated variables 
	capture drop `L'
	* confirm newvarname does not exist 
	capture confirm variable `varlist'_d
	if !_rc {
		display in red "`varlist' already exists"
		exit 198
	}
	qui preserve
	use `using', clear
	* listpatient
	if "`listpatient'" !="" {
		di "" 
		di "" 
		di in red "listpatient: all"
		list patient icd10_date icd10_code source icd10_type age if patient =="`listpatient'", sepby(patient) 
	}
	* select relevant diagnoses 
	marksample touse, novarlist
	qui drop if !`touse'
	* list
	if "`list'" !="0" {
		di in red " --- list start ---"
		listif patient icd10_date icd10_code source icd10_type age, id(patient) sort(patient icd10_date) n(`list')  sepby(patient) 
		di in red " --- list end ---"
	}
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: meeting if conditions"
		list patient icd10_date icd10_code source icd10_type age if patient =="`listpatient'", sepby(patient) 
	}
	* select age 
	if "`minage'" !="" qui drop if age < `minage'
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: >= minage"
		list patient icd10_date icd10_code source icd10_type age if patient =="`listpatient'", sepby(patient) 
	}
	* mindate 
	if "`mindate'" != "" qui drop if icd10_date < `mindate'
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: >= mindate"
		list patient icd10_date icd10_code source icd10_type age if patient =="`listpatient'", sepby(patient) 
	}
	* maxdate
	if "`maxdate'" != "" qui drop if icd10_date > `maxdate'
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: <= maxdate"
		list patient icd10_date icd10_code source icd10_type age if patient =="`listpatient'", sepby(patient) 
	}
	* number of diagnoses 
	qui bysort patient icd10_date: keep if _n ==1
	if "`listpatient'" !="" {
		di in red "listpatient: keep one record per date"
		list patient icd10_date icd10_code source icd10_type age if patient =="`listpatient'", sepby(patient) 
	}
	* n 
	if "`n'" != "" qui bysort patient (icd10_date): gen `varlist'_n =_N	
	* generate indicator variable sepcified in newvarname
	if "`y'" != "" {
		qui gen `varlist'_y = 1
		* label 
			if "`label'" != "" {
				label define  `varlist'_y 1 "`label'" 
				lab val `varlist'_y `varlist'_y
			}
	}
	* select first diag event 
	qui bysort patient (icd10_date): keep if _n ==1
	* event date 
	qui rename icd10_date `varlist'_d
	if "`listpatient'" !="" {
		di in red "listpatient: keep first event"
		list patient `varlist'_* if patient =="`listpatient'", sepby(patient) 
	}
	* clean
	qui keep patient `varlist'_*
	* order and apply n and y options
	order patient `varlist'_d 
	* save events
	qui tempfile events
	qui save `events'
	* merge events to original dataset 
	restore 
	qui merge 1:1 patient using `events', keep(match master) nogen
	if "`y'" != "" qui replace `varlist'_y = 0 if `varlist'_y ==. 
end
