
##' @title Generic risk prediction function
##'
##' @description Instead of going through the trouble of making a
##'   generic method, I just made a function called `predict_risk`
##'   that switches based on the value of `model`. This function
##'   is used by `make_mccv_output()` to draw predicted risk
##'   probabilities from the models fitted in the analysis.
##'
##' @param training the training dataset.
##'
##' @param testing the testing dataset.
##'
##' @param pipeline an untrained recipe (it will be trained on `training`).
##'
##' @param times a numeric value indicating when risk predictions are computed.
##'
##' @param model a character value indicating what type of model to fit.
##'
##' @param verbose `TRUE` or `FALSE`; should output be printed?

predict_risk <- function(training,
                         testing,
                         pipeline,
                         verbose,
                         times,
                         model){

  # note that the functions in switch() are single imputation
  # risk prediction functions; they are not the same
  # functions as the predict_risk_cph, predict_risk_xgb,
  # and predict_risk_rf functions that are defined later
  # in this script.

  .f <- switch(
    model,
    'cph' = predict_risk_cph_si,
    'xgb' = predict_risk_xgb_si,
    'rf'  = predict_risk_rf_si
  )

  # if single imputation is used, then the training
  # data are just a tibble and we only need to fit
  # the model as specified.

  if(is_tibble(training)) {

    output <- .f(training = training,
       testing = testing,
       pipeline = pipeline,
       verbose = verbose,
       times = times)

  } else {

    # if multiple imputation is used, then the training
    # data are a list of tibbles, and we fit models to
    # each tibble, separately. After getting risk prediction
    # values from each model, we aggregate by taking the median.

    output <- map2(
      .x = training,
      .y = testing,
      .f = .f,
      pipeline = pipeline,
      verbose  = verbose,
      times    = times
    ) %>%
      reduce(cbind) %>%
      apply(1, median) %>%
      matrix(ncol = 1)

  }

  output


}

predict_risk_cph <- function(training,
                             testing,
                             pipeline,
                             verbose,
                             times) {

  predict_risk(training = training,
               testing = testing,
               pipeline = pipeline,
               verbose = verbose,
               times = times,
               model = 'cph')

}

predict_risk_xgb <- function(training,
                             testing,
                             pipeline,
                             verbose,
                             times) {

  predict_risk(training = training,
               testing = testing,
               pipeline = pipeline,
               verbose = verbose,
               times = times,
               model = 'xgb')

}

predict_risk_rf <- function(training,
                            testing,
                            pipeline,
                            verbose,
                            times) {

  predict_risk(training = training,
               testing = testing,
               pipeline = pipeline,
               verbose = verbose,
               times = times,
               model = 'rf')

}
