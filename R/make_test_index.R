#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param n_split
#' @param n_row
make_test_index <- function(n_split = 10,
                            n_row,
                            test_proportion = 1/2) {

  n_test <- round(n_row * test_proportion)

  test_index <- vector(mode = 'list', length = n_split)

  for(i in seq_along(test_index))
    test_index[[i]] <- sample(x = n_row,
                                 replace = FALSE,
                                 size = n_test)

  enframe(test_index, name = 'iteration', value = 'test_index')

}
