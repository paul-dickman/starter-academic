+++
date = "2019-03-02"
lastmod = "2021-03-11"
title = "-strs- version history"
author = "Paul Dickman, Enzo Coviello"
summary = "History of -strs-, including links to previous versions."
tags = ["strs","software","Stata"]
math = true
[header]
image = ""
caption = ""
+++

**`strs` can be updated using the `adoupdate` command (from the Stata command line).**

20210311 [Version 1.4.3.1](../1431.zip)

- No changes to the code
- Added [the GNU General Public License](https://www.gnu.org/licenses/gpl.html)
- package moved to a new directory on my server (old version will need to be reinstalled rather than updating)

20200515 [Version 1.4.3.0](../1430.zip)

- added new option, cilog, to calculate confidence intervals for net survival on the cumulative excess hazard 
scale (i.e., -log(R(t)) where R(t) is net survival). Default is the log cumulative excess hazard scale (i.e., log(-log(R(t))).
- added new option, noconfirm, to bypass the code confirming the existence of the using file. This option is required if the using file has an extension other than .dta, in which case the extension of using file must be specified. 
- improved the code that confirms existance of the using file (popmort file)
- Fixed a bug in testing uniqueness of observations in popmort file that manifested when the filename contained periods

20200219 [Version 1.4.2.9](../1429.zip)

- indweight() now gives warnings if weights are zero, missing, or negative
- updated age-std.do to include an example with individual weights
- updated section in the help file with examples of age-standardisation

20200116 [Version 1.4.2.8](../1428.zip)

- Fixed a small bug

20191114 [Version 1.4.2.7](../1427.zip)

- Fixed a small bug (thanks Paul Lambert); added indweight to keep statement in lines 434 and 438 (it is conditionally referenced in line 449) 
- Expanded some abbreviated commands in strs.ado (e.g., "g" expanded to "generate", "ca" expanded to "capture")

20190305 [Version 1.4.2.6](../1426.zip)

- "using" file can now be read from the web.
- added "suggested citation" to the help file; other small changes to the help file.

20181024 [Version 1.4.2.5](../1425.zip)

- Fixed a couple of small bugs.

20180819 [Version 1.4.2.3](../1423.zip)

- The -brenner- option can now be used together with the -pohar- option. That is, Pohar Perme estimates of net survival can be standardised using the approach of Brenner et al. (2004).
- A new option, `indweight(varname)` allows the user to specify any chosen weights.
- Abbreviated variable names have been unnabreviated. That is, `strs` should now work for users who have "set varabbrev off".
- If times are left truncated (e.g., period analysis), Brenner-Hakulinen weights are computed based on the number of incident cases that contribute person-time within the time window and the number of incident cases in each -standstrata-.
- The standard error of Brenner-Hakulinen estimates has been slightly modified. For period analysis, the new formula is<br>  
<code>
gen var_Lambda=(end-start)^2*`d_sq'/y^2 
</code> <br>

where `d_sq` is the number of events multiplied by the Brenner-Hakulinen squared weights. The formula is similar for cohort analysis.

20170416 [Version 1.4.2.2](../1422.zip)   

- Corrected bug (line 691) that resulted in incorrect estimates of Pohar Perme (actuarial) estimator when all individuals in an interval died.

20161116 [Version 1.4.2.1](../1421.zip)   

- The variable end is now generated as a float (line 1240) to avoid potential problems if the user has "set type double".

20150507 [Version 1.4.2](../142.zip)

- Sample data sets have been modified. The cancer registry that provided us with these data asked us to remove references to the source and to randomly permute the dates of diagnosis. As such, some estimates may differ slightly compared to those shown in published papers.
- The temporary variable __000000 was saved to the individual data set, which could cause problems for future operations.
- More informative error messages when _age or _year were present in the patient data.
- Our two papers have been published in The Stata Journal; [strs](/pdf/Dickman2015.pdf) and [stnet](/pdf/Coviello2015.pdf).

20150218 Version 1.4.1

- Minor bug fixes.

20150209 Version 1.4.0

- Crude probabilities of death (`cuminc` option) are now estimated when late entry is detected (e.g., period analysis) or when the `ht` (hazard-transformation) option is used. We thank Ron Dewar (Cancer Care Nova Scotia) for bringing this issue to our attention and helping with the implementation and testing of the new code. See [strs_technical_140.pdf](/rsmodel/stata_colon/strs_technical_140.pdf) for technical details.

20131106 Version 1.3.9

- esteve.ado updated to correct a bug that gave incorrect results when interval widths were other than 1.
- Fixed bug that caused `strs` to give an error if the time origin was both non-zero and constant for all observations.
- Improved variance formula for Pohar Perme estimator.
- The `savstand()` option now works as it should when the brenner option is used (previously it did not have any effect).

20130329 Version 1.3.8

- Improved algorithm for the Pohar Perme estimator. Thanks to Karri Seppä and Arun Pokhrel. Instead of weighting by the cumulative expected survival at the end of the interval, weights are based on the cumulative expected survival at the midpoint of the interval.
- New option, -ht-, that causes `strs` to use the hazard transformation approach for cohort/complete analysis (rather than the default actuarial approach)
- Corrected a bug that lead to incorrect (too wide) confidence intervals for the Pohar Perme standardised estimates.
- Corrected a bug that caused `strs` to erroneously report late entry in some circumstances when an -if- expression was used.
- Corrected a bug that caused `strs` to report an incorrect number censored in the last interval when the -calyear- option is specified.
- Corrected a bug that caused `strs` to report incorrect confidence intervals for standardised estimates when relative/net survival is greater than 1. Confidence intervals now no longer calculated calculated when RSR > 1.
- CIs for standardised estimates now respect the -format- option (%6.4f by default).
- NOTES: `strs` implements two alternative approaches to estimating survival, the actuarial approach and the hazard transformation (ht) approach. In the actuarial approach all calculations are done on the survival scale whereas in the ht approach we first estimate the cumulative hazard and then transform to the the survival scale. In version 1.3.7, the ht approach was the default if late entry was detected (i.e., period analysis) whereas the actuarial approach was the default if there was no late entry (i.e., cohort estimation).
The choice of default approach remains unchanged in 1.3.8, although a new option, -ht-, has been added that forces `strs` to use the hazard transformation approach.
Ederer I estimates are not available using the ht approach. Requesting Ederer I estimates together with the ht option or in the presence of late entry will cause an error.
The variables w (number censored in the interval) and n_prime (effective number at risk) are not calculated when the ht approach is used so requesting these in the list option will cause an error.

20120304 Version 1.3.7

- Fixed a bug that caused an error when using the calyear option (the error caused the program to stop and no incorrect results were presented).

20120216 Version 1.3.6

- The Pohar Perme estimator of net survival (pohar option) can now be used in the presence of late entry (e.g., period analysis).
- The -calyear- option (introduced in version 1.3.5) for use with the pohar option can now also be used with Ederer II estimation. The code has also been optimised (no longer required to split the data twice) and should be faster.
- Better control of the output when standardised estimates are requested.
- Pohar Perme estimates are now saved in the -individual- file.

20110914 Version 1.3.5

- Updated code for the estimator of net survival proposed by Pohar Perme et al (the (pohar) option). The new code has been checked by comparing the results with the R function written by Maja Pohar Perme. When the (pohar) option is specified the new option (calyear) is available. This option splits at each calendar year, thereby enabling a slightly more precise computation of the weights used by this estimator. When the (calyear) option is used the results produced by `strs` match almost completely those obtained in R. However, this increases the memory needs and can reduce the speed of computation. Even without the (calyear) option the results agree to the 4th significant digit. The do file four_methods.do contains code for estimating relative/net survival using 4 methods (Ederer I, Ederer II, Hakulinen, and Pohar Perme) and presenting the estimates graphically.

20110614 Version 1.3.3

- EXPERIMENTAL: New option (pohar) for the estimator of net survival proposed by Pohar Perme et al (Biometrics 2011 in press). This has not been fully tested and should be considered experimental, although it gives comparable results when applied to the Slovenian data used in the R package by Maja Pohar Perme (we do not expect identical results since `strs` splits time). The do file four_methods.do contains code for estimating relative/net survival using 4 methods (Ederer I, Ederer II, Hakulinen, and Pohar Perme) and presenting the estimates graphically.
- Standard errors of cr_e2 (se_cr_e2) and cr_hak (se_cr_hak) are now calculated.
- Standard errors and confidence intervals for standardized survival estimates are calculated using the method described by Corazziari et al (2004). The same approach has been applied to the standardized cumulative incidence estimates.
- Confidence intervals for age standardized estimates are now computed even when the survival probability is zero (i.e., all cases die within the interval) for some intervals.
- Added an additional check on the standardized survival estimates when the period or hybrid approach is used. They are dropped from the first interval in which they are not computed.

20101105 Version 1.3.2

- Corrected a bug (introduced with Stata 11) that lead to incorrect confidence limits for survival estimates when P or CP were zero. Updated models.do to use Stata version 11 syntax for factor variables.

20100926 Version 1.3.1

- Corrected a bug whereby the check (using isid) added in 1.3.0 incorrectly returned an error when the filename (for the population mortality file) contained spaces.

20100617 Version 1.3.0

- Now requires Stata version 9. 
- Prior to version 1.3.0 `strs` reported incorrect standard errors (for both all-cause and relative survival) when period analysis was performed.
- This has now been corrected. See standard_errors.pdf for details.
- Added a check (using the isid command) that the mergeby variables uniquely index the observations in the population mortality file.

20091120 Version 1.2.9 (this is the latest version of `strs` that will run in Stata version 8)

- More informative error message when some records do not merge with popmort file.
- More informative message when late entry is detected. Set n_prime to missing when late entry is detected.

20080604 Version 1.2.8

- Major bug fix: Exit times (deaths or censorings) that occurred on the boundaries of life table intervals were previously classified (incorrectly) into the earlier interval rather than the latter interval. This is because stsplit uses intervals that are open on the left and closed on the right whereas life table intervals are closed on the left and open on the right.
- New feature: Cumulative incidence of death due to cancer and cumulative incidence of death due to other causes in the presence of competing risks can be calculated using the method of Cronin and Feuer (2000) via the new cuminc option.
- New option: keep() can be used to restrict the variables written to the 'individual' data file.
- New option: savstand species that standardised estimates be saved to an output data set.
- Fix: Command exits with an error if missing values found for any variable listed in the mergeby() option.
- Fix: The variables start or end (but not both) can be suppressed when using the list() option. If one of these two is specified then the other is suppressed. If neither is specified then both are listed (as in previous versions).

20070702 Version 1.2.5

- Corrected bug that gave incorrect estimates if brenner option was used together with if qualifier.
- Corrected bug in calculating cumulative survival when interval specific survival was zero (everyone dies during the interval). In previous versions the cumulative survival was multiplied by 1 when it should be multiplied by zero.

20061008 Version 1.2.4

- `strs` now exits with a warning if ederer1 and brenner options are used together.
- improved code for period analysis in survival_period.do. 

20060504 Version 1.2.3

20051128 Version 1.2.0

- New algorithm for hakulinen estimates of period survival.
- Incorporation of weights to provide standardised survival estimates, including the 'alternative approach' developed by Brenner et al. (not yet fully tested). See the standstrata and brenner options. 
- Data no longer saved to grouped.dta and individ.dta by default - use the new save(replace) option (or saveind and savgroup to specify the filenames).
- New option notables to supress listing of the life tables.
- Improved error reporting.

20041124 Version 1.1.0

- A major upgrade thanks to help from Enzo Coviello. Added Ederer I and Hakulinen estimates (period analysis can only be performed with Ederer II). Many 'options' are now truly optional. Improved error checking. Added a list option for specifying variables to be printed and a format option. The command now runs without a by option (producing a single life table for all patients).

20041008 Version 1.0.1

- Corrected an error in the formula for the standard error of the interval-specific relative survival. The line
`quietly gen se_r=se_p/r`
was changed to
`quietly gen se_r=se_p/p_star`

20040809 Version 1.0




