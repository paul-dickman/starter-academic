+++
title = 'stnet: estimating net survival using a life-table approach'
subtitle = "Enzo Coviello, Paul Dickman, Karri Seppä, Arun Pokhrel"
summary = "Description of -stns-, a Stata command that implements the Pohar Perme estimator for discrete survival time data (e.g., life tables)."
date = '2019-03-01'
tags = ["software", "Stata", "stnet"]
+++

`stnet` is a Stata command that implements the [Pohar Perme estimator](https://doi.org/10.1111/j.1541-0420.2011.01640.x) of net survival using a life table approach. This work is a collaboration between Enzo Coviello, myself, Karri Seppä, and Arun Pokhrel. Enzo Coviello did essentially all of the Stata coding and played a major role in adapting the Pohar Perme estimator to discrete time. 

The Pohar Perme estimator estimator was developed for continuous survival times, yet cancer registries often have only discrete survival times (for example, survival time in completed months). We proposed an approach to estimation that is also appropriate when survival times are discrete (ties are common). When ties are rare (e.g., when survival times are measured in days), there is little practical difference between our modified estimator and the continuous time estimator. Our estimator, however, makes more reasonable assumptions in the presence of ties and is more appropriate when exact times are not available. See Table 1 in our [Stata Journal](/pdf/Coviello2015.pdf) article for a comparison of the estimators and [Seppä et al](https://doi.org/10.1016/j.ejca.2013.09.019) for another comparison and additional discussion.    

Details of the modified estimator and its implementation in Stata can be found in our [Stata Journal](/pdf/Coviello2015.pdf) article. The estimator is also implemented in [strs]({{< ref "/software/strs/" >}}), but `stnet` is faster. 

`stnet` can be installed from the Boston College Statistical Software Components (SSC) archive using the following command (from the Stata command line)

<code> 
ssc install stnet
</code>

## Suggested citation

If you use this package, please cite the associated paper in The [Stata Journal](/pdf/Coviello2015.pdf).

> Enzo Coviello, Karri Seppä, Paul W. Dickman, Arun Pokhrel, 2015. Estimating net survival using a life-table approach, The Stata Journal, StataCorp LP, vol. 15(1), pages 173-185.

## Examples
- [Comparison of Ederer II and Pohar Perme with stnet and strs](/software/stnet/comparestrs/)
- [Comparison of strs, stnet, and stns](/software/stnet/compare_stns/)

## Extended index (with summary of each page)




