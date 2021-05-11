
pacman::p_load(
  conflicted,
  dotenv,
  targets,
  tarchetypes,
  ## data cleaning
  janitor,
  naniar,
  ## imputation
  ipa,
  mice,
  miceRanger,
  ## reporting
  rmarkdown,
  glue,
  table.glue,
  knitr,
  kableExtra,
  gtsummary,
  gt,
  ## data analysis
  tidyverse,
  rstanarm,
  tidybayes,
  data.table,
  magrittr,
  survival,
  xgboost,
  tidymodels,
  randomForestSRC,
  MASS,
  VIM,
  Hmisc,
  rpart,
  party,
  ## model evaluation
  riskRegression
)

pacman::p_load_gh("bcjaeger/xgboost.surv")

conflicted::conflict_prefer("roc",         "pROC")
conflicted::conflict_prefer("complete",    "mice")
conflicted::conflict_prefer("filter",      "dplyr")
conflicted::conflict_prefer("select",      "dplyr")
conflicted::conflict_prefer("slice",       "dplyr")
conflicted::conflict_prefer('summarise',   "dplyr")
conflicted::conflict_prefer('summarize',   "dplyr")
conflicted::conflict_prefer('select',      "dplyr")
conflicted::conflict_prefer("gather",      "tidyr")
conflicted::conflict_prefer("set_names",   "purrr")
conflicted::conflict_prefer("discard",     "purrr")
conflicted::conflict_prefer("fixed",       "stringr")
conflicted::conflict_prefer("all_numeric", "recipes")
conflicted::conflict_prefer("matches",     "tidyselect")
conflicted::conflict_prefer("impute",      "miceRanger")
conflicted::conflict_prefer("R2",          "rstanarm")
