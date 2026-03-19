* Name: Sarah Mzee
* Course: PBHLT 7101
* Assignment: Project 1 – ANSUR II Analysis
* Date: March 12, 2026

clear all
set more off

cd "~/Desktop"
use "ansur2allV2.dta", clear

* INITIAL CHECKS
  describe
  codebook
  tab age

drop if age < 18
summ age

* RECODE MISSING (-99 to .a)
  foreach var in thumbtipreach span footlength kneeheightmidpatella ///
  waistheightomphalion functionalleglength cervicaleheight ///
  trochanterionheight stature waistcircumference ///
  chestcircumference bicristalbreadth hipbreadth ///
  hipbreadthsitting weightkg {
  replace `var' = .a if `var' == -99
  }

* CREATE VARIABLES
  gen weight_kg = weightkg/10
  label variable weight_kg "Weight in kilograms"

gen height_cm = heightin * 2.54
label variable height_cm "Height in centimeters"

* FLAG SUSPECT VALUES
  gen suspect_weight = 0
  replace suspect_weight = 1 if weight_kg < 35 | weight_kg > 250
  replace weight_kg = .b if suspect_weight == 1
  label variable suspect_weight "Flag: suspect weight"

gen suspect_height = 0
replace suspect_height = 1 if height_cm < 120 | height_cm > 230
replace height_cm = .b if suspect_height == 1
label variable suspect_height "Flag: suspect height"

gen suspect_flag = 0
replace suspect_flag = 1 if suspect_weight == 1 | suspect_height == 1
label variable suspect_flag "Any suspect value"

tab suspect_weight
tab suspect_height
tab suspect_flag

* BMI
  gen bmi = weight_kg / ((height_cm/100)^2)
  label variable bmi "Body Mass Index"

gen bmi_cat = .
replace bmi_cat = 1 if bmi < 18.5
replace bmi_cat = 2 if bmi >= 18.5 & bmi < 25
replace bmi_cat = 3 if bmi >= 25 & bmi < 30
replace bmi_cat = 4 if bmi >= 30

capture label define bmilbl 1 "Underweight" 2 "Normal" 3 "Overweight" 4 "Obese"
label values bmi_cat bmilbl

tab bmi_cat

* CLEAN CATEGORICAL VARIABLES
  gen female = .
  replace female = 1 if gender == "Female"
  replace female = 0 if gender == "Male"

capture label define femlbl 0 "Male" 1 "Female"
label values female femlbl

gen comp = .
replace comp = 1 if component == "Regular Army"
replace comp = 2 if component == "Army Reserve"
replace comp = 3 if component == "Army Nationa"

capture label define complbl 1 "Regular Army" 2 "Army Reserve" 3 "National Guard"
label values comp complbl

* DESCRIPTIVES
  tab female
  tab comp
  summ age
  summ height_cm weight_kg
  summ stature waistcircumference chestcircumference

tabstat height_cm weight_kg stature waistcircumference ///
chestcircumference, by(female) stat(mean sd min max)

tabstat height_cm weight_kg stature waistcircumference ///
chestcircumference, by(comp) stat(mean sd min max)

* FIGURES
  histogram height_cm, normal
  histogram weight_kg, normal

graph box height_cm, over(female)
graph box weight_kg, over(comp)

* ANALYSIS
  pwcorr stature kneeheightmidpatella cervicaleheight ///
  trochanterionheight functionalleglength span, sig

ttest stature, by(gender)

oneway stature age, tabulate

* DUPLICATE CHECK
  capture drop dup_flag
  duplicates tag subjectnumericrace, gen(dup_flag)
  label variable dup_flag "Duplicate observation flag"

tab dup_flag

encode writingpreference, gen(write_pref)
label variable write_pref "Writing hand preference (encoded)"

tab write_pref

* Create month from date
gen month = month(date)

* Create season variable
gen season = .
replace season = 1 if inlist(month,12,1,2)
replace season = 2 if inlist(month,3,4,5)
replace season = 3 if inlist(month,6,7,8)
replace season = 4 if inlist(month,9,10,11)

label define seasonlbl 1 "Winter" 2 "Spring" 3 "Summer" 4 "Fall"
label values season seasonlbl
label variable season "Season of measurement"

tab season

* Body type based on waist-to-height ratio

gen whtr = waistcircumference / stature
label variable whtr "Waist-to-height ratio"

gen body_type = .

* Female cutoffs
replace body_type = 1 if whtr < 0.45 & female == 1
replace body_type = 2 if whtr >= 0.45 & whtr < 0.55 & female == 1
replace body_type = 3 if whtr >= 0.55 & female == 1

* Male cutoffs
replace body_type = 1 if whtr < 0.50 & female == 0
replace body_type = 2 if whtr >= 0.50 & whtr < 0.60 & female == 0
replace body_type = 3 if whtr >= 0.60 & female == 0

label define bodylbl 1 "Lean" 2 "Average" 3 "High Adiposity"
label values body_type bodylbl
label variable body_type "Body type classification"

tab body_type
* % of height from hip (trochanterionheight)

gen hip_height_pct = trochanterionheight / stature * 1002
label variable hip_height_pct "% of height to hip"

* Compare by gender
graph box hip_height_pct, over(female) ///
title("Percent Height to Hip by Gender")

* Correlations for males
pwcorr stature kneeheightmidpatella cervicaleheight ///
trochanterionheight functionalleglength span if female==0, sig

* Correlations for females
pwcorr stature kneeheightmidpatella cervicaleheight ///
trochanterionheight functionalleglength span if female==1, sig

twoway scatter cervicaleheight stature, ///
title("Relationship between Stature and Cervicale Height") ///
ytitle("Cervicale Height") xtitle("Stature")

* Weight difference (measured - reported)
gen weight_diff = weight_kg - (weightlbs * 0.453592)

* Height difference (measured - reported)
gen height_diff = height_cm - (heightin * 2.54)

gen weight_diff = weight_kg - (weightlbs * 0.453592)
gen height_diff = height_cm - (heightin * 2.54)
summ weight_diff height_diff

summ weightlbs weight_kg

drop weight_kg
gen weight_kg = weightkg / 10
label variable weight_kg "Weight in kilograms"
