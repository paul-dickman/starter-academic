+++
title = "Modelling excess mortality using matched cohort data"
date = 2020-11-26
math = true
draft = true

# Tags and categories
# For example, use `tags = []` for no tags, or the form `tags = ["A Tag", "Another Tag"]` for one or more tags.
tags = ["Blog"]
categories = ["Blog"]

# Featured image
# To use, add an image named `featured.jpg/png` to your page's folder. 
[image]
  # Caption (optional)
  caption = ""

  # Focal point (optional)
  # Options: Smart, Center, TopLeft, Top, TopRight, Left, Right, BottomLeft, Bottom, BottomRight
  focal_point = ""
+++

In a standard excess mortality model (also known as relative survivival model) the all-cause hazard, $h(t)$, at time since diagnosis $t$ for persons diagnosed with cancer is modelled as the sum of the known baseline hazard, $h^\ast(t)$, and the excess hazard due to a diagnosis of cancer.
$$
h(t) = h^\ast(t) + \lambda(t)
$$

When estimated as a Poisson regression model, follow-up time is partitioned into bands corresponding to life table intervals and indicator variables included in the design matrix. The model is written as
$$
h({\bf x}) = h^\ast({\bf x}) + \exp({\bf x \beta}) \label{eq:rrmodel}
$$
or
$$
\ln\left[h({\bf x}) - h^\ast({\bf x})\right] = {\bf x \beta}. \label{eq:rrmodel:ln}
$$

[Caroline's Stata Med paper has a better mathematical description. Update to use that.]

The excess hazard is additive to the expected hazard, but we assume the excess component is a multiplicative function of covariates (i.e., proportional excess hazards). Non-proportional excess hazards are common but can be incorporated by introducing follow-up time by covariate interaction terms. 

The baseline hazard, $h^\ast({\bf x})$, is obtained from external data (the population mortality file) and is assumed to be fixed and known. Fitting the model requires two data files:

1. individual-level data on the patients with the disease (e.g., data on the cancer patients);
2. a "popmort" file containing tabulated mortality rates from the general population that are used to estimate $h^\ast({\bf x})$.

Instead, we might fit the model to a single data set containing individual level data on the cancer patients along with individual-level data on matched comparators randomly selected from the general population; a so-called matched cohort studies. We fit the same conceptual model, but $h^\ast({\bf x})$ is now estimated (with error) from individual-level data.

For simplicity, assume we are fitting a model with one binary covariate, sex, and we will fit a Poisson regression model.

$X_1$ takes the value 1 for the cancer patients and 0 for the population comparators.

$X_2$ takes the value 1 for males and 0 for females.

The model we wish to estimate is
   
$$
d/y = \left(\beta_0 + \beta_1 X_1\right)^{\beta_2 X_2}
$$

$$
\ln(d) = \ln(y) + {\beta_2 X_2} \ln \left(\beta_0 + \beta_1 X_1\right)
$$

where $d$ is the number of events and $y$ the person time.

We assume constant hazards for simplicity, but we can timesplit and replace $\beta_0$ with a step function.

I have two questions:

1. Have I specified the model correctly?
2. How do we fit this model?

