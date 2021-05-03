#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param test_index
make_sim_parameters <- function(n_iter, test_index,
                                md_strat = c('mia',
                                             'meanmode_si',
                                             'ranger_si',
                                             'ranger_mi',
                                             'pmm',
                                             'bayesreg',
                                             'hotdeck_si',
                                             'hotdeck_mi',
                                             'nbrs_mi',
                                             'nbrs_si'),
                                outcome = c('dead', 'txpl'),
                                additional_missing_pct = c(0, 15, 30)) {

  expand.grid(
    iteration = seq(n_iter),
    md_strat = md_strat,
    outcome = outcome,
    additional_missing_pct = additional_missing_pct,
    stringsAsFactors = FALSE
  ) %>%
    as_tibble() %>%
    left_join(test_index, by = 'iteration')

}
