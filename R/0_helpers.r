csci_predictors <- c("BDH_AVE", "ELEV_RANGE", "KFCT_AVE",
                     "P_MEAN", "LogWSA", "New_Lat",
                     "New_Long", "PPT_00_09", 
                     "SITE_ELEV", "SumAve_P", "TEMP_00_09")
csci_metrics <- c("Clinger_PercentTaxa", "Coleoptera_PercentTaxa", "Taxonomic_Richness", 
                  "EPT_PercentTaxa", "Shredder_Taxa", "Intolerant_Percent")

csci_bugs_col <- c("StationCode", "SampleID", "FinalID", "Distinct", "LifeStageCode",
                   "BAResult")


###Validity helper###

validity <-   function(object){
  bugcolumns <- c("StationCode", "SampleID", "FinalID", "BAResult", "Distinct", "LifeStageCode")
  predictorcolumns <- csci_predictors
  if(any(duplicated(object@predictors$StationCode)))
    return(print("Ambiguity caused by duplicate StationCodes in station data"))
  
  if(!(all(bugcolumns %in% names(object@bugdata))))
    return(print(paste("Bug data missing column:", bugcolumns[!(bugcolumns %in% names(object@bugdata))], collapse=" & ")))
  BMIMetrics::BMI(object@bugdata)
  if(any(is.na(as.matrix(object@bugdata[, bugcolumns[-5]]))))
    return(print(paste("NAs found in bug data.")))


  if(!(all(predictorcolumns %in% names(object@predictors))))
    return(print(paste("Predictors missing column:", predictorcolumns[!(predictorcolumns %in% names(object@predictors))], collapse=" & ")))
  if(any(is.na(as.matrix(object@predictors[, predictorcolumns]))))
    return(print(paste("NAs found in predictor data")))

  if(!("AREA_SQKM" %in% names(object@predictors)) & !("LogWSA" %in% names(object@predictors)))
    return(print("Predictors must include a column AREA_SQKM or LogWSA"))
  if(!all(as.character(object@bugdata$StationCode) %in% as.character(object@predictors$StationCode)))
    return(print("All StationCode IDs must be represented in both bug and predictor data"))
  if(length(unique(object@bugdata$SampleID)) != nrow(unique(object@bugdata[, c("StationCode", "SampleID")])))
    return(print("SampleIDs must be unique to one StationCode"))
  "pass"
}


###OE model prediction###
model.predict.RanFor.4.2 <-function(bugcal.pa,grps.final,preds.final,ranfor.mod, prednew,bugnew,Pc,Cal.OOB=FALSE) {
  
  #first convert bug matrix to P/A (1/0);
  temp.pa <- bugnew[, 3:ncol(bugnew)];                                                                                                             
  temp.pa[temp.pa>0]<-1;
  rm(bugnew);
  
  #1. - initial definitions;
  names(grps.final)<-row.names(bugcal.pa);
  nsite.cal<-length(grps.final); #number of calibration sites;
  npreds<-length(preds.final); #number of predictor variables;
  grpsiz<-table(grps.final); #tabulate sites per group;
  ngrps<-length(grpsiz);  #number of groups;
  
  #2. Alignment of new predictor and bug data with model data;
  #2a) Align the rows (samples) of the new bug data to the new predictor data;
  temp.pa<-temp.pa[row.names(prednew),];
  #2b)reshape bugnew columns (taxa) to match those in bugcal.pa, and be in same order;
  # New bug data might have fewer or more columns (taxa) than calibration bug data;
  # create a new empty site x taxa matrix with bugcal.pa columns and bugnew rows, fill it with zeros;
  nsite.new<-dim(temp.pa)[[1]];
  ntaxa<-dim(bugcal.pa)[[2]];
  bugnew.pa<-matrix(rep(0,nsite.new*ntaxa),nrow=nsite.new,dimnames=list(rownames(temp.pa),names(bugcal.pa)));
  #loop through columns of new matrix and fill with columns of the original test data matrix;
  col.match<-match(dimnames(bugnew.pa)[[2]],dimnames(temp.pa)[[2]]);
  for(kcol in 1:ntaxa) if(!is.na(col.match[kcol]))bugnew.pa[,kcol]<-temp.pa[,col.match[kcol]];
  ################;
  
  ## STEP 3. -- Use RF to predict the group (cluster) membership for all new sites. ;
  # Does not use RIVPACS assumption of weighting the membership probabilities by Calibration group size, as a prior probability;
  # Also, RF predictions do not have an outlier test, unlike DFA predictions;
  # Predicted probs are outputted as a matrix, sites are rows, columns are groups;
  
  #If Cal.OOB is true, do OOB predictions, appropriate ONLY for CAL data;
  # If it is false, do a new prediction;                                                                                                              
  if(Cal.OOB==TRUE) grpprobs<-ranfor.mod$votes else 
    grpprobs<-randomForest:::predict.randomForest(ranfor.mod,newdata=prednew[,preds.final],type='prob')
  
  ############;
  #STEP 4 -- Compute predicted occurrence probability for each modeled taxon at each new sample;
  # "modeled OTU's" consist of all taxa that were found at >=1 calibration sample;
  #To do this, first calculate the occurrence freqs of all modeled taxa in the Calibration sample groups;
  grpocc<-apply(bugcal.pa,2,function(x){tapply(x,grps.final,function(y){sum(y)/length(y)})})
  
  #finally, compute the matrix of predicted occurrence (capture) probabilities, for all new samples and all modeled taxa;
  #This is the matrix-algebra form of the RIVPACS combining formula (e.g., Clarke et al. 2003, Eq. 4)
  site.pred.dfa<-grpprobs%*%grpocc
  
  #######################;
  
  # STEP 5. Compute O, E, O/E and BC for all samples. ;
  # Also compute O/E and BC for the null model;
  
  #5.1 loop over all samples. Compute and store  O, predicted E, predicted BC for each sample. ;
  #temporary data frame to hold nonnull results for all samples. ;
  nsit.new<-dim(prednew)[[1]];
  OE.stats<-data.frame(OBS=rep(NA,nsit.new), E.prd=rep(NA,nsit.new),BC.prd=rep(NA,nsit.new),row.names=row.names(prednew));
  for(i in 1:nsit.new) {
                        #i<-1;
                        cur.prd<-site.pred.dfa[i,]; #vector of predicted probs for current sample;
                        spdyn<-names(cur.prd)[cur.prd>=Pc];  #subset of taxa with Pi>=Pcutoff;
                        cur.prd<-cur.prd[spdyn]; #vector of Pi for subset of included taxa;
                        cur.obs<-bugnew.pa[i,spdyn]; #vector of observed P/A for those taxa;
                        OE.stats$OBS[i]<-sum(cur.obs); #observed richness (O);
                        OE.stats$E.prd[i]<-sum(cur.prd); #Expected richness (E);
                        OE.stats$BC.prd[i]<-sum(abs(cur.obs-cur.prd))/ (OE.stats$OBS[i]+OE.stats$E.prd[i]); #BC value;
  }; #finish sample loop;
  
  #5.2 - Compute Expected richness (E) and BC for null model using taxa >= Pc.
  # Note that the set of taxa included in the null model is fixed for all samples;
  pnull<-apply(bugcal.pa,2,sum)/dim(bugcal.pa)[[1]];  #null model predicted occurrnece probabilities, all taxa;
  nulltax<-names(pnull[pnull>=Pc]); #subset of taxa with Pnull >= Pc;
  Enull<-sum(pnull[nulltax])
  
  
  
  Obsnull<-apply(subset(bugnew.pa, select=nulltax),1,sum); #vector of Observed richness, new samples, under null model;
  BC.null<-apply(subset(bugnew.pa, select=nulltax),1,function(x)sum(abs(x-pnull[nulltax])))/(Obsnull+Enull); #vector of null-model BC;
  
  #5.3 - Final data frame contains values of O, E, O/E, Onull, Enull, Onull/Enull, BC.prd and BC.null, for all samples;
  #Also includes outlier flags;
  
  OE.final<-data.frame(O=OE.stats$OBS,E=OE.stats$E.prd,
                       OoverE=OE.stats$OBS/OE.stats$E.prd, 
                       Onull=Obsnull,Enull=rep(Enull,length(Obsnull)),OoverE.null=Obsnull/Enull,
                       BC= OE.stats$BC.prd,BC.null=BC.null,
                       row.names=row.names(bugnew.pa))
  return(OE.final)
} #end of function;

isInside <- function(newdata, refcaldata, averageImp, confidence = 0.99){
  predictors <- csci_predictors
  refcal <- scale(refcaldata[, predictors])
  
  refcal <- refcal[, averageImp$variable] * averageImp$Importance
  pcrefcal <- princomp(refcal)
  pcdata <- data.frame(axis1 = pcrefcal$scores[, 1], axis2 = pcrefcal$scores[, 2],
                       axis3 = pcrefcal$scores[, 3])

  test <- dataEllipse(as.matrix(pcdata[, 1:2]), levels=c(confidence))
  test2 <- dataEllipse(as.matrix(pcdata[, 2:3]), levels=c(confidence))

  #Calculate the ellipse radii
  axes <- sort(unlist(union(colwise(max)(as.data.frame(test2)), colwise(max)(as.data.frame(test)))))
  xradius <-  axes[4]
  yradius <- axes[2]
  zradius <- axes[1]
  
  prep <- scale(newdata[, predictors])
  prep <- prep[, averageImp$variable] * averageImp$Importance
  pdata <- predict(pcrefcal, prep)
  x <- pdata[, 1]
  y <- pdata[, 2]
  z <- pdata[, 3]  
  data.frame(outlier = ifelse(
    (x^2)/(xradius^2) + (y^2)/(yradius^2) + (z^2)/(zradius^2) <= 1,
    0, 1))
  
}

