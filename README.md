---
output:
  html_document:
    keep_md: yes
    toc: no
    self_contained: no
---

## CSCI

#### *Raphael Mazor, raphaelm@sccwrp.org, Marcus W. Beck, marcusb@sccwrp.org, Mark W. Engeln*

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
## 3  7.544418   8.90 1.17968010              0.83 0.8326549           0.18
## 4 12.953853  11.05 0.85302807              0.22 0.8267922           0.17
## 5 10.248486  13.25 1.29287384              0.94 1.2006869           0.87
## 6 10.248486   9.00 0.87817846              0.26 0.9074543           0.30
##        CSCI CSCI_Percentile
## 1 0.1306918            0.00
## 2 0.2231975            0.00
## 3 1.0061675            0.52
## 4 0.8399101            0.16
## 5 1.2467804            0.94
## 6 0.8928164            0.25
## 
## $Suppl1_mmi
##   StationCode   SampleID MMI_Score Clinger_PercentTaxa
## 1       Site3 BadSample1 0.1638082           0.0000000
## 2       Site3 BadSample2 0.3488195           0.0000000
## 3       Site1    Sample1 0.8326549           0.2755542
## 4       Site2    Sample2 0.8267922           0.4708968
## 5       Site3    Sample3 1.2006869           0.6725710
## 6       Site3    Sample4 0.9074543           0.6370130
##   Clinger_PercentTaxa_predicted Clinger_PercentTaxa_score
## 1                     0.6422118                 0.0000000
## 2                     0.6422118                 0.0000000
## 3                     0.3929307                 0.5259888
## 4                     0.6216008                 0.4721785
## 5                     0.6422118                 0.7645213
## 6                     0.6422118                 0.7071097
##   Coleoptera_PercentTaxa Coleoptera_PercentTaxa_predicted
## 1             0.00000000                       0.07977832
## 2             0.00000000                       0.07977832
## 3             0.11378915                       0.08284403
## 4             0.07781496                       0.05155909
## 5             0.12355096                       0.07977832
## 6             0.07450142                       0.07977832
##   Coleoptera_PercentTaxa_score Taxonomic_Richness
## 1                    0.2321037               1.00
## 2                    0.2321037               2.00
## 3                    0.7441147              34.70
## 4                    0.7224305              32.10
## 5                    0.8034322              41.55
## 6                    0.5766157              26.85
##   Taxonomic_Richness_predicted Taxonomic_Richness_score EPT_PercentTaxa
## 1                     32.27143                0.0000000       0.0000000
## 2                     32.27143                0.0000000       0.5000000
## 3                     26.13860                0.9018592       0.2594347
## 4                     32.79767                0.6521791       0.4464490
## 5                     32.27143                0.9211983       0.5203430
## 6                     32.27143                0.5247979       0.5568376
##   EPT_PercentTaxa_predicted EPT_PercentTaxa_score Shredder_Taxa
## 1                 0.5267920             0.0000000           0.0
## 2                 0.5267920             0.6971410           0.0
## 3                 0.3943971             0.4952350           0.0
## 4                 0.5783728             0.5009068           4.8
## 5                 0.5267920             0.7351123           3.9
## 6                 0.5267920             0.8032316           1.0
##   Shredder_Taxa_predicted Shredder_Taxa_score Intolerant_Percent
## 1                2.033700           0.2291321         0.00000000
## 2                2.033700           0.2291321         0.00000000
## 3                1.929400           0.2457120         0.01050000
## 4                3.760033           0.7177308         0.08908538
## 5                2.033700           0.8490870         0.15480000
## 6                2.033700           0.3880949         0.13830521
##   Intolerant_Percent_predicted Intolerant_Percent_score
## 1                    0.1696027               0.15600955
## 2                    0.1696027               0.15600955
## 3                    0.1440950               0.22461634
## 4                    0.3143217               0.05000889
## 5                    0.1696027               0.45095565
## 6                    0.1696027               0.41952753
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
## 1       Site1    Sample1 Acari   0.8814250         5.85
## 2       Site2    Sample2 Acari   0.9585321        11.50
## 3       Site3 BadSample1 Acari   0.8678715         0.00
## 4       Site3 BadSample2 Acari   0.8678715         0.00
## 5       Site3    Sample3 Acari   0.8678715        18.15
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
## 1          5          6          7          7          5          7
## 2          4          6          7          5          4          8
## 3         25         23         25         25         28         26
## 4          2          1          2          1          1          2
## 5          3          4          5          3          3          5
## 6          2          2          1          2          2          2
##   Iteration7 Iteration8 Iteration9 Iteration10 Iteration11 Iteration12
## 1          7          5          4           7           6           7
## 2          6          8          4           7           6           5
## 3         25         21         25          19          23          20
## 4          1          2          1           2           2           2
## 5          4          3          5           2           4           4
## 6          2          2          2           2           1           0
##   Iteration13 Iteration14 Iteration15 Iteration16 Iteration17 Iteration18
## 1           5           6           4           7           5           6
## 2           3           6           7           7           7           4
## 3          25          23          21          26          24          25
## 4           1           2           2           1           2           1
## 5           5           4           3           3           5           5
## 6           0           2           2           2           2           1
##   Iteration19 Iteration20
## 1           3           8
## 2           5           3
## 3          29          25
## 4           1           1
## 5           5           5
## 6           2           1
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

