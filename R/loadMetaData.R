#' Read in reference taxonomy data used to build CSCI models
#' @import BMIMetrics
#' @export
#' @details
#' This function loads a data frame containing all taxonomic data at reference sites used to calibrate and validate the CSCI, including their sample date, 
#' FinalID, BAResult, LifeStageCode, SiteSet (RefCal, RefVal), and SAFIT designations.
loadMetaData <- function(metadata.year = 2025){
  BMIMetrics::loadMetaData(metadata.year = metadata.year)
}