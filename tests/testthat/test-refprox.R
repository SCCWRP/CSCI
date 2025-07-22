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

test_that("refprox function generates expected data for CentralValley_Foothill_stations3 data", {
  input_data_path = test_path("testdata", "refprox_CentralValley_Foothill_stations3_data.rds")
  input_data = input_data_path |> readr::read_rds()
  results = input_data |> refprox(output = "dat")
  # Set a random seed for reproducibility of slice_sample below
  set.seed(1)
  # Get a subset of the output so the snapshot is not too large
  results = results |> dplyr::slice_sample(n = 25)
  expect_snapshot(results)
})

test_that("refprox function generates expected data for 2024_R9_sites2 data", {
  input_data_path = test_path("testdata", "refprox_2024_R9_sites2.rds")
  input_data = input_data_path |> readr::read_rds()
  results = input_data |> refprox(output = "dat")
  # Set a random seed for reproducibility of slice_sample below
  set.seed(1)
  # Get a subset of the output so the snapshot is not too large
  results = results |> dplyr::slice_sample(n = 25)
  expect_snapshot(results)
})

test_that("refprox function generates expected data for 901NP9BWR_site data", {
  input_data_path = test_path("testdata", "refprox_901NP9BWR_site.rds")
  input_data = input_data_path |> readr::read_rds()
  results = input_data |> refprox(output = "dat")
  # Set a random seed for reproducibility of slice_sample below
  set.seed(1)
  # Get a subset of the output so the snapshot is not too large
  results = results |> dplyr::slice_sample(n = 25)
  expect_snapshot(results)
})
