/**************************************************************
*Project	:	Datasets creator
*Objetive	: 	Cleaning raw data for analysis 
*Author		:  	Ronny M. Condor (ronny.condor@unmsm.edu.pe)
*Inputs		:	Many sources
*Outputs	:	Cleaned datasets
*Comments	:	
		
*****************************************************************/

* econresearchR folder structure
********************************

global root "G:\Mi unidad\Teaching Assistant\TA-Economics of distribution & inequality\03_data"

global raw	"${root}\01_raw"
global codes	"${root}\02_codes"
global cleaned	"${root}\03_cleaned"
global analysis "${root}\04_analysis"
global results	"${root}\05_results"

* Packages needes
*net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
set scheme cleanplots, perm

*==========================================================================
*			Dataset : Gini Index
* 			Sources : World Bank
*==========================================================================

local clean	=	1

if `clean' == 1 {

import excel "${raw}\API_SI.POV.GINI_DS2_en_excel_v2_2592999.xls", sheet("Data") firstrow case(lower) clear

*keep if countrycode=="PER"

reshape long y, i(countrycode) j(year)

rename y gini
keep year countrycode countryname gini
order year countrycode countryname gini
label variable year "Year"
label variable gini "Gini Index"

replace gini = gini/100
replace countryname = upper(ustrto(ustrnormalize(countryname, "nfd"), "ascii", 2))

save "${cleaned}\giniWB.dta", replace
}

*==========================================================================
*				Dataset: ENAHO (2019-2020)
*				Source : INEI
*==========================================================================

local clean	=	0 //1 if need cleaning

if `clean' == 1 {

*1.Tempfiles with relevant variables

local key_vars ubigeo conglome vivienda hogar
local use_vars gashog1d gashog2d gru11hd gru21hd gru31hd gru41hd gru51hd gru61hd gru71hd gru81hd ingmo1hd inghog2d mieperho pobreza fac* linea* linpe 

forvalues yy = 2019(1)2020	{

use "${raw}/Modulo 34/`yy'/`yy'.dta", clear
	gen year=`yy'

		foreach var in `key_vars' ubigeo {
	    destring `var', force replace
		}
	sort year `key_vars'
	keep year `key_vars' `use_vars' 
	save "${raw}\tmp_`yy'.dta",	replace
}

*2. Append

clear
forvalues yy=2019(1)2020{	
	append using "${raw}/tmp_`yy'.dta"
	}


*3. Generate household-level variables

gen poor_ext = (pobreza == 1)
gen poor     = (pobreza <= 2)
gen no_poor  = (pobreza == 3)

*Based on Aragon & Rud (AEJ:EP 2013)
gen y_raw = ingmo1hd/mieperho/12 
gen y     = inghog2d/mieperho/12 
gen exp   = gashog2d/mieperho/12 

gen y_rel   =   y/linea
gen exp_rel = exp/linea

*Consumption by type	
*Type 1: food 
*Type 2: clothes
*Type 3: home rent, fuel and utilities
*Type 4: funiture and home maintenance
*Type 5: healthcare
*Type 6: transport and communication
*Type 7: leisure, education and cultural activities

egen exp_1 = rowtotal(gru11hd) 
egen exp_2 = rowtotal(gru21hd)
egen exp_3 = rowtotal(gru31hd)
egen exp_4 = rowtotal(gru41hd)
egen exp_5 = rowtotal(gru51hd)
egen exp_6 = rowtotal(gru61hd)
egen exp_7 = rowtotal(gru71hd)
drop gru* inghog* gashog*

 
*4. Variable Labels
 
label var exp_1 "expenditures on food "
label var exp_2 "expenditures on clothes"
label var exp_3 "expenditures on household maintenance and rent"
label var exp_4 "expenditures on furnishes"
label var exp_5 "expenditures on health services and goods"
label var exp_6 "expenditures on transport and comms"
label var exp_7 "expenditures on leisure"

label var poor     "Is poor"
label var poor_ext "Is extremely poor"
label var no_poor	"Is no poor"

label var linea "Linea total"
label var linpe "Linea de alimentos"

label var y_raw "Raw monetary HH income per capita (monthly, current PEN)"
label var y     "Net HH income per capita (monthly, current PEN)"
label var exp   "Total expenditures per capita (monthly, current PEN)"

label var y_rel   "HH pc income relative to poverty line"
label var exp_rel "Expenditure relative to poverty line"

label var linea "Poverty line"
label var linpe "Extreme poverty line"

order year, before(conglome)
compress

*5. Geographical Variable
tostring ubigeo, gen(district)
replace district = "0" + district if length(district) == 5
gen department   = substr(district,1,2)
gen province     = substr(district,1,4)
lab var department 	"Department"
lab var province 	"Province"
destring province, replace

gen     dep_name = ""
replace dep_name = "AMAZONAS"      if department == "01"
replace dep_name = "ANCASH"        if department == "02"
replace dep_name = "APURIMAC"      if department == "03"
replace dep_name = "AREQUIPA"      if department == "04"
replace dep_name = "AYACUCHO"      if department == "05"
replace dep_name = "CAJAMARCA"     if department == "06"
replace dep_name = "CALLAO"        if department == "07"
replace dep_name = "CUSCO"         if department == "08"
replace dep_name = "HUANCAVELICA"  if department == "09"
replace dep_name = "HUANUCO"       if department == "10"
replace dep_name = "ICA"           if department == "11"
replace dep_name = "JUNIN"         if department == "12"
replace dep_name = "LA LIBERTAD"   if department == "13"
replace dep_name = "LAMBAYEQUE"    if department == "14"
replace dep_name = "LIMA"          if department == "15"
replace dep_name = "LORETO"        if department == "16"
replace dep_name = "MADRE DE DIOS" if department == "17"
replace dep_name = "MOQUEGUA"      if department == "18"
replace dep_name = "PASCO"         if department == "19"
replace dep_name = "PIURA"         if department == "20"
replace dep_name = "PUNO"          if department == "21"
replace dep_name = "SAN MARTIN"    if department == "22"
replace dep_name = "TACNA"         if department == "23"
replace dep_name = "TUMBES"        if department == "24"
replace dep_name = "UCAYALI"       if department == "25"

destring department, replace
label define department 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 6 "CAJAMARCA" 7 "CALLAO" ///
						8 "CUSCO" 9 "HUANCAVELICA" 10 "HUANUCO" 11 "ICA" 12 "JUNIN" 13 "LA LIBERTAD" 14 "LAMBAYEQUE" ///
						15 "LIMA" 16 "LORETO" 17 "MADRE DE DIOS" 18 "MOQUEGUA" 19 "PASCO" 20 "PIURA" 21 "PUNO" ///
						22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI"
label values department department
drop district

*6. Save cleaned dataset and remove temporal files

forvalues yy=2019(1)2020{
	erase "${raw}/tmp_`yy'.dta"
    }

save "${cleaned}\enaho_2019_to_2020.dta", replace

}

*==========================================================================
*				Dataset: ENAHO - Gini indices (2019 y 2020)
*				Source : INEI
*==========================================================================

local clean	=	0 //1 if need cleaning

if `clean' == 1 {
	
use "${cleaned}\enaho_2019_to_2020.dta", clear

*2. Store indices in dataset variables
*First option
*statsby gini = r(gini), by(dep_name): ineqdeco y

*Second option

*Regional level
forvalues yy = 2019(1)2020{

ineqdeco y if year== `yy' , by(department)
return list //note: inequality indices stored for each group

gen gini`yy' 	= 	.
lab var gini`yy' "Gini index `yy'"

levelsof department, local(levels)
foreach x of local levels {
	qui ineqdeco y if department == `x' & year == `yy' 
	replace gini`yy' = r(gini) if department == `x' & year == `yy' 
}

}

collapse (mean) gini*, by(department year)
sort year department
lab var year 	 "Year"
lab var gini2019 "Gini index 2019"
lab var gini2020 "Gini index 2020"
gen gini = gini2019 if year == 2019
replace gini = gini2020 if year == 2020
drop gini2019 gini2020
save "${cleaned}\gini_regional", replace

*Province level
use "${cleaned}\enaho_2019_to_2020.dta", clear

levelsof province, local(levels)
keep if year == 2019
gen gini = .

levelsof province, local(levels)
qui foreach x of local levels {
	ineqdeco y if province == `x'
	replace gini = r(gini) if province == `x'
}

preserve
collapse (mean) gini, by(department province year)
sort year department province
sort year department
lab var year 	 "Year"
save "${cleaned}\gini_provincial", replace
restore



}

*==========================================================================
*				Dataset: Peruvian presidential election
*							Second round (2021)
*				Source : ONPE
*==========================================================================

local clean	=	0 //1 if need cleaning

if `clean' == 1 {

import delimited "${raw}\Resultados_2da_vuelta_Version_ONPE\Resultados_2da_vuelta_Version_PCM .csv", clear 
keep ubigeo - votos_vi

drop if departamento == "AFRICA" | departamento == "AMERICA" | departamento == "ASIA" | departamento == "EUROPA" | departamento == "OCEANIA" 

rename 	(distrito provincia) (district province_lab)

encode(departamento), gen(department)
drop departamento

tostring ubigeo, replace
replace ubigeo = "0" + ubigeo if length(ubigeo) == 5
gen province     = substr(ubigeo,1,4)
destring province, replace
destring ubigeo, replace

lab var ubigeo				"Ubigeo"
lab var department			"Departamento"

label define department 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 6 "CAJAMARCA" 7 "CALLAO" ///
						8 "CUSCO" 9 "HUANCAVELICA" 10 "HUANUCO" 11 "ICA" 12 "JUNIN" 13 "LA LIBERTAD" 14 "LAMBAYEQUE" ///
						15 "LIMA" 16 "LORETO" 17 "MADRE DE DIOS" 18 "MOQUEGUA" 19 "PASCO" 20 "PIURA" 21 "PUNO" ///
						22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI", modify
label values department department
label var province_lab		"Provincia"
lab var province			"Provincia (CODE)"
lab var district			"Distrito"
lab var tipo_eleccion 		"Tipo de elección"
lab var mesa_de_votacion 	"Mesa de votación"
lab var descrip_estado_acta "Estado del acta"
lab var tipo_observacion	"Código del tipo de observación"
lab var n_cvas				"Número de ciudadanos que votaron en la mesa según el acta de sufragio"
lab var n_elec_habil		"Número de electores hábiles de la mesa"
lab var votos_p1			"Votos por Partído Politico Perú Libre"
lab var votos_p2			"Votos por Partido Político Fuerza Popular"
lab var votos_vn			"Votos nulos"
lab var votos_vb			"Votos en blanco"
lab var votos_vi			"Votos impugnados"	

order ubigeo department province province_lab district

save "${cleaned}\presidential_election_PER2021.dta", replace

}

*==========================================================================
*				Dataset: Spatial data of departments
*				Source : GEO-GPS PERU
*==========================================================================

local clean	=	0 //1 if need cleaning

if `clean' == 1 {

grmap, activate
shp2dta using "${raw}\INEI_departamental\INEI_LIMITE_DEPARTAMENTAL_GEOGPSPERU_JUANSUYO_931381206.shp", database("${cleaned}\perureg") coordinates("${cleaned}\peruregcoord") genid(id) gencentroids(centroids) replace

use "${cleaned}\perureg.dta", clear
keep id x_centroids y_centroids Shape_STAr Shape_STLe Shape_Leng Shape_Area
gen department = id
lab var department "Department"
label define department 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 6 "CAJAMARCA" 7 "CALLAO" ///
						8 "CUSCO" 9 "HUANCAVELICA" 10 "HUANUCO" 11 "ICA" 12 "JUNIN" 13 "LA LIBERTAD" 14 "LAMBAYEQUE" ///
						15 "LIMA" 16 "LORETO" 17 "MADRE DE DIOS" 18 "MOQUEGUA" 19 "PASCO" 20 "PIURA" 21 "PUNO" ///
						22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI"
label values department department
order id department
save "${cleaned}\perureg.dta", replace

}

*==========================================================================
*				Dataset: Political Stability and 
*						 Absence of Violence/Terrorism 
*				Source : World Bank
*==========================================================================

local clean	=	1 //1 if need cleaning

if `clean' == 1 {

import excel "${raw}\Data_Extract_From_Worldwide_Governance_Indicators.xlsx", sheet("Data") firstrow case(lower) clear

drop seriesname
foreach var of varlist yr2019 - yr1996 {
	replace `var' = "" if `var'==".."
}

destring yr*,replace

reshape long yr, i(countrycode) j(year)

rename yr pol_est
lab var pol_est "Political Stability and Absence of Violence/Terrorism: Estimate"
lab var year "Year"
sort countrycode

replace countryname = upper(ustrto(ustrnormalize(countryname, "nfd"), "ascii", 2))
drop seriescode

save "${cleaned}\political_stability_WB.dta", replace

}

*==========================================================================
*				Dataset: PIB per cápita
*				Source : World Bank
*==========================================================================

import excel "${raw}\API_NY.GDP.PCAP.CD_DS2_en_excel_v2_2627338.xls", sheet("Data") firstrow case(lower) clear

reshape long y, i(countrycode) j(year)

rename y gdp_pc
keep year countrycode countryname gdp_pc
order year countrycode countryname gdp_pc
label variable year "Year"
label variable gdp_pc "GDP per capita (current USD)"

replace countryname = upper(ustrto(ustrnormalize(countryname, "nfd"), "ascii", 2))

save "${cleaned}\gdp_pc_WB.dta", replace
