{smcl}
{* *! version 2.1  6 May 2022}{...}
{viewerdialog fdiag "dialog fdiag"}{...}
{vieweralsosee "[D] fdiag" "mansection D fdiag"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[P] display" "help display"}{...}
{vieweralsosee "[D] edit" "help edit"}{...}
{vieweralsosee "[P] tabdisp" "help tabdisp"}{...}
{vieweralsosee "[R] table" "help table"}{...}
{viewerjumpto "Syntax" "fdiag##syntax"}{...}
{viewerjumpto "Menu" "fdiag##menu"}{...}
{viewerjumpto "Description" "fdiag##description"}{...}
{viewerjumpto "Options" "fdiag##options"}{...}
{viewerjumpto "Remarks" "fdiag##remarks"}{...}
{viewerjumpto "Examples" "fdiag##examples"}{...}
{p2colset 1 13 15 2}{...}
{p2col:{bf:[D] fdiag} }Creates newvar_d containing the date of the first diagnosis meeting the if condition {p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{opt fdiag} {newvar} {cmd: using} [if] [, options] 

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :Options}
{synopt :{opt mindate(date):}}disregards diagnoses before mindate {p_end}
{synopt :{opt maxdate(date):}}disregards diagnoses after maxdate {p_end}
{synopt :{opt minage(integer):}}disregards diagnoses before minage{p_end}
{synopt :{opt maxage(integer):}}disregards after maxage {p_end}
{synopt :{opt n:}}generates newvar_n containing the number of diagnoses in age and date range meeting the if condition and are on different dates {p_end}
{synopt :{opt y:}}generates the binary indicator newvar_y for the presence of a diagnosis in age and date range meeting the if condition {p_end}
{synopt :{opt label(string):}}labels value 1 of newvar_y with string{p_end}
{synopt :{opt list(N):}}lists diagnoses meeting the if condition of a random sample of N patients. The ado file listif is required for this option. {p_end}
{synopt :{opt listpat:ient(patient)}}lists diagnoses of specified patient id before and after applying age and date restrictions {p_end}
{synopt :{opt desc:ribe}}specifies the using dataset and coding of its variables are described {p_end}
{synopt :{opt nogen:erate}}specifies that newvar_* not be created {p_end}

{marker description}{...}
{title:Description}
{synoptset 24 tabbed}{...}
{synopt :{opt newvar:}}name of new variable to be generated{p_end}
{synopt :{opt using:}}filename of cleaned AfA controls ICD10_X table{p_end}
{synopt :{opt if:}}if condition selecting relevant diagnoses{p_end}

{marker examples}{...}
{title:Examples}

 * Generate variables for first diagnosis of a major depression at or after age 18 between Jan 1, 2011 & Jul 1, 2020 
{phang}{cmd: fdiag} depression {cmd: using} "$clean/ICD10_F" if regexm(icd10_code, "F3[2-3]") |  icd10_code =="F34.1", minage(18) mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') n y list(3) {p_end}

 * Review data of an indiviudal patient by specifying the listpatient and nogenerate options
{phang}{cmd: fdiag} depression {cmd: using} "$clean/ICD10_F" if regexm(icd10_code, "F31"), minage(18) mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') listpatient("B006300243") nogenerate {p_end} 
 * Explore coding of using data by specifying the describe and nogenerate options  
{phang}{cmd: fdiag} bipolar {cmd: using} "$clean/ICD10_F", nogen describe {p_end} 
 * Generate variables for first hospital admission for a bipolar disorder 
{phang}{cmd: fdiag} bipolar {cmd: using} "$clean/ICD10_F" if regexm(icd10_code, "F31") & source ==3 & inlist(code_role, "REASON FOR ADMISSION"), n y list(3) {p_end}

{marker Notes}{...}
{title:Notes}
{phang}{cmd: fdiag}  uses a 1:m merge. The loaded dataset has to be in a wide format.{p_end}

{title:Also See}
{phang}{cmd: fdrug}{p_end}
{phang}{cmd: flab}{p_end}
{phang}{cmd: fhos}{p_end}
	
{marker Author}{...}
{title:Author}
{phang}Andreas Haas{p_end}
{phang}University of Bern {p_end}
{phang}Email: andreas.haas@ispm.unibe.ch{p_end}

