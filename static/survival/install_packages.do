/************************************************************************
install_packages.do

Download and install course files (e.g., data files and solution do files)
and user-written Stata commands for cancer survival course.

Paul Dickman
*************************************************************************/
set more off

*** Create course directory ****
* If c:\survival exists you can choose to install into another directory 
* or comment out the mkdir command if you want to install the course files there
mkdir c:\survival, public
cd c:\survival

* download course files (e.g., data files and solution do files)
net install http://www.pauldickman.com/survival/course_files, all replace

ssc install stpm2, replace
ssc install rcsgen, replace
ssc install stcompet, replace
ssc install stcompadj, replace
ssc install stpm2cm, replace
ssc install stpm2cif, replace
ssc install partpred, replace
ssc install survsim, replace
ssc install stgenreg, replace
ssc install stmixed, replace
ssc install strcs, replace
ssc install stpepemori, replace
net install st0211, from(http://www.stata-journal.com/software/sj10-4) replace

* strs - estimate and model relative survival
net install http://www.pauldickman.com/rsmodel/stata_colon/strs, replace

* strsmix and strsnmix: relative survival cure models
net install st0131, from(http://www.stata-journal.com/software/sj7-3)

* grc1leg - combine graphs into one graph with a common legend
net install grc1leg, from(http://www.stata.com/users/vwiggins)

* yet more matrix commands
net install dm79, from(http://www.stata.com/stb/stb56)
