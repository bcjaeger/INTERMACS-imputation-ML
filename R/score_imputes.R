
##' @title score imputation accuracy
##'
##' @description this function computes an accuracy score
##'   for each nominal and numeric variable in a given dataset.
##'   It is used by `make_mccv_output()`.
##'
##' @param imputed_data a dataset where missing values have been imputed.
##'
##' @param amputed_values a list containing the true values for data
##'   that have been imputed and an index describing which rows in
##'   `imputed_data` correspond to these values.
##'

score_imputes <- function(imputed_data, amputed_values){

  miss_cols <- names(amputed_values)

  names_numeric <- imputed_data %>%
    select(all_of(miss_cols)) %>%
    select(where(is.numeric)) %>%
    names() %>%
    intersect(names(amputed_values))

  names_nominal <- imputed_data %>%
    select(all_of(miss_cols)) %>%
    select(where(is.factor), where(is.character)) %>%
    names() %>%
    intersect(names(amputed_values))

  score_numeric <- score_nominal <- NULL

  empty_numeric <- length(names_numeric) == 0
  empty_nominal <- length(names_numeric) == 0

  if(!empty_numeric){

    score_numeric <- rep(NA_real_, length(names_numeric))

    for(i in seq_along(score_numeric)){

      col = names_numeric[i]
      mis = amputed_values[[col]]$index

      score_numeric[i] <- rmse_r2(
        truth = amputed_values[[col]]$values,
        estimate = imputed_data[[col]][mis],
        observed = imputed_data[[col]][-mis]
      )

    }

  }

  if(!empty_nominal){

    score_nominal <- rep(NA_real_, length(names_nominal))

    for(i in seq_along(score_nominal)){

      col = names_nominal[i]
      mis = amputed_values[[col]]$index

      score_nominal[i] <- accuracy(
        truth = amputed_values[[col]]$values,
        estimate = imputed_data[[col]][mis]
      )

    }

  }

  tibble(nominal = mean(score_nominal),
         numeric = mean(score_numeric))

}


accuracy <- function(truth, estimate){

  mean(truth == estimate)

}

rmse <- function(truth, estimate){

  sq_err <- (truth - estimate)^2
  mse <- mean(sq_err)
  sqrt(mse)

}

rmse_r2 <- function(truth, estimate, observed){

  est_rmse <- rmse(truth, estimate)
  base_rmse <- rmse(truth, mean(observed))

  1 - est_rmse / base_rmse

}
