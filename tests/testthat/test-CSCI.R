test_that("CSCI runs on bugs_stations data and produces previously produced headers", {
  data("bugs_stations")
  results <- suppressWarnings(CSCI(bugs = bugs_stations[[1]], stations = bugs_stations[[2]]))
  expect_snapshot(ls(results))
})
