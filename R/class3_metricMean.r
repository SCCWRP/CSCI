setClass("metricMean", representation(mean.metric="data.frame"),
         contains=c("mmi", "oe"))

setValidity("metricMean", function(object){
  if(!(setequal(object@subsample[[1]]$SampleID, object@oesubsample$SampleID))){return("Incompatible objects")} else
    TRUE
})

setMethod("initialize", "metricMean", function(.Object="metricMean", x="mmi", y="oe"){
  for(i in names(getSlots("mmi"))){
    slot(.Object, i) <- slot(x, i)
  }
  for(i in names(getSlots("oe"))){
    slot(.Object, i) <- slot(y, i)
  }
  .Object@mean.metric <- merge(y@oeresults, x@summary[, 1:3])
  .Object@mean.metric$CSCI <- apply(.Object@mean.metric[, c("OoverE", "MMI_Score")], 1, mean)
  .Object
})

setMethod("summary", "metricMean", function(object = "metricMean", report="all"){
  load(system.file("data", "oe_stuff.rdata", package="CSCI"))
  load(system.file("data", "extent.rdata", package="CSCI"))
  load(system.file("data", "mahalData.rdata", package="CSCI"))
  arglist <- c("core", "Suppl1_mmi", "Suppl1_grps", "Suppl1_OE", "Suppl2_OE", "Suppl2_mmi")
  report <- match.arg(report, c(arglist, "all"), several.ok=TRUE)
  if(report == "all")report <- arglist
  reportlist <- list()
  add <-  function(obj){
    reportlist[[length(reportlist)+1]] <- obj
    reportlist
  }
  object@mean.metric$Number_of_MMI_Iterations <- ifelse(object@mean.metric$Count > 500, 20, 1)
  object@mean.metric$Number_of_OE_Iterations <- 
    ifelse(object@mean.metric$Count - object@mean.metric$Count*(object@ambiguous$individuals/100) >= 400, 20, 1)
  object@mean.metric$Pcnt_Ambiguous_Individuals <- object@ambiguous$individuals[match(object@ambiguous$SampleID,
                                                                                      object@mean.metric$SampleID)]
  object@mean.metric$Pcnt_Ambiguous_Taxa <- object@ambiguous$taxa[match(object@ambiguous$SampleID,
                                                                        object@mean.metric$SampleID)]
  object@mean.metric$overall_flag <- ifelse(object@mean.metric$Count >=450 & object@mean.metric$Pcnt_Ambiguous_Individuals < 20,
                                            "Adequate", "Inadequate")
  object@mean.metric$mmi_indiv_flag <- ifelse(object@mean.metric$Count >=450, "Adequate", "Inadequate")
  object@mean.metric$ambig_indiv_flag <- with(object@mean.metric, 
                                              ifelse(Count - (Pcnt_Ambiguous_Individuals * Count) >= 360,
                                                     "Adequate", "Inadequate"))
  
  predcheck <- function(data){
    dat <- sapply(names(extent), function(col){
      sapply(data[, col], function(x){extent[1, col] > x | extent[2, col] < x})
    })
    if(nrow(data) ==1)dat <- t(dat)
    res <- apply(dat, 1, function(x)paste(names(which(x)), collapse=", "))
    res[res == ""] <- "All within range"
    res
  }
    
  if("core" %in% report){
    object@mean.metric$E <- object@fulliterations[[1]]$E[match(object@mean.metric$SampleID,
                                                               object@fulliterations[[1]]$SampleID)]
    object@mean.metric$Mean_O <- object@mean.metric$E * object@mean.metric$OoverE
    
    cols <-c("StationCode", "SampleID", "Count", "Number_of_MMI_Iterations", 
             "Number_of_OE_Iterations", "Pcnt_Ambiguous_Individuals",
             "Pcnt_Ambiguous_Taxa",
             "E", "Mean_O", "OoverE", 
             "MMI_Score", "CSCI")
        
    reportlist <- add(object@mean.metric[, cols])
    
    names(reportlist) <- "core"
    reportlist$core <- within(reportlist$core, {
      OoverE_Percentile <- round(pnorm(OoverE, mean=1, sd=0.190276), digits=2)
      MMI_Percentile <- round(pnorm(MMI_Score, mean=1, sd=0.179124), digits=2)
      CSCI_Percentile <- round(pnorm(CSCI, mean=1, sd=0.160299), digits=2)
    })
    reportlist$core <- reportlist$core[, c(cols[1:9],
                                           "OoverE", "OoverE_Percentile",
                                           "MMI_Score", "MMI_Percentile",
                                           "CSCI", "CSCI_Percentile")]
  }
  
  names <- csci_metrics
  if("Suppl1_mmi" %in% report){
    model <- object@modelprediction[, names]
    names(model) <- paste0(names(model), "_predicted")
    sup1mmi <- cbind(object@mean.metric[, c("StationCode", "SampleID", "MMI_Score")],
                     object@metrics[, names], model, object@result)
    colorder <- c("StationCode", "SampleID", "MMI_Score", "Clinger_PercentTaxa", 
                  "Clinger_PercentTaxa_predicted", "Clinger_PercentTaxa_score", 
                  "Coleoptera_PercentTaxa", "Coleoptera_PercentTaxa_predicted", 
                  "Coleoptera_PercentTaxa_score", "Taxonomic_Richness", "Taxonomic_Richness_predicted", 
                  "Taxonomic_Richness_score", "EPT_PercentTaxa", "EPT_PercentTaxa_predicted", 
                  "EPT_PercentTaxa_score", "Shredder_Taxa", "Shredder_Taxa_predicted", 
                  "Shredder_Taxa_score", "Intolerant_Percent", "Intolerant_Percent_predicted", 
                  "Intolerant_Percent_score")
    reportlist <- add(sup1mmi[, colorder])
    names(reportlist)[length(reportlist)] <- "Suppl1_mmi"
  }

  
  predict <- predict(oe_stuff[[1]],newdata=unique(object@predictors[,oe_stuff[[4]]]),type='prob')
  colnames(predict) <- paste0("pGroup", 1:11)
  
  predict2 <- data.frame(StationCode = sapply(strsplit(row.names(predict), "%"), `[`, 1),
                        SampleID = sapply(strsplit(row.names(predict), "%"), `[`, 2),
                        predict)
  row.names(predict2) <- NULL
  if("Suppl1_grps" %in% report){
    reportlist <- add(unique(predict2[, -2]))
    names(reportlist)[length(reportlist)] <- "Suppl1_grps"
  }
  
  if("Suppl1_OE" %in% report){
    object@predictors$StationCode <- as.character(object@predictors$StationCode)
    E <- cbind(StationCode = unique(object@predictors$StationCode), 
                 predict %*% apply(oe_stuff[[2]],2,function(x){tapply(x,oe_stuff[[3]],function(y){sum(y)/length(y)})}))
    E <- merge(object@predictors[, c("StationCode", "SampleID")], melt(as.data.frame(E), id.vars="StationCode"),
               all=TRUE, by = "StationCode")
    object@oesubsample$Replicate_mean <- apply(object@oesubsample[, paste("Replicate", 1:20)], 1, mean)
    O <- dcast(object@oesubsample, SampleID + StationCode ~ STE, value.var="Replicate_mean", sum, na.rm=TRUE)
    O <- melt(O, id.vars=c("SampleID", "StationCode"))
    
    result <- merge(E, O, by=c("variable", "StationCode", "SampleID"), all=TRUE)
    names(result) <- c("OTU", "StationCode", "SampleID", "CaptureProb", "MeanObserved")
    result$CaptureProb<-as.numeric(result$CaptureProb)
    result$MeanObserved[is.na(result$MeanObserved)] <- 0
    reportlist <- add(result[, c("StationCode", "SampleID", "OTU", "CaptureProb", "MeanObserved")])
    names(reportlist)[length(reportlist)] <- "Suppl1_OE"
  }
  if("Suppl2_OE" %in% report){
    E <- cbind(StationCode = unique(object@predictors$StationCode), 
               predict %*% apply(oe_stuff[[2]],2,function(x){tapply(x,oe_stuff[[3]],function(y){sum(y)/length(y)})}))
    E <- melt(as.data.frame(E), id.vars="StationCode")
    names(E)[2:3] <- c("OTU", "CaptureProb") 
    O <- object@oesubsample[, c("SampleID", "StationCode", "STE", paste("Replicate", 1:20))]
    O <- dcast(melt(O, id.vars=c("SampleID", "StationCode", "STE")), SampleID + StationCode + STE ~ variable,
                    value.var="value", fun.aggregate=sum)
    names(O)[3] <- c("OTU")
    result <- merge(E, O, by=c("StationCode", "OTU"))
    
    x <- result
    x[, 5:24] <- colwise(function(x)ifelse(x > 0, 1, 0))(x[, 5:24])
    
    

    test <- sapply(paste("Replicate", 1:20), function(rep){
     sapply(split(x, x$SampleID), function(df){
        captable <- reportlist$Suppl1_OE[reportlist$Suppl1_OE$SampleID == unique(df$SampleID), ]
        ingroup <- as.character(captable$OTU[captable$CaptureProb > 0.5])
        sum(df[df$OTU %in% ingroup, rep] > 0)/
          sum(as.numeric(captable$CaptureProb[captable$OTU %in% ingroup]))
      })
    })
    
    if(length(unique(reportlist$Suppl1_OE$SampleID)) == 1){
      test <- t(test)
      row.names(test) <- unique(reportlist$Suppl1_OE$SampleID)
    }
    test <- data.frame("SampleID" = row.names(test), "StationCode" = 
                         reportlist$Suppl1_OE$StationCode[match(row.names(test), reportlist$Suppl1_OE$SampleID)],
                       "OTU" = "OoverE", CaptureProb = NA, test, row.names=NULL)
    names(test)[5:24] <- paste("Replicate", 1:20)
    
    combinedres <- rbind(result, test)
    reportlist <- add(combinedres[, c(1, 4, 2, 3, 5:ncol(combinedres))])
    names(reportlist)[length(reportlist)] <- "Suppl2_OE"
    names(reportlist$Suppl2_OE)[5:24] <- paste0("Iteration", 1:20)
  }
  if(all(c("Suppl2_mmi", "Suppl1_mmi") %in% report)){
    load(system.file("data", "maxmin_v2.rdata",  package="CSCI"))
    
    cmmi <- melt(object@metrics, id.vars="SampleID")
    cmmi$variable <- as.character(cmmi$variable)
    cmmi$replicate <- sapply(strsplit(cmmi$variable, "_"), tail, 1)
    cmmi$metric <- match.arg(cmmi$variable, names, TRUE)
    cmmi$replicate[cmmi$replicate == ""] <- "Mean"
    cmmi <- cmmi[cmmi$replicate != "Mean", c("SampleID", "metric", "replicate", "value")]
    
    
    prediction <- melt(reportlist$Suppl1_mmi, id.vars=c("StationCode", "SampleID"))
    prediction <- subset(prediction, grepl("predicted", variable))
    prediction$variable <- as.character(prediction$variable)
    prediction$variable <- substr(prediction$variable, 1, nchar(prediction$variable) - 10)
    names(prediction)[3:4] <- c("metric", "predicted_value")
    x <- merge(cmmi, prediction)
    x$score <- mapply(function(value, predict, metric){
      result <- (value - predict - maxmin[1, metric])/(maxmin[2, metric] - maxmin[1, metric])
      result <- ifelse(result > 1, 1, ifelse(
        result < 0, 0, result))
      result
    }, x$value, x$predicted_value, x$metric)
    x$replicate <- suppressWarnings(as.numeric(x$replicate))
    x <- arrange(x[, c("StationCode", "SampleID", "metric", "replicate", "value", "predicted_value", "score")],
                 SampleID, metric, replicate)
    names(x)[names(x) == "replicate"] <- "Iteration"
    reportlist <- add(x)
    names(reportlist)[length(reportlist)] <- "Suppl2_mmi"
  }
  reportlist$core <- plyr::rename(reportlist$core, c("MMI_Score" = "MMI"))
  if(length(reportlist)==1)transform(reportlist) else reportlist
})
  

