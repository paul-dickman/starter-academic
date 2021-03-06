+++
title = "Symposium for statisticians working in register-based cancer epidemiology, Stockholm, 25-26 September 2019"  
date = 2019-09-23
widgets = false  
summary = "Symposium for statisticians working in register-based cancer epidemiology"  
+++

{{% toc %}}
	
## Date and location

Start: 25 September 2019, 11:00 (lunch), 12:00 Scientific program

End:   26 September 2019, 15:00

Location: [Department of Medical Epidemiology and Biostatistics (MEB)](https://ki.se/en/meb/contact-us), Karolinska Insitutet, Stockholm, Sweden.

## About

The aim of the symposium is for statisticians working with population-based cancer epidemiology (i.e., using cancer registry data) to present and discuss their ongoing research and topics of mutual interest. The meeting is by invitation only and continues a tradition of similar symposia, the most recent held in Oslo in September 2018. We prioritise presentations of work in progress and discussion of current topics of mutual interest, although presentation of completed projects is also possible. Our ambition is an interactive symposium with lots of time allocated to discussion. The symposium is invitation only in order to limit the number of participants so as to facilitate discussion.

## Finance
As with previous meetings, each participant funds their own travel and accommodation. The organisers will provide the venue, lunch, dinner, and refreshments. There is no registration fee.

## Accommodation
We recommend the [Elite Hotel Carolina Tower](https://www.elite.se/en/hotels/stockholm/hotel-carolina-tower/). The hotel is located 100 meters from the main entrance to Karolinska Institutet and the airport bus stops outside (stop "Karolinska Sjukhuset Eugeniavägen" on the route to Liljeholmen). See your invitation e-mail (or contact the organisers) for details of the corporate rate and how to book. 

## Organising committee
[Paul Dickman](mailto:paul.dickman@ki.se), [Caroline Weibull](mailto:caroline.weibull@ki.se), [Hannah Bower](mailto:hannah.bower@ki.se).

## Timetable

Venue: [Department of Medical Epidemiology and Biostatistics (MEB)](https://ki.se/en/meb/contact-us), Karolinska Institutet. All sessions (including lunch on the first day) will be held in lecture room Wargentin on the fourth floor.

#### Wednesday, 25 September 2019 

| Time | Description                  |
| -----| ---------------------------- |
|11:00 | Lunch (sandwiches at MEB)    |
|12:00 | Scientific program           |
|14:00 | Coffee                       |
|14:30 | Scientific program           |
|15:45 | Coffee                       |
|16:15 | Scientific program           |
|17:30 | Close                        |
|18:30 | Dinner (La Bergerie)         |

#### Thursday, 26 September 2019

| Time | Description            |
| -----| ---------------------- |
|08:30 | Scientific program     |
|09:45 | Coffee                 |
|10:15 | Scientific program     |
|11:30 | Lunch (Svarta Räfven)  |
|12:30 | Scientific program     |
|13:30 | Coffee                 |
|14:00 | Scientific program     |
|15:00 | Close                  |
|16:30 | PubMEB                 |

#### Dinner, Wednesday 25 September 2019

All meals (including dinner) will be funded by Karolinska Institutet. Dinner will be at [La Bergerie](http://labergerie.se). We have ordered the ["Rotisserie menu 550kr"](http://labergerie.se/wp-content/uploads/2019/04/middagrmeny-labergerie.pdf) and have informed the restaurant of food preferences (e.g., vegetarian) and allergies. The restaurant is a 10 minute taxi or a 40 minute walk from the hotel. It's a pleasant walk along Karlbergs canal; we plan to walk together from the hotel with those who choose to walk (leaving at 17:50). 
                                
## Scientific program

We have a total of 9 hours allocated for the scientific program (4.5 hours each day). We will allocate 30 minutes to each of the 13 presentations (including questions) which will leave plenty of time remaining for additional topics or additional discussion if required. The presentations will be made in the following order, but there is no strict timetable. If there is interest in extended discussion surrounding one of the presentations then we will allocate time to such discussion. We are planning for an extended discussion of Bjørn Møller's presentation on choice of estimator of net survival. We will conclude with a general discussion.

_Wednesday_ <br>
1. Mark Rutherford, Life expectancy with high levels of missing data<br>
2. Janne Pitkäniemi, Estimating the proportion of chronic cancers<br>
3. Nurgul Batyrbekova, Multiple time scales in flexible parametric models<br>
4. Nikolaos Skourlis, Using different timescales for different events in a competing risks framework using flexible parametric models [[slides](Skourlis_Nikolaos.pdf)]<br>
5. Mark Rutherford, Estimating age-standardized net survival, even when age-specific data are sparse (10 minutes)<br>
6. Bjørn Møller, Which estimator of net survival should we use for routine cancer registry reports? (with extended discussion)<br>


_Thursday_ <br>
7. Mike Sweeting, Impact of cardiovascular comorbidity on cancer outcomes<br>
8. Sarah Booth, Producing up-to-date survival predictions from prognostic models using temporal recalibration  [[slides](SarahBooth.pdf)]<br>
9. Mark Clements, Extensions of multi-state models to calculate prevalence, quality-adjusted life-years, and costs<br>
10. Wendy Wu, Multi-state model for the estimation of overdiagnosis in the breast cancer screening program [[slides](Wu_KI_20190926.pdf)]<br>
11. Paul Lambert, New ideas for regression standardisation<br>
12. Betty Syriopoulou, Relative survival and mediation analysis [[slides](BettySyriopoulou.pdf)]<br>
13. Paul Lambert, Standardised crude probabilities of death<br>
	
## Choice of net survival estimator for routine reports

Some thoughts from Paul Dickman. I would like to have an extended discussion on Bjørn's talk and hear thoughts from the various organisations who produce reports on patient survival. There are three estimators that are potential candidates for use:

1. Pohar Perme
2. Age-standardised Ederer II
3. Model-based

In estimating 1-year or 5-year net survival where there is a reasonable amount of data there is little practical difference between these estimators. The Pohar Perme estimator is consistent, but bias in the other two is negligible (assuming a reasonable model) and there will be very little difference in the standard errors. When there is a reasonable amount of data, I would suggest using the Pohar Perme estimator, since it is unbiased, does not rely on fitting a reasonable model, does not require combining estimates, and the variance is similar to the other approaches.

The interesting question is what to do when there is not "sufficient data/information", and where is the limit for "sufficient data/information". The approach differs depending on whether interest is in:

1. An age-standardised estimate; or
2. An age-specific estimate.

For age-standardisation with sparse data, use of individual weights (Brenner alternative approach) is recommended (Mark Rutherford spoke about this as ISCB). I'll focus on age-specific estimates since they are typically based on less information. It would seem there is cutoff in the amount of information under which no estimate at all should be provided. Where is that cutoff? I can see three potential categories:

1. Sufficient information (use Pohar Perme estimator)
2. Low information (use, for example, modelling to provide stable estimates)
3. Insufficient information (no estimate can be presented)    

Does the middle category, where we use an approach other than Pohar Perme, exist or are there just two categories (Pohar Perme or nothing)? If we are prepared to use modelling for the middle category, should we also use modelling for category 1?

We should also consider the reason for having limited/insufficient information. I don't believe long-term net survival should be estimated for elderly patients. I agree with Maja Pohar Perme and colleagues that the relatively high variance in their estimator in some situations is a reflection of the low amount of information in the data. When the amount of information is low, as it can be in small jurisdictions, is it preferable to use modelling to obtain more stable estimates? Are there circumstances where we are willing to make some assumptions (e.g., model) in order to reduce variance? 
	
## List of attendees
Paul Dickman (Karolinska Institutet)<br>
Caroline Weibull (Karolinska Institutet)<br>
Hannah Bower (Karolinska Institutet)<br>
Nurgul Batyrbekova (Karolinska Institutet)<br>
Mark Clements (Karolinska Institutet)<br>
Frida Lundberg (Karolinska Institutet)<br>
Anna Johansson (Karolinska Institutet)<br>
Nikolaos Skourlis (Karolinska Institutet)<br>
Therese Andersson (Karolinska Institutet)<br>
Alessandro Gasparini (Karolinska Institutet)<br>
Benjamin Christoffersen (Karolinska Institutet)<br>
Keith Humphreys (Karolinska Institutet) [only Thursday 26th]<br>
Erin Gabriel (Karolinska Institutet) [only Thursday 26th]<br>
Arvid Sjölander (Karolinska Institutet) [only Thursday 26th]<br>
Enoch Chen (Karolinska Institutet)<br>
Yuliya Leontyeva (Karolinska Institutet)<br>
Anna Olofsson (Regional Cancer Center, Stockholm Gotland)<br>
Wendy Yi-Ying Wu (Umeå University)<br>
Bjørn Møller (Cancer Registry of Norway)<br>
Bjarte Aagnes (Cancer Registry of Norway)<br>
Yngvar Nilssen (Cancer Registry of Norway)<br>
Bettina Kulle Andreassen (Cancer Registry of Norway)<br>
Janne Pitkäniemi (Finnish Cancer Registry)<br>
Gerda Engholm (Danish Cancer Society)<br>
Jane Christensen (Danish Cancer Society)<br>
Marianne Steding-Jessen (Danish Clinical Quality Program and Clinical Registries, RKKP)<br>
Paul Lambert (University of Leicester and Karolinska Institutet)<br>
Michael Crowther (University of Leicester)<br>
Mike Sweeting (University of Leicester)<br>
Mark Rutherford (University of Leicester)<br>
Betty Syriopoulou (University of Leicester)<br>
Sarah Booth (University of Leicester)<br>
Robert Szulkin (Scandinavian Development Services, Sweden)<br>

## Acknowledgements

We thank the cancer registries that provide the data that make our research possible, and all the professionals who contribute to making high quality data available.

We thank the Swedish Cancer Society (Cancerfonden) for financial support.

