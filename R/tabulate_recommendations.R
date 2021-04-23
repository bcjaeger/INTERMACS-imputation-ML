##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title

tabulate_recommendations <- function() {

  tibble(
    imputation_strat = c("Imputation to the mean",
                         "Missingness as an attribute",
                         "Hot deck",
                         "K-nearest-neighbors",
                         "Predictive mean matching",
                         "Random forest",
                         "Bayesian regression"),
    features = c("Imputes missing values with mean for continuous and mode for categorical variables",
                 "Treats missing status as a category for predictor variables",
                 "Uses observations from similar cases based on sorting",
                 "Uses observations from similar cases based on Gower's distance",
                 "Uses observations from similar cases based on predicted values from a model",
                 "Applies random forests to impute missing values, iterating until error estimates stabilize",
                 "Draws imputed values from posterior distributions, accounting for model uncertainty"),
    pros = list(c("Computationally efficient",
                  "Straightforward to implement in testing data",
                  "High imputation accuracy"),
                c("Computationally efficient",
                  "Highest prognostic accuracy of downstream models among single imputation techniques"),
                c("More computationally efficient than other imputation techniques",
                  "Less restrictive assumptions since models are not used"),
                c("Flexible",
                  "Most accurate imputed values when single imputation is applied"),
                c("Flexible",
                  "Intuitive"),
                c("Accurate imputed values for numeric variables when single imputation is applied",
                  "Most accurate prognostic accuracy of downstream models when multiple imputation is applied"),
                c("Computationally efficient",
                  "High prognostic accuracy of downstream models when multiple imputation is applied")),
    cons = list(c("Lower prognostic accuracy for downstream models"),
                c("Difficult to implement for continuous variables in traditional statistical models"),
                c("Low imputation accuracy and prognostic accuracy of downstream models when single imputation is applied"),
                c("Computationally inefficient and scales poorly to larger datasets"),
                c("Models may become computationally intractable with larger proportions of missing data or collinearity in predictors"),
                c("Very high computational overhead and requires large amounts of memory to store random forest models for imputation of new data"),
                c("May require assumptions for Bayesian modeling")),
    recs = c("Useful when the proportion of missing values is low or when imputation accuracy is higher priority than prognostic accuracy of downstream models.",
             "Useful when the modeling algorithm involves decision trees and computational efficiency is a high priority.",
             "Useful when multiple imputation is feasible",
             "Useful if computationally feasible and imputation accuracy is a high priority",
             "Useful when multiple imputation is feasible",
             "Useful in a broad range of scenarios for single or multiple imputation, if computationally feasible",
             "Useful when multiple imputation is feasible")
  ) %>%
    mutate(imputation_strat = fct_inorder(imputation_strat))

}
