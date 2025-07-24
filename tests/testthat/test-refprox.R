test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})
test_that("refprox function output is consistent for bug_stations[[2]][1, ]", {
  results = refprox(bugs_stations[[2]][1, ], output = "dat")
  # Set a random seed for reproducibility of slice_sample below
  set.seed(1)
  # Get a subset of the output so the snapshot is not too large
  results = results |> dplyr::slice_sample(n = 25)
  expect_snapshot(results)
})

test_that("refprox function output is consistent for bug_stations[[2]][2, ]", {
  results = refprox(bugs_stations[[2]][2, ], output = "dat")
  # Set a random seed for reproducibility of slice_sample below
  set.seed(1)
  # Get a subset of the output so the snapshot is not too large
  results = results |> dplyr::slice_sample(n = 25)
  expect_snapshot(results)
})

test_that("refprox function output is consistent for bug_stations[[2]][3, ]", {
  results = refprox(bugs_stations[[2]][3, ], output = "dat")
  # Set a random seed for reproducibility of slice_sample below
  set.seed(1)
  # Get a subset of the output so the snapshot is not too large
  results = results |> dplyr::slice_sample(n = 25)
  expect_snapshot(results)
})
