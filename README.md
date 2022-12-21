
![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-sunburst) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-sunburst) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-sunburst) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-sunburst) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-sunburst)

# sunburst v1.0


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**coming soon**):

```
ssc install sunburst, replace
```

GitHub (**v1.0**):

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

The syntax for **v1.0** is as follows:

```
sunburst value [if] [in], by(variables) 
                [ radius(numlist) step(num) palette(str) colorby(option) share 
                  threshold(cutoff) valcondition(str) format(str) lwidth(list)  
                  title(str) subtitle(str) note(str) scheme(str) name(str) aspect(num) ]

```

See the help file `help sunburst` for details.

The most basic use is as follows:

```
sunburst value, by(variables)
```



## Examples

Load the Stata dataset

```
use "https://github.com/asjadnaqvi/stata-sunburst/blob/main/data/sunburst.dta?raw=true", clear
```

Let's test the `sunburst` command:


```
sunburst value, by(continent)
```

<img src="/figures/sunburst1.png" height="400">

```
sunburst value, by(continent) labsize(3) lw(2)
```

<img src="/figures/sunburst2.png" height="400">

```
sunburst value, by(continent region)
```
<img src="/figures/sunburst3.png" height="400">

```
sunburst value, by(continent region) labsize(3 3) lw(0.5 0.25)
```

<img src="/figures/sunburst4.png" height="400">

```
sunburst value, by(continent country)  labsize(3 1.4) lw(0.2 0.02) 
```

<img src="/figures/sunburst5.png" height="400">

```
sunburst value, by(continent country)  labsize(3 1.4) lw(0.2 0.02) threshold(1000)
```

<img src="/figures/sunburst6.png" height="400">

```
sunburst value, by(continent country)  labsize(3 1.4) lw(0.2 0.02) threshold(2000)
```

<img src="/figures/sunburst7.png" height="400">

```
sunburst value, by(continent country)  labsize(3 1.4) lw(0.2 0.01) labcond(>1500)
```

<img src="/figures/sunburst8.png" height="400">

```
sunburst value, by(continent country)  labsize(3 1.4) lw(0.2 0.01) labcond(>1500) colorby(level)
```

<img src="/figures/sunburst9.png" height="400">

```
sunburst value, by(continent region country) labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) threshold(2000) colorby(level)
```

<img src="/figures/sunburst10.png" height="400">

```
sunburst value, by(continent region country) labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) threshold(2000) labcond(>1000) colorby(level)
```

<img src="/figures/sunburst11.png" height="400">

```
sunburst value, by(continent region country) labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) threshold(2000) labcond(>1000) colorby(level)  palette(CET C7) 
```

<img src="/figures/sunburst12.png" height="400">

```
sunburst value, by(continent region country) labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) threshold(2000) labcond(>1000) colorby(level)  palette(CET C6, reverse) 
```

<img src="/figures/sunburst13.png" height="400">

```
sunburst value, by(continent region country) labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) threshold(2000) share colorby(level)  palette(CET C7) 
```

<img src="/figures/sunburst14.png" height="400">

```
sunburst value, by(continent region country) labsize(2.2 1.8 1.4) lw(0.2 0.1 0.01) threshold(2000) share labcond(>1) colorby(level)  palette(CET C7) 
```

<img src="/figures/sunburst15.png" height="400">

```
sunburst value, by(continent region country) labsize(2 1.8 1.4) lw(0.2 0.1 0.01) threshold(2000) share labcond(>1) colorby(level) palette(CET C7) radius(6 12 15 25)
```

<img src="/figures/sunburst16.png" height="400">

```
sunburst value, by(continent region country) labsize(2 1.8 1.4) lw(0.2 0.1 0.01) threshold(2000) share labcond(>1) colorby(level) palette(CET C7) radius(6 12 18 25) ///
		title("My (half) sunburst figure in Stata") subtitle("Some more info here") note("Made using the #sunburst package.") 
```

<img src="/figures/sunburst17.png" height="400">

```
sunburst value, by(continent region country) labsize(2 1.8 1.4) lw(0.2 0.1 0.01) threshold(2000) share labcond(>1) colorby(level) palette(CET C7) radius(6 12 18 25) ///
		text(2.4 0 "My (half) sunburst figure" "in Stata", size(3))	
```

<img src="/figures/sunburst18.png" height="400">


## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-sunburst/issues) to report errors, feature enhancements, and/or other requests.


## Versions

**v1.0 (24 Dec 2022)**
- Public release.







