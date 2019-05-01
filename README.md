
## CSCI

#### *Raphael Mazor, <raphaelm@sccwrp.org>, Marcus W. Beck, <marcusb@sccwrp.org>, Mark W. Engeln*

[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/SCCWRP/CSCI?branch=master&svg=true)](https://ci.appveyor.com/project/SCCWRP/CSCI)
[![Travis-CI Build
Status](https://travis-ci.org/SCCWRP/CSCI.svg?branch=master)](https://travis-ci.org/SCCWRP/CSCI)

R package materials to calculate the California Stream Condition Index
(CSCI) based on O/E and pMMI scores using benthic macroinvertebrates.

### Installation

Install the package as follows:

``` r
install.packages('devtools')
library(devtools)
install_github('SCCWRP/CSCI')
library(CSCI)
```

### Citation

Please cite the package as follows:

Mazor, MD, Rehn, AC, Ode, PR, Engeln, M, Schiff, KC, Stein, ED, Gillett,
DJ, Herbst, DB, Hawkins, CP. 2016. Bioassessment in complex
environments: Designing an index for consistent meaning in different
settings. Freshwater Science 35(1): 249-271.

### Usage

The core function is `CSCI` which requires taxonomic and site level
data.

``` r
#A list of two data frames: bugs and stations
data(bugs_stations) 

# run the estimator
results <- CSCI(bugs = bugs_stations[[1]], stations = bugs_stations[[2]])

# see all the components of the report
ls(results)
```

    ## [1] "core"        "Suppl1_grps" "Suppl1_mmi"  "Suppl1_OE"   "Suppl2_mmi" 
    ## [6] "Suppl2_OE"

``` r
# preview report components
lapply(results, head)
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
    ## 3  7.544418   8.95 1.18630752              0.84 0.8280605           0.17
    ## 4 12.953853  11.65 0.89934633              0.30 0.8279333           0.17
    ## 5 10.248486  13.35 1.30263138              0.94 1.1985317           0.87
    ## 6 10.248486   9.00 0.87817846              0.26 0.9079721           0.30
    ##        CSCI CSCI_Percentile
    ## 1 0.1306918            0.00
    ## 2 0.2231975            0.00
    ## 3 1.0071840            0.52
    ## 4 0.8636398            0.20
    ## 5 1.2505816            0.94
    ## 6 0.8930753            0.25
    ## 
    ## $Suppl1_mmi
    ##   StationCode   SampleID MMI_Score Clinger_PercentTaxa
    ## 1       Site3 BadSample1 0.1638082           0.0000000
    ## 2       Site3 BadSample2 0.3488195           0.0000000
    ## 3       Site1    Sample1 0.8280605           0.2724754
    ## 4       Site2    Sample2 0.8279333           0.4538100
    ## 5       Site3    Sample3 1.1985317           0.6718539
    ## 6       Site3    Sample4 0.9079721           0.6378788
    ##   Clinger_PercentTaxa_predicted Clinger_PercentTaxa_score
    ## 1                     0.6422118                 0.0000000
    ## 2                     0.6422118                 0.0000000
    ## 3                     0.3929307                 0.5210178
    ## 4                     0.6216008                 0.4445904
    ## 5                     0.6422118                 0.7633635
    ## 6                     0.6422118                 0.7085076
    ##   Coleoptera_PercentTaxa Coleoptera_PercentTaxa_predicted
    ## 1             0.00000000                       0.07977832
    ## 2             0.00000000                       0.07977832
    ## 3             0.11088235                       0.08284403
    ## 4             0.07571452                       0.05155909
    ## 5             0.12649958                       0.07977832
    ## 6             0.07437037                       0.07977832
    ##   Coleoptera_PercentTaxa_score Taxonomic_Richness
    ## 1                    0.2321037                1.0
    ## 2                    0.2321037                2.0
    ## 3                    0.7306730               34.7
    ## 4                    0.7127176               32.2
    ## 5                    0.8170673               41.4
    ## 6                    0.5760096               26.9
    ##   Taxonomic_Richness_predicted Taxonomic_Richness_score EPT_PercentTaxa
    ## 1                     32.27143                0.0000000       0.0000000
    ## 2                     32.27143                0.0000000       0.5000000
    ## 3                     26.13860                0.9018592       0.2594118
    ## 4                     32.79767                0.6548757       0.4556507
    ## 5                     32.27143                0.9171534       0.5175701
    ## 6                     32.27143                0.5261462       0.5577778
    ##   EPT_PercentTaxa_predicted EPT_PercentTaxa_score Shredder_Taxa
    ## 1                 0.5267920             0.0000000          0.00
    ## 2                 0.5267920             0.6971410          0.00
    ## 3                 0.3943971             0.4951922          0.00
    ## 4                 0.5783728             0.5180823          4.95
    ## 5                 0.5267920             0.7299366          3.85
    ## 6                 0.5267920             0.8049864          1.00
    ##   Shredder_Taxa_predicted Shredder_Taxa_score Intolerant_Percent
    ## 1                2.033700           0.2291321         0.00000000
    ## 2                2.033700           0.2291321         0.00000000
    ## 3                1.929400           0.2457120         0.01110000
    ## 4                3.760033           0.7415752         0.08797499
    ## 5                2.033700           0.8411389         0.15300000
    ## 6                2.033700           0.3880949         0.13728498
    ##   Intolerant_Percent_predicted Intolerant_Percent_score
    ## 1                    0.1696027               0.15600955
    ## 2                    0.1696027               0.15600955
    ## 3                    0.1440950               0.22575954
    ## 4                    0.3143217               0.04789322
    ## 5                    0.1696027               0.44752604
    ## 6                    0.1696027               0.41758365
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
    ## 1       Site1    Sample1 Acari   0.8814250         5.60
    ## 2       Site2    Sample2 Acari   0.9585321        10.05
    ## 3       Site3 BadSample1 Acari   0.8678715         0.00
    ## 4       Site3 BadSample2 Acari   0.8678715         0.00
    ## 5       Site3    Sample3 Acari   0.8678715        19.10
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
    ## 1          6          4          5          5          7          7
    ## 2          9          5          7          8          8          7
    ## 3         25         26         25         24         26         26
    ## 4          1          2          1          2          0          1
    ## 5          2          3          3          2          4          3
    ## 6          0          1          2          1          0          2
    ##   Iteration7 Iteration8 Iteration9 Iteration10 Iteration11 Iteration12
    ## 1          6          5          8           4           8           6
    ## 2          6          7          5           6           6           7
    ## 3         21         27         23          25          25          22
    ## 4          2          2          1           2           0           1
    ## 5          4          2          4           3           3           1
    ## 6          2          2          2           2           2           1
    ##   Iteration13 Iteration14 Iteration15 Iteration16 Iteration17 Iteration18
    ## 1           5           6           5           5           5           7
    ## 2           7           6           6           8           9           7
    ## 3          22          24          23          25          21          23
    ## 4           0           2           1           2           1           2
    ## 5           4           3           4           4           3           4
    ## 6           2           1           1           0           1           2
    ##   Iteration19 Iteration20
    ## 1           4           4
    ## 2           8           7
    ## 3          26          21
    ## 4           2           1
    ## 5           4           5
    ## 6           0           1
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
