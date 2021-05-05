

##' @title colorize text in html or latex docs
##'
##' @description This function is used in our distill article to
##'   differentiate between real and fake results.
##'
##' @param x the text to color, as a character value. E.g., 'some text'
##'
##' @param color the desired color, as a character value. E.g., 'green'
##'
colorize <- function(x, color) {
  if (knitr::is_latex_output()) {
    sprintf("\\textcolor{%s}{%s}", color, x)
  } else if (knitr::is_html_output()) {
    sprintf("<span style='color: %s;'>%s</span>", color, x)
  } else x
}
