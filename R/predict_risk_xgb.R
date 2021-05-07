##' @title Risk prediction with gradient boosted decision trees.
##'
##' @description this function is used by `predict_risk()`, which in
##'   turn is used by `make_mccv_output()`. The purpose of this function
##'   is to generate a set of predicted probabilities for the risk of a
##'   given outcome at all of the values specified in `times`. Specifically,
##'   this function computes the predicted probabilities for observations
##'   in the `testing` data using gradient boosted decision trees fitted to
##'   the `training` data. Prior to fitting the model, a data processing
##'   `pipeline` is trained on the `training` data and then applied to
##'   the `testing` data.
##'
##' @param training the training dataset.
##'
##' @param testing the testing dataset.
##'
##' @param pipeline an untrained recipe (it will be trained on `training`).
##'
##' @param verbose `TRUE` or `FALSE`; should output be printed?
##'
##' @param times a numeric value indicating when risk predictions are computed.


predict_risk_xgb_si <- function(training,
                                testing,
                                pipeline,
                                verbose,
                                times) {

  suppressWarnings(
    expr = {
      .rec <- prep(pipeline, training = training)
      .trn <- juice(.rec)
      .tst <- bake(.rec, new_data = testing)
    }
  )

  xgb_data <- as_sgb_data(.trn, time = time, status = status)

  xgb_cv_folds <- xgb_folds(data = .trn, nfolds = 10, strata = status)

  if(verbose) message("Tuning xgboost parameters")

  xgb_cv_tune <- expand.grid(
    max_depth = c(2,4),
    min_child_weight = c(3),
    colsample_bynode = 1/2,
    subsample = 1/2,
    eta = 0.03,
    eval_metric = 'cox-nloglik',
    objective = 'survival:cox'
  ) %>%
    apply(1, as.list) %>%
    enframe(value = 'params') %>%
    mutate(
      fit = map(
        .x = params,
        .f = xgb.cv,
        data = xgb_data$data,
        label = xgb_data$label,
        nrounds = 25000,
        folds = xgb_cv_folds,
        early_stopping_rounds = 50,
        print_every_n = 25000
      )
    )

  if(verbose) message("Done")

  xgb_params_tuned <- xgb_cv_tune %>%
    mutate(
      nrounds = map_int(fit, ~.x$best_iteration),
      score = map_dbl(
        .x = fit,
        .f = ~min(.x$evaluation_log$test_cox_nloglik_mean)
      )
    ) %>%
    arrange(score) %>%
    slice(1)

  if(verbose) message("Fitting xgboost model")

  model <- sgb_fit(params = xgb_params_tuned$params[[1]],
                   nrounds = xgb_params_tuned$nrounds,
                   sgb_df = xgb_data,
                   verbose = as.numeric(verbose))

  if(verbose) message("Done")

  predictors <- setdiff(names(.tst), c('time', 'status'))

  1 - predict(model,
              new_data = as.matrix(.tst[, predictors]),
              eval_times = times)


}
