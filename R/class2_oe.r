setClass("oe", representation(ambiguous="data.frame",
                              oesubsample="data.frame",
                              iterations="matrix",
                              fulliterations="list",
                              datalength="numeric",
                              oeresults="data.frame"), 
         contains="bugs",
         prototype=list(ambiguous=data.frame(),
                        oesubsample=data.frame(),
                        iterations=matrix(),
                        fulliterations=list(),
                        datalength=numeric(),
                        oeresults=data.frame()
         ))


setMethod("nameMatch", "oe", function(object, effort = "SAFIT1__OTU_a"){
  
  colnames(object@bugdata)[which(colnames(object@bugdata) == "FinalID")] <- "Taxa"
  colnames(object@bugdata)[which(colnames(object@bugdata) == "BAResult")] <- "Result"
  object@oeresults <- ddply(object@bugdata, .(SampleID),
                            plyr::summarise, Result = sum(Result))[, c("SampleID", "Result")]
  names(object@oeresults)[2] <- "Count"
  ###Clean data###
  object@bugdata$Taxa <- stringr::str_trim(object@bugdata$Taxa)
  ##Aggregate taxa###
  object@bugdata <- ddply(object@bugdata, .(SampleID, StationCode, Taxa, LifeStageCode, Distinct),
                          plyr::summarise, Result = sum(Result))

  ###Match to STE###
  load(system.file("metadata.rdata", package="BMIMetrics"))
  otu_crosswalk <- metadata
  object@bugdata$STE <- rep(NA, length(object@bugdata$Taxa))
  object@bugdata$STE <- otu_crosswalk[match(object@bugdata$Taxa, otu_crosswalk$FinalID), as.character(effort)]
  object@bugdata$STE <- as.character(object@bugdata$STE)
  object@bugdata <- object@bugdata[which(object@bugdata$STE != "Exclude"), ]
  object@bugdata$STE[which(is.na(object@bugdata$STE))] <- "Missing"
  
  ###Calculate ambiguous###
  percent.ambiguous <- ddply(object@bugdata, "SampleID", function(df){
    100*sum(df$Result[df$STE == "Ambiguous"])/sum(df$Result)
  })
  taxa.ambiguous <- ddply(object@bugdata, "SampleID", function(df){
    100*length(df$Taxa[df$STE == "Ambiguous"])/length(df$Taxa)
  })
  object@ambiguous <- merge(percent.ambiguous, taxa.ambiguous, by="SampleID")
  names(object@ambiguous)[2:3] <- c("individuals", "taxa")
  object@bugdata <- object@bugdata[object@bugdata$STE != "Ambiguous",]
  object@bugdata <- ddply(object@bugdata, .(StationCode, SampleID, STE),
                          plyr::summarise, Result = sum(Result))
  return(object)
})    
            
setMethod("subsample", "oe", function(object, rand = sample.int(10000, 1)){
  if(nrow(object@ambiguous)==0){object <- nameMatch(object)}
  
  subsample <- lapply(seq(1 + rand, 20 + rand), function(i){
    commMatrix <- acast(object@bugdata, SampleID ~ STE, value.var="Result", fill=0,
                        fun.aggregate = sum, na.rm=TRUE)
    samp <- rep.int(400, nrow(commMatrix))
    samp[rowSums(commMatrix, na.rm=TRUE) < 400] <- 
      rowSums(commMatrix, na.rm=TRUE)[rowSums(commMatrix, na.rm=TRUE) < 400]
    set.seed(i)
    
    commMatrix <- vegan::rrarefy(commMatrix, samp)
    
    if(i == 1+ rand)
      melt(commMatrix)
    else
      melt(commMatrix)$value
  }
  )
  subsample <- do.call(cbind, subsample)
  colnames(subsample)[3:22] <- paste("Replicate", 1:20)
  subsample <- subsample[rowSums(subsample[, 3:22]) > 0, ]
  subsample$STE <- subsample$Var2
  subsample$SampleID <- subsample$Var1
  subsample <- subsample[, c(-1, -2)]
  object@oesubsample <- merge(object@bugdata, subsample, all.x=TRUE,
                              by=c("SampleID", "STE"))
  object@oesubsample[is.na(object@oesubsample)] <- 0
  return(object)
})

setMethod("rForest", "oe", function(object){
  if(nrow(object@oesubsample)==0){object <- subsample(object, rand = sample.int(10000, 1))}

  if(is.null(object@predictors$LogWSA))
    object@predictors$LogWSA <-log10(object@predictors$AREA_SQKM)
  if(is.null(object@predictors$AREA_SQKM))
    object@predictors$AREA_SQKM <- 10^(object@predictors$LogWSA)
  object@predictors$Log_P_MEAN <-  log10(object@predictors$P_MEAN + 0.0001)
  object@predictors <- merge(unique(object@oesubsample[, c("StationCode", "SampleID")]), object@predictors,
                             by="StationCode", all.x=FALSE)
  row.names(object@predictors) <- paste0(object@predictors$StationCode, "%", object@predictors$SampleID)
  
  iterate <- function(rep){
    patable <- dcast(data=object@oesubsample[, c("StationCode", "SampleID", "STE", rep)],
                     StationCode + SampleID ~ STE,
                     value.var=rep,
                     fun.aggregate=function(x)sum(x)/length(x))
    patable[is.na(patable)] <- 0
    row.names(patable) <- paste(patable$StationCode, "%", patable$SampleID, sep="")
    
    
    iresult <- model.predict.RanFor.4.2(bugcal.pa=oe_stuff[[2]],
                                        grps.final=oe_stuff[[3]],
                                        preds.final=oe_stuff[[4]],
                                        ranfor.mod=oe_stuff[[1]],
                                        prednew=object@predictors,
                                        bugnew=patable,
                                        Pc=0.5,
                                        Cal.OOB=FALSE)
    iresult$SampleID <- unique(object@predictors$SampleID)
    return(iresult)
  }
  object@fulliterations <- lapply(paste("Replicate", 1:20), function(i)iterate(i))
  labels <- strsplit(row.names(object@fulliterations[[1]]), "%")
  labels <- as.data.frame(matrix(unlist(labels), nrow=length(labels), byrow=T))
  object@fulliterations <- lapply(object@fulliterations, function(l){
    row.names(l)<-labels[, 2]
    l
  })
  object@iterations <- do.call(cbind, lapply(object@fulliterations, function(l)l$OoverE))
  oeresults <- data.frame(labels, apply(object@iterations, 1, mean))
  names(oeresults) <- c("StationCode", "SampleID", "OoverE")
  object@oeresults <- merge(oeresults, object@oeresults)
  object
})


setMethod("score", "oe", function(object)rForest(object))

setMethod("summary", "oe", function(object = "oe"){
  if(nrow(object@oeresults) != 0){
    object@oeresults
  } else
    show(object)
})
