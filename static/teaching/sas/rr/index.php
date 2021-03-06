<?PHP
$strPageStyle = 'main';
$strTitle = 'Estimating ratios of proportions (risk ratios)';
require ('../../../config.php');
require ('../../../header.php');
require ('../../../sidebar_main.html');
?>
<!-- main content start -->

</a>

<p><a href="renal2.sas">SAS code</a></p>
<p><a href="renal2.pdf">Output from SAS code</a></p>

<!-- main content end -->
<p>Logistic regression is the most commonly applied statistical model in epidemiological studies with binary outcomes. For case-control studies this is the appropriate statistical model. For cross-sectional and prospective studies, however, there are other alternatives. Logistic regression yields an odds ratio as the estimated measure of association although odds ratios are often misinterpreted as risk ratios (ratios of proportions) when there is no justification to do so [Schwartz et al.(1999), Zou (2004)]. Wacholder (1986) showed how to estimate risk ratios in the framework of generalised linear models and Zou (2004) suggested using Poisson regression with a robust variance estimator. Barros and Hirakata (2003) compare these and other methods.</p>
<p>My aim is not to discuss the relative merits of odds ratios versus risk ratios (there is still fierce debate in the literature and neither is uniformly best) or the relative merits of the various approaches to estimating risk ratios. This page simply contains sample SAS code illustrating how to implement the methods proposed by Wacholder (1986)  and Zou (2004). In particular, the code illustrates how problems with non-convergence when applying the Wacholder approach can (at least sometimes) be circumvented by specifying suitable initial values.</p>
<p><strong>References</strong></p>
<p> Barros AJ, Hirakata VN. Alternatives for logistic regression in cross-sectional studies: an empirical comparison of models that directly estimate the prevalence ratio. <em>BMC Med Res Methodol.</em> 2003;3:21. [<a href="http://www.pubmedcentral.nih.gov/articlerender.fcgi?tool=pubmed&pubmedid=14567763">Free Full text</a>] </p>
<p>Schwartz LM, Woloshin S, Welch HG. Misunderstandings about the effects of race and sex on physicians&rsquo; referrals for cardiac catheterization. <em>N Engl J Med</em> 1999;341:279&ndash;83.
<!-- HIGHWIRE ID="159:7:702:3" -->
<a href="http://aje.oxfordjournals.org/cgi/ijlink?linkType=FULL&amp;journalCode=nejm&amp;resid=341/4/279"><nobr>[Free Full&nbsp;Text]</nobr></a></p>
<p> Wacholder S. 
  Abstract Binomial regression in GLIM: estimating risk ratios and risk differences. <em>Am J Epidemiol.</em> 1986;123(1):174-84. [<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=pubmed&cmd=Retrieve&dopt=AbstractPlus&list_uids=3509965&query_hl=5&itool=pubmed_docsum">PubMed</a>] </p>
<p> Zou G.  A modified poisson regression approach to prospective studies with binary data. <em>Am J Epidemiol.</em> 2004 Apr 1;159(7):702-6.  [<a href="http://aje.oxfordjournals.org/cgi/content/full/159/7/702">Free Full text</a>]</p>
<?PHP
require ('../../../footer.php');
?>
