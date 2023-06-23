![sunburst-1](https://github.com/asjadnaqvi/stata-sunburst/assets/38498046/2076680a-f020-4662-91ea-bb37bcfc1a47)

![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-sunburst) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-sunburst) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-sunburst) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-sunburst) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-sunburst)

---

[Installation](#Installation) | [Syntax](#Syntax) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---

# sunburst v1.3
(23 Jun 2023)

## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**v1.2**):

```
ssc install sunburst, replace
```

GitHub (**v1.3**):

```
net install sunburst, from("https://raw.githubusercontent.com/asjadnaqvi/stata-sunburst/main/installation/") replace
```

The `palettes` package is required to run this command:

```
ssc install palettes, replace
ssc install colrspace, replace
```

Even if you have these packages installed, please check for updates: `ado update, update`.

If you want to make a clean figure, then it is advisable to load a clean scheme. These are several available and I personally use the following:

```
ssc install schemepack, replace
set scheme white_tableau  
```

I also prefer narrow fonts in figures with long labels. You can change this as follows:

```
graph set window fontface "Arial Narrow"
```


## Syntax

The syntax for **v1.3** is as follows:

```stata

sunburst numvar [if] [in], by(variables) 
                [ radius(numlist) step(num) palette(str) colorby(option) colorprop fade(num) share 
                  threshold(cutoff) labcondition(num) format(str) lwidth(list) labcolor(str) cfill(str)
                  title(str) subtitle(str) note(str) scheme(str) name(str) aspect(num) ]
```

See the help file `help sunburst` for details.

The most basic use is as follows:

```
sunburst value, by(variables)
```



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

<img src="/figures/sunburst1.png" height="400">

```
sunburst pop, by(NUTS0) labsize(3) lw(2)
```

<img src="/figures/sunburst2.png" height="400">

```
sunburst pop if NUTS0=="FR", by(NUTS1 NUTS2)
```
<img src="/figures/sunburst3.png" height="400">

```
sunburst pop if NUTS0=="FR", by(NUTS1 NUTS2) labsize(3 3) lw(0.5 0.25) format(%15.0fc)
```

<img src="/figures/sunburst4.png" height="400">

```
sunburst pop if NUTS0=="FR", by(NUTS1 NUTS2)  labsize(2 2) lw(0.2 0.02)  format(%15.0fc)
```

<img src="/figures/sunburst5.png" height="400">

```
sunburst pop if NUTS0=="FR", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) threshold(500000) format(%15.0fc)
```

<img src="/figures/sunburst6.png" height="400">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) threshold(100000) format(%15.0fc)
```

<img src="/figures/sunburst7.png" height="400">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) labcond(1000000)  format(%15.0fc)
```

<img src="/figures/sunburst8.png" height="400">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) labcond(1000000)  format(%15.0fc)
```

<img src="/figures/sunburst9.png" height="400">

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) format(%15.0fc) colorprop
```

<img src="/figures/sunburst10.png" height="400">

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) format(%15.0fc) colorprop threshold(500000) 
```

<img src="/figures/sunburst11.png" height="400">

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) format(%15.0fc) colorprop threshold(500000)  palette(CET C6) 
```

<img src="/figures/sunburst12.png" height="400">

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) format(%15.0fc) colorprop threshold(500000) palette(CET C6, reverse) 
```

<img src="/figures/sunburst13.png" height="400">

### Shares

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share 
```

<img src="/figures/sunburst14.png" height="400">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share threshold(1000000)
```

<img src="/figures/sunburst15.png" height="400">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share labcond(2) threshold(300000) colorprop 
```

<img src="/figures/sunburst15_1.png" height="400">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share labcond(2) threshold(200000) colorprop  radius(6 12 24)
```

<img src="/figures/sunburst16.png" height="400">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share labcond(2) ///
	threshold(200000) colorprop  radius(6 12 24) ///
	title("My (half) sunburst figure in Stata") subtitle("Some more info here") note("Made using the #sunburst package.") 
```

<img src="/figures/sunburst17.png" height="400">

```
sunburst pop if NUTS0=="DE", by(NUTS1 NUTS2) labsize(2 2) lw(0.2 0.02) format(%5.1fc) share labcond(2) ///
	threshold(200000) colorprop  radius(6 12 24) ///
	title("My (half) sunburst figure in Stata") subtitle("Some more info here") note("Made using the #sunburst package.") 
```

<img src="/figures/sunburst18.png" height="400">

### fade (v1.1)

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS3) labsize(2 2) lw(0.2 0.01) lc(white) format(%5.1fc) ///
	share labcond(2) colorprop fade(60) 
```

<img src="/figures/sunburst19.png" height="400">

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS3) labsize(2 2) lw(0.2 0.01) lc(white) format(%5.1fc) ///
	share labcond(2) colorprop fade(0)
```

<img src="/figures/sunburst20.png" height="400">


### colorby(name) (v1.2)

```
sunburst pop if NUTS0=="ES", by(NUTS1 NUTS3) labsize(2 2) lw(0.2 0.01) lc(white) format(%5.1fc) ///
	share labcond(2) colorprop fade(60) colorby(name)
```

<img src="/figures/sunburst21.png" height="400">

## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-sunburst/issues) to report errors, feature enhancements, and/or other requests.


## Change log

**v1.3 (23 Jun 2023)**
- Fixed a major precision bug that was causing slices to be mis-aligned, and labels to skip.
- Added `labcolor()`, and `cfill()` options.
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







