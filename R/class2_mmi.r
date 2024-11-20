setClass("mmi", representation(subsample = "list",
                               metrics = "data.frame",
                               modelprediction = "data.frame",
                               result = "data.frame",
                               finalscore = "data.frame",
                               datalength = "numeric",
                               summary ="data.frame",
                               metadata.year="numeric"
                               ),
         contains="bugs",
         prototype = list(subsample = data.frame(),
                          metrics = data.frame(),
                          modelprediction = data.frame(),
                          result = data.frame(),
                          finalscore = data.frame(),
                          datalength = numeric(),
                          summary = data.frame(),
                          metadata.year=2025
         )
)

setMethod(
  "initialize", "mmi",
  function(.Object, bugdata = NULL, predictors = NULL, metadata.year = 2025, ...) {
    .Object <- callNextMethod(.Object, ...)
    if (!is.null(bugdata)) .Object@bugdata <- bugdata
    if (!is.null(predictors)) .Object@predictors <- predictors
    .Object@metadata.year <- metadata.year
    return(.Object)
  }
)


setMethod("nameMatch", "mmi", function(object){
  bugs <- BMIMetrics::BMI(object@bugdata, object@metadata.year)
  class(bugs) <- rev(class(bugs))
  object@bugdata <- bugs
  return(object)
})

setMethod("subsample", "mmi", function(object, rand = sample(10000, 1)){
  if(is.null(object@bugdata$distinct)){object <- nameMatch(object)}
  

  object@subsample <- lapply(seq(1 + rand, 20 + rand), function(i){
    set.seed(i)
    BMIMetrics::sample(object@bugdata, object@metadata.year)
  })
  return(object)
})

setMethod("metrics", "mmi", function(object){
  if(length(object@subsample) == 0){object <- subsample(object, rand = sample.int(10000, 1))}
  
  metricsList <- lapply(1:20, function(i) {
    x <- object@subsample[[i]]
    results <- BMIMetrics::BMICSCI(aggregate(x), effort=1)[c("SampleID", csci_metrics)]
    names(results)[-1] <- paste0(names(results)[-1], "_", i)
    results
    })
  result.reduce <- Reduce(function(x,y)merge(x,y, by="SampleID"), metricsList)
  names <- csci_metrics
  means <- sapply(names, function(names)apply(result.reduce[, grep(names, names(result.reduce))], 1, mean))
  if(all(class(means) != "matrix"))means <- t(means)
  object@metrics <- cbind(result.reduce, means)
  return(object)
})

setMethod("rForest", "mmi", function(object){
  if(nrow(object@metrics) == 0){object <- metrics(object)}
  
  object@predictors <- merge(unique(object@bugdata[, c("StationCode", "SampleID")]), object@predictors, by="StationCode", all.x=TRUE)
  object@modelprediction <- as.data.frame(matrix(NA, nrow = nrow(object@predictors)))
  
  if(is.null(object@predictors$LogWSA))
    object@predictors$LogWSA <-log10(object@predictors$AREA_SQKM)
  object@predictors$Log_P_MEAN <-  log10(object@predictors$P_MEAN + 0.00001)
  
  res <- sapply(final_forests, function(rf) randomForest:::predict.randomForest(rf, object@predictors))
  if(all(class(res)!="matrix"))res <- data.frame(t(res[1:8]))
  
  object@modelprediction <- as.data.frame(res)
  names(object@modelprediction) <- csci_metrics
  object@modelprediction$V1 <- unique(object@predictors$SampleID)
  return(object)
})

setMethod("score", "mmi", function(object){
  if(nrow(object@modelprediction) == 0){object <- rForest(object)}

  col_names <- csci_metrics
  object@metrics <- object@metrics[order(object@metrics$SampleID), ]
  object@modelprediction <- object@modelprediction[order(object@modelprediction$V1), ]
  
  object_result <- sapply(col_names, function(col){
    result <- (object@metrics[, col] - object@modelprediction[, col] - maxmin[1, col])/(maxmin[2, col] - maxmin[1, col])
    result <- ifelse(result > 1, 1, ifelse(
      result < 0, 0, result))
    result
  })
  if(all(class(object_result) != "matrix"))object_result <- t(object_result)
  object@result <- data.frame(object_result)
  names(object@result) <- paste0(col_names, "_score")
  object@finalscore <- data.frame(unique(object@modelprediction$V1), 
                                  apply(object@result, 1, mean)/0.628016448)
  d <- data.frame(object@finalscore, object@metrics[, col_names], 
                  object@modelprediction, object@result)
  d <- merge(unique(object@bugdata[, c("StationCode", "SampleID")]), d, by.x="SampleID", by.y="unique.object.modelprediction.V1.")
  colnames(d)[1:3] <- c("SampleID", "StationCode", "MMI_Score")
  object@summary <- d
  
  return(object)
})

setMethod("summary", "mmi", function(object = "mmi"){
  if(nrow(object@result) != 0){
    object@summary
  } else
    show(object)
})

            
            