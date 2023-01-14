{smcl}
{* 14Jan2022}{...}
{hi:help sunburst}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-sunburst":sunburst v1.1 (GitHub)}}

{hline}

{title:sunburst}: A Stata package for (half) sunburst plots.

{p 4 4 2}
The command is based on the following guide on Medium: {browse "https://medium.com/the-stata-guide/stata-graphs-half-sunburst-plot-19131cf40446":Half-sunburst plots}.
The command is still {it:beta} and is subject to change and improvements. Please regularly check the {browse "https://github.com/asjadnaqvi/stata-sunburst":GitHub} page for version changes and updates.
A full circle sunburst will be released in later versions.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:sunburst} {it:numvar} {ifin}, {cmd:by}({it:variables}) 
                {cmd:[} {cmdab:rad:ius}({it:numlist}) {cmd:step}({it:num}) {cmd:palette}({it:str}) {cmd:colorby}({it:option}) {cmd:fade}({it:num}) {cmd:share} 
                  {cmdab:thresh:old}({it:cutoff}) {cmdab:labcond:ition}({it:num}) {cmd:format}({it:str}) {cmdab:lw:idth}({it:list}) 
                  {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:aspect}({it:num}) {cmd:]}

{p 4 4 2}


{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt sunburst numvar, by(variables)}}The command requires a numerical variable {it:numvar}, plotted over a sequence of heirarchical variables defined by {opt by()}.
The option {opt by()} should be specified from higher grouping category to finer categories. If there are imperfect overlaps in the {opt by()} layers, then lower tier layers
will be split based on higher tier layers. Currently, there is no limit to the number of layers that can be specified. But more complex combinations of 
layers will result in longer processing times for the graph.{p_end}

{p2coldent : {opt rad:ius(numlist)}}The radii for the arcs can be manually specified here for fine tuning. Note that the number of radii should be one more than
the number of {opt over()} variables. If no option is specified, then the command will automatically start with a radius of 5, incremented in {opt steps} of 5.{p_end}

{p2coldent : {opt step(num)}}The step size for auto-generated radii can be modified here. The default is {opt step(5)}.{p_end}

{p2coldent : {opt palette(name)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.
The first layer defined as the first option in {opt by()} will determine the colors. The next set of layers will take on this color with slightly lower fill intensities.{p_end}

{p2coldent : {opt colorby(base|layer)}}The {opt colorby()} option determines how colors are drawn. The default {opt colorby(base)} option just uses a homogenous
color determined the first layer and the palette scheme. The {opt colorby(layer)} or {opt colorby(level)} option (both are interchangable) adds a 
gradient fill to the {it:last} layer. Where the gradient is interpolated between the base color and faded to 10% of the base color. 
The {opt fade()} can bse used to control this value (see below). Note that the base color is determined by the first layer.
This option can significantly slow down the computation of the graph if there are a lot of layer combinations.{p_end}

{p2coldent : {opt fade(num)}}The amount of fade when using the {opt colorby(layer)} option (see above). The default value is {opt fade(10)} or 10% of base color.{p_end}

{p2coldent : {opt share}}Show shares (0-100) rather than values in layer labels. Shares add up to 100 for each {opt by()} layer.{p_end}

{p2coldent : {opt thresh:old(value)}}The cut-off value below which the values are collapsed into one group, and labeled as "Rest of ...". This option is highly useful if
there are a lot of very small barely-discernible slices. Default is {opt thresh(0)}.{p_end}

{p2coldent : {opt labcond:ition(num)}}The condition for showing value labels. For example, if we only want to display categories with a greater than a value of 100, we can specify
{opt valcond(100)}. If the {opt share} is used, then please specify the share threshold (out of 100). Default is {opt valcond(0)}.{p_end}

{p2coldent : {opt format(str)}}Format the displayed values. Default for standard values is {opt format(%9.0fc)} and for shares it is {opt format(%5.2f)}.{p_end}

{p2coldent : {opt lw:idth(numlist)}}The option can be used to specify a list of line widths for the {opt by()} layers. The number of elements should equal the number of variables in {opt by()}.
Default line widths are {it:0.12} for the {it:1...n-1} layers, and {it:0.02} for the {it:n}th layer.{p_end}

{p2coldent : {opt xsize()}, {opt ysize()}, {opt aspect()}}For the semi-circle graph, the dimensions have been fixed at {opt xsize(2)} and {opt ysize(1)}. This naturally results in an aspect ratio of {opt aspect(0.5)}.
Regardless, these parameters have been made available to allow the users to play around with the dimensions. Use cautiously!{p_end}

{p2coldent : {opt title()}, {opt subtitle()}, {opt note()}, {opt name()}}These are standard twoway graph options.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018) is required for {cmd:sunburst}:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to update the dependencies:
{stata ado update, update}

{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-sunburst":GitHub} for examples.



{hline}

{title:Package details}

Version      : {bf:sunburst} v1.1
This release : 14 Jan 2023
First release: 24 Dec 2022
Repository   : {browse "https://github.com/asjadnaqvi/stata-sunburst":GitHub}
Keywords     : Stata, graph, sunburst
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{title:Acknowledgements}



{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-sunburst/issues":GitHub} by opening a new issue.

{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 


{title:Other visualization packages}

{psee}
    {helpb treecluster}, {helpb sankey}, {helpb alluvial}, {helpb circlebar}, {helpb spider}, {helpb treemap}, {helpb circlepack}, {helpb arcplot},
	{helpb marimekko}, {helpb bimap}, {helpb joyplot}, {helpb streamplot}, {helpb delaunay}, {helpb clipgeo},  {helpb schemepack}

