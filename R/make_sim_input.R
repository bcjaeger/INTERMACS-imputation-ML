#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param n_split
#' @param n_row
#' @param md_strat
#' @param outcome
#' @param additional_missing_pct
make_sim_input <- function(n_split,
                           n_row,
                           md_strat,
                           outcome,
                           additional_missing_pct,
                           test_proportion = 1/2) {

  # create the test index, which is used to split
  # the fake INTERMACS data into train/test sets
  # throughout Monte-Carlo cross-validation.
  n_test <- round(n_row * test_proportion)

  test_index <- vector(mode = 'list', length = n_split)

  for(i in seq_along(test_index))
    test_index[[i]] <- sample(x = n_row,
                              replace = FALSE,
                              size = n_test)

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
