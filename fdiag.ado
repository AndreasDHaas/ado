capture program drop fdiag
program define fdiag
* version 2.1  AH 6 May 2022 
	* assert master table is in wide format 
	qui gunique patient
	if r(maxJ) > 1 {
		display in red "Currently loaded dataset is not in wide format. The variable patient has to uniquly identify observations."
		exit 198
	}	
	* syntax checking enforces that variables specified in IF are included in master table. 
	* workaround: original dataset is preserved. Variables specified in IF and not included in master table are generate before systax checking and original dataset restored thereafter
	preserve 
	foreach var in patient icd10_code code_role icd_1 {
		qui capture gen `var' = ""
	}
	foreach var in icd10_date source discharge_date icd10_type icd_23 age {
		qui capture gen `var' = .
	}	
	* syntax 
	syntax newvarname using [if] , [ MINDATE(string) MAXDATE(string) MINAGE(integer -999) MAXAGE(integer 999) LABel(string) N Y LIST(integer 0) LISTPATient(string) DESCribe NOGENerate ] 
	restore 
	* confirm newvarname does not exist 
	if "`nogenerate'" =="" { 
		capture confirm variable `varlist'_d
		if !_rc {
			display in red "`varlist' already exists"
			exit 198
		}
	}
	qui preserve
	use `using', clear
	*describe
	if "`describe'" !="" {
		describe
		lab list source 
		lab list icd10_type
		tab code_role, mi
	}
	* listpatient
	if "`listpatient'" !="" {
		di "" 
		di "" 
		di in red "listpatient: all"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	* select relevant diagnoses 
	marksample touse, novarlist
	qui drop if !`touse'
	* list
	if "`list'" !="0" {
		di in red " --- list start ---"
		listif patient icd10_date discharge_date icd10_code source icd10_type code_role age, id(patient) sort(patient icd10_date) n(`list')  sepby(patient) 
		di in red " --- list end ---"
	}
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: meeting if conditions"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	* select age 
	if "`minage'" !="" qui drop if age < `minage' 
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: >= minage"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	if "`maxage'" !="" qui drop if age > `maxage' & age !=. 
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: <= maxage"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	* mindate 
	if "`mindate'" != "" qui drop if icd10_date < `mindate'
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: >= mindate"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	* maxdate
	if "`maxdate'" != "" qui drop if icd10_date > `maxdate' & icd10_date !=. 
	* listpatient
	if "`listpatient'" !="" {
		di in red "listpatient: <= maxdate"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
	}
	* number of diagnoses 
	qui bysort patient icd10_date: keep if _n ==1
	if "`listpatient'" !="" {
		di in red "listpatient: keep one record per date"
		list patient icd10_date discharge_date icd10_code source icd10_type code_role age if patient =="`listpatient'", sepby(patient) 
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
	if "`nogenerate'" =="" { 
		qui merge 1:1 patient using `events', keep(match master) nogen
		if "`y'" != "" {
			qui replace `varlist'_y = 0 if `varlist'_y ==. 
			tab `varlist'_y, mi
		}
	}
end
