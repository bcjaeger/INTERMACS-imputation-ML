
##' @title Risk prediction with random forests
##'
##' @description this function is used by `predict_risk()`, which in
##'   turn is used by `make_mccv_output()`. The purpose of this function
##'   is to generate a set of predicted probabilities for the risk of a
##'   given outcome at all of the values specified in `times`. Specifically,
##'   this function computes the predicted probabilities for observations
##'   in the `testing` data using a random forests model fitted to
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

predict_risk_rf_si <- function(training,
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


  message("fitting CIF model")

  # unbiased random forest using pec and party packages.
  model <- cforest(
    formula = Surv(time,status) ~ .,
    data = .trn,
    controls = cforest_unbiased(maxsurrogate = 3)
  )

  message("done")
  message("computing CIF predictions")

  predictions <- treeresponse(model, newdata = .tst, OOB = TRUE) %>%
    map_dbl(.f = predictRisk,
        newdata = .tst[1, , drop = FALSE], # this is arbitrary
        times = times) %>%
    matrix(ncol = 1)

  message("done")

  predictions

  # a fast randomforest using Ishwaran's package
  # model <- rfsrc.fast(formula = Surv(time, status) ~ .,
  #                     data = .trn,
  #                     ntree = 1000,
  #                     nodesize = 20,
  #                     nsplit = 5,
  #                     forest = TRUE,
  #                     na.action = 'na.impute')
  # predictRisk(model,
  #             newdata = .tst,
  #             times = times)

}
