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
#' \code{FinalID} and \code{LifeStageCode}.
#' 
#' The default value \code{purge = FALSE} will not remove rows where the FinalIDs
#' are incorrect, otherwise they are removed.  In the former example, a new
#' column \code{problemFinalID} is added as a T/F vector indicating which 
#' rows are incorrect.  For both \code{purge = FALSE} and \code{purge = TRUE}, 
#' rows with correct FinalID values are also checked for correct life stage codes
#' in the \code{LifeStageCode} column.  Values are replaced with default values 
#' in a lookup table provided with the package if they are incorrect.  A new 
#' column \code{fixedLifeStageCode} is added as a T/F vector indicating which 
#' rows were fixed for an incorrect life stage code. 
#' 
#' The argument \code{trace} specifies if warnings are returned to the console 
#' that provide diagnostics on rows with incorrect \code{FinalID} or \code{LifeStageCode}
#' values. Row numbers apply to input data and will differ from output data if rows
#' are purged. 
#' 
#' @param data A data frame with BMI data (see details)
#' @param purge If true, a data frame will be returned
#' with problematic rows removed, see details. 
#' @param trace logical indicating if warnings 
#' are printed to the console
#' 
#' @export
#' 
#' @examples 
#' 
#' # load bug, station data
#' data(bugs_stations) 
#' 
#' \dontrun{
#' 
#' # function return input data if no errors
#' cleanData(bugs_stations[[1]])
#' 
#' # create some wrong FinalID values in bug data
#' wrongdata <- bugs_stations[[1]]
#' wrongdata$FinalID <- as.character(wrongdata$FinalID)
#' wrongdata$FinalID[c(1, 15, 30)] <- c('idwrong1', 'idwrong2', 'idwrong3')
#' 
#' # default, purge nothing
#' # indicates wrong rows and FinalIDs, new column fixFinalID with T/F for wrong/right
#' cleanData(wrongdata)
#' 
#' # purge
#' # indicates wrong rows and FinalIDs, removes from output
#' cleanData(wrongdata, purge = TRUE)
#' 
#' # create some wrong lifestagecodes, only applies if purge is T
#' wrongdata$LifeStageCode <- as.character(wrongdata$LifeStageCode)
#' wrongdata$LifeStageCode[c(2, 16, 31)] <- c('lscwrong1', 'lscwrong2', 'lscwrong3')
#' 
#' # notice new warnings, no purge
#' cleanData(wrongdata)
#' 
#' #compare with purge
#' cleanData(wrongdata, purge = TRUE)
#' }


cleanData <- function(data, purge = FALSE, trace = TRUE){

  # load BMI metadata with FinalID, lifestagecode, etc
  meta <- BMIMetrics::loadMetaData()
  
  # get bug FinalID values from input data
  data$FinalID <- stringr::str_trim(data$FinalID)
  
  # fix final id cases in input data using metadata
  casefix <- meta$FinalID[match(toupper(data$FinalID),
                                toupper(meta$FinalID))]
  data$FinalID[!is.na(casefix)] <- casefix[!is.na(casefix)]
  
  # logical vector of FinalID in input data that are not in metadata  
  nomatch <- !(data$FinalID %in% meta$FinalID)
  
  # logical vector for life stage codes in clean data that are not matched in metadata
  nolsc <- !with(data, paste(FinalID, LifeStageCode)) %in%
    with(meta, paste(FinalID, LifeStageCode)) & data$FinalID %in% meta$FinalID
  
  # exit if data checks are good
  if(!any(nomatch, nolsc)){
  
    if(trace) warning('Data already clean!')
    return(data)
    
  }
    
  # add new column with T/F showing which lifestagecodes were wrong
  data$fixedLifeStageCode <- nolsc
  
  # warning for incorrect lsc
  if(trace & any(nolsc)){
    warning('LifeStageCodes incorrect and replaced with defaults, rows ',
            paste(rownames(data)[nolsc], collapse = ', '), ', replaced values for ',
            paste(data[nolsc, 'FinalID'], data[nolsc, 'LifeStageCode'], collapse = ', '), 
            ', see column fixedLifeStageCode'
    )
  
  # replace lifestagecodes with defaults if incorrect for correct taxa
  data$LifeStageCode[nolsc] <- meta$DefaultLifeStage[match(data$FinalID[nolsc], 
                                                           meta$FinalID)]
    
  }
  
  # remove offending records in input data with incorrect FinalID
  # or if no purge is false and all records found, do the same
  if(purge){
    
    # console warning if purge is true and incorrect FinalID present
    if(trace & any(nomatch))
      warning('Unrecognized FinalIDs removed from input, rows ',
              paste(which(nomatch), collapse = ', '), ', values ',
              paste(data$FinalID[nomatch], collapse = ', ')
      )
    
    # clean input data with FinalID in metadata
    # or removes none if all FinalID present in data
    data <- data[!nomatch, ]

  # purge is F
  } else {
    
    # add new column with T/F showing which finalIDs to fix
    data$problemFinalID <- nomatch
    
    # console warning if purge is false and incorrect FinalID present
    if(trace & any(nomatch))
      warning('Unrecognized FinalIDs retained, rows ' , paste(which(nomatch), collapse = ', '), 
              ', values ', paste(data$FinalID[nomatch], collapse = ', '), 
              ', see column problemFinalID')
    
  }

  return(data)
  
}