![sunburst-1](https://github.com/asjadnaqvi/stata-sunburst/assets/38498046/2076680a-f020-4662-91ea-bb37bcfc1a47)

![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-sunburst) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-sunburst) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-sunburst) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-sunburst) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-sunburst)

---

[Installation](#Installation) | [Syntax](#Syntax) | [Citation guidelines](#Citation-guidelines) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---

# sunburst v1.8
(16 Oct 2024)

## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**v1.71**):

```
ssc install sunburst, replace
```

GitHub (**v1.8**):

```
net install sunburst, from("https://raw.githubusercontent.com/asjadnaqvi/stata-sunburst/main/installation/") replace
```

The `palettes` package is required to run this command:

```stata
ssc install palettes, replace
ssc install colrspace, replace
ssc install graphfunctions, replace
```

Even if you have these packages installed, please check for updates: `ado update, update`.

If you want to make a clean figure, then it is advisable to load a clean scheme. These are several available and I personally use the following:

```stata
ssc install schemepack, replace
set scheme white_tableau  
```

I also prefer narrow fonts in figures with long labels. You can change this as follows:

```stata
graph set window fontface "Arial Narrow"
```


## Syntax

The syntax for the latest version is as follows:

```stata
sunburst numvar [if] [in], by(variables) 
                [ radius(numlist) step(num) palette(str) colorby(option) colorvar(var) colorprop fade(num) share 
                  format(str) threshold(num) labcondition(num) labcolor(str) lwidth(numlist) 
                  labsize(numlist) lablayer(numlist) labprop labscale(num) points(num) wrap(num)
                  full rotate(angle) cfill(str) clcolor(str) clwidth(str) * ]
```

See the help file `help sunburst` for details.

The most basic use is as follows:

```
sunburst value, by(variables)
```

## Citation guidelines
Software packages take countless hours of programming, testing, and bug fixing. If you use this package, then a citation would be highly appreciated. Suggested citations:


*in BibTeX*

```
@software{sunburst,
   author = {Naqvi, Asjad},
   title = {Stata package ``sunburst''},
   url = {https://github.com/asjadnaqvi/stata-sunburst},
   version = {1.8},
   date = {2024-10-16}
}
```

*or simple text*

```
Naqvi, A. (2024). Stata package "sunburst" version 1.8. Release date 16 October 2024. https://github.com/asjadnaqvi/stata-sunburst.
```


*or see [SSC citation](https://ideas.repec.org/c/boc/bocode/s459164.html) (updated once a new version is submitted)*




## Examples

Load the Stata dataset which contains the population of European regions:

```
use "https://github.com/asjadnaqvi/stata-sunburst/blob/main/data/demo_r_pjangrp3_clean.dta?raw=true", clear

drop year
keep NUTS_ID y_TOT

drop if y_TOT==0

keep if length(NUTS_ID)==5

gen NUTS2 = substr(NUTS_ID, 1, 4)
gen NUTS1 = substr(NUTS_ID, 1, 3)
gen NUTS0 = substr(NUTS_ID, 1, 2)
ren NUTS_ID NUTS3
ren y_TOT pop
format pop %12.0fc
```

Let's test the `sunburst` command:


```
sunburst pop, by(NUTS0)
```

<img src="/figures/sunburst1.png" width="100%">

```
sunburst pop, by(NUTS0) labsize(3) lw(2)
```

<img src="/figures/sunburst2.png" width="100%">

```
sunburst pop if NUTS0=="FR", by(NUTS1 NUTS2)
```
<img src="/figures/sunburst3.png" width="100%">

```
sunburst pop if NUTS0=="FR", by(NUTS1 NUTS2) labsize(3 3) lw(0.5 0.25) format(%15.0fc)
```

<img src="/figures/sunburst4.png" width="100%">

```
sunburst pop if NUTS0=="FR", by(NUTS1 NUTS2)  labsize(2 2) lw(0.2 0.02)  format(%15.0fc)
```

<img src="/figures/sunburst5.png" width="100%">

```
sunburst pop if NUTS0=="FR", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) threshold(500000) format(%15.0fc)
```

<img src="/figures/sunburst6.png" width="100%">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) threshold(100000) format(%15.0fc)
```

<img src="/figures/sunburst7.png" width="100%">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) labcond(1000000)  format(%15.0fc)
```

<img src="/figures/sunburst8.png" width="100%">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) labcond(1000000)  format(%15.0fc)
```

<img src="/figures/sunburst9.png" width="100%">

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) format(%15.0fc) colorprop
```

<img src="/figures/sunburst10.png" width="100%">

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) format(%15.0fc) colorprop threshold(500000) 
```

<img src="/figures/sunburst11.png" width="100%">

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) format(%15.0fc) colorprop threshold(500000)  palette(CET C6) 
```

<img src="/figures/sunburst12.png" width="100%">

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) format(%15.0fc) colorprop threshold(500000) palette(CET C6, reverse) 
```

<img src="/figures/sunburst13.png" width="100%">

### Shares

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share 
```

<img src="/figures/sunburst14.png" width="100%">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share threshold(1000000)
```

<img src="/figures/sunburst15.png" width="100%">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share labcond(2) threshold(300000) colorprop 
```

<img src="/figures/sunburst15_1.png" width="100%">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share labcond(2) threshold(200000) colorprop  radius(6 12 24)
```

<img src="/figures/sunburst16.png" width="100%">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share labcond(2) ///
	threshold(200000) colorprop  radius(6 12 24) ///
	title("My (half) sunburst figure in Stata") subtitle("Some more info here") note("Made using the #sunburst package.") 
```

<img src="/figures/sunburst17.png" width="100%">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share labcond(2) ///
	threshold(200000) colorprop  radius(6 12 24) ///
	title("My (half) sunburst figure in Stata") subtitle("Some more info here") note("Made using the #sunburst package.") 
```

<img src="/figures/sunburst18.png" width="100%">

### fade (v1.1)

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS3) labsize(2 2) lw(0.2 0.01) lc(white) format(%5.1fc) ///
	share labcond(2) colorprop fade(60) 
```

<img src="/figures/sunburst19.png" width="100%">

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS3) labsize(2 2) lw(0.2 0.01) lc(white) format(%5.1fc) ///
	share labcond(2) colorprop fade(0)
```

<img src="/figures/sunburst20.png" width="100%">


### colorby(name) (v1.2)

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS3) labsize(2 2) lw(0.2 0.01) lc(white) format(%5.1fc) ///
	share labcond(2) colorprop fade(60) colorby(name)
```

<img src="/figures/sunburst21.png" width="100%">


### labellayer() (v1.3)

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3) lablayer(2 3) ///
	labsize(2.2 1.4 1.4) lw(0.2 0.1 0.01)  labcond(100000) format(%15.0fc) 
```

<img src="/figures/sunburst22.png" width="100%">


### labprop and labscale (v1.4)

```
sunburst pop if NUTS0=="ES", by(NUTS2 NUTS3) labprop 
```

<img src="/figures/sunburst23.png" width="100%">

```
sunburst pop if NUTS0=="ES", by(NUTS2 NUTS3) labprop labscale(0.6)
```

<img src="/figures/sunburst24.png" width="100%">


### colorvar (v1.5) 

Let's generate a plot with specific list of countries:

```
sunburst pop if inlist(NUTS0, "AT", "NO", "DK", "NL"), by(NUTS0 NUTS1) labprop labscale(0.6) format(%12.0fc)
```
<img src="/figures/sunburst25_1.png" width="100%">

If we want to preserve the color assignment, we generate a custom variable:

```
gen colors = .
replace colors = 1 if NUTS0=="AT"
replace colors = 2 if NUTS0=="NO"
replace colors = 3 if NUTS0=="NL"
replace colors = 4 if NUTS0=="DK"
replace colors = 5 if NUTS0=="FI"
```

and we can pass it on to the command and keep the colors consistent across the layers:


```
sunburst pop if inlist(NUTS0, "AT", "NO", "DK", "NL"), by(NUTS0 NUTS1) labprop labscale(0.6) format(%12.0fc) colorvar(colors)
```
<img src="/figures/sunburst25_2.png" width="100%">


```
sunburst pop if inlist(NUTS0, "NO", "DK", "NL", "FI"), by(NUTS0 NUTS1) labprop labscale(0.6) format(%12.0fc) colorvar(colors)
```
<img src="/figures/sunburst25_3.png" width="100%">


```
sunburst pop if inlist(NUTS0, "NO", "AT", "NL", "FI"), by(NUTS0 NUTS1) labprop labscale(0.6) format(%12.0fc) colorvar(colors)
```

<img src="/figures/sunburst25_4.png" width="100%">


### colorvar(), colorby(), and colorprop tests

Two layers

```
sunburst pop if inlist(NUTS0, "NO", "DK", "NL", "FI"), by(NUTS0 NUTS2) labprop labscale(0.6) format(%12.0fc) colorprop
sunburst pop if inlist(NUTS0, "NO", "DK", "NL", "FI"), by(NUTS0 NUTS2) labprop labscale(0.6) format(%12.0fc) colorprop colorby(name)
sunburst pop if inlist(NUTS0, "NO", "DK", "NL", "FI"), by(NUTS0 NUTS2) labprop labscale(0.6) format(%12.0fc) colorprop colorvar(colors) 
```

<img src="/figures/sunburst26_1.png" width="100%">
<img src="/figures/sunburst26_1_1.png" width="100%">
<img src="/figures/sunburst26_2.png" width="100%">

Three layers

```
sunburst pop if inlist(NUTS0, "NO", "DK", "NL", "FI"), by(NUTS0 NUTS1 NUTS3) labprop labscale(0.6) format(%12.0fc) colorprop
sunburst pop if inlist(NUTS0, "NO", "DK", "NL", "FI"), by(NUTS0 NUTS1 NUTS3) labprop labscale(0.6) format(%12.0fc) colorprop colorby(name)  
sunburst pop if inlist(NUTS0, "NO", "DK", "NL", "FI"), by(NUTS0 NUTS1 NUTS3) labprop labscale(0.6) format(%12.0fc) colorprop colorvar(colors)  
```

<img src="/figures/sunburst26_3.png" width="100%">
<img src="/figures/sunburst26_3_1.png" width="100%">
<img src="/figures/sunburst26_4.png" width="100%">

Four layers

```
sunburst pop if inlist(NUTS0, "NO", "DK", "NL", "FI"), by(NUTS0 NUTS1 NUTS2 NUTS3) labprop labscale(0.6) format(%12.0fc) colorprop
sunburst pop if inlist(NUTS0, "NO", "DK", "NL", "FI"), by(NUTS0 NUTS1 NUTS2 NUTS3) labprop labscale(0.6) format(%12.0fc) colorprop colorby(name) 	
sunburst pop if inlist(NUTS0, "NO", "DK", "NL", "FI"), by(NUTS0 NUTS1 NUTS2 NUTS3) labprop labscale(0.6) format(%12.0fc) colorprop colorvar(colors) 	
```

<img src="/figures/sunburst26_5.png" width="100%">
<img src="/figures/sunburst26_5_1.png" width="100%">
<img src="/figures/sunburst26_6.png" width="100%">


### v1.6 full option

```
sunburst pop if NUTS0=="AT", by(NUTS1 NUTS2 NUTS3) full labs(1.4 1.4 1.4)
```

<img src="/figures/sunburst27_1.png" width="100%">


```
sunburst pop if NUTS0=="FR", by(NUTS1 NUTS2) full labprop
```

<img src="/figures/sunburst27_2.png" width="100%">


### v1.8: circle fill + rotate

```
sunburst pop if NUTS0=="PT", by(NUTS2 NUTS3) clc(black) lc(black) 
```

<img src="/figures/sunburst28_1.png" width="100%">


```
sunburst pop if NUTS0=="PT", by(NUTS2 NUTS3) full clc(black) lc(black) 
```

<img src="/figures/sunburst28_2.png" width="100%">


```
sunburst pop if NUTS0=="PT", by(NUTS2 NUTS3) full clc(black) lc(black) rotate(90)
```

<img src="/figures/sunburst29.png" width="100%">




## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-sunburst/issues) to report errors, feature enhancements, and/or other requests.


## Change log

**v1.8 (16 Oct 2024)**
- Options `wrap()` and `cfill()` now depend on [graphfunctions](https://github.com/asjadnaqvi/stata-graphfunctions) for better figures.
- Added option `rotate()`. This will only work if a full figure is drawn using `full` (requested by Eric Melse).

**v1.71 (07 Feb 2024)**
- Added `wrap()` option for label wrapping.
- Minor code cleanups.

**v1.7 (07 Feb 2024)**
- Fixed a major bug where repeated categories in second or higher layers were causing misalignment of arcs.
- Changes some of the internal variables to tempvars to avoid potential conflicts with common variable names.
- Fixed the orientation of the variable labels in the 4th quadrant if the `full` circle option was used.
- Minor cleanups.

**v1.6 (26 Jan 2024)**
- Rewrite of core routines. 
- Added `full` option to generate a full circle. 
- Added `clcolor()` and `clwidth()` options to better control central circle fill.
- Minor code cleanups. 

**v1.5 (23 Aug 2023)**
- Implements the `colorvar(var)` option to allow full control of assigning the colors (requested by Richard Mills).
- Major code cleanups.

**v1.4 (05 Aug 2023)**
- Fixed a major bug that was causing categories with similar values to shuffle in the figure (reported by Richard Mills).
- Fixed a bug where empty `by()` categories were causing the alignment of arcs to mess up.
- Added `labprop` option to make labels proportional.
- Added `labscale()` option to change how the labels scale in the `labprop` option.
- Added `saving()` option.
- Added `points()` option to allow users to define how much points for each arc need to be calculated.
- Several minor code cleanups.

**v1.3 (23 Jun 2023)**
- Fixed a major precision bug that was causing slices to be mis-aligned, and labels to skip.
- Added `labcolor()`, `cfill()`, `lablayer()` (requested by Zumin Shi) options.
- Various bug fixes.

**v1.2 (22 Jan 2023)**
- Bug in `threshold()` collapse fixed.
- Option `colorprop` added to simplify specifying the gradient fill. This also aligns it with the [treemap](https://github.com/asjadnaqvi/stata-treemap) package.
- Option `colorby()` simplified to currently accepting one option `colorby(name)` which assign colors based on the alphabetical order (requested by Marc Kaulisch).

**v1.1 (14 Jan 2023)**
- This version fixes the draw order of layers which is now determined by size rather than names. This makes the layouts more palatable to the eye.
- Added several error checks.
- The option `threshold()` will not collapse to "Rest of ..." if there is only one variable.
- Colors now fade to 10% of base color.
- A `fade()` option allows users to control the fade level.
- Various bug fixes plus code cleanup.

**v1.0 (24 Dec 2022)**
- Public release.







