{smcl}
{* 07Feb2024}{...}
{hi:help sunburst}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-sunburst":sunburst v1.7 (GitHub)}}

{hline}

{title:sunburst}: A Stata package for sunburst plots.

{p 4 4 2}
The command is based on the following guide on Medium: {browse "https://medium.com/the-stata-guide/stata-graphs-half-sunburst-plot-19131cf40446":Half-sunburst plots}.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:sunburst} {it:numvar} {ifin}, {cmd:by}({it:variables}) 
                {cmd:[} {cmdab:rad:ius}({it:numlist}) {cmd:step}({it:num}) {cmd:palette}({it:str}) {cmd:colorby}({it:option}) {cmd:colorvar}({it:var}) {cmd:colorprop} {cmd:fade}({it:num}) {cmd:share} 
                  {cmd:format}({it:str}) {cmdab:thresh:old}({it:num}) {cmdab:labcond:ition}({it:num}) {cmdab:labc:olor}({it:str}) {cmdab:lw:idth}({it:numlist}) 
                  {cmdab:labs:ize}({it:numlist}) {cmdab:labl:ayer}({it:numlist}) {cmd:labprop} {cmd:labscale}({it:num}) {cmd:points}({it:num})
                  {cmd:full} {cmd:cfill}({it:str}) {cmdab:clc:olor}({it:str}) {cmdab:clw:idth}({it:str})
                  {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:saving}({it:str}) {cmd:aspect}({it:num}) 
                {cmd:]}

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

{p2coldent : {opt colorby(option)}}Currently only {opt colorby(name)} can be specified. This colors the slices based on the alphabetical order of the first layer rather than the order
determined by the value rank in the counter-clockwise direction.{p_end}

{p2coldent : {opt colorvar(var)}}This option allows assigning custom colors from a variable. The variable should have a unique integer number assigned to the highest {opt by()} category variable.
The integers indicate the color number from the palette used. For example if a group has a color variable equal to 4, then the fouth color in the palette will be used. This option is highly useful to ensure
color consistency across different sunburst plots that have overlapping categories regardless of the order they appears in the figures.
Multiple groups can be assigned the same color. If the color variable is missing values, it will be assigned one number higher than the highest value in the group.{p_end}

{p2coldent : {opt colorprop}}The last layer has a gradient fill across the categories, where the base color is faded from 100% to 10% through equal intervals interpolation.
The fade value can be controlled by the {opt fade()} option described below.{p_end}

{p2coldent : {opt fade(num)}}The amount of fade when using the {opt colorby(layer)} option (see above). The default value is {opt fade(10)} or 10% of base color.{p_end}

{p2coldent : {opt share}}Show shares (0-100) rather than values in layer labels. Shares add up to 100 for each {opt by()} layer.{p_end}

{p2coldent : {opt thresh:old(value)}}The cut-off value below which the values are collapsed into one group, and labeled as "Rest of ...". This option is highly useful if
there are a lot of very small barely-discernible slices. Default is {opt thresh(0)}.{p_end}

{p2coldent : {opt labcond:ition(num)}}The condition for showing value labels. For example, if we only want to display categories with a greater than a value of 100, we can specify
{opt labcond(100)}. If the {opt share} is used, then please specify the share threshold (out of 100). Default is {opt labcond(0)}.{p_end}

{p2coldent : {opt labc:olor(str)}}The color of the labels. Default is {opt labc(white)}.{p_end}

{p2coldent : {opt labs:ize(numlist)}}The list defining the size of the labels for each layer. Default is {opt labs(2)}. If only one option is specified, it will apply to all layers.{p_end}

{p2coldent : {opt labl:ayer(numlist)}}The list of layers for which to show value labels. For example, if we have three layers and we want label the last two, the syntax is {opt labl(2 3)}.
Note that first layer is always indexed as layer 1 internally. Default is show value labels for all layers. {p_end}

{p2coldent : {opt labprop}}Show labels proportional to their size.{p_end}

{p2coldent : {opt labscale(num)}}Changing the scaling of the proportional labels. Default is {opt labscale(1)}. A value of <1 penalizes reduces the scaling of smaller values to make them
more visible. This is an advanced option so use it carefully and test with small increments.{p_end}

{p2coldent : {opt format(str)}}Format the displayed values. Default for standard values is {opt format(%9.0fc)} and for shares it is {opt format(%5.2f)}.{p_end}

{p2coldent : {opt lw:idth(numlist)}}The option can be used to specify a list of line widths for the {opt by()} layers. The number of elements should equal the number of variables in {opt by()}.
Default line widths are {it:0.12} for the {it:1...n-1} layers, and {it:0.02} for the {it:n}th layer.{p_end}

{p2coldent : {opt cfill(str)}}The color fill of the semi circle. Default is {opt cfill(white)}. This option is especially useful if a non-white background is used.{p_end}

{p2coldent : {opt clc:olor(str)}}Line color of the center circle line. Default is {opt clc(white)}.{p_end}

{p2coldent : {opt clw:idth(str)}}Line with of the center circle line. Default is {opt clw(0.2)}.{p_end}

{p2coldent : {opt points(num)}}Number of points to evaluate an arc. Default value is {opt points(100)}. If the arc are very small, it is recommended to reduce the points to lower
the memory burden of drawing more points. This is an advanced option so use carefully.{p_end}

{p2coldent : {opt xsize()}, {opt ysize()}, {opt aspect()}}For the semi-circle graph, the dimensions have been fixed at {opt xsize(2)} and {opt ysize(1)}. 
This naturally results in an aspect ratio of {opt aspect(0.5)}.
Regardless, these parameters have been made available to allow the users to play around with the dimensions. But use these cautiously.{p_end}

{p2coldent : {opt title()}, {opt subtitle()}, {opt note()}}These are standard twoway graph options.{p_end}

{p2coldent : {opt name()}, {opt saving()}}These are standard twoway graph options.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018, 2022) is required for {cmd:sunburst}:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to update the dependencies:
{stata ado update, update}

{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-sunburst":GitHub} for examples.


{hline}

{title:Package details}

Version      : {bf:sunburst} v1.7
This release : 07 Feb 2024
First release: 24 Dec 2022
Repository   : {browse "https://github.com/asjadnaqvi/stata-sunburst":GitHub}
Keywords     : Stata, graph, sunburst
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}



{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-sunburst/issues":GitHub} by opening a new issue.

{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb joyplot}, 
	{helpb marimekko}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb streamplot}, {helpb sunburst}, {helpb treecluster}, {helpb treemap}

