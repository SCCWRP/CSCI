
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

#see all the components of the report
ls(results)
```

```
## [1] "core"        "Suppl1_grps" "Suppl1_mmi"  "Suppl1_OE"   "Suppl2_mmi" 
## [6] "Suppl2_OE"
```

```r
 #see the core report
results$core
```

```
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
## 3  7.544418   9.00 1.19293493              0.84 0.8316831           0.17
## 4 12.953853  11.10 0.85688792              0.23 0.8532012           0.21
## 5 10.248486  13.05 1.27335877              0.92 1.2013691           0.87
## 6 10.248486   9.00 0.87817846              0.26 0.9049074           0.30
##        CSCI CSCI_Percentile
## 1 0.1306918            0.00
## 2 0.2231975            0.00
## 3 1.0123090            0.53
## 4 0.8550445            0.18
## 5 1.2373639            0.93
## 6 0.8915430            0.25
```

