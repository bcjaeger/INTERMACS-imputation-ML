


##' @title evaluate predictions from multiple models
##'
##' @description This function is used in slurm_run.R to generate AUC,
##'   scaled Brier scores, and calibration errors.
##'
##' @param risk_predictions a list of prediction matrices, where
##'  - each item in the list is a matrix of predicted risk from a different model
##'  - each column in the matrix has predictions for a specific time
##'  - each row in the matrix has predictions for a specific individual.
##' @param times the times at which predictions of risk were made
##'
##' @param testing_data data containing outcomes for the predicted cases.
##'
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
