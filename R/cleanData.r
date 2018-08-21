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
#' @return 
#' If \code{msgs = FALSE} (default), a data frame is returned that is either the same 
#' as the input if all checks have passed or a purged (\code{purge = TRUE}) or non-purged 
#' \code{purge = FALSE}) dataset with additional columns for \code{FinalID} and 
#' \code{LifeStageCode}.  If \code{msgs = TRUE}, a two-element list is returned, where 
#' the first element \code{data} is the data frame that would be returned if \code{msgs = FALSE}
#' and the second element is \code{msg} with a concatenated character string of messages
#' indicating if all checks have passed and if not, which issues were encountered.  In the 
#' latter case, row numbers in the messages indicate which observations in the input data 
#' had issues.
#' 
#' @param data A data frame with BMI data (see details)
#' @param purge If true, a data frame will be returned
#' with problematic rows removed, see details. 
#' @param msgs logical, if \code{FALSE} a purged or non-purged data frame, if \code{TRUE} a
#' two-element list with the data frame and concated list of messages, see the return value
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
#' # function returns input data
#' cleanData(bugs_stations[[1]])
#' 
#' # same as above but retrieve msgs
#' cleanData(bugs_stations[[1]], msgs = TRUE)
#' 
#' # create some wrong FinalID values in bug data
#' wrongdata <- bugs_stations[[1]]
#' wrongdata$FinalID <- as.character(wrongdata$FinalID)
#' wrongdata$FinalID[c(1, 15, 30)] <- c('idwrong1', 'idwrong2', 'idwrong3')
#' 
#' # default, purge nothing
#' # new columns fixedLifeStageCode, ProblemFinalID with T/F for wrong/right
#' cleanData(wrongdata)
#' 
#' # purge
#' # removes from output
#' cleanData(wrongdata, purge = TRUE)
#' 
#' # create some wrong lifestagecodes, only applies if purge is T
#' wrongdata$LifeStageCode <- as.character(wrongdata$LifeStageCode)
#' wrongdata$LifeStageCode[c(2, 16, 31)] <- c('lscwrong1', 'lscwrong2', 'lscwrong3')
#' 
#' # no purge
#' cleanData(wrongdata)
#' 
#' #compare with purge
#' cleanData(wrongdata, purge = TRUE)
#' 
#' # with messages
#' cleanData(wrongdata, purge = TRUE, msgs = TRUE)
#' }


cleanData <- function(data, purge = FALSE, msgs = FALSE){

  # placeholder for msgs
  msg <- NULL
  
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
  
    out <- data
    if(msgs){
      
      msg <- c(msg, 'Data already clean')
      out <- list(data = out, msg = msg)
    
    } 
    
    return(out)
    
  }
  
  # add new column with T/F showing which lifestagecodes were wrong
  data$fixedLifeStageCode <- nolsc
  
  # add new column with T/F showing which finalIDs to fix
  data$problemFinalID <- nomatch
  
  # msg for incorrect lsc
  if(msgs & any(nolsc))
    msg <- c(msg, 
             paste0('LifeStageCodes incorrect and replaced with defaults, rows ',
              paste(rownames(data)[nolsc], collapse = ', '), ', replaced values for ',
              paste(data[nolsc, 'FinalID'], data[nolsc, 'LifeStageCode'], collapse = ', '), 
              ', see column fixedLifeStageCode'
             ))

  # msg and incorrect FinalID present
  if(msgs & any(nomatch))
    msg <- c(msg, 
             paste0('Unrecognized FinalIDs, rows ',
                    paste(which(nomatch), collapse = ', '), ', values ',
                    paste(data$FinalID[nomatch], collapse = ', ')
             ))

  # replace lifestagecodes with defaults if incorrect for correct taxa
  data$LifeStageCode[nolsc] <- meta$DefaultLifeStage[match(data$FinalID[nolsc], 
                                                           meta$FinalID)]
  
  # remove offending records in input data with incorrect FinalID
  if(purge){
    data <- data[!nomatch, ]
    msg <- c(msg, 'Unrecognized FinalIDs purged')
  }
  
  # final output
  out <- data
  if(msgs) 
    out <- list(
      data = out, 
      msg = msg
      )
  
  return(out)
  
}