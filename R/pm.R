#' @title plus or minus printing
#' @description this function is used in tables to write a "+" sign
#'   before positive numbers. I feel this makes it easier to skim
#'   the table and note which cells are > 0 versus < 0. Hopefully
#'   you feel that way too.
#' @param x a numeric vector
#'
pm <- function(x) ifelse(x > 0, "+", "")

