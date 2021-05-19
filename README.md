# interratal

Stata program that converts long dataset to wide

## Overview

Researchers seeking to hire field staff may want to conduct an inter-ratal assessment for candidates. 
This program would be helpful in grading such inter-ratal assessments


## installation(v1.0)

```stata
net install shortlist, all replace ///
	from("https://raw.githubusercontent.com/mbidinlib/interratal/master/ado")
```

## Syntax

```stata

interratal using "data", 							///
		key(key variable name) 						///
		masterval(key value for master response)			///
		enumid(enumerator id) 						///
		enumname(enumerator name) 					///
		outfile(output file name and path) 				///
		xlsform(xls form for the data)					


```


