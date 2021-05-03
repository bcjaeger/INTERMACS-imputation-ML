##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title Bayesian analysis of Monte-Carlo cross-validation results
##' @param sim_output a target created by run_sim().
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
    output[[i]] <- stan_lm(
      formula = value ~ md_strat + additional_missing_pct,
      data = model_data[[i]],
      prior = R2(0.50),
      iter = 3000
    )

    # this is slower but more appropriate
    # output[[i]] <- stan_lmer(
    #   formula = value ~ md_strat + additional_missing_pct + (1 | iteration),
    #   data = model_data[[i]],
    #   iter = 5000
    # )

  }

  output

}
