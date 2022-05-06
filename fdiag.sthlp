{smcl}
{* *! version 2.0  28 April 2022}{...}
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
{p2col:{bf:[D] fdiag} }Creates a binary variable (newvarname) flagging patients who received a specific ICD10 diagnosis and the date of first diagnosis (newvarname_sd) {p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{opt fdiag} newvarname using if  [{cmd:,} {it:options}]

{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}

{syntab :Options}
{synopt :{opt minage(integer):}}drops diagnoses that occured before minage{p_end}
{synopt :{opt mindate(integer):}}drops diagnoses that occured before mindate {p_end}
{synopt :{opt mindate(integer):}}drops diagnoses that occured after maxdate {p_end}
{synopt :{opt n:}}adds variable with number of diagnoses in age and date range on separate dates {p_end}
{synopt :{opt y:}}creates binary variable named nevarname_y for event occurence {p_end}
{synopt :{opt label(string):}}labels value 1 in newvarname_y with string{p_end}
{synopt :{opt listall(integer):}}lists all diagnoses meeting if condition of x randomly selected patients. x is specified in parenthesis{p_end}
{synopt :{opt list(integer):}}lists diagnoses meeting if condition in age and date range of x randomly selected patients. x is specified in parenthesis{ {p_end}

{marker description}{...}
{title:Description}
{synoptset 21 tabbed}{...}
{synopt :{opt newvarname:}}name of new variable to be generated{p_end}
{synopt :{opt using:}}filename of icd10 table{p_end}
{synopt :{opt if:}}if statement selecting the relevant diagnoses{p_end}

{marker examples}{...}
{title:Examples}
{phang}{cmd: fdiag} depression using "$clean/ICD10_F" if regexm(icd10_code, "F3[2-3]") |  icd10_code =="F34.1", minage(11) mindate(`=d(01/01/2011)') maxdate(`=d(01/07/2020)') n y list(3) {p_end}

				


