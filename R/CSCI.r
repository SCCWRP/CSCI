#' Score samples using the CSCI tool
#'
#' @description
#' A function that aggregates many of the steps involved in the scoring of the California Stream Condition Index
#' (CSCI) into a single function. These steps include data quality flagging, conversions of taxonomic names,
#' iterative subsampling (20 iterations), metric calculations, prediction of expected taxa and metric values,
#' scoring, and aggregation into a final index. Input data includes sample-wise raw, unprocessed taxonomy 
#' in a flat format, and station-wise predictor data in a crosstab format. See example data (\code{\link{bugs_stations}})
#' for reference. A complete description of the index is provided in Mazor et al. (in review). The O/E component 
#' of this function is adapted from John van Sickle's RIVPACS model building scripts.
#'
#' @details
#' A valid "bugs" data frame consists of the following columns: StationCode, SampleID, FinalID (i.e., taxa names),
#' LifeStageCode ("A", "L", "P", or "X"), BAResult (i.e., taxa counts), and Distinct (a positive integer where 
#' the taxonomist has indicated distinctiveness, else left blank or 0). Values for FinalID and LifeStageCode 
#' must conform to values from SWAMP lookup tables (\url{http://swamp.mpsl.mlml.calstate.edu/}). See CSCI guidance 
#' document for details on these fields.
#' 
#' A valid "stations" data frame consists of the following columns: StationCode (must match with same column in 
#' the "bugs" data frame), BDH_AVE, ELEV_RANGE, KFCT_AVE, P_MEAN, LogWSA, New_Lat, New_Long, PPT_00_09,
#' SITE_ELEV, SumAve_P, TEMP_00_09. See CSCI guidance document for details on these fields.
#' 
#' The data frames are also subject to the following constraints: no missing blank cells in any field in 
#' either data frame (except for the Distinct column); all values under StationCode in the "bugs" data frame 
#' must be represented under StationCode in the "stations" data frame; every SampleID must be associated 
#' with only a single StationCode; no duplicated data in either data frame (e.g., every combination of 
#' the SampleID, FinalID, LifeStageCode, and Distinct should be unique in the "bugs" data frame).
#' 
#' In order to produce replicable results, the RNG seed can be controlled using the rand argument. Any integer may be
#' entered, which will be passed to \code{\link{set.seed}}. 
#'
#' @param bugs A data frame with BMI data (see details)
#' @param stations A data frame with environmental data, one row per station (see details)
#' @param rand An integer to control the random number generator (RNG) seed for the subsampling. By default set to
#' \code{sample.int(10000, 1)}
#' @param purge A logical value indicating whether FinalID/LifeStageCode combinations not in the internal
#' database should be removed from the data. If TRUE, purged taxa will be listed in output. If FALSE (default),
#' any unrecognized combinations will cause an error.
#' @param distinct A logical value to overwrite the \code{Distinct} column in \code{bugs} with \code{NA} values, default (\code{FALSE}) is leave as is.
#' @export
#' 
#' @return 
#' A list of data frames that serve as reports in varying detail:
#' \item{core}{A summary of the CSCI results, and data quality flags, averaged across 20 iterations.}
#' \item{Suppl1_mmi}{A detailed breakdown of the results of the MMI component of the
#'  CSCI, averaged across 20 iterations.}
#' \item{Suppl1_grps}{Probability of biotic group membership in a SampleID by Group format}
#' \item{Suppl1_OE}{A detailed breakdown of the results of the O/E component of the CSCI,
#'  averaged across 20 iterations. Capture probabilities and mean abundances of each OTU are provided.}
#' \item{Suppl2_mmi}{Similar to Suppl1_mmi, except broken down by iteration}
#' \item{Suppl2_OE}{Similar to Suppl1_OE, except brown down by replicatesiteration. Iteration-wise O/E scores are also provided.}
#' 
#' @author Mark Engeln \email{marke@@sccwrp.org}
#' @author Raphael Mazor \email{raphaelm@@sccwrp.org}
#' 
#' @examples
#' data(bugs_stations) #A list of two data frames: bugs and stations
#' results <- CSCI(bugs = bugs_stations[[1]], stations = bugs_stations[[2]])
#' ls(results) #see all the components of the report
#' results$core #see the core report
#' 
#' @references R.D. Mazor, A. Rehn, P. R. Ode, M. Engeln, K. Schiff. (2013) \emph{Development
#' of a bioassessment tool for streams in heterogeneous regions: Accommodating environmental complexity
#' through site specificity in the California Stream Condition Index}. In review.
#' 
#' @references J. Van Sickle. (2010) \emph{R code to make predictions of O/E 
#' for a new set of sites based on a Random Forest predictive model} (Version 4.2)[R script]
#' 
#' @seealso \code{\link{bugs_stations}}
CSCI <- function (bugs, stations, rand = sample.int(10000, 1), purge = FALSE, distinct = TRUE) {
  options(stringsAsFactors=FALSE)
  
  if(purge) {
    load(system.file("metadata.rdata",  package="BMIMetrics"))
    IDStage <- paste(bugs$FinalID, bugs$LifeStageCode)
    good <- IDStage %in% paste(metadata$FinalID, metadata$LifeStageCode)
    purged <- unique(IDStage[!good])
    bugs <- bugs[good, ]
  }
  
  # make distinct NA 
  if(!distinct) bugs$Distinct <- NA
  
  names(bugs) <- csci_bugs_col[match(toupper(names(bugs)), toupper(csci_bugs_col))]
  bugs <- ddply(bugs, names(bugs)[names(bugs) != "BAResult"], plyr::summarise,
                BAResult = sum(BAResult))
  
  caseFix <- data.frame(upper = c(toupper(csci_predictors), "AREA_SQKM", "STATIONCODE"), 
                        correct = c(csci_predictors, "AREA_SQKM", "StationCode"))
  predCols <- toupper(names(stations)) %in% caseFix$upper
  names(stations)[predCols] <- caseFix$correct[match(toupper(names(stations)[predCols]),
                                                     caseFix$upper)]
  
  stations$LogWSA <- if(!is.null(stations$AREA_SQKM))log10(stations$AREA_SQKM)
  
  stations <- stations[, names(stations) %in% c("StationCode",
                                                csci_predictors )]
  mmi <- new("mmi", bugs, stations)
  valid <- validity(mmi)
  
  if(valid != "pass")stop(valid)
  
  mmi_s <- subsample(mmi, rand)
  mmi_s <- score(mmi_s)
  
  oe <- new("oe", bugs, stations)
  oe_s <- subsample(oe, rand)
  oe_s <- score(oe_s)
  
  res <- new("metricMean", mmi_s, oe_s)
  report <- summary(res)
  if(purge)report$purged <- purged
  report
}
