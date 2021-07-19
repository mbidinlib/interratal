


*!Mathew Bidinlib
/*=====================================================
Title		: Compare Inter ratal test
Purporse	: This is do file Grades Interatal test 
Author		: Mathew Bidinlib
		    (mbidinlib@poverty-action.org)   
=======================================================*/

*cap program drop interratal

program define interratal

 #d ;

    syntax using/ ,
		  [KEY(str)] 
		  [MASTERval(string)] 
		  [OUTfile(str)] 
		  [ENUMId(name)] 
		  [ENUMName(name)] 
		  [XLSform(str)]
		  [COMPAREvars(str)]
	;
	#d cr
	clear all
	set more off
	set min_memory 1g, perm
	 
	qui{
	
		cls
			
		* Check if neccesary options are specified
		if ("`key'" == "" | "`masterval'" =="" | "`enumid'" =="" | "`enumname'" =="" | "`outfile'" =="") {
			noi di as err "The following options required [key, ,masterval, outfile, enumid, enumname], but at least one is missing"
			exit
		}
	
			if ("`xlsform'" =="" & "`comparevars'" =="") {
			noi di ""
			noi di ""
			noi di "You did not specify variables to compare. The program will proceed and compare all variables in memory "
			noi di "{hline}"
			noi di ""
		}

	
		noi di "{hline}"
		noi di "Grading inter-ratal test enteries of  " _column(15) `"`using'"'
		noi di "{hline}"
		
		* 1 Define macros
		***************
		loc c_key 		`key'
		loc c_key_val	`masterval' 
		loc enum_id  	`enum_id'
		loc enum_name	`enum_name'
		loc outfile     "`outfile'"
		glo xls 		"`xlsform'"

		* Import elx form and keep data vars
		*************************************
		if "`xlsform'" !=""{
			noi di  ""
			noi di "Importing xls file : " _column(15) "${xls}"
			import excel "${xls}", sheet(survey) first clear
			confirm numeric variable disabled
			
			noi di "Keeping lis of variables : " _column(15) "${xls}"
			if _rc{
				drop if disabled == "yes" | disabled == "1"
			}
			preserve
			keep if regexm(type, "select_one|integer|decimal|date")
			levelsof name, loc (names1)
			restore
			keep if regexm(type, "select_mult")
			levelsof name, loc (names2)

			* Consolidate variables
			***********************
			loc vars ""
			foreach i of local names1{
				loc vars = "`vars' " + "`i'*"
			}
			foreach i of local names2{
				loc vars = "`vars' " + "`i'*"
			}

		}
		
		else loc vars "`comparevars'"
		
		putexcel set "`outfile'", sheet(summary) replace
		putexcel B1:C1 = "Summary", bold merge hcenter
		cap putexcel save 
		
		
		noi di ""
		noi di "Comparing Enteries"
		noi di "{hline}"
		noi di "Comparing other enteries with the master  " _column(15) "Key: `key'|| ID: `masterval'"
		*Compare with Master 
		**********************
		if  regexm(`"`using'"', ".dta$") {
			use "`using'", clear
			
			else if regexm(`"`using'"', ".csv$"){
				import delimited "`using'", clear
				
				else {
					noi di as err "The master data sould be dta or csv format. Add the file extension to the name"
					exit
				}
			}
		}

		if ("`xlsform'" =="" & "`comparevars'" =="")  noi di "Keeping all variables"
		else keep `vars' `c_key' `enum_name' `enum_id'
		*if regexm("`:type `c_key''", "str") loc c_key_val = "`c_key_val'"
		*else loc c_key_val = `c_key_val'

		* Loop through all Vars
		************************
		loc count = 0
		local varsl = ""
		foreach k of varl _all {

			if !inlist("`k'", "`c_key'", "`enum_name'", "`enum_id'")  { //exclude the key and enumerator vars
				loc ++count
				loc varsl = "`varsl' " + "`k'"
				preserve
				keep if `c_key' == "`c_key_val'"
				loc master_val = `k'[1]
				restore
		 
				gen intrate_score_`count' = 0
				if regexm("`:type `k''", "str"){
					replace intrate_score_`count' = 1  if `k' == "`master_val'"
				} 
				else replace intrate_score_`count' = 1  if `k' == `master_val'
			}

			
			}
			
		egen interate_sum = rowtotal(intrate_score_*)
		gen interate_percent = round((interate_sum/`count')*100, .01)
		gsort -interate_percent


		loc savevars =  "`c_key' " +  "`enum_name' " + "`enum_id' " + "interate_sum interate_percent"

		* Export master output
		export excel `savevars' using "`outfile'", sheet(master_compared) firstrow(var) sheetreplace cell(B2)

		* Apply Mata Sheet format
		*************************
		count
		loc  rows = r(N)
		mata: sht_format("master_compared")




		noi di "Comparing enteries with the mode  " _column(15) 

		*Compare with Mode
		**********************
		if  regexm(`"`using'"', ".dta$") {
			use "`using'", clear
			
			else if regexm(`"`using'"', ".csv$"){
				import delimited "`using'"
				
				else {
					noi di as err "The master data sould be dta or csv format. Add the file extension to the name"
					exit
				}
			}
		}

		if ("`xlsform'" =="" & "`comparevars'" =="")  noi di "Keeping all variables"
		else keep `vars' `c_key' `enum_name' `enum_id'
		loc count = 0
		gen master_val = `c_key' == "`c_key_val'"
		foreach k of varl _all {

			if !inlist("`k'", "`c_key'", "`enum_name'", "`enum_id'" "master_val")  { //exclude the key and enumerator vars
				loc ++count
				
				preserve
				bys `k' : gen g_sum = _N
				gsort -g_sum -master_val
				
				loc master_val = `k'[1]
				restore
			
				gen intrate_score_`count' = 0
				if regexm("`:type `k''", "str"){
					replace intrate_score_`count' = 1  if `k' == "`master_val'"
				} 
				else replace intrate_score_`count' = 1  if `k' == `master_val'
			}
				
		}
		egen interate_sum = rowtotal(intrate_score_*)
		gen interate_percent = round((interate_sum/`count')*100, .01)
		gsort -interate_percent

		* Export master output
		export excel `savevars' using "`outfile'", sheet(mode_compared) firstrow(var) sheetreplace cell(B2)
		count
		loc  rows = r(N)
		mata: sht_format("mode_compared")



		noi  di ""
		noi di "Exporting Summary Sheet  " 
		
		* Summary Sheet
		preserve 
		clear
		set obs 7
		gen variable = ""
		replace variable = "Purpose" 						in 1
		replace variable = "Key Variable" 					in 2
		replace variable = "Key value for master"			in 3
		replace variable = "Enumerator ID variable" 		in 4
		replace variable = "Enumerator Name variable" 		in 5
		replace variable = "# Variables compared"			in 6
		replace variable = "List of variables compared" 	in 7

		gen response = ""
		replace response = "Grade Interatal Test" 			in 1		
		replace response = "`c_key'"						in 2
		replace response = "`c_key_val'"					in 3
		replace response = "`enumid'"						in 4
		replace response = "`enumname'"	 					in 5
		replace response = " `count'"						in 6
		replace response = "`varsl'"						in 7

		export excel using "`outfile'", sheet(summary, modify)  cell(B2)
		loc  rows = 6 
		loc  savevars  "variable response"
		mata: sht_format("summary")

		restore

		
	}

	di "`outfile' `savevars' `rows'"

end


mata:

void sht_format(string scalar sheet) {
	filename 		= st_local("outfile")
	vars			= st_local("savevars")
	rows			= strtoreal(st_local("rows"))

	class xl scalar b

	b.load_book(filename)
	b.set_sheet(sheet)
	b.set_sheet_gridlines(sheet, "off")
	
	dat= st_data(.,vars)

	b.set_border((2, rows + 2), (2, cols(dat) + 1), "thin")
	b.set_top_border((2, 2),  (2, cols(dat) + 1), "thick")
	b.set_bottom_border((2, 2),  (2, cols(dat) + 1), "thick")
	b.set_left_border((2, rows + 2), (2, 2), "thick")
	b.set_right_border((2, rows + 2), (cols(dat) + 1, cols(dat) + 1), "thick")
	b.set_bottom_border((rows 
	+ 2, rows + 2), (2, cols(dat) + 1), "thick")

}

end
