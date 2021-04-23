##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title
##' @param risk_predictions
##' @param times
##' @param testing_data
evaluate_risk_predictions <- function(risk_predictions,
                                      times,
                                      testing_data) {

  risk_predictions %>%
    unite(md_strat, model, col = 'md_strat_mdl', sep = '..') %>%
    select(md_strat_mdl, sprobs) %>%
    deframe() %>%
    discard(.p = ~all(is.na(.x))) %>%
    Score(
      formula = Surv(time, status) ~ 1,
      data = testing_data,
      times = times,
      summary = 'IPA',
      plots = 'Calibration',
      se.fit = 0,
      contrasts = FALSE
    ) %>%
    tidy_score() %>%
    separate(md_strat_mdl, into = c('md_strat', 'model'), sep = '\\.\\.')


}
