test_that("check_type<_bundle>() works", {

  test_obj <- "sdf"
  test_obj2 <- 123

  # numeric
  expect_error(check_type("numeric", test_obj),
               "Argument `test_obj` requires numeric input",
               ignore.case = TRUE)

  expect_error(check_type_bundle("numeric", test_obj2, test_obj),
               "Argument `test_obj` requires numeric input",
               ignore.case = TRUE)

  # character
  expect_silent(check_type("character", test_obj))

  expect_error(check_type_bundle("character", test_obj2, test_obj),
               "Argument `test_obj2` requires character input",
               ignore.case = TRUE)

  # logical
  expect_error(check_type("logical", test_obj),
               "Argument `test_obj` requires logical input",
               ignore.case = TRUE)

  expect_error(check_type_bundle("logical", test_obj, test_obj2),
               "Argument `test_obj` requires logical input",
               ignore.case = TRUE)

})


test_that("is_length_one<_bundle>() works", {

  test_obj <- NULL
  test_obj2 <- 123

  expect_error(is_length_one(test_obj),
               "Argument `test_obj` requires input with length equals to 1",
               ignore.case = TRUE)

  expect_error(is_length_one_bundle(test_obj2, test_obj),
               "Argument `test_obj` requires input with length equals to 1",
               ignore.case = TRUE)

})


test_that("is_non_negative<_bundle>() works", {

  test_obj <- -1
  test_obj2 <- 2

  expect_error(is_non_negative(test_obj),
               "Argument `test_obj` requires non-negative input",
               ignore.case = TRUE)

  expect_error(is_non_negative_bundle(test_obj2, test_obj),
               "Argument `test_obj` requires non-negative input",
               ignore.case = TRUE)

})


test_that("is_positive<_bundle>() works", {

  test_obj <- 0
  test_obj2 <- 2

  expect_error(is_positive(test_obj),
               "Argument `test_obj` requires positive input",
               ignore.case = TRUE)

  expect_error(is_positive_bundle(test_obj2, test_obj),
               "Argument `test_obj` requires positive input",
               ignore.case = TRUE)

})


test_that("check_in() works", {

  test_obj <- "a"

  expect_error(check_in(c("b", "c"), test_obj),
               'Argument `test_obj` only accepts one of these options: "b", "c"',
               ignore.case = TRUE)

  expect_silent(check_in(c("a", "b", "c"), test_obj))

})


test_that("is_not_null<_bundle>() works", {

  test_obj <- NULL
  test_obj2 <- 1

  expect_error(is_not_null(test_obj),
               'Argument `test_obj` requires valid column name',
               ignore.case = TRUE)

  expect_error(is_not_null_bundle(test_obj2, test_obj),
               'Argument `test_obj` requires valid column name',
               ignore.case = TRUE)

})

test_that("equal_length() works", {

  test_obj <- c(1,2,3)
  test_obj2 <- c("sdf", "d", "e", "er")

  expect_error(equal_length(test_obj, test_obj2),
               'Arguments `test_obj`, `test_obj2` require names of columns with equal lengths',
               ignore.case = TRUE)


})


test_that("check_numeric_column<_bundle>() works", {

  test_obj <- c(1,2,3)
  test_obj2 <- c("sdf", "d", "e", "er")

  expect_silent(check_numeric_column(test_obj))

  expect_error(check_numeric_column_bundle(test_obj, test_obj2),
               'Argument `test_obj2` requires a name of a numeric column with length greater than 0',
               ignore.case = TRUE)


})


test_that("check_integer_timeID() works", {

  test_obj <- c(1L,2L,3L)
  test_obj2 <- c("sdf", "d", "e", "er")

  expect_silent(check_integer_timeID(test_obj))

  expect_error(check_integer_timeID(test_obj2),
               'Internal variable timeID is not an integer vector. A proper transformation for the time column is needed. Consider to provide proper values to Arguments `timeUnit` and `timeStep` to perform the transformation',
               ignore.case = TRUE)


})


test_that("any_null_bool() works", {

  test_obj <- c(1L,2L,3L)
  test_obj2 <- NULL

  expect_true(any_null_bool(test_obj, test_obj2))

  expect_false(any_null_bool(test_obj))


})


test_that("all_null_bool() works", {

  test_obj <- c(1L,2L,3L)
  test_obj2 <- NULL

  expect_false(all_null_bool(test_obj, test_obj2))

  expect_true(all_null_bool(test_obj2))


})


test_that("all_noise_bool() works", {

  test_obj <- c(1L,2L,3L)
  test_obj2 <- c(-1,-1,-1)

  expect_false(all_noise_bool(test_obj))

  expect_true(all_noise_bool(test_obj2))


})
