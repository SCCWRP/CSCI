#' Score samples using the CSCI tool
#'
#' @description
#' Function to find or remove errors in BMI data
#' 
#' @details
#' This functions checks for several types of common errors:
#' incorrect case in FinalID names,
#' FinalIDs that are missing from the internal database,
#' FinalIDs with inappropriate life stage codes (e.g., non-insects
#' with a LifeStageCode other than 'X').
#' 
#' This functions requires that the dataframe contains at least two columns:
#' FinalID and LifeStageCode.
#' 
#' @param data A data frame with BMI data (see details)
#' @param purge If true (default) a data frame will be returned
#' with problematic rows removed. Else, a report of problems will be
#' returned.
#' @export
#' 



cleanData <- function(data, purge=TRUE){
  meta <- loadMetaData()
  
  data$FinalID <- str_trim(data$FinalID)
  casefix <- meta$FinalID[match(toupper(data$FinalID),
                                toupper(meta$FinalID))]
  data$FinalID[!is.na(casefix)] <- casefix[!is.na(casefix)]
    
  nomatch <- !(data$FinalID %in% meta$FinalID)
  if(!purge)
    bad <- data[nomatch, ]
  
  data <- data[!nomatch, ]

  lsc <- with(data, paste(FinalID, LifeStageCode)) %in%
    with(meta, paste(FinalID, LifeStageCode))
  
  data$LifeStageCode[!lsc] <- meta$DefaultLifeStage[match(data$FinalID[!lsc], 
                                                       meta$FinalID)]
  
  if(!purge)
    data <- rbind(data, bad)
  
  data
}