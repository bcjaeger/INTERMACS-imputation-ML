
##' @title safer imputation with hot-deck
##' @description if hotdeck imputation fails, it will leave missing values
##'   in the data, which will cause errors when the data are eventually
##'   passed into a risk regression model. To prevent this from happening,
##'   hotdeck_safe() will perform hot-deck imputation and then perform
##'   post-processing of the data. In slurm_run.R, we use hotdeck imputation
##'   and then perform meanmode imputation on the data to fill in any
##'   missing values that hot-deck imputation was unable to impute.
##' @param ... parameters passed to VIM::hotdeck.
##' @param recipe a recipe to process the imputed data. All it needs to
##'   do is impute a small number of missing values that VIM::hotdeck may
##'   not be able to impute.
hotdeck_safe <- function(..., recipe) {
  bake(recipe, new_data = suppressWarnings(hotdeck(...)))
}
