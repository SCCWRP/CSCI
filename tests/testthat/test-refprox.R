test_that("refprox function generates expected data for bug_stations[[2]][1, ]", {
  results = refprox(bugs_stations[[2]][1, ], output = "dat")
  expect_snapshot(results)
})

test_that("refprox function generates expected data for bug_stations[[2]][2, ]", {
  results = refprox(bugs_stations[[2]][2, ], output = "dat")
  expect_snapshot(results)
})

test_that("refprox function generates expected data for bug_stations[[2]][3, ]", {
  results = refprox(bugs_stations[[2]][3, ], output = "dat")
  expect_snapshot(results)
})
