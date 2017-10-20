
## CSCI

#### *Raphael Mazor, raphaelm@sccwrp.org, Marcus W. Beck, marcusb@sccwrp.org, Mark W Engeln*

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
## 3  7.544418   8.85 1.17305268              0.82 0.8337532           0.18
## 4 12.953853  10.90 0.84144850              0.20 0.8478843           0.20
## 5 10.248486  13.30 1.29775261              0.94 1.2126907           0.88
## 6 10.248486   9.00 0.87817846              0.26 0.9063075           0.30
##        CSCI CSCI_Percentile
## 1 0.1306918            0.00
## 2 0.2231975            0.00
## 3 1.0034029            0.51
## 4 0.8446664            0.17
## 5 1.2552216            0.94
## 6 0.8922430            0.25
## 
## $Suppl1_mmi
##   StationCode   SampleID MMI_Score Clinger_PercentTaxa
## 1       Site3 BadSample1 0.1638082           0.0000000
## 2       Site3 BadSample2 0.3488195           0.0000000
## 3       Site1    Sample1 0.8337532           0.2750616
## 4       Site2    Sample2 0.8478843           0.4527886
## 5       Site3    Sample3 1.2126907           0.6704316
## 6       Site3    Sample4 0.9063075           0.6361472
##   Clinger_PercentTaxa_predicted Clinger_PercentTaxa_score
## 1                     0.6422118                 0.0000000
## 2                     0.6422118                 0.0000000
## 3                     0.3929307                 0.5251934
## 4                     0.6216008                 0.4429413
## 5                     0.6422118                 0.7610671
## 6                     0.6422118                 0.7057118
##   Coleoptera_PercentTaxa Coleoptera_PercentTaxa_predicted
## 1             0.00000000                       0.07977832
## 2             0.00000000                       0.07977832
## 3             0.11529412                       0.08284403
## 4             0.08046568                       0.05155909
## 5             0.13160644                       0.07977832
## 6             0.07464387                       0.07977832
##   Coleoptera_PercentTaxa_score Taxonomic_Richness
## 1                    0.2321037               1.00
## 2                    0.2321037               2.00
## 3                    0.7510741              34.70
## 4                    0.7346881              33.00
## 5                    0.8406826              42.15
## 6                    0.5772744              26.80
##   Taxonomic_Richness_predicted Taxonomic_Richness_score EPT_PercentTaxa
## 1                     32.27143                0.0000000       0.0000000
## 2                     32.27143                0.0000000       0.5000000
## 3                     26.13860                0.9018592       0.2579412
## 4                     32.79767                0.6764485       0.4491252
## 5                     32.27143                0.9373779       0.5162991
## 6                     32.27143                0.5234496       0.5559829
##   EPT_PercentTaxa_predicted EPT_PercentTaxa_score Shredder_Taxa
## 1                 0.5267920             0.0000000          0.00
## 2                 0.5267920             0.6971410          0.00
## 3                 0.3943971             0.4924473          0.00
## 4                 0.5783728             0.5059021          5.20
## 5                 0.5267920             0.7275641          3.95
## 6                 0.5267920             0.8016362          1.00
##   Shredder_Taxa_predicted Shredder_Taxa_score Intolerant_Percent
## 1                2.033700           0.2291321         0.00000000
## 2                2.033700           0.2291321         0.00000000
## 3                1.929400           0.2457120         0.01090000
## 4                3.760033           0.7813159         0.09097838
## 5                2.033700           0.8570352         0.15210000
## 6                2.033700           0.3880949         0.13797018
##   Intolerant_Percent_predicted Intolerant_Percent_score
## 1                    0.1696027                0.1560095
## 2                    0.1696027                0.1560095
## 3                    0.1440950                0.2253785
## 4                    0.3143217                0.0536157
## 5                    0.1696027                0.4458112
## 6                    0.1696027                0.4188892
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
## 1       Site1    Sample1 Acari   0.8814250         5.65
## 2       Site2    Sample2 Acari   0.9585321         9.90
## 3       Site3 BadSample1 Acari   0.8678715         0.00
## 4       Site3 BadSample2 Acari   0.8678715         0.00
## 5       Site3    Sample3 Acari   0.8678715        17.85
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
## 1          7          5          5          6          7          5
## 2          7          7          5          7          7          7
## 3         23         24         20         28         27         22
## 4          1          2          2          2          2          2
## 5          3          5          4          5          3          3
## 6          1          1          1          0          1          2
##   Iteration7 Iteration8 Iteration9 Iteration10 Iteration11 Iteration12
## 1          5          5          7           6           6           6
## 2          9          7          8           5           6           6
## 3         24         21         22          21          20          25
## 4          1          2          2           0           1           0
## 5          4          4          5           4           2           3
## 6          2          1          1           2           1           2
##   Iteration13 Iteration14 Iteration15 Iteration16 Iteration17 Iteration18
## 1           6           5           5           5           4           4
## 2           5           5           6           8           7           5
## 3          21          19          26          24          22          22
## 4           2           1           2           2           2           1
## 5           4           5           3           2           2           4
## 6           2           1           1           1           1           1
##   Iteration19 Iteration20
## 1           7           7
## 2           8           7
## 3          26          17
## 4           0           2
## 5           4           3
## 6           2           2
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

