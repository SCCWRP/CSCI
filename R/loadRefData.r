#' Read in reference data used to build CSCI models
#' @export
#' @details
#' This function loads a data frame containing all reference sites used to calibrate the CSCI, including their sample date, 
#' biotic group ID, O, E, O/E, MMI scores, observed metrics, predicted metrics, and scored metrics.
loadRefData <- function(){
  read.csv(system.file("Data", "refsamples.csv", package="CSCI"))
}