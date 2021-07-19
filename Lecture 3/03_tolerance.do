/**************************************************************
*Project	:	Inequality topics: Tolerance to inequality
*Objetive	: 	Exploratory analysis of tolerance to inequality 
*Author		:  	Ronny M. Condor (ronny.condor@unmsm.edu.pe)
*Inputs		:	ENAHO (2019-2020)
*Outputs	:	Graphs and tables
*Comments	:	
		
*****************************************************************/

* econresearchR folder structure
********************************

global root "G:\Mi unidad\Teaching Assistant\TA-Economics of distribution & inequality\03_data"

global raw		"${root}\01_raw"
global codes	"${root}\02_codes"
global cleaned	"${root}\03_cleaned"
global analysis "${root}\04_analysis"
global results	"${root}\05_results"


**************************************************
*			Tolerance to inequality
**************************************************
use "${cleaned}\giniWB", clear

merge 1:1 countrycode year using "${cleaned}\political_stability_WB.dta", keep(3) nogen

merge 1:1 countrycode year using "${cleaned}\gdp_pc_WB.dta", keep(3) nogen


sort gdp_pc
xtile gdp_pc_q = gdp_pc, nq(5)

gen l_pol_est = log(pol_est)
gen l_gdp_pc  = log(gdp_pc)
gen l_gini	  = log(gini)

*Inequality vs stability
sum pol_est, d
tabstat pol_est, by(countryname)
graph tw (hist pol_est)
graph export "${analysis}\tolerance_inq1.png", as(png) name("Graph") replace

graph tw (hist pol_est if gdp_pc_q == 1, color(red%30)) ///
		 (hist pol_est if gdp_pc_q == 5, color(blue%30)), ///
		 legend(label(1 "Primer quintil") label(2 "Quinto quintil")) ///
		 ytitle("Densidad") xtitle("Índice de estabilidad política y" "ausencia del terrorismo") ///
		 saving(graph1, replace)

graph tw (kdensity pol_est if gdp_pc_q == 1, color(red%30)) ///
		 (kdensity pol_est if gdp_pc_q == 5, color(blue%30)), ///
		 legend(label(1 "Primer quintil") label(2 "Quinto quintil")) ///
		 ytitle("Densidad") xtitle("Índice de estabilidad política y" "ausencia del terrorismo") ///
		 saving(graph2, replace)

graph combine graph1.gph graph2.gph, note("Fuente: Banco Mundial" "Elaboración propia") col(2)
graph export "${analysis}\tolerance_inq2.png", as(png) name("Graph") replace

sort pol_est gdp_pc_q
cumul pol_est if gdp_pc_q == 1, gen(pol_est1)
cumul pol_est if gdp_pc_q == 5, gen(pol_est5)

tw (line pol_est1 pol_est if gdp_pc_q == 1) (line pol_est5 pol_est if gdp_pc_q == 5), ///
	ytitle("Función de distribución acumulada (CDF)") ///
	xtitle("Índice de estabilidad política y" "ausencia del terrorismo") ///
	legend(label(1 "Primer quintil") label(2 "Quinto quintil")) ///
	note("Fuente: Banco Mundial" "Elaboración propia")
graph export "${analysis}\tolerance_inq3.png", as(png) name("Graph") replace


tw (scatter pol_est gini), ///
	xtitle("Índice de Gini") ytitle("Índice de estabilidad política y" "ausencia del terrorismo") ///
	note("Fuente: Banco Mundial" "Elaboración propia")
graph export "${analysis}\tolerance_inq4.png", as(png) name("Graph") replace

binscatter pol_est gini, nquantiles(50) title("") xtitle("Índice de Gini") ///
		 ytitle("Índice de estabilidad política y" "ausencia del terrorismo") ///
		 note("Fuente: Banco Mundial" "Elaboración propia") 
graph export "${analysis}\tolerance_inq5.png", as(png) name("Graph") replace


tw (scatter pol_est gini) if countrycode == "PER", ///
	xtitle("Índice de Gini") ytitle("Índice de estabilidad política y" "ausencia del terrorismo") ///
	saving(graph1, replace)
binscatter pol_est gini if countrycode == "PER", title("") xtitle("Índice de Gini") ///
		 ytitle("Índice de estabilidad política y" "ausencia del terrorismo") ///
		 savegraph(graph2) replace reportreg

graph combine graph1.gph graph2.gph, title("Perú") note("Fuente: Banco Mundial" "Elaboración propia") col(2)
graph export "${analysis}\tolerance_inq6.png", as(png) name("Graph") replace


tw  (scatter l_pol_est l_gini if gdp_pc_q == 1) (scatter l_pol_est l_gini if gdp_pc_q == 5) ///
	(lfit l_pol_est l_gini if gdp_pc_q == 1) (lfit l_pol_est l_gini if gdp_pc_q == 5), ///
	xtitle("Log del Índice de Gini") ytitle("Log del Índice de estabilidad política y" "ausencia del terrorismo") ///
	note("La estimación fue realizada mediante una regresión lineal (OLS)" "Fuente: Banco Mundial" "Elaboración propia") ///
	legend(order(1 3 2 4) cols(2) position(6)) ///
	legend(label (1 "Quintil 1 (observado)") label (2 "Quintil 5 (observado)") label (3 "Quintil 1 (estimado)") label (4 "Quintil 5 (estimado)"))
graph export "${analysis}\tolerance_inq7.png", as(png) name("Graph") replace

reg l_pol_est l_gini gdp_pc_q


