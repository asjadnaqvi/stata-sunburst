{smcl}
{* 04May2026}{...}
{hi:help sunburst}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-sunburst":sunburst v2.0 (GitHub)}}

{hline}

{title:sunburst}: A Stata package for sunburst plots.

{p 4 4 2}
The command is based on the following guide on Medium: {browse "https://medium.com/the-stata-guide/stata-graphs-half-sunburst-plot-19131cf40446":Half-sunburst plots}.

{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:sunburst} {it:numvarlist} {ifin}, {cmd:by}({it:variables}) 
                {cmd:[} {cmdab:rad:ius}({it:numlist}) {cmd:step}({it:num}) {cmd:palette}({it:str}) {cmd:colorby}({it:option}) {cmd:colorvar}({it:var}) {cmd:colorprop} {cmd:fade}({it:num}) {cmd:share} 
                  {cmd:format}({it:str}) {cmdab:thresh:old}({it:num}) {cmdab:labcond:ition}({it:num}) {cmdab:labc:olor}({it:str}) {cmdab:lw:idth}({it:numlist}) 
                  {cmdab:labs:ize}({it:numlist}) {cmdab:labl:ayer}({it:numlist}) {cmd:labprop} {cmd:labscale}({it:num}) {cmd:points}({it:num}) {cmd:rotate}({it:degrees}) 
                  {cmd:full} {cmd:cfill}({it:str}) {cmdab:clc:olor}({it:str}) {cmdab:clw:idth}({it:str}) {cmd:wrap}({it:numlist}) {cmd:fill}({it:numlist}) {cmd:misscolor}({it:str}) {cmd:misslabel}({it:str}) {opt asis} * {cmd:]}
{p 4 4 2}


{marker options}{title:Options}

{synoptset 24 tabbed}{...}

{marker required}{dlgtab:Required}

{p2coldent : {opt sunburst} numvarlist}The command accepts either one numerical variable or one numerical variable per hierarchy layer. With a single value variable, the supplied variable is treated as the leaf value and upper layers are derived by aggregation.{p_end}

{p2coldent : {opt by(variables)}}At least one hierarchy variable should be specified in top-to-bottom order. If multiple value variables are provided in {it:numvarlist}, then their count must match the number of {opt by()} variables.{p_end}

{p 8 8 2}When multiple value variables are supplied, any residual between a parent layer and the sum of observed children is drawn as an explicit missing slice. By default these slices are left unlabeled and filled using {bf:white}.{p_end}

{marker display}{dlgtab:Display options}

{p2coldent : {opt rad:ius(numlist)}}Define arc radii manually. The number of radii should be one more than the number of {opt by()} variables. If omitted, radii are generated automatically using {opt step()}.{p_end}

{p2coldent : {opt step(num)}}Step size for auto-generated radii. Default is {opt step(5)}.{p_end}

{p2coldent : {opt asis}}Draw in data order. Default behavior sorts categories by descending values.{p_end}

{p2coldent : {opt share}}Show shares (0-100) instead of raw values in labels.{p_end}

{p2coldent : {opt format(fmt)}}Format shown values. Defaults are {opt format(%9.0fc)} for values and {opt format(%5.2f)} for shares.{p_end}

{p2coldent : {opt thresh:old(num)}}Values below the threshold are collapsed into a "Rest of ..." category. Default is {opt thresh(0)}.{p_end}

{p2coldent : {opt xsize(num)}, {opt ysize(num)}}Width and height of the figure. Defaults are {opt xsize(2)} and {opt ysize(1)} for half sunburst; with {opt full}, defaults are internally adjusted for a square canvas.{p_end}

{marker colors}{dlgtab:Colors and palette}

{p2coldent : {opt palette(str)}}Named palette from {stata help colorpalette:colorpalette}. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt colorby(option)}}Currently supports {opt colorby(name)} to assign colors using the first-layer category names rather than rank order.{p_end}

{p2coldent : {opt colorvar(var)}}Use an integer variable to control palette index assignment for first-layer categories, enabling consistent colors across plots.{p_end}

{p2coldent : {opt colorprop}}Apply a within-group gradient on the final layer, interpolated from base color to faded color.{p_end}

{p2coldent : {opt fade(num)}}Controls the faded end color when {opt colorprop} is used. Default is {opt fade(60)}.{p_end}

{p2coldent : {opt misscolor(str)}}Fill color for residual or missing slices from incomplete lower layers. Default is {opt misscolor(white)}.{p_end}

{p2coldent : {opt misslabel(str)}}Label used for residual or missing slices from incomplete lower layers. Default is blank (no label).{p_end}

{marker labels}{dlgtab:Labels and text}

{p2coldent : {opt labcond:ition(num)}}Minimum threshold for showing labels. With {opt share}, specify threshold in percentage points (0-100).{p_end}

{p2coldent : {opt wrap(numlist)}}Wrap labels after the specified character counts. One value applies to all layers, or provide one value per layer. Word boundaries are respected.{p_end}

{p2coldent : {opt labc:olor(str)}}Label color. Default is {opt labc(black)}.{p_end}

{p2coldent : {opt labs:ize(numlist)}}Label sizes per layer. If fewer values than layers are supplied, the last value is reused for remaining layers.{p_end}

{p2coldent : {opt labl:ayer(numlist)}}Specify layers for which labels are shown. Layers are indexed from 1 (inner hierarchy) to {it:n} (outermost hierarchy).{p_end}

{p2coldent : {opt labprop}}Scale labels proportionally to slice size.{p_end}

{p2coldent : {opt labscale(num)}}Adjust proportional label scaling. Default is {opt labscale(1)}.{p_end}

{marker layout}{dlgtab:Layout and styling}

{p2coldent : {opt rotate(degrees)}}If {opt full} is specified, rotate the chart counter-clockwise by {it:degrees}. Default is {opt rotate(0)}.{p_end}

{p2coldent : {opt full}}Draw a full-circle sunburst instead of the default half-circle.{p_end}

{p2coldent : {opt lw:idth(numlist)}}Line widths by layer. Defaults are {it:0.12} for inner layers and {it:0.02} for the outermost layer.{p_end}

{p2coldent : {opt fill(numlist)}}Fill opacity by layer. If fewer values than layers are provided, the last value is reused for remaining layers. If omitted, layer-wise defaults are used.{p_end}

{p2coldent : {opt lc:olor(str)}}Line color of slices. Default is {opt lcolor(white)}.{p_end}

{p2coldent : {opt cfill(str)}}Fill color of center circle. Default is {opt cfill(white)}.{p_end}

{p2coldent : {opt clc:olor(str)}}Line color of the center circle. Default is {opt clc(white)}.{p_end}

{p2coldent : {opt clw:idth(str)}}Line width of the center circle. Default is {opt clw(0.2)}.{p_end}

{p2coldent : {opt points(num)}}Number of points used to evaluate arc boundaries. Default is {opt points(100)}.{p_end}

{marker twoway}{dlgtab:Twoway options}

{p2coldent : {opt *}}All other standard twoway options not elsewhere specified and not blocked by the program.{p_end}

{synoptline}
{p2colreset}{...}


{marker dependencies}{...}
{title:Dependencies}

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}
{stata ssc install graphfunctions, replace}

Please make sure you have the latest versions installed.

{marker examples}{...}
{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-sunburst":GitHub} for examples.


{hline}

{marker feedback}{...}
{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-sunburst/issues":GitHub} by opening a new issue.


{marker package}{...}
{title:Package details}

Version      : {bf:sunburst} v2.0
This release : 04 May 2026
First release: 24 Dec 2022
Repository   : {browse "https://github.com/asjadnaqvi/stata-sunburst":GitHub}
Keywords     : Stata, graph, sunburst
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{marker citation}{...}
{title:Citation guidelines}

Suggested citation guidlines for this package:

See {browse "https://ideas.repec.org/c/boc/bocode/s459164.html"} for the official SSC citation. 
Please note that the GitHub version might be newer than the SSC version.

{marker references}{...}
{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 


{marker others}{...}
{title:Other visualization packages}

{psee}
    {helpb alluvial}, {helpb arcplot}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, 
	{helpb geoboundary}, {helpb geoflow}, {helpb graphfunctions}, {helpb marimekko}, {helpb polarspike}, {helpb ridgeline}, 
	{helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit},
	{helpb streamplot}, {helpb sunburst}, {helpb ternary}, {helpb tidytuesday}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}.

or visit {browse "https://github.com/asjadnaqvi":GitHub}.