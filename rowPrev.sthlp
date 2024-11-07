{smcl}
{* *! * version 1.0  AH 04 Nov 2024 }{...}
{viewerdialog percentages "dialog rowPrev"}{...}
{viewerjumpto "Syntax" "rowPrev##syntax"}{...}
{viewerjumpto "Description" "rowPrev##description"}{...}
{viewerjumpto "Options" "rowPrev##options"}{...}
{viewerjumpto "Examples" "rowPrev##examples"}{...}
{p2colset 1 15 20 2}{...}
{p2col:{bf:[T] rowPrev} {hline 2}} Genarates a two-way table of frequency counts, and row precentages with exact 95% CIs  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmdab:rowPrev} {stratavar} varname 
{ifin}
[{cmd:,}
{it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Main}
{synopt:{opt append(string)}}append output to table specified in string{p_end}
{synopt:{opt head:ing(string)}}add row with heading specified in string{p_end}
{synopt:{opt nohead:ing}}suppress heading row{p_end}
{synopt:{opt nomi:ssings}}exclude observations with missing values in varname from analysis {p_end}
{synopt:{opt drop(stringlist)}}suppress output for levels of varname specified in stringlist{p_end}
{synopt:{opt nopercent}}suppress percentages{p_end}
{synopt:{opt clean(string)}}show clean version of table in output{p_end}

{syntab:Format}
{synopt:{opt freqf:ormat(string)}}format frequencies according to Stata format specified in string{p_end}
{synopt:{opt percentf:ormat(string)}}format percentages according to Stata format specified in string{p_end}
{synopt:{opt labelf:ormat(string)}}format label column according to Stata format specified in string{p_end}
{synopt:{opt pf:ormat(string)}}format p-values according to Stata format specified in string{p_end}
{synopt:{opt ind:ent(integer)}}indent labels by the number of blanks specified, (default=2){p_end}
{synopt:{opt percentsign}}add percent sign{p_end}
{synopt:{opt brackets}}replaces parentheses with brackets{p_end}
{synopt:{opt midpoint}}use midpoint as decimal point separator{p_end}

{syntab:Advanced}
{synopt:{opt varsu:ffix(string)}}rename all variables in table with suffix{p_end}
{synopt:{opt var(string)}}overwrites values in variable var{p_end}

{marker description}{...}
{title:Description}

{pstd}
{opt percentages} produces a two-way table (stratavar x varname) of frequency counts with row percentages and 95% CIs and appends the formatted table to an existing table created with the user-written commands header.ado. 

{marker examples}{...}
{title:Examples}

    ***Setup	
{phang}{cmd:clear}{p_end}
{phang}{cmd:set obs 1000}{p_end}
{phang}{cmd:generate sex = (runiform() < 0.5)}{p_end}
{phang}{cmd:label define sex 0 "Male" 1 "Female"}{p_end}
{phang}{cmd:label values sex sex}{p_end}
{phang}{cmd:generate agegrp = ceil(3 * runiform())}{p_end}
{phang}{cmd:label define age 1 "18-30" 2 "31-50" 3 "51-70"}{p_end}
{phang}{cmd:label values age age}{p_end}
{phang}{cmd:generate prob_dep = 0.1 + 0.1 * sex + 0.1 * (agegrp - 1)}{p_end}
{phang}{cmd:generate depression = (runiform() < prob_dep)}{p_end}
{phang}{cmd:label define depression 0 "No depression" 1 "Depression"}{p_end}
{phang}{cmd:label values depression depression}{p_end}

	***Tabulate data 
{phang}{cmd:tab sex depression, row}{p_end}
{phang}{cmd:tab age depression, row}{p_end}

    ***Generate table header 
{phang}{cmd:header depression, saving("Table1") percentformat(%3.1fc) freqlab("N=") clean freqf(%9.0fc) nopercent}{p_end}

    ***Estimates frequencies and row percentages for the prvalence of foreign cars within each level of price_cat and appends these rows to table header}{p_end}
{phang}{cmd:rowPrev sex depression, percentformat(%3.1fc) percentsign append("Table1") clean heading(Sex)}{p_end}
{phang}{cmd:rowPrev age depression, percentformat(%3.1fc) percentsign append("Table1") clean heading(Age group)}{p_end}
  
    ***Load table in memory and prepare for export in word
{phang}{cmd:tblout using "Table1", clear align format("%15s")}{p_end}
{phang}{cmd:replace c1 = "N" in 2}{p_end}
{phang}{cmd:replace e1 = "Prevalence (95% CI)" in 2}{p_end}
{phang}{cmd:replace c2 = "N" in 2}{p_end}
{phang}{cmd:replace e2 = "Prevalence (95% CI)" in 2}{p_end}
{phang}{cmd:replace c3 = "N" in 2}{p_end}
{phang}{cmd:replace e3 = "Percent" in 2}{p_end}

    ***Export table in word
{phang}{cmd:capture putdocx clear}{p_end}
{phang}{cmd:putdocx begin, font("Arial", 8)}{p_end}
{phang}{cmd:putdocx paragraph, spacing(after, 0)}{p_end}
{phang}{cmd:putdocx text ("Table 1: Prevalence of depression by demographic characteristics"), font("Arial", 9, black) bold}{p_end}
{phang}{cmd:putdocx table tbl1 = data(*), border(all, nil) border(top, single) border(bottom, single) layout(autofitcontent)}{p_end}
{phang}{cmd:putdocx table tbl1(., .), halign(right)  font("Arial", 8)}{p_end}
{phang}{cmd:putdocx table tbl1(., 1), halign(left)}{p_end}
{phang}{cmd:putdocx table tbl1(1, .), halign(center) bold}{p_end}
{phang}{cmd:putdocx table tbl1(2, .), halign(center)  border(bottom, single)}{p_end}
// Merging cells in the first row
{phang}{cmd:putdocx table tbl1(1, 2), colspan(2)}{p_end}
{phang}{cmd:putdocx table tbl1(1, 3), colspan(2)}{p_end}
{phang}{cmd:putdocx table tbl1(1, 4), colspan(2)}{p_end}
{phang}{cmd:putdocx pagebreak}{p_end}
{phang}{cmd:putdocx save "Depression.docx", replace}{p_end}
		 
{marker author}{...}
{title:Author}
{pstd}
Andreas Haas, Email: andreas.haas@ispm.unibe.ch
