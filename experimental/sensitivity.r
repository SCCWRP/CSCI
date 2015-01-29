library(ggplot2)

# bugs <- bugs_stations[[1]]
# stations <- bugs_stations[[2]]

predictorSensitivityMMI <- function(bugs, stations, pred, from, to, by, rand = sample.int(10000, 1)){
  stopifnot(length(pred) == 1)
  stopifnot(pred %in% names(stations))
  mmi <- new("mmi", bugs, stations)
  stopifnot(CSCI:::validity(mmi))
  mmi_s <- subsample(mmi, rand)
  
  score_list <- lapply(seq(from, to, by), function(val){
    mmi_s@predictors[, pred] <- val
    res <- score(mmi_s)@finalscore
    names(res) <- c("SampleID", paste0(pred, "_", val))
    res
  })
  ouput <- Reduce(function(x,y)merge(x, y, by="SampleID"), score_list)
  ouput.melt <- melt(ouput, id.vars="SampleID")
  ouput.melt$variable_val <- as.numeric(sapply(strsplit(as.character(ouput.melt$variable), "_"), function(x)tail(x, 1)))
  ouput.melt
}

predictorSensitivityE <- function(bugs, stations, pred, from, to, by, rand = sample.int(10000, 1)){
  stopifnot(length(pred) == 1)
  stopifnot(pred %in% names(stations))
  oe <- new("oe", bugs, stations)
  stopifnot(CSCI:::validity(oe))
  oe_s <- subsample(oe, rand)
  
  score_list <- lapply(seq(from, to, by), function(val){
    oe_s@predictors[, pred] <- val
    obj <- score(oe_s)
    res <- obj@fulliterations[[1]][, c("SampleID", "E")]
    res$StationCode <- obj@bugdata$StationCode[match(res$SampleID, obj@bugdata$SampleID)]
    res <- unique(res[, c("StationCode", "E")])
    names(res) <- c("StationCode", paste0(pred, "_", val))
    res
  })
  ouput <- Reduce(function(x,y)merge(x, y, by="StationCode"), score_list)
  ouput.melt <- melt(ouput, id.vars="StationCode")
  ouput.melt$variable_val <- as.numeric(sapply(strsplit(as.character(ouput.melt$variable), "_"), function(x)tail(x, 1)))
  ouput.melt
}

# mmi_temp <- predictorSensitivityMMI(bugs, stations, "TEMP_00_09", 0, 3000, 100)
# oe_temp <- predictorSensitivityE(bugs, stations, "TEMP_00_09", 0, 3000, 100)
# mmi_CaO_mean <- predictorSensitivityMMI(bugs, stations, "CaO_mean", 5, 50, 5)
# oe_lat <- predictorSensitivityE(bugs, stations, "New_Lat", 32, 40, 1)
# 
# ggplot(oe_lat, aes(variable_val, value, group=StationCode, colour=StationCode)) + geom_line()
# 
# ggplot(mmi_CaO_mean, aes(variable_val, value, group=SampleID, colour=SampleID)) + geom_line()
# 
# ggplot(oe_temp, aes(variable_val, value, group=StationCode, colour=StationCode)) + geom_line()
# 
# ggplot(mmi_temp, aes(variable_val, value, group=SampleID, colour=SampleID)) + geom_line()
