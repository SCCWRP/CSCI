#' Read in reference data used to build CSCI models
#' @export
#' 
loadRefData <- function(){
  read.csv(system.file("Data", "refsamples.csv", package="CSCI"))
}