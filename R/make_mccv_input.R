#' @title Make inputs for Monte-Carlo cross-validation
#'
#' @description the function creates a dataset that contains
#'   input values for the function make_mccv_output().
#'
#' @param n_split the desired number of MCCV iterations. Each split
#'   will divide the `intermacs_fake` data into a training and testing
#'   set, with the testing set containing `test_proportion`% of the data.
#'
#' @param n_row the total number of rows in the data. For `intermacs_fake`,
#'   this number is 10,000.
#'
#' @param md_strat a character vector with each value indicating a specific
#'   strategy to impute missing data.
#'
#' @param outcome a character vector with each value indicating a specific
#'   outcome to develop risk prediction models for.
#'
#' @param additional_missing_pct a numeric vector with each value indicating
#'   a specific percentage of missing values to add to each predictor prior
#'   to imputing missing values.
#'
#' @details in order to assess imputation accuracy, `additional_missing_pct`
#'   must be set to a value > 0. However, to avoid getting errors or
#'   instability in the imputation procedures, `additional_missing_pct`
#'   probably should not be > 40.
#'
make_mccv_input <- function(n_split,
                           n_row,
                           md_strat,
                           outcome,
                           additional_missing_pct,
                           test_proportion = 1/2) {

  # compute the number of rows to include in the testing data
  # round to the nearest integer
  n_test <- round(n_row * test_proportion)

  # create the test index, which is used to split
  # the fake INTERMACS data into train/test sets
  # throughout Monte-Carlo cross-validation.
  test_index <- vector(mode = 'list', length = n_split)

  # sample the testing rows at random, store each sample in test_index
  for(i in seq_along(test_index))
    test_index[[i]] <- sample(x = n_row,
                              replace = FALSE,
                              size = n_test)

  # the md_strat, outcome, and additional_missing_pct
  # should all be crossed with each other, i.e., every
  # single pairwise combination should be included.
  # However, each combination should be run through
  # the exact same training/testing split. Therefore,
  # we include interation in sim_parms below, and then
  # we join sim_parms with test_index to assign the
  # exact same train/test indices to sim parameters
  # in the output.

  sim_parms <- expand_grid(
    iteration = seq(n_split),
    md_strat = md_strat,
    outcome = outcome,
    additional_missing_pct = additional_missing_pct
  )

  test_index %>%
    enframe(name = 'iteration',
            value = 'test_index') %>%
    left_join(sim_parms,
              by = 'iteration')

}
