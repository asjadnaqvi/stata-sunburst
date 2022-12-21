*! sunburst v1.0 24 Dec 2022. Beta release.
*! Asjad Naqvi 

* A Step-by-step guide for a basic version is on Medium:
* https://medium.com/the-stata-guide/stata-graphs-half-sunburst-plot-19131cf40446

cap program drop sunburst

program sunburst, // sortpreserve

version 15
 
	syntax varlist(numeric max=1) [if] [in], by(varlist) ///
		[ RADius(numlist) palette(string) colorby(string) THRESHold(numlist max=1 >=0) share format(str) LABCONDition(string) step(real 5) ]   ///
		[ LWidth(numlist) LColor(string) LABSize(numlist) aspect(real 0.5) xsize(real 2) ysize(real 1)  ]   ///
		[ legend(passthru) title(passthru) subtitle(passthru) note(passthru) scheme(passthru) name(passthru) text(passthru) ] 
		
	
		
	// check dependencies
	cap findfile colorpalette.ado
	if _rc != 0 {
		display as error "The palettes package is missing. Install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}
	
	marksample touse, strok
	
	

qui {
preserve		
	keep if `touse'
	keep `varlist' `by'
	drop if `varlist'==. |  `varlist'==0
	
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
			di as error "The radius order is not correctly specified."
			exit
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
	
	if `len' > 1 {  // only if there is more than one layer, then collpse categories
		gen tag`sec' = .
		levelsof `sec' , local(lvls)

		foreach x of local lvls {
			replace tag`sec' = 1 if `sec'=="`x'" & value < `threshold'
			replace `last' = "Rest of `x'" if tag`sec'==1 &  `sec' =="`x'"
		}
	}
	
	collapse (mean) value, by(`vars')

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
		
	// get the first row correct
	if `len' > 1 {
		forval i = 0/`second' {
			local variables `variables' var`i'
		}
	}
	else {
		local variables var0 var1
	}

	gsort `variables' - val`len'
	bysort `variables': gen rank = _n

	gen order0 = 1 in 1
	gen order`len' = _n

	if `len' > 1 {	
		forval i = 1/`second' {
			
			local j = `i' - 1
			local bylist `bylist' var`j'
			
			
			egen tag`i' = tag(var`j' var`i')
			gen order`i' = sum(var`i'!=var`i'[_n-1]  )	
			replace order`i' = . if tag`i'!=1
			drop tag`i'
			
			encode var`i', gen(l`i'name)  // patch higher tier ids to lower tiers
		}
	}
	else {
		encode var1, gen(l1name)
	}

	sort `variables' order`len'
	drop if order`len' ==.	
	
	// pad the first row
	expand 2 in 1

	local obs = _N

	forval i = 0/`len' {
		replace val`i'   = 0 in `obs'
		replace order`i' = 0 in `obs'	
	}

	replace rank   = 0 in `obs'
	sort order`len'
		
	// calculate the shares

	forval i = 0/`len' {
		gen double share`i' = val`i' / val0 if order`i'!=.
		gen double theta`i'_temp = share`i' * _pi
		gen double theta`i' = .
		
		sum order`i' , meanonly
		forval j = 1/`r(max)' {
			replace theta`i' = sum(theta`i'_temp) if order`i' <= `j' 
		}
		drop theta`i'_temp
	}

	// generate the end points of the pie in polar coordinates

	forval i = 0/`len' {
		gen double x`i' = `rad`i'' * cos(theta`i')
		gen double y`i' = `rad`i'' * sin(theta`i')
	}	
	
	gen id = _n

	reshape long var val order share theta x y , i(id *name rank) j(layer) string
	destring layer, replace force

	sort layer id order
	*drop name
	count
	drop if order==.
	drop id

	replace order = order + 1

	bysort layer: replace var    =   var[_n+1]			
	bysort layer: replace val    =   val[_n+1]	
	bysort layer: replace share  = share[_n+1]		
	bysort layer: replace rank   =  rank[_n+1]		
	
	if `len' > 1 {
		forval i = 1/`second' {
			bysort layer: replace l`i'name = l`i'name[_n+1]	
		}
	}
	else {
		replace l1name =   l1name[_n+1]	
	}
	
	drop if layer==0 // clean above already
	drop rank

	gen double angle = .
	gen double xlab = .
	gen double ylab = .

	gen mark0 = .
	gen id  = .
	gen tag = .
	gen seq = .  // order of points
	sort layer 
	

	*******************************
	**** Process the layers		***
	*******************************	
	

	levelsof layer, local(lyrs)

	foreach z of local lyrs {
					
			expand 4 if layer==`z'	
			sort layer order 
			by layer order: gen id`z' = _n if layer==`z'
			replace id = id`z' if layer==`z'
			drop id`z'

			replace x = 0 if id==1 & layer==`z'
			replace y = 0 if id==1 & layer==`z'

			replace x = . if id==4 & layer==`z'
			replace y = . if id==4 & layer==`z'

			replace x = x[_n+3] if id==3 & layer==`z'
			replace y = y[_n+3] if id==3 & layer==`z'

			replace mark0 = 0   if id==1 & layer==`z'	// identify the origin. important for sorting later

			
	****** get the arcs right

	local addobs 100

	expand `addobs' if id==4  & layer==`z' // & inlist(quad, 1,2)

	egen tag`z' = tag(order) if layer==`z'
	replace tag = tag`z' if layer==`z'
	drop tag`z'			

	sort layer order id x
	by layer order id: gen seq`z' = _n if layer==`z'
	replace seq = seq`z' if layer==`z'
	drop seq`z'

		levelsof order if layer==`z' , local(lvls)

		foreach x of local lvls {
			sum x if mark0==. & order==`x' & layer==`z' , meanonly
			local increment = (r(max) - r(min)) / `addobs'
			replace x = r(min) + (`increment' * seq ) if x==. & layer==`z' & order==`x' 
			replace y = sqrt(`rad`z''^2 - x^2) 	      if y==. & layer==`z' & order==`x'  
			
			// fix the zero sqrt error for end points
			replace y = 0 if x!=. & y==. & layer==`z' & order==`x'
			
			// clean up
			replace x  = . 							 if id==2 & layer==`z' & order==`x'
			replace y  = . 							 if id==2 & layer==`z' & order==`x'
		}

	drop if id==2 & layer==`z'
	
	local inner = `z' - 1
	
	local labrad`z' =  `rad`inner'' + (`rad`z'' - `rad`inner'') * 0.50  // place the labels center

	levelsof order if layer==`z' , local(lvls)
	local items = r(r) - 1 

		
	forval x = 1/`items' {
		local y = `x' + 1
		
		summ theta if order==`x' & tag==1 & layer==`z', meanonly
		local anglex = r(mean)
		
		summ theta if order==`y' & tag==1 & layer==`z', meanonly
		local angley = r(mean)
		
		replace angle =  (`anglex' + `angley') / 2 	if order==`x' & layer==`z' & tag==1
		replace xlab  =  `labrad`z'' * cos(angle) 	if order==`x' & layer==`z' & tag==1
		replace ylab  =  `labrad`z'' * sin(angle) 	if order==`x' & layer==`z' & tag==1
	
	}		

	drop if var=="" & layer==`z'
	sort layer order id mark0 seq
	}	


	// labels
	replace share = share * 100
	
	if "`format'"== "" {
		if "`share'" == "" {
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
			replace varstr = var + " (" + string(share, "`format'") + "%)"  if id==1 & layer==`i'
		}
	}	
		
	// generate the quadrants	
	cap drop quad
	gen quad = .  // quadrants
		replace quad = 1 if xlab > 0 & ylab >= 0 & id==1
		replace quad = 2 if xlab < 0 & ylab >= 0 & id==1

		
	cap drop angle2	
	gen angle2 = .
		replace angle2 = (angle  * (180 / _pi))       if angle <= _pi & id==1 & quad==1
		replace angle2 = (angle  * (180 / _pi)) - 180 if angle <= _pi & id==1 & quad==2

		
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
			noi di in yellow "Warning: fewer label sizes specified than the number of layers."
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
	
	
	if "`lcolor'" == "" local lcolor white
	
	
	// base layers
	if `len' ==1 {
		levelsof l1name if layer==1, local(lvls)
		local items = r(r)

		foreach x of local lvls {	
			colorpalette `palette', n(`items') `poptions' nograph
			local level `level' (area y x if layer==1 & l1name==`x', nodropbase fi(100) fc("`r(p`x')'") lc(`lcolor') lw(`lw`i'')) ||
			
		}
	}
	else {	// >2 layers
	
		forval i = 1/`second' {
			local j = `second' - `i' + 1  // reverse
			local fill = 100 - ((`j' - 1) * 8 ) // layer-wise fill grading
			
			levelsof l1name if layer==`j', local(lvls)
			local items = r(r)

			foreach x of local lvls {	
				colorpalette `palette', `poptions' n(`items') nograph	
				local level `level' (area y x if layer==`j' & l1name==`x', nodropbase fi(`fill') fc("`r(p`x')'") lc(`lcolor') lw(`lw`j'')) ||
				
			}
		}
	}
	
	// last layer 

	local fill = 100 - (5 * `len')  
	
	if `len' <=2 {
		local level`len'

		levelsof l1name if layer==`len' , local(lvl1)   
		local i1 = r(r)

		foreach x of local lvl1 {			// loop over first layer
			
			if "`colorby'"=="base" | "`colorby'"=="" {
				colorpalette `palette', `poptions' n(`i1') nograph
				local level`len' `level`len'' (area y x if layer==`len' & l1name==`x', nodropbase fi(`fill') fc("`r(p`x')'") lc(`lcolor') lw(`lw`len'')) ||				
				
			}
			
			if "`colorby'"=="level" | "`colorby'"=="layer"  {
			
				qui levelsof order if layer==`len' & l1name==`x', local(lvl`len')   
				local i`len' = r(r)
				local c`len' = 1
				foreach z of local lvl`len' { 
					di "`x' -  `c`len''"
						
					colorpalette `palette', `poptions' n(`i1') nograph
					colorpalette "`r(p`x')'" gs14, n(`i`len'') nograph // scale the colors
					local level`len' `level`len'' (area y x if layer==`len' & l1name==`x' & order==`z', nodropbase fi(`fill') fc("`r(p`c`len'')'") lc(`lcolor') lw(`lw`len'')) ||
						
					local ++c`len'		
				}
			}
		}
	}
	else {
		local level`len'
		levelsof l1name if layer==`len' , local(lvl1)   
		local i1 = r(r)

		foreach x of local lvl1 {			// loop over first layer
			
			if "`colorby'"=="base" | "`colorby'"=="" {
				colorpalette `palette', `poptions' n(`i1') nograph
				local level`len' `level`len'' (area y x if layer==`len' & l1name==`x', nodropbase fi(`fill') fc("`r(p`x')'") lc(`lcolor') lw(`lw`len'')) ||				
				
			}
			
			if "`colorby'"=="level" | "`colorby'"=="layer"  {
				qui levelsof l`second'name if layer==`len' & l1name==`x', local(lvl`second')   
				local i`second' = r(r)
				local c`second' = 1
				foreach y of local lvl`second' {  // loop over second last year
							
					qui levelsof order if layer==`len' & l1name==`x' & l`second'name==`y', local(lvl`len')   
					local i`len' = r(r)
					local c`len' = 1
					foreach z of local lvl`len' {  // loop over last year
						
						colorpalette `palette', `poptions' n(`i1') nograph
						colorpalette "`r(p`x')'" gs14, n(`i`len'') nograph // scale the colors
						local level`len' `level`len'' (area y x if layer==`len' & l1name==`x' & l`second'name==`y' & order==`z', nodropbase fi(`fill') fc("`r(p`c`len'')'") lc(`lcolor') lw(`lw`len'')) ||
						
						local ++c`len'		
					}
				local ++c`second'
				}
			}
		}
	}		
	
	
		
	// labels level 1 to (n-1)
	if "`labcondition'"  != "" {
		if "`share'" == "" {
			local labcon "& val `labcondition'"
		}
		else {
			local labcon "& share `labcondition'"
		}
	}

	if `len' >= 2 {
		forval i = 1/`second' {
			qui levelsof order if layer==`i' & tag==1, local(lvls)

			foreach x of local lvls {
				summ angle2 if order== `x' & tag==1 & layer==`i', meanonly
				local labs `labs' (scatter ylab xlab if order== `x'  & layer==`i' & tag==1 `labcon' , mc(none) mlabel(varstr) mlabangle(`r(mean)')  mlabpos(0) mlabsize(`labs`i''))  ||
			}
		}	
	}

	// labels level n
	qui levelsof order if layer==`len' & tag==1, local(lvls)

	foreach x of local lvls {
		
		summ angle2 if order== `x' & tag==1 & layer==`len' , meanonly
		
			local lab`len' `lab`len'' (scatter ylab xlab if order== `x' & layer==`len' & quad==2 `labcon', mc(none) mlabel(varstr) mlabangle(`r(mean)') mlabpos(0) mlabsize(`labs`len''))  ||
	
			local lab`len' `lab`len'' (scatter ylab xlab if order== `x' & layer==`len' & quad==1 `labcon', mc(none) mlabel(varstr) mlabangle(`r(mean)') mlabpos(0) mlabsize(`labs`len''))  ||

	}	

	
	*** Final plot
	
	
	twoway ///
		`level`len'' ///
		`level' ///
		`lab`len''	 ///
		`labs'	 ///
			(function  sqrt(`rad0'^2 - (x)^2), recast(area) fc(white) fi(100) lw(0.15) lc(white) range(-`rad0' `rad0'))  ///
			, 															///
			aspect(`aspect') xsize(`xsize') ysize(`ysize') 								///
			yscale(off) xscale(off) legend(off) 						///
			xlabel(-`rad`len'' `rad`len'', nogrid) ylabel(0 `rad`len'', nogrid)	///
			`text' `title' `note' `subtitle' `name' `scheme'
	
		
restore	
}

end

*********************************
******** END OF PROGRAM *********
*********************************


