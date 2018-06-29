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
#' @param purge If true, a data frame will be returned
#' with problematic rows removed. Else, the original data frame
#' will be returned with a new column, \code{fixFinalID}, with 
#' T/F values indicating rows with the FinalID (T) to fix
#' @param trace logical indicating if warning messages indicating problem
#' rows are printed to the console
#' 
#' @export
#' 
#' @examples 
#' 
#' # load bug, station data
#' data(bugs_stations) 
#' 
#' # create some wrong FinalID values in bug data
#' wrongdata <- bugs_stations[[1]]
#' wrongdata$FinalID <- as.character(wrongdata$FinalID)
#' wrongdata$FinalID[c(1, 15, 30)] <- c('idwrong1', 'idwrong2', 'idwrong3')
#' 
#' \dontrun{
#' # default, purge nothing
#' # indicates wrong rows and FinalIDs, new column fixFinalID with T/F for wrong/right
#' cleanData(wrongdata)
#' 
#' # CSCI function returns the same as above if purge is F and incorrect FinalID are found (default)
#' CSCI(wrongdata, bugs_stations[[2]])
#' 
#' # purge
#' # indicates wrong rows and FinalIDs, removes from output
#' cleanData(wrongdata, purge = TRUE)
#' 
#' # create some wrong lifestagecodes, only applies if purge is T
#' wrongdata$LifeStageCode <- as.character(wrongdata$LifeStageCode)
#' wrongdata$LifeStageCode[c(2, 16, 31)] <- c('lscwrong1', 'lscwrong2', 'lscwrong3')
#' 
#' # purge, notice new warnings
#' cleanData(wrongdata, purge = TRUE)
#' }


cleanData <- function(data, purge = FALSE, trace = TRUE){
  
  # load BMI metadata with FinalID, lifestagecode, etc
  meta <- loadMetaData()
  
  # get bug FinalID values from input data
  data$FinalID <- str_trim(data$FinalID)
  
  # fix final id cases in input data using metadata
  casefix <- meta$FinalID[match(toupper(data$FinalID),
                                toupper(meta$FinalID))]
  data$FinalID[!is.na(casefix)] <- casefix[!is.na(casefix)]
  
  # logical vector of FinalID in input data that are not in metadata  
  nomatch <- !(data$FinalID %in% meta$FinalID)
  
  # remove offending records in input data with incorrect FinalID
  # or if no purge is false and all records found, do the same
  if(purge | (!purge & sum(nomatch) == 0)){
    
    # console warning if purge is true and incorrect FinalID present
    if(trace & purge & any(nomatch))
      warning('Incorrect FinalIDs removed from input data, rows ',
              paste(which(nomatch), collapse = ', '), ', values ',
              paste(data$FinalID[nomatch], collapse = ', ')
      )

    # clean input data with FinalID in metadata
    # or removes none if all FinalID present in data
    data <- data[!nomatch, ]

    # logical vector for life stage codes in clean data that are matched in metadata
    lsc <- with(data, paste(FinalID, LifeStageCode)) %in%
      with(meta, paste(FinalID, LifeStageCode))

    # console warning if incorrect LifeStagecode values were found
    if(trace & any(!lsc))
      warning('LifeStageCodes incorrect and replaced with defaults, rows ',
              paste(rownames(data)[!lsc], collapse = ', '), ', replaced values for ',
              paste(data[!lsc, 'FinalID'], data[!lsc, 'LifeStageCode'], collapse = ', ')
      )
    
    # replace lifestagecodes with defaults if incorrect for correct taxa
    data$LifeStageCode[!lsc] <- meta$DefaultLifeStage[match(data$FinalID[!lsc], 
                                                         meta$FinalID)]

  # purge is F and some FinalID not found
  } else {
    
    # add new column with T/F showing which ones to fix
    data$fixFinalID <- nomatch
    
    if(trace)
      warning('Incorrect FinalIDs retained for rows ' , paste(which(nomatch), collapse = ', '), 
              ', values ', paste(data$FinalID[nomatch], collapse = ', '), 
              ', see column fixFinalID')
    
  }

  return(data)
  
}