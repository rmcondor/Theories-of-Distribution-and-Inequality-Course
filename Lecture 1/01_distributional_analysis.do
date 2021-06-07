/**************************************************************
*Project	:	Distributional analysis of income (2004 - 2019)
*Objetive	: 	Create descriptive graphs and tables
*Author		:  	Ronny M. Condor (ronny.condor@unmsm.edu.pe)
*Inputs		:	ENAHO (2009-205)
*Outputs	:	Graphs and tables
*Comments	:	ENAHO dataset of many years was cleaned and generated previously by Sebastion Sardon. For more details, check his Github page. 
		
*****************************************************************/

global root "G:\Mi unidad\Teaching Assistant\TA-Economics of distribution & inequality\03_data"

global raw	"${root}\01_raw"
global codes	"${root}\02_codes"
global cleaned	"${root}\03_cleaned"
global analysis "${root}\04_analysis"
global results	"${root}\05_results"

*Dataset
use "${cleaned}\enaho_2009_to_2015",clear


*Variables of interest
global key_variables year conglome vivienda hogar codperso
global analysis_variables y_raw y y_rel factor07 linpe linea poor_ext poor
keep $key_variables $analysis_variables

*To have households as observations:
*duplicates drop year conglome vivienda hogar, force

*Summary of income per capita

forvalues x=2009(2)2015{
di "Año `x'"
sum y [aw=factor07] if year==`x', detail
display "Población de referencia (`x') =" r(sum_w) 
display "Coeficiente de variación (`x')=" r(sd)/r(mean)
}

*Histogram
*scheme
set scheme cleanplots, perm

*Order the income vector
sort y

*Not considering the 1% more rich (figure1)
forvalues x=2009(2)2015{
_pctile y if year==`x' [aw=factor07], percentiles(99)
display r(r1)
histogram y if year==`x' & y<=r(r1), bin(100) frac title("`x'") xtitle("Ingreso per cápita mensual") ytitle("Proporción") 
gr save hist`x', replace
}
graph combine hist2009.gph hist2011.gph hist2013.gph hist2015.gph, col(2) note("Fuente: INEI" "Elaboración: @rmcondor")
graph export "${analysis}\figura1.png", as(png) name("Graph") replace

*Using log(income) (figure2)
gen lny=log(y)
replace lny=. if lny<0
forvalues x=2009(2)2015{
histogram lny if year==`x', bin(100) frac title("`x'") xtitle("Ingreso per cápita mensual") ytitle("Proporción") 
gr save hist`x', replace
}
graph combine hist2009.gph hist2011.gph hist2013.gph hist2015.gph, col(2) note("Fuente: INEI" "Elaboración: @rmcondor")
graph export "${analysis}\figura2.png", as(png) name("Graph") replace

*Kernel density function (figure3)
*Average poverty line
sum linea [aw=factor07] if year>2009 & year<=2015
local lp = log(r(mean))
di `lp'

twoway (kdensity lny [aw=factor07] if year==2009) ///
(kdensity lny [aw=factor07] if year==2011) ///
(kdensity lny [aw=factor07] if year==2013) ///
(kdensity lny [aw=factor07] if year==2015), xline(`lp', lcolor(gold)) xtitle("Logaritmo del ingreso per cápita mensual") ytitle("Densidad") legend(label (1 "2009") label (2 "2011") label (3 "2013") label (4 "2015")) note("Fuente: INEI" "Elaboración: @rmcondor" "La línea punteada amarilla marca la línea de pobreza promedio entre 2009 y 2015 (en logaritmos).")
graph export "${analysis}\figura3.png", as(png) name("Graph") replace



*Cumulative distribution function (cdf) (figure4)
sort year y
by year: gen shrpop = sum(factor07) 
by year: replace shrpop=shrpop/shrpop[_N]

sum linea [aw=factor07] if year>2009 & year<=2015
local lp = r(mean)
twoway (line shrpop y if year==2009 & shrpop<0.95)  (line shrpop y if year==2011 & shrpop<0.95) (line shrpop y if year==2013 & shrpop<0.95) (line shrpop y if year==2015 & shrpop<0.95), xline(`lp', lcolor(gold)) xtitle("Ingreso per cápita mensual") ytitle("Proporción") legend(label (1 "2009") label (2 "2011") label (3 "2013") label (4 "2015")) note("Fuente: INEI" "Elaboración: @rmcondor" "La línea punteada amarilla marca la línea de pobreza promedio entre 2009 y 2015.")
graph export "${analysis}\figura4.png", as(png) name("Graph") replace


*Boxplots (figure5)
preserve
keep if year==2009 | year==2011 | year==2013 | year==2015
gr box y [aw=factor07] , nooutsides over(year) ytitle("Ingreso per cápita mensual") note("Fuente: INEI" "Elaboración: @rmcondor")
graph export "${analysis}\figura5.png", as(png) name("Graph") replace
restore

*Lorenz curve (figure6)
sort year y
by year: gen shrinc=sum(y*factor07) 
by year: replace shrinc=shrinc/shrinc[_N] //Cumulative income by year

twoway (line shrinc shrpop if year==2009) (line shrinc shrpop if year==2011) (line shrinc shrpop if year==2013) (line shrinc shrpop if year==2015) (function y=x) , xtitle("Porcentaje de la población") ytitle("Porcentaje de los ingresos")legend(label (1 "2009") label (2 "2011") label (3 "2013") label (4 "2015") label (5 "Línea de perfecta igualdad")) note("Fuente: INEI" "Elaboración: @rmcondor")
graph export "${analysis}\figura6.png", as(png) name("Graph") replace

*Coefficient Gini
ineqdec0 y, by(year)

*Graphs
use "${cleaned}\giniWB.dta", clear
drop if gini == .

graph tw (line gini year), xtitle("") ytitle("Coeficiente de Gini") note("Fuente: Banco Mundial" "Elaboración: @rmcondor")
graph export "${analysis}\figura7.png", as(png) name("Graph") replace

*Graphs
use "${cleaned}\povertylevel.dta", clear
graph tw (line national year), xtitle("") ytitle("Incidencia (% población)") note("Fuente: INEI" "Elaboración: @rmcondor") xlabel(2004(2)2019)
graph export "${analysis}\figura8.png", as(png) name("Graph") replace

graph tw (line national year) (line urban year) (line rural year) , xtitle("") ytitle("Incidencia (% población)") note("Fuente: INEI" "Elaboración: @rmcondor") xlabel(2004(2)2019) legend(label(1 "Nacional") label(2 "Urbano") label(3 "Rural"))
graph export "${analysis}\figura9.png", as(png) name("Graph") replace


*Drop thrash graphs
forvalues x=2009(2)2015{
	erase "${codes}/hist`x'.gph"
    }