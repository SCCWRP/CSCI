## CSCI

#### *Raphael Mazor, raphaelm@sccwrp.org, Marcus W. Beck, marcusb@sccwrp.org, Mark W. Engeln*

[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/SCCWRP/CSCI?branch=master&svg=true)](https://ci.appveyor.com/project/SCCWRP/CSCI)
[![Travis-CI Build Status](https://travis-ci.org/SCCWRP/CSCI.svg?branch=master)](https://travis-ci.org/SCCWRP/CSCI)

R package materials to calculate the California Stream Condition Index (CSCI) based on O/E and pMMI scores using benthic macroinvertebrates.

### Installation

Install the package as follows:


```r
install.packages('devtools')
library(devtools)
install_github('SCCWRP/CSCI')
library(CSCI)
```

### Citation

Please cite the package as follows:

Mazor, MD, Rehn, AC, Ode, PR, Engeln, M, Schiff, KC, Stein, ED, Gillett, DJ, Herbst, DB, Hawkins, CP. 2016. Bioassessment in complex environments: Designing an index for consistent meaning in different settings. Freshwater Science 35(1): 249-271.

### Usage

The core function is `CSCI` which requires taxonomic and site level data.


```r
#A list of two data frames: bugs and stations
data(bugs_stations) 

# run the estimator
results <- CSCI(bugs = bugs_stations[[1]], stations = bugs_stations[[2]])

# see all the components of the report
ls(results)
```

```
## [1] "core"        "Suppl1_grps" "Suppl1_mmi"  "Suppl1_OE"   "Suppl2_mmi" 
## [6] "Suppl2_OE"
```

```r
# preview report components
lapply(results, head)
```

```
## $core
##   StationCode   SampleID Count Number_of_MMI_Iterations
## 1       Site3 BadSample1   100                        1
## 2       Site3 BadSample2   600                       20
## 3       Site1    Sample1   556                       20
## 4       Site2    Sample2   826                       20
## 5       Site3    Sample3   607                       20
## 6       Site3    Sample4   513                       20
##   Number_of_OE_Iterations Pcnt_Ambiguous_Individuals Pcnt_Ambiguous_Taxa
## 1                       1                  0.0000000            0.000000
## 2                       1                 83.3333333           50.000000
## 3                      20                  0.5395683            2.631579
## 4                      20                  0.9685230            1.666667
## 5                      20                  9.7199341            6.250000
## 6                       1                 37.6218324           41.025641
##           E Mean_O     OoverE OoverE_Percentile       MMI MMI_Percentile
## 1 10.248486   1.00 0.09757538              0.00 0.1638082           0.00
## 2 10.248486   1.00 0.09757538              0.00 0.3488195           0.00
## 3  7.544418   8.70 1.15317043              0.79 0.8337828           0.18
## 4 12.953853  11.25 0.86846749              0.24 0.8760187           0.24
## 5 10.248486  13.55 1.32214646              0.95 1.1967358           0.86
## 6 10.248486   9.00 0.87817846              0.26 0.9063380           0.30
##        CSCI CSCI_Percentile
## 1 0.1306918            0.00
## 2 0.2231975            0.00
## 3 0.9934766            0.48
## 4 0.8722431            0.21
## 5 1.2594411            0.95
## 6 0.8922582            0.25
## 
## $Suppl1_mmi
##   StationCode   SampleID MMI_Score Clinger_PercentTaxa
## 1       Site3 BadSample1 0.1638082           0.0000000
## 2       Site3 BadSample2 0.3488195           0.0000000
## 3       Site1    Sample1 0.8337828           0.2750616
## 4       Site2    Sample2 0.8760187           0.4796700
## 5       Site3    Sample3 1.1967358           0.6680028
## 6       Site3    Sample4 0.9063380           0.6361472
##   Clinger_PercentTaxa_predicted Clinger_PercentTaxa_score
## 1                     0.6422118                 0.0000000
## 2                     0.6422118                 0.0000000
## 3                     0.3929307                 0.5251934
## 4                     0.6216008                 0.4863436
## 5                     0.6422118                 0.7571456
## 6                     0.6422118                 0.7057118
##   Coleoptera_PercentTaxa Coleoptera_PercentTaxa_predicted
## 1             0.00000000                       0.07977832
## 2             0.00000000                       0.07977832
## 3             0.11495798                       0.08284403
## 4             0.07748185                       0.05155909
## 5             0.12951590                       0.07977832
## 6             0.07464387                       0.07977832
##   Coleoptera_PercentTaxa_score Taxonomic_Richness
## 1                    0.2321037                1.0
## 2                    0.2321037                2.0
## 3                    0.7495197               34.8
## 4                    0.7208901               33.6
## 5                    0.8310154               41.6
## 6                    0.5772744               26.8
##   Taxonomic_Richness_predicted Taxonomic_Richness_score EPT_PercentTaxa
## 1                     32.27143                0.0000000       0.0000000
## 2                     32.27143                0.0000000       0.5000000
## 3                     26.13860                0.9045558       0.2571849
## 4                     32.79767                0.6926281       0.4743398
## 5                     32.27143                0.9225466       0.5135198
## 6                     32.27143                0.5234496       0.5559829
##   EPT_PercentTaxa_predicted EPT_PercentTaxa_score Shredder_Taxa
## 1                 0.5267920             0.0000000           0.0
## 2                 0.5267920             0.6971410           0.0
## 3                 0.3943971             0.4910356           0.0
## 4                 0.5783728             0.5529665           5.2
## 5                 0.5267920             0.7223766           3.8
## 6                 0.5267920             0.8016362           1.0
##   Shredder_Taxa_predicted Shredder_Taxa_score Intolerant_Percent
## 1                2.033700           0.2291321          0.0000000
## 2                2.033700           0.2291321          0.0000000
## 3                1.929400           0.2457120          0.0111000
## 4                3.760033           0.7813159          0.0978878
## 5                2.033700           0.8331908          0.1507000
## 6                2.033700           0.3880949          0.1380305
##   Intolerant_Percent_predicted Intolerant_Percent_score
## 1                    0.1696027               0.15600955
## 2                    0.1696027               0.15600955
## 3                    0.1440950               0.22575954
## 4                    0.3143217               0.06678047
## 5                    0.1696027               0.44314377
## 6                    0.1696027               0.41900415
## 
## $Suppl1_grps
##   StationCode pGroup1 pGroup2 pGroup3 pGroup4 pGroup5 pGroup6 pGroup7
## 1       Site1  0.0002  0.0287  0.0065  0.0361  0.0007  0.0079  0.0000
## 2       Site2  0.1077  0.2976  0.0000  0.0056  0.0253  0.0994  0.3547
## 3       Site3  0.0192  0.1103  0.1226  0.1631  0.0068  0.0002  0.0001
##   pGroup8 pGroup9 pGroup10 pGroup11
## 1  0.2169  0.0843   0.4991   0.1196
## 2  0.0078  0.1012   0.0006   0.0001
## 3  0.0530  0.2653   0.0700   0.1894
## 
## $Suppl1_OE
##   StationCode   SampleID   OTU CaptureProb MeanObserved
## 1       Site1    Sample1 Acari   0.8814250         6.00
## 2       Site2    Sample2 Acari   0.9585321         9.80
## 3       Site3 BadSample1 Acari   0.8678715         0.00
## 4       Site3 BadSample2 Acari   0.8678715         0.00
## 5       Site3    Sample3 Acari   0.8678715        18.45
## 6       Site3    Sample4 Acari   0.8678715        37.00
## 
## $Suppl2_OE
##   StationCode SampleID                      OTU       CaptureProb
## 1       Site1  Sample1                    Acari 0.881424961134976
## 2       Site1  Sample1                    Argia 0.366983484848485
## 3       Site1  Sample1                   Baetis 0.880591985549809
## 4       Site1  Sample1              Callibaetis 0.101509696969697
## 5       Site1  Sample1 Ceratopsyche_Hydropsyche 0.698923583910464
## 6       Site1  Sample1           Cheumatopsyche 0.193852461500248
##   Iteration1 Iteration2 Iteration3 Iteration4 Iteration5 Iteration6
## 1          7          5          7          6          7          7
## 2          4          7          8          6          8          6
## 3         25         25         20         25         25         27
## 4          2          2          2          1          0          1
## 5          0          3          4          4          5          3
## 6          2          1          2          1          1          1
##   Iteration7 Iteration8 Iteration9 Iteration10 Iteration11 Iteration12
## 1          7          5          5           7           6           6
## 2          7          8          9           6           6           7
## 3         22         28         25          27          25          17
## 4          2          1          1           2           2           1
## 5          3          4          4           5           4           4
## 6          2          2          2           2           1           1
##   Iteration13 Iteration14 Iteration15 Iteration16 Iteration17 Iteration18
## 1           5           5           5           7           7           5
## 2           8           5           5           5           5           6
## 3          22          25          30          23          23          24
## 4           2           2           1           2           1           1
## 5           3           4           3           2           4           3
## 6           1           2           1           2           2           1
##   Iteration19 Iteration20
## 1           7           4
## 2           5           8
## 3          25          22
## 4           2           1
## 5           3           2
## 6           1           2
## 
## $Suppl2_mmi
##   StationCode   SampleID              metric Iteration value
## 1       Site3 BadSample1 Clinger_PercentTaxa         1     0
## 2       Site3 BadSample1 Clinger_PercentTaxa         2     0
## 3       Site3 BadSample1 Clinger_PercentTaxa         3     0
## 4       Site3 BadSample1 Clinger_PercentTaxa         4     0
## 5       Site3 BadSample1 Clinger_PercentTaxa         5     0
## 6       Site3 BadSample1 Clinger_PercentTaxa         6     0
##   predicted_value score
## 1       0.6422118     0
## 2       0.6422118     0
## 3       0.6422118     0
## 4       0.6422118     0
## 5       0.6422118     0
## 6       0.6422118     0
```

