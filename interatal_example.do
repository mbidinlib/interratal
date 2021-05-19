
program drop interratal

interratal using "data.dta", ///
		key(trainee_name) ///
		masterval("Master") ///
		enumid(mu3) 		///
		enumname(trainee_name) ///
		outfile("Out_`c(current_date)'.xlsx") ///
		comparevars(gb1 gb2 gb3 gb4 gb5 gb6 gb7 gb8 gb9 gb10)
	
	
	
