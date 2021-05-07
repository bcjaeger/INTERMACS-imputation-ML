
##' @title Bayesian analysis of Monte-Carlo cross-validation results
##'
##' @description the use of a Bayesian hierarchical model allows us to
##'   analyze posterior distribution of model performance, accounting
##'   for the correlation that comes from training and testing
##'   different modeling algorithms in the same training and testing data.
##'   One Bayesian model is fitted for each combination of outcome predicted
##'   and modeling algorithm used (Cox PH or xgboost). The dependent variable
##'   in these models is the performance metric, e.g., C-statistic.
##'   Each model adjusts for the amount of additional missing data created
##'   prior to the imputation of missing data and also adjusts for the
##'   missing data strategy that was used. These results are passed into
##'   visualize_md_strat_inference().
##'
##' @param sim_output a target created by make_sim_output(), which is
##'   defined in R/make_sim_output.R
##'
make_bayes_mccv_fit <- function(sim_output) {

  model_data <- sim_output %>%
    mutate(md_strat = fct_relevel(md_strat, 'meanmode_si')) %>%
    select(-bri) %>%
    pivot_longer(cols = c(auc, ipa, cal_error), names_to = 'metric') %>%
    split(
      f = list(
        .$outcome,
        .$model,
        .$metric
      )
    )

  output <- vector(mode = 'list', length = length(model_data))
  names(output) <- names(model_data)

  for(i in seq_along(output)){

    # this is faster but less appropriate
    # output[[i]] <- stan_lm(
    #   formula = value ~ md_strat + additional_missing_pct,
    #   data = model_data[[i]],
    #   prior = R2(0.50),
    #   iter = 3000
    # )

    # this is slower but more appropriate
    output[[i]] <- stan_lmer(
      formula = value ~ md_strat + additional_missing_pct + (1 | iteration),
      data = model_data[[i]],
      iter = 5000
    )

  }

  output

}
