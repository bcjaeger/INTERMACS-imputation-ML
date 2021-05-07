

##' @title Risk prediction with cox proportional hazards
##'
##' @description this function is used by `predict_risk()`, which in
##'   turn is used by `make_mccv_output()`. The purpose of this function
##'   is to generate a set of predicted probabilities for the risk of a
##'   given outcome at all of the values specified in `times`. Specifically,
##'   this function computes the predicted probabilities for observations
##'   in the `testing` data using a proportional hazards model fitted to
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
##'

predict_risk_cph_si <- function(training,
                                testing,
                                pipeline,
                                verbose,
                                times) {

  # prevent hard error when MIA is used.
  if(any(is.na(training)) | any(is.na(testing)))
    return(matrix(NA_real_, nrow = nrow(testing)))

  suppressWarnings(
    expr = {
      .rec <- prep(pipeline, training = training)
      .trn <- juice(.rec)
      .tst <- bake(.rec, new_data = testing)
    }
  )

  formula_null <- Surv(time, status) ~ 1

  all_predictors <- names(.trn) %>%
    setdiff(c('time', 'status')) %>%
    glue_collapse(sep = " + ")

  formula_full <- as.formula(glue("Surv(time, status) ~ {all_predictors}"))

  scope = list(
    lower = formula_null,
    upper = formula_full
  )

  if(verbose) message("fitting CPH model")

  suppressWarnings(
    model <- stepAIC(
      coxph(Surv(time, status) ~ 1, data = .trn, x = TRUE),
      scope = scope,
      direction = 'both',
      trace = verbose,
      k = log(nrow(.trn)), # uses BIC
      steps = ncol(.trn) - 2 # subtract 2 outcome columns
    )
  )

  if( any(is.na(model$coefficients)) ){

    formula <- Surv(time, status) ~ .
    data_refit <- .trn[, all.vars(model$formula)]

    while ( any(is.na(model$coefficients)) ) {

      if(verbose) message("Found a coefficient dependency")

      na_index <- which(is.na(model$coefficients))
      to_drop <- names(model$coefficients)[na_index]
      data_refit[, to_drop] <- NULL
      model <- coxph(formula = formula, data = data_refit, x = TRUE)

    }

  }

  if (verbose) message("done")

  predictRisk(object = model, newdata = .tst, times = times)

}
