*! sunburst v1.72 (16 Oct 2024)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.8  (16 Oct 2024): wrap() is now more flexible. Rotate added with full. cfill now requires shapes.
* v1.71 (10 Jun 2024): added wrap(option)
* v1.7  (07 Feb 2024): fixed a bug where repeat categories were causing misalignment. Change some variables to tempvars 
* v1.6  (26 Jan 2024): rewrite of core routines. Added full circle option. Added cfill options.
* v1.5  (23 Aug 2023): colorvar() added.
* v1.4  (05 Aug 2023): Stabilized the sorting to ensure consistency. Added label controls. labprop, saving(), labscale() points() added.
* v1.3  (23 Jun 2023): labcolor(), cfill(), fixed precision issues. 
* v1.2  (22 Jan 2023): colorby() added. colorprop added. threshold() collapse fixed.
* v1.1  (14 Jan 2023): fixed draw order. added error checks. added fade option. for format check. Rest of check. 
* v1.0  (24 Dec 2022): Beta release.


* A Step-by-step guide for a basic version is on Medium:
* https://medium.com/the-stata-guide/stata-graphs-half-sunburst-plot-19131cf40446

cap program drop sunburst

program sunburst, sortpreserve

	version 15

	syntax varlist(numeric max=1) [if] [in], by(varlist) ///
		[ RADius(numlist) palette(string) THRESHold(numlist max=1 >=0) share format(str) LABCONDition(numlist max=1 >=0) step(real 5)        ] ///
		[ LWidth(numlist) LColor(string) LABSize(numlist) xsize(real 2) ysize(real 1)  ]   ///
		[ legend(passthru)   ] ///
		[ fade(real 60) 			]  ///  // v1.1 options
		[ colorby(string) colorprop ] ///  // v1.2 updates
		[ LABColor(string) 			]  ///  // v1.3 updates
		[ LABLayer(numlist) points(real 100) labprop labscale(real 1) 	] ///  // v1.4
		[ colorvar(string) 			] ///   // v1.5
		[ full cfill(string) CLWidth(string) CLColor(string)   *	] ///  // v1.6
		[ wrap(numlist >=0 max=1) rotate(real 0) ]  // v1.7
		
	// check dependencies
	cap findfile colorpalette.ado
	if _rc != 0 {
		display as error "The {bf:palettes} package is missing. Install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}

	
	cap findfile labsplit.ado
	if _rc != 0 {
		display as error "The {bf:graphfunctions} package is missing. Install the {stata ssc install graphfunctions, replace:graphfunctions}."
		exit
	}	
	
	// check errors

	if "`colorby'" != "" {
		if !inlist("`colorby'", "name") {
			di as error "Wrong colorby() option specified. Correct options are {it:name}. See {stata help sunburst:help file}."
			exit
		}
	}

	if "`colorby'"!="" & "`colorvar'"!="" {
		di as error "Both colorby() and colorvar() cannot be specified."
		exit
	}

	if "`format'" != "" {
		if substr("`format'",1,1)!= "%" {
			di as error "Please specify the correct format as %#.#x, for example, %15.0f. See {stata help format} for details."
			exit
		}
	}


	marksample touse, strok


quietly {
preserve		

	keep if `touse'
	keep `varlist' `by' `colorvar'
	drop if missing(`varlist') |  `varlist'==0   // is this the right thing to do? wait for someone to complain


	local switch = 0
	if "`colorvar'"=="" {
		tempvar _group 
		gen `_group' = .
		local colorvar `_group'
	}
	else {
		local switch = 1

		// check for missing
		summ    `colorvar', meanonly
		replace `colorvar' = r(max) + 1 if missing(`colorvar')
	}

	//////////////////////
	// prepare the data //
	/////////////////////

	local len : word count `by'   				// number of variables

	if `len' > 1 local second = `len' - 1    	// second last variable

	foreach v of local by {
		if substr("`: type `v''",1,3) != "str" {
			if "`: value label `v' '" != "" { 	// has value label
				decode `v', gen(`v'_temp)
				drop `v'
				ren `v'_temp `v'
			}
			else {								// has no value label
				gen `v'_temp = string(`v')
				drop `v'
				ren `v'_temp `v'
			}
		}
	}

	cap ren `varlist' value

	tokenize "`by'"

	forval i = 1/`len' {
		ren ``i'' var`i'
		local vars `vars' var`i'
	}

	local last : word `len' of `vars'     				// last variable
	if `len' > 1 local sec  : word `second' of `vars'  	// second last variable	


	// define a radius 
	if "`radius'"=="" {
		forval i = 0/`len' {
			local autorad = 5 + (`i' * `step')  		// define an autogap of 5 with base of 5.
			local radius `radius' `autorad'  
		}
	}

	local radlen : word count `radius'   // number of variables
	local target = `len' + 1

	// radius error checks
	if "`radius'"!="" {
		if `radlen' < `target' {
			di as error "For `len' variables, `target' radii need to be defined."
			exit
		}

		local raderror = 0	
		forval i = 2/`target' {
			local j = `i' - 1

			local a : word `i' of `radius'
			local b : word `j' of `radius'

			if `a' < `b' {
				local raderror = 1
				break
			}
		}

		if `raderror' == 1 {
			di as error "The radius() order should be from smallest to largest."
			exit 198
		}
	}

	// pass on as lists	
	forval i = 0/`len' {
		local rad `rad' rad`i'  
	}

	tokenize `radius'
	args `rad'

	// and move on	
	if "`threshold'"=="" local threshold = 0

	collapse (sum) value (mean) `colorvar', by(`vars') // added the double collapse to get the threshold right for higher tiers (v1.2)

	if `len' > 1 {  // only if there is more than one layer, then collpse categories
		gen tag`sec' = .
		levelsof `sec' , local(lvls)

		foreach x of local lvls {
			count if `sec'=="`x'" & value <= `threshold'
			if r(N) > 1 {
				replace tag`sec' = 1 if `sec'=="`x'" & value <= `threshold'
				replace `last' = "Rest of `x'" if tag`sec'==1 &  `sec' =="`x'"
			}
		}
	}

	
	collapse (sum) value (mean) `colorvar' , by(`vars')

		
	
	gen var0 = "Total"
	egen double val0 = sum(value)  // global total

	
	
	if `len' > 1 {
		forval i = 1/`second' {   
			local j = `i' - 1
			bysort var`j' var`i' : egen double val`i' = sum(value)
		}
	}

	
	
	ren value val`len'  // individual total
	order var* val*

	// define the new sorting here
	forval i = 1/`len' {
		local mysort `mysort' -val`i' var`i'
	}

	
	
	gsort `mysort' 
	gen order0 = 1 in 1
	
	local mylist var0
	
	forval i = 1/`len' {
		
		local mylist `mylist' var`i'
		
		egen tag`i' = tag(`mylist') 
		gen order`i' = sum(tag`i')  

		if "`colorby'" == "name" {
			encode var`i', gen(l`i'name)  // patch higher tier ids to lower tiers	
		}
		else {
			gen l`i'name = order`i'
		}

	}
	
	
	sort order`len'
	drop if order`len' ==.	

	// get the first row correct
	if `len' > 1 {
		forval i = 0/`second' {
			local variables `variables' order`i'
		}
	}
	else {
		local variables order0 order1
	}

	bysort `variables': gen rank = _n

	drop if order`len' ==.	


	if `len' > 1 {	
		forval i = 1/`second' {	
			replace order`i' = . if tag`i'!=1
		}
	}
	drop tag*


	// duplicate the first row
	expand 2 in 1

	local obs = _N

	forval i = 0/`len' {
		replace val`i'   = 0 in `obs'
		replace order`i' = 0 in `obs'	
	}

	replace rank   = 0 in `obs'

	sort order`len'


	local aspect 0.5
	local 2pi = 1
	local ro = 0
	
	if "`full'" != "" {
		local aspect 1
		local 2pi = 2
		local xsize = 1
		local ro = `rotate' * _pi / 180  	
	}
	
	
	// calculate the shares
	forval i = 0/`len' {
		gen double share`i' = val`i' / val0 if order`i'!=.
		gen double theta`i'_temp = (share`i' * `2pi' * _pi) 
		gen double theta`i' = .

		sum order`i' , meanonly
		forval j = 1/`r(max)' {
			replace theta`i' = sum(theta`i'_temp) if order`i' <= `j' 
		}
		drop theta`i'_temp
	}


	gen id = _n
	

	reshape long var val order share theta, i(id *name rank) j(layer) string
	destring layer, replace force

	sort layer id order
	drop if order==.
	drop id

	
	replace order = order + 1


	bysort layer: replace var    =   var[_n+1]			
	bysort layer: replace val    =   val[_n+1]	
	bysort layer: replace share  = share[_n+1]		
	bysort layer: replace rank   =  rank[_n+1]		
	bysort layer: replace theta  = theta[_n+1]	
	bysort layer: replace `colorvar'  =  `colorvar'[_n+1]		


	if `len' > 1 {
		forval i = 1/`second' {
			bysort layer: replace l`i'name = l`i'name[_n+1]	
		}
	}
	else {
		replace l1name =  l1name[_n+1]	
	}


	drop if layer==0 // clean above already
	drop rank

	gen double x = .
	gen double y = .
	
	gen double angle = .
	gen double xlab = .
	gen double ylab = .

	gen mark0 = .
	gen id  = .
	gen tag = .
	gen seq = .  // order of points
	sort layer 

	gen double test1 = . // increment the angles

	*******************************
	**** Process the layers		***
	*******************************	


	levelsof layer, local(lyrs)

	foreach z of local lyrs {

		expand 3 if layer==`z'	
		sort layer order 
		by layer order: gen id`z' = _n if layer==`z'
		replace id = id`z' if layer==`z'
		drop id`z'

		replace x = 0 if inlist(id,2) & layer==`z'
		replace y = 0 if inlist(id,2) & layer==`z'
		replace mark0 = 0   if inlist(id,2) & layer==`z'	// identify the origin. important for sorting later
		
		
		****** get the arcs right

		local addobs `points'

		expand `addobs' if id==3  & layer==`z' // & inlist(quad, 1,2)

		egen tag`z' = tag(order) if layer==`z'
		replace tag = tag`z' if layer==`z'
		drop tag`z'			

		sort layer order id x
		by layer order id: gen seq`z' = _n if layer==`z'
		replace seq = seq`z' if layer==`z'
		drop seq`z'


		levelsof order if layer==`z' , local(lvls)

		local start = 0 + `ro' // start of the angle
		
		foreach x of local lvls {
			
			summ theta if order==`x' & layer==`z', meanonly
			local end = r(max) + `ro'
			
			local delta = (`end' - `start') / (`addobs' - 1)
			replace test1 = `start' + `delta' * (seq - 1) if order==`x' & layer==`z' & !inlist(id,1,2)

			replace x = (`rad`z'') * cos(test1) if x!=0 & order==`x' & layer==`z'
			replace y = (`rad`z'') * sin(test1) if x!=0 & order==`x' & layer==`z'
			
			local start = `end'
		
		}


		local inner = `z' - 1

		local labrad`z' =  `rad`inner'' + (`rad`z'' - `rad`inner'') * 0.50  // place the labels in the center

		levelsof order if layer==`z' , local(lvls)
		local items = r(r) - 1 

		
		local anglex = 0 + `ro'

		forval x = 1/`items' {

			summ theta if order==`x' & tag==1 & layer==`z', meanonly
			local angley = r(mean) + `ro'

			replace angle =  (`anglex' + `angley') / 2 	if order==`x' & layer==`z' & tag==1
			replace xlab  =  (`labrad`z'') * cos(angle) 	if order==`x' & layer==`z' & tag==1
			replace ylab  =  (`labrad`z'') * sin(angle) 	if order==`x' & layer==`z' & tag==1

			local anglex = `angley'
			
		}		

		drop if var=="" & layer==`z'
		sort layer order id mark0 seq
	}	

	
	
	

	*** define format options
	if "`format'"  == "" {
		if "`share'"  == "" {
			local format %9.0fc
		}
		else {
			local format %5.2f
		}
	}	



	gen varstr = ""

	forval i = 1/`len' {
		if "`share'" == "" {
			replace varstr = var + " (" + string(val, "`format'") + ")"  if id==1 & layer==`i' 
		}
		else {
			replace varstr = var + " (" + string(share * 100, "`format'") + "%)"  if id==1 & layer==`i'
		}
	}	


	if "`lablayer'" != "" {
		local lablayer : subinstr local lablayer " " ",", all 

		forval i = 1/`len' {
			replace varstr = var if !inlist(`i', `lablayer') &  id==1 & layer==`i'
		}

	}	

	cap drop test1
	
	/*
	if "`wrap'" != "" {
		gen _length = length(varstr) if varstr!= ""
		summ _length, meanonly		
		local _wraprounds = floor(`r(max)' / `wrap')
		
		forval i = 1 / `_wraprounds' {
			local wraptag = `wrap' * `i'
			replace varstr = substr(varstr, 1, `wraptag') + "`=char(10)'" + substr(varstr, `=`wraptag' + 1', .) if _length > `wraptag' & _length!=. 
		}
	}	
	*/
	
	if "`wrap'" != "" {
		ren varstr varstr_temp
		labsplit varstr_temp, wrap(`wrap') gen(varstr)
		drop varstr_temp
	}		
	

	// generate the quadrants	
	cap drop quad
	gen int quad = .  // quadrants
	replace quad = 1 if xlab >= 0 & ylab >= 0 & id==1
	replace quad = 2 if xlab <  0 & ylab >= 0 & id==1

	replace quad = 3 if xlab <  0 & ylab <  0 & id==1
	replace quad = 4 if xlab >= 0 & ylab <  0 & id==1


	gen double angle2 = .

	replace angle2 = (angle  * (180 / _pi)) - 180 if angle >  _pi & id==1 
	replace angle2 = (angle  * (180 / _pi))  	  if angle <= _pi & id==1 
		
	replace angle2 = (angle  * (180 / _pi))       if id==1 & quad==4
	replace angle2 = (angle  * (180 / _pi)) - 180 if id==1 & quad==2

	
	***********************
	// draw the layers   //
	***********************	

	if "`palette'" == "" {
		local palette tableau
	}
	else {
		tokenize "`palette'", p(",")
		local palette  `1'
		local poptions `3'
	}

	if "`lwidth'" != "" {

		local lwcount : word count `lwidth'
		if `lwcount' < `len' {
			noi di in yellow "Warning: fewer lines widths specified than the number of layers."
		}

		if `len' > 1 {
			forval i = 1/`len' {
				local lw `lw' lw`i'
			}
		}

		tokenize `lwidth'
		args `lw'
	}
	else {

		if `len' > 1 {
			forval i = 1/`second' {
				local lw`i' 0.12
			}	
		}
		local lw`len' 0.02

	}


	if "`labsize'" != "" {
		local lbcount : word count `labsize'
		if `lbcount' < `len' {
			noi di in red "Warning: fewer label sizes specified than the number of layers."
			exit 198
		}

		if `len' > 1 {
			forval i = 1/`len' {
				local lbs `lbs' labs`i'
			}
		}

		tokenize `labsize'
		args `lbs'
	}
	else {

		if `len' > 1 {
			forval i = 1/`second' {
				local labs`i' 2
			}
		}

		local labs`len' 1.5
	}	

	if "`lcolor'"   == "" local lcolor   white
	if "`labcolor'" == "" local labcolor black

	// base layers
	if `len' ==1 {
		levelsof l1name if layer==1, local(lvls)
		local items = r(r)

		if "`switch'" == "1" {
			summ `colorvar', meanonly
			local items = r(max)
		}

		foreach x of local lvls {	

			if "`switch'" == "1" {

				summ `colorvar' if layer==1 & l1name==`x', meanonly
				local idx = r(mean)
				colorpalette `palette', n(`items') `poptions' nograph

				local level `level' (area y x if layer==1 & l1name==`x', nodropbase fi(100) fc("`r(p`idx')'") lc(`lcolor') lw(`lw`i'')) ||
			}
			else {
				colorpalette `palette', n(`items') `poptions' nograph		
				local level `level' (area y x if layer==1 & l1name==`x', nodropbase fi(100) fc("`r(p`x')'") lc(`lcolor') lw(`lw`i'')) ||


			}
		}
	}
	else {	// >2 layers

		forval i = 1/`second' {
			local j = `second' - `i' + 1  // reverse
			local fill = 100 - ((`j' - 1) * 8 ) // layer-wise fill grading

			levelsof l1name if layer==`j', local(lvls)
			local items = r(r)


			if "`switch'"== "1" {
				summ `colorvar', meanonly
				local items = r(max)

				foreach x of local lvls {	
					summ `colorvar' if layer==`j' & l1name==`x', meanonly
					local idx = r(mean)

					colorpalette `palette', n(`items') `poptions' nograph

					local level `level' (area y x if layer==`j' & l1name==`x', nodropbase fi(`fill') fc("`r(p`idx')'") lc(`lcolor') lw(`lw`j'')) ||

				}
			}
			else {
				foreach x of local lvls {	
					colorpalette `palette', `poptions' n(`items') nograph	
					local level `level' (area y x if layer==`j' & l1name==`x', nodropbase fi(`fill') fc("`r(p`x')'") lc(`lcolor') lw(`lw`j'')) ||

				}
			}
		}
	}

	
	
	// last layer 

	local fill = 100 - (5 * `len')  

	if `len' <= 2 {   // upto 2 layers

		local level`len'

		levelsof l1name if layer==`len' , local(lvl1)   
		local i1 = r(r)

		if "`switch'"== "1" {
			summ `colorvar' if layer==`len', meanonly
			local i1 = r(max)
		}

		foreach x of local lvl1 {			// loop over first layer


			if "`colorprop'"!=""  {

				if "`switch'"== "1" {

					levelsof order if layer==`len' & l1name==`x', local(lvl`len')   
					local i`len' = r(r)
					local c`len' = 1
					foreach z of local lvl`len' { 

						summ `colorvar' if layer==`len' & l1name==`x' & order==`z', meanonly
						local idx = r(mean) 

						colorpalette `palette', `poptions' n(`i1') nograph

						colorpalette "`r(p`idx')'" "`r(p`idx')'%`fade'", n(`i`len'') nograph // graduate the colors
						local level`len' `level`len'' (area y x if layer==`len' & l1name==`x' & order==`z', nodropbase fi(`fill') fc("`r(p`c`len'')'") lc(`lcolor') lw(`lw`len'')) 

						local ++c`len'		
					}

				}
				else {

					levelsof order if layer==`len' & l1name==`x', local(lvl`len')   
					local i`len' = r(r)
					local c`len' = 1
					foreach z of local lvl`len' { 

						colorpalette `palette', `poptions' n(`i1') nograph

						colorpalette "`r(p`x')'" "`r(p`x')'%`fade'", n(`i`len'') nograph // graduate the colors
						local level`len' `level`len'' (area y x if layer==`len' & l1name==`x' & order==`z', nodropbase fi(`fill') fc("`r(p`c`len'')'") lc(`lcolor') lw(`lw`len'')) 

						local ++c`len'		
					}
				}
			}
			else {
				if "`switch'"=="1" {


					summ `colorvar', meanonly
					local items = r(max)

					summ `colorvar' if layer==`len' & l1name==`x', meanonly
					local idx = r(mean)

					colorpalette `palette', n(`items') `poptions' nograph
					local level`len' `level`len'' (area y x if layer==`len' & l1name==`x', nodropbase fi(`fill') fc("`r(p`idx')'") lc(`lcolor') lw(`lw`len'')) 		

				}
				else {

					colorpalette `palette', `poptions' n(`i1') nograph
					local level`len' `level`len'' (area y x if layer==`len' & l1name==`x', nodropbase fi(`fill') fc("`r(p`x')'") lc(`lcolor') lw(`lw`len'')) 		

				}
			}
		}
	}
	else {   // 3 or more layers


		local level`len'
		levelsof l1name if layer==`len' , local(lvl1)   
		local i1 = r(r)

		if "`switch'"== "1" {
			summ `colorvar' if layer==`len', meanonly
			local i1 = r(max)
		}


		foreach x of local lvl1 {			// loop over first layer


			if "`colorprop'"!=""  { // proportional colors


				if "`switch'"=="1" {  // with switch

					qui levelsof l`second'name if layer==`len' & l1name==`x', local(lvl`second')   
					local i`second' = r(r)
					local c`second' = 1
					foreach y of local lvl`second' {  // loop over second last year

						qui levelsof order if layer==`len' & l1name==`x' & l`second'name==`y', local(lvl`len')   
						local i`len' = r(r)
						local c`len' = 1
						foreach z of local lvl`len' {  // loop over last year

							summ `colorvar' if layer==`len' & l1name==`x' & l`second'name==`y' & order==`z', meanonly
							local idx = r(mean)


							colorpalette `palette', `poptions' n(`i1') nograph
							colorpalette "`r(p`idx')'" "`r(p`idx')'%`fade'", n(`i`len'') nograph // scale the colors
							local level`len' `level`len'' (area y x if layer==`len' & l1name==`x' & l`second'name==`y' & order==`z', nodropbase fi(`fill') fc("`r(p`c`len'')'") lc(`lcolor') lw(`lw`len'')) 

							local ++c`len'		
						}
						local ++c`second'
					}				

				}
				else { // without switch

					qui levelsof l`second'name if layer==`len' & l1name==`x', local(lvl`second')   
					local i`second' = r(r)
					local c`second' = 1
					foreach y of local lvl`second' {  // loop over second last year

						qui levelsof order if layer==`len' & l1name==`x' & l`second'name==`y', local(lvl`len')   
						local i`len' = r(r)
						local c`len' = 1
						foreach z of local lvl`len' {  // loop over last year

							colorpalette `palette', `poptions' n(`i1') nograph
							colorpalette "`r(p`x')'" "`r(p`x')'%`fade'", n(`i`len'') nograph // scale the colors
							local level`len' `level`len'' (area y x if layer==`len' & l1name==`x' & l`second'name==`y' & order==`z', nodropbase fi(`fill') fc("`r(p`c`len'')'") lc(`lcolor') lw(`lw`len'')) 

							local ++c`len'		
						}
						local ++c`second'
					}
				}
			}

			else {  // not propotional colors

				if "`switch'"=="1" {  // with colorvar

					summ `colorvar', meanonly
					local items = r(max)

					summ `colorvar' if layer==`len' & l1name==`x', meanonly
					local idx = r(mean)

					colorpalette `palette', n(`items') `poptions' nograph
					local level`len' `level`len'' (area y x if layer==`len' & l1name==`x', nodropbase fi(`fill') fc("`r(p`idx')'") lc(`lcolor') lw(`lw`len'')) 			

				}

				else {  // with no color var
					colorpalette `palette', `poptions' n(`i1') nograph
					local level`len' `level`len'' (area y x if layer==`len' & l1name==`x', nodropbase fi(`fill') fc("`r(p`x')'") lc(`lcolor') lw(`lw`len'')) 		
				}
			}
		}
	}		


	// labels level 1 to (n-1)
	if "`labcondition'"  != "" {
		if "`share'" == "" {
			local labcon "& val >= `labcondition'"
		}
		else {
			local labshare = `labcondition' / 100
			local labcon "& share >= `labshare'"
		}
	}

	if `len' >= 2 {
		forval i = 1/`second' {
			qui levelsof order if layer==`i' & tag==1, local(lvls)

			foreach x of local lvls {

				if "`labprop'" != "" {

					summ share if order== `x' & layer==`i' & tag==1, meanonly

					local mylabs = `labs`i'' * sqrt(5 * `r(mean)' ^ `labscale')
				}
				else {
					local mylabs `labs`i'' 
				}


				summ angle2 if order== `x' & tag==1 & layer==`i', meanonly

				local labs `labs' (scatter ylab xlab if order== `x'  & layer==`i' & tag==1 `labcon' , mc(none) mlabel(varstr) mlabcolor(`labcolor') mlabangle(`r(mean)')  mlabpos(0) mlabsize(`mylabs'))  
			}
		}	
	}


	// labels level n
	qui levelsof order if layer==`len' & tag==1, local(lvls)

	foreach x of local lvls {

		if "`labprop'" != "" {
			summ share if order== `x' & layer==`len' & tag==1, meanonly
			local mylabs = `labs`len'' * sqrt(5 * `r(mean)' ^ `labscale')
		}
		else {
			local mylabs `labs`len'' 
		}

		summ angle2 if order== `x' & tag==1 & layer==`len' , meanonly

		local lab`len' `lab`len'' (scatter ylab xlab if order== `x' & layer==`len' `labcon', mc(none) mlabel(varstr) mlabcolor(`labcolor') mlabangle(`r(mean)') mlabpos(0) mlabsize(`mylabs')) 

	}	

	
	**** inner circle
	
		if "`cfill'"  	== "" local cfill white
		if "`clcolor'"  == "" local clcolor white
		if "`clwidth'"  == "" local clwidth 0.2
	
	
		if "`full'" != "" {
			shape circle, n(500) rad(`rad0') genx(_circx) geny(_circy)  genid(_circid) genorder(_circorder) replace
		}
		else {
			shape pie, n(500) end(180) rad(`rad0') genx(_circx) geny(_circy) genid(_circid) genorder(_circorder) replace
		}

		local ccir (area _circy _circx, fc(`cfill') fi(100) lw(`clwidth') lc(`clcolor'))
	
	
	*** Final plot

	twoway ///
		`level`len'' ///
		`level' 	 ///
		`lab`len''	 ///
		`labs'	 	 ///
		`ccir'		 ///
			, 			 ///
			aspect(`aspect') xsize(`xsize') ysize(`ysize') 				///
			yscale(off) xscale(off) legend(off) 						///
			xlabel(-`rad`len'' `rad`len'', nogrid) ylabel(0 `rad`len'', nogrid)	///
			`options'


	*/
	restore	
}

end

*********************************
******** END OF PROGRAM *********
*********************************


