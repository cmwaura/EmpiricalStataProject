
eststo clear
log using "C:\Users\crispus\Desktop\dataall\empirical project1.log"

use "C:\Users\crispus\Downloads\telephoneS15.dta"

// histogram of the age sets, education and income in the data
histogram age
histogram edu 
histogram income 

// summarizes the data for teens adults and seniors
sum teen adults sen
 
//robust regression of the variables inc teens adu sen
reg inc teen adu sen, r

// creation of line and scatter plots for the
// variables income age marriage and income
twoway(lfit inc age)
twoway(scatter mar age)
twoway(scatter inc married)

// pool the marriage data into two sets those who were
 //married and those who were technically single either 
  //by divorce or just never married.
  gen mar_1 = (mar == 1)
  
//summary details of married couples
  sum mar_1
  
//some regressions with the new created variable
  reg income mar_1 ben, r
  reg income mar_1 hhsize  if hhsize > 2
  
// testing for multicollinearity in my data
  vif
	
//sorting the data per the tariff  and summarizing it
  bysort tar: summ MAP MAS MAO MBP MBS MBO CAP CAS CAO CBP CBS CBO
  
//save the data as a text file to be used in latex
  bysort tariff: sutex MAP MAS MAO MBP MBS MBO CAP CAS CAO CBP CBS CBO, file(empirical.tex) replace
  
// more regressions.
  reg MAP mar_1 inc edu hhsize, robust
  reg MAP mar_1 i.inc i.edu hhsize teens, robust
  eststo regr1
  reg MAP mar_1 i.inc i.edu hhsize teens if hhsize > 2
  
//store my data as a file
  eststo regr2
  
//generate a variable mar_teens.
  gen mar1_teens = mar_1*teens
  
//regression using mar_teens
  reg MAP i.edu mar_1 i.inc teens i.mar1_teens, robust
  
//store the data
  eststo regr2
  
  reg MAP i.edu i.mar_1 i.inc teens mar1_teens i.month, robust
  eststo regr3
  reg MAO i.edu i.mar_1 i.inc teens mar1_teens i.month, robust
  eststo regr4
  esttab reg* using project2.tex, replace indicate(Month FE = *month) b(3) star se(3) r2 label keep(hhsize 1.mar_1 mar1_teens  teens)
  
  //generate bill
  gen bill = .
  replace bill = 14.02 + max(0, -5 + 0.02*CAP + 0.02*MAP + 0.65*0.02*CAS + 0.65*0.02*MAS + 0.40*0.02*CAO + 0.40*0.02*MAO + 0.02*CBP + 2*0
  .02*MBP + 0.65*0.02*CBS + 2*0.65*0.02*MBS + 0.40*0.02*CBO + 2*0.40*0.02*MBO) if tariff == 1
  replace bill = 18.70 if tariff == 0
  
  // regressing with new variable bill.
  reg bill mar_1 i.income, robust
  eststo regr5
  reg bill mar_1 mar1_teens income, robust
  eststo regr6
  reg bill mar_1 mar1_teens income teens, robust
  eststo reg7
  
  //export to an excel table
  esttab reg* using ex3.csv, replace b(3) star se(3) r2 label drop(1.age *income)
  
  //conduct a bitest for married couples
  ttest mar_1 = 0.5
  
  //tabulate the results.
  tabulate mar_1 mar1_teens, chi2
  
  //ttest for the bill in tariff 1
  ttest bill = 18.70
  // more testing for the bill using the categorical variable of mar_1 and
  //mar1_teens.
  anova bill mar_1 
  tabulate mar_1, summ(bill)
  anova bill mar1_teens
  tabulate mar1_teens, summarize(bill).
  
  
  

  
  
  
  log close
  
