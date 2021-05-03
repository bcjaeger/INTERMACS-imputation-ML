##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title
##' @param scores
tidy_score <- function(scores) {

  q <- 10
  q_high_enough <- cal_error <- TRUE

  while(cal_error & q_high_enough){

    cal_estm <- try(
      plotCalibration(scores,
                      plot = FALSE,
                      method = 'q',
                      q = q,
                      cens.method="local") %>%
        use_series('plotFrame') %>%
        map_dbl(~mean((.x$Pred - .x$Obs)^2)) %>%
        enframe(name = 'md_strat_mdl', value = 'cal_error'),
      silent = TRUE
    )

    q <- q - 1

    if(!inherits(cal_estm, 'try-error')) cal_error <- FALSE
    if(q <= 3) q_high_enough <- FALSE

  }

  auc_estm <- as_tibble(scores$AUC$score) %>%
    select(md_strat_mdl = model, auc = AUC)

  bri_estm <- as_tibble(scores$Brier$score) %>%
    select(md_strat_mdl = model, bri = Brier, ipa = IPA)

  if(cal_error){
    cal_estm <- auc_estm %>%
      rename(cal_error = auc) %>%
      mutate(cal_error = NA_real_)
  }

  auc_estm %>%
    left_join(bri_estm, by = 'md_strat_mdl') %>%
    left_join(cal_estm, by = 'md_strat_mdl')

}
