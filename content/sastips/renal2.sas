*--------------------------------------------------------------------*;
* Program: /jml/biostatmethods/chapter7/renal.sas                    *;
* Source:  Biostatistical Methods: The assessment of Relative Risks  *;
*          John Wiley and Sons, 2000                                 *;
* Author:  John M. Lachin <jml@biostat.bsc.gwu.edu>                  *;
*          Copyright (c) 2000 by John M. Lachin                      *;
* Purpose: The SAS program and data set presented in Table 7.5       *;
*          for the analysis of a subset of the DCCT nephropathy      *;
*          data used in Example 7.4. This is used to generate the    *;
*          output presented in Table 7.6. This also includes the     *;
*          call of PROC GENMOD presented in Example 7.7 and the      *;
*          output presented in Table 7.7. Further it includes the    *;
*          computaion of the sums of squares (through Proc           *;
*          Univariate) described in Example 7.14.                    *;
*                                                                    *;
*          Modified by Paul Dickman to illustrate various methods    *;
*          for estimating ratios of proportions (rather than odds    *; 
*          ratios)                                                   *;
*                                                                    *;
* Web URL: http://www.bsc.gwu.edu/jml/biostatmethods                 *;
*--------------------------------------------------------------------*;
 
options pageno=1;
 
data renal;
input obsn micro24 int hbael duration sbp female;
yearsdm=duration/12; 
label
obsn='observation number'
micro24='prevalence of microalbuminuria at 6 years fu'
int='intensive treatment (vs conventional)'
hbael='level (%) of HbA1c at baseline'
duration='prior duration of diabetes'
sbp='systolic blood pressure (mm Hg)'
female='female (vs male) gender'
;
cards;
  1 0 1  9.63 178 104 1
  2 0 0  7.93 175 112 0
  3 1 0 11.20 126 110 1
  4 1 0 10.88 116 106 0
  5 0 0  8.22 168 110 1
  6 1 1 12.73  71 112 0
  7 0 0  8.28 107 116 1
  8 0 1  9.44  79 120 1
  9 0 0  7.44 176 120 1
 10 0 0  8.33  47 140 0
 11 1 1  9.89 135 126 1
 12 0 1 12.06 117 120 0
 13 0 1  9.01  35 128 1
 14 0 1 10.05  82 110 1
 15 1 1  9.60  70 108 1
 16 0 1 10.17 159 121 1
 17 0 1 10.67  43 110 0
 18 0 1  8.52 142 118 0
 19 1 0  8.13  99 124 1
 20 0 0  8.27 105  98 1
 21 1 0  8.60 126 126 0
 22 1 0  9.83 139 116 0
 23 0 0  8.04  97 118 0
 24 0 1  9.38 113 100 0
 25 1 0 10.72 115 110 0
 26 0 1  7.85  48 114 0
 27 0 1  9.72 151 118 0
 28 0 0  7.80  19 110 0
 29 0 0  8.96  84 108 1
 30 0 1  8.96  80 124 0
 31 0 1  7.09 109 130 1
 32 0 1  8.20  90 130 0
 33 0 1  8.81  92 104 1
 34 0 1  8.28 112 120 1
 35 0 1 11.95  38 104 1
 36 0 0 14.37 147 122 1
 37 1 0  7.72 119 128 0
 38 0 1  9.99 119 120 1
 39 1 1  9.67 180 116 0
 40 0 1  7.26  16 110 0
 41 0 1  7.80 154 130 0
 42 0 0 10.23 124 108 1
 43 1 0 11.77  57 120 1
 44 0 0  9.56  44 126 0
 45 1 0 12.38  96 110 1
 46 0 0 10.94  99 100 1
 47 0 1  9.56 143 130 0
 48 0 1  8.27 116 115 0
 49 0 0  9.70  56 108 0
 50 0 0  7.36 168  96 1
 51 0 0  8.03 162 118 0
 52 0 0  8.82 114 124 1
 53 0 0  7.28 157 104 0
 54 1 1 10.70 135  92 0
 55 0 1  9.40  77 124 1
 56 0 1 11.03 165 120 0
 57 0 1  8.62 142  98 1
 58 0 1  7.01  71 120 0
 59 1 0 12.22  67 102 1
 60 0 1  8.22 147 120 0
 61 1 0 10.55 101 116 0
 62 0 1  9.66  78  90 1
 63 0 0 10.13  77 110 1
 64 1 0  9.44  84 118 0
 65 0 0  9.61 167 126 1
 66 0 1  8.78 137 110 0
 67 0 0  7.34 173 144 0
 68 0 0  9.10 177 100 1
 69 0 1  7.44 113 136 1
 70 0 1  9.35  59 118 0
 71 1 1  7.36 138 148 0
 72 0 0  8.09 146 114 1
 73 0 1  9.60 147 122 1
 74 1 0  9.63 131 118 0
 75 1 0  8.19 107 120 0
 76 0 0  6.72 116 112 0
 77 0 1  9.77  67 124 1
 78 0 1  7.86  99 130 0
 79 1 0 10.02 157 124 0
 80 0 0  9.98 105 106 0
 81 0 1  7.89 172 110 1
 82 0 0  7.50 133 118 0
 83 0 0  7.74 135  90 1
 84 0 0  8.54 146 104 1
 85 0 1 11.07  82 122 1
 86 1 1 10.23  84 104 1
 87 1 0  8.11  55 128 0
 88 0 1 10.84  84 138 0
 89 1 0  9.32 170 110 1
 90 0 1 10.75 102 118 1
 91 0 0  8.22  97 116 0
 92 0 1  9.70 131 110 1
 93 0 1  9.11 145 126 0
 94 0 1  9.29 129 114 0
 95 0 1  8.33 122 118 1
 96 1 1 11.09  27 104 0
 97 0 1  8.98 112 112 1
 98 1 0 10.56  97 120 0
 99 0 1  8.16 166 118 1
100 0 1  8.08 172  92 1
101 1 0 10.44  72 128 1
102 0 1  8.07 109 118 1
103 1 1  7.50 147 114 0
104 1 1  8.49 168 122 1
105 0 0 10.52  35 120 0
106 0 1  9.49 154 110 0
107 0 1 12.40 119 112 1
108 0 1  8.49 173  98 1
109 0 1  9.79  35  94 1
110 0 0  7.44 104 114 0
111 0 1  8.22 133 112 0
112 0 0  7.18  17 108 0
113 0 1  9.29 132 118 0
114 0 0  9.26 151 118 1
115 0 0 10.16  96 122 0
116 0 1  7.09 153 118 0
117 0 1  8.10 163 116 1
118 1 0 10.54  46 130 0
119 0 0  9.23  70 112 1
120 0 0 10.07 112 110 1
121 1 0  8.87 138 132 0
122 0 1  7.95  55 122 0
123 0 0  6.66 141 112 0
124 1 0  8.77 168 112 0
125 0 0  9.07 111 124 1
126 0 1  8.98 116 100 0
127 0 1  8.89  33 118 0
128 0 1 10.94  88 110 0
129 0 1  8.50 118 125 0
130 1 0 12.34 122 110 1
131 0 1 12.45 117  98 1
132 1 0  8.82 130 140 0
133 0 1 10.78 120 110 0
134 0 1  8.25 143 102 0
135 0 0  9.48 135 120 0
136 0 0  8.74 155 136 0
137 0 1  7.43 145 112 0
138 0 1  7.94 112 140 0
139 0 0 11.31 101 120 1
140 1 0 10.12 110 120 0
141 0 1  7.36 165 130 0
142 0 1  9.17 154 118 1
143 0 1  8.59 163 132 0
144 1 0  8.07  93 126 0
145 0 1 10.28 104 118 0
146 0 0  8.00  84 110 1
147 0 1  8.10  63 108 0
148 0 0 10.60 163 132 0
149 0 0  7.60  76 124 0
150 0 1  9.50 152 126 1
151 0 0 10.30 125 102 0
152 0 1  8.80 127 120 1
153 1 0  9.30 136 114 1
154 0 1 10.00 175 128 0
155 0 0  9.10 140 118 1
156 1 1 12.50  91 120 0
157 0 0  9.70 132 106 1
158 1 0 11.80 157 128 0
159 0 1  7.00  64 126 0
160 0 1  9.00 141 114 0
161 0 1  8.00  46 131 0
162 1 0 12.50  99 116 1
163 1 0  7.10  89 114 0
164 0 0  8.60 139 130 1
165 0 1 12.20  76 106 1
166 0 1 11.70 118 110 1
167 1 0 11.30  99 122 1
168 0 0  6.80  41 104 1
169 0 0 10.60  82 106 1
170 0 1  8.70 101  98 1
171 0 0  7.90 136 126 0
172 0 0 10.10 127 124 0
;
 
proc genmod data = renal descending;
model micro24 = int hbael yearsdm sbp female
  / dist=binomial link=logit;
title 'DCCT - logistic regression';
run;

ods output parameterestimates=parmest obstats=obstats;
proc genmod data = renal descending;
model micro24 = int hbael yearsdm sbp female
  / dist=binomial link=log;
title 'DCCT - log link';
run;
ods output close;

ods output parameterestimates=parmest obstats=obstats;
proc genmod data = renal descending;
model micro24 = int hbael yearsdm sbp female
  / dist=binomial link=log intercept=-1 initial=0 0 0 0 0;
title 'DCCT - log link specifying initial values';
run;
ods output close;

proc genmod data = renal descending;
class obsn;
model micro24 = int hbael yearsdm sbp female
  / dist=poisson link=log;
title 'DCCT - Poisson regression with robust standard errors';
repeated subject=obsn / type=ind;
run;
