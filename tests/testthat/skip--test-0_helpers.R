library(testthat)
library(BMIMetrics)
library(reshape2)
library(randomForest)

data(bugs_stations, package="CSCI")

context("Validity function")

mmi <- new("mmi", bugs_stations[[1]], bugs_stations[[2]])
oe <- new("oe", bugs_stations[[1]], bugs_stations[[2]])

test_that("Example data passes", {
  expect_that(validity(mmi), is_true())
  expect_that(validity(oe), is_true())
})

test_that("NAs throw errors in bug data", {
  expect_that(local({mmi@bugdata$StationCode[1] <- NA
  validity(mmi)}), prints_text("NAs found in bug data."))
  expect_that(local({mmi@bugdata$SampleID[1] <- NA
  validity(mmi)}), prints_text("NAs found in bug data."))
  expect_that(local({mmi@bugdata$FinalID[1] <- NA
  validity(mmi)}), throws_error())
  expect_that(local({mmi@bugdata$BAResult[1] <- NA
  validity(mmi)}), prints_text("NAs found in bug data."))
  expect_that(local({mmi@bugdata$LifeStageCode[1] <- NA
  validity(mmi)}), throws_error())
})

test_that("Missing bug columns", {
  expect_that(local({mmi@bugdata <- mmi@bugdata[, -1]
  validity(mmi)}), prints_text("Bug data missing column: StationCode"))
  expect_that(local({mmi@bugdata <- mmi@bugdata[, -2]
  validity(mmi)}), prints_text("Bug data missing column: SampleID"))
  expect_that(local({mmi@bugdata <- mmi@bugdata[, -3]
  validity(mmi)}), prints_text("Bug data missing column: FinalID"))
  expect_that(local({mmi@bugdata <- mmi@bugdata[, -4]
  validity(mmi)}), prints_text("Bug data missing column: BAResult"))
  expect_that(local({mmi@bugdata <- mmi@bugdata[, -5]
  validity(mmi)}), prints_text("Bug data missing column: LifeStageCode"))
  
})


test_that("Missing predictor columns", {
  expect_that(local({mmi@predictors <- mmi@predictors[, -1]
  validity(mmi)}), prints_text("Predictors missing column: StationCode"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -3]
  validity(mmi)}), prints_text("Predictors missing column: New_Long"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -4]
  validity(mmi)}), prints_text("Predictors missing column: New_Lat"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -5]
  validity(mmi)}), prints_text("Predictors missing column: SITE_ELEV"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -6]
  validity(mmi)}), prints_text("Predictors missing column: ELEV_RANGE"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -7]
  validity(mmi)}), prints_text("Predictors missing column: TEMP_00_09"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -8]
  validity(mmi)}), prints_text("Predictors missing column: PPT_00_09"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -9]
  validity(mmi)}), prints_text("Predictors missing column: SumAve_P"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -10]
  validity(mmi)}), prints_text("Predictors missing column: KFCT_AVE"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -11]
  validity(mmi)}), prints_text("Predictors missing column: BDH_AVE"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -12]
  validity(mmi)}), prints_text("Predictors missing column: MgO_Mean"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -13]
  validity(mmi)}), prints_text("Predictors missing column: P_MEAN"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -14]
  validity(mmi)}), prints_text("Predictors missing column: CaO_Mean"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -15]
  validity(mmi)}), prints_text("Predictors missing column: PRMH_AVE"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -16]
  validity(mmi)}), prints_text("Predictors missing column: S_Mean"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -18]
  validity(mmi)}), prints_text("Predictors missing column: LPREM_mean"))
  expect_that(local({mmi@predictors <- mmi@predictors[, -19]
  validity(mmi)}), prints_text("Predictors missing column: N_MEAN"))
})

test_that("No missing data in predictors", {
  expect_that(local({mmi@predictors[1, "StationCode"] <- NA
  validity(mmi)}), prints_text("NAs found in predictor data"))
  expect_that(local({mmi@predictors$New_Long[1] <- NA
  validity(mmi)}), prints_text("NAs found in predictor data"))
})

test_that("AREA_SQKM or LogWSA present", {
  expect_that(local({mmi@predictors <- mmi@predictors[, c(-2, -20)]
  validity(mmi)}), prints_text("Predictors must include a column AREA_SQKM or LogWSA"))
})
