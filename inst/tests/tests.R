library(testthat)

test_that("creating filenames", {
  test_name<-make_filename("2013")
  expect_that(test_name, is_a("string"))
})
