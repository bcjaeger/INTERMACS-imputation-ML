

## Load packages, e.g. library(targets).
source("./packages.R")

## Load all R files
lapply(list.files("./R", full.names = TRUE), source)

# the plan for this project is written below.

tar_plan(

  # the fake INTERMACS data was created using the R
  # synthpop package. Random forests were fit to
  # generate fake data for each variable. A subset
  # of the original variables was selected to be
  # included in the fake INTERMACS data for computational
  # reasons, including (1) the overhead of working with the data
  # in this project and (2) the desire to keep the demand
  # for memory manageable (i.e. storing data in GitHub)
  intermacs_fake = read_csv("data/intermacs_fake.csv"),

  # when to predict risk for outcomes, in months after surgery
  times = 6,

  # rounding specification for the project
  rspec = round_spec() %>%
    round_using_magnitude(
      digits = c(2, 2, 1),
      breaks = c(1, 10, 100)
    ) %>%
    round_half_even() %>%
    format_missing(replace_na_with = '---'),

  # create descriptive data for summaries of the fake intermacs data
  descriptive_data = make_descriptive_data(intermacs_fake, times),
  upset_data = make_upset_data(descriptive_data),

  tbl_characteristics = tabulate_characteristics(descriptive_data),
  tbl_missingness = tabulate_missingness(descriptive_data, rspec),


  # labels that are used throughout the project
  md_method_labels = c(
    'meanmode' = 'Imputation to the mean',
    'mia' = 'Missingness as an attribute',
    'hotdeck' = 'Hot deck',
    'nbrs' = 'K-nearest-neighbors',
    'pmm' = 'Predictive mean matching',
    'ranger' = 'Random forest',
    'bayesreg' = 'Bayesian regression'
  ),

  # labels that are used throughout the project
  md_type_labels = c(
    'si' = 'Single imputation',
    'mi' = 'Multiple imputation'
  ),

  # labels that are used throughout the project
  model_labels = c(
    'rf' = 'Random forest',
    'xgb' = 'Gradient boosted decision trees',
    'cph' = 'Proportional hazards'
  ),

  # labels that are used throughout the project
  outcome_labels = c(
    'dead' = 'Mortality',
    'txpl' = 'Transplant'
  ),

  # labels that are used # labels that are used throughout the project
  additional_missing_labels = c(
    'No additional missing data'  = '0',
    '+15% additional missing data'= '15',
    '+30% additional missing data'= '30'
  ),


  # inputs for the Monte-Carlo cross-validation experiment.
  mccv_input = make_mccv_input(
    # number of train/test splits to iterate over. You can input
    # any number > 1, but note that each iteration will take a few hours.
    n_split = 10,
    # number of total data points. I wouldn't recommend changing this.
    n_row = nrow(intermacs_fake),
    # The values of md_strat are somewhat rigid and probably
    # shouldn't be changed unless specific code is added to
    # the make_mccv_output() function. However, you can comment
    # some of these values out if you want to reduce the amount
    # of time it takes to run the analysis.
    md_strat = c(
      'mia',
      'meanmode_si',
      'ranger_si',
      'ranger_mi',
      'pmm',
      'bayesreg',
      'hotdeck_si',
      'hotdeck_mi',
      'nbrs_mi',
      'nbrs_si'
    ),
    # outcomes to fit models for. I wouldn't try changing these
    # as it may break code downstream that expects >1 outcome type
    outcome = c('dead','txpl'),
    # how much additional missing data to create prior to imputing.
    # These can safely be modified but I would avoid going over 40%
    # and also don't forget to update additional_missing_labels above.
    additional_missing_pct = as.numeric(additional_missing_labels)
  ),

  # The Monte-Carlo cross-validation experiment -------------------------------
  # there are several ways to build this target:

  # 1. Use the pre-made results from the real intermacs data
  #    If this is what you want, remove the # symbol from the
  #    single line of code below (i.e., uncomment it):
  #
  # mccv_output = read_csv("data/mccv_output_real.csv"),
  #
  #    Also, make sure the other lines defining mccv_output
  #    are commented so that you don't accidentally try
  #    to make two targets with the same name. The targets
  #    package will throw an error if this happens.


  # 2. Use the pre-made results from the fake intermacs data
  #    (these were created using the mccv_input values above)
  #    If this is what you want, uncomment the line below:
  #
  mccv_output = read_csv("data/mccv_output_fake.csv"),
  #
  #    Note that intermacs_fake won't give the exact same answer as the true
  #    INTERMACS data, but the two datasets do give similar results.

  # 3. Make your own results using the fake intermacs data!
  #    (this is cool but it will take some time)
  #    If this is what you want, uncomment all of the lines
  #    in the tar_target() command below:

  # tar_target(
  #   mccv_output,
  #   make_mccv_output(
  #     intermacs_fake = intermacs_fake,
  #     times = times,
  #     iteration = mccv_input$iteration,
  #     test_index = mccv_input$test_index,
  #     md_strat = mccv_input$md_strat,
  #     outcome = mccv_input$outcome,
  #     additional_missing_pct = mccv_input$additional_missing_pct
  #   ),
  #   # iterate over all rows of mccv_input and bind the results by row.
  #   # note that some results have >1 rows, so the number
  #   # of rows for mccv_input < number of rows for mccv_output
  #   pattern = map(mccv_input)
  # ),

  bayes_mccv_fit = make_bayes_mccv_fit(mccv_output),

  tbl_impute_accuracy = tabulate_impute_accuracy(mccv_output,
                                                 md_method_labels,
                                                 additional_missing_labels),

  tbl_md_strat = tabulate_md_strat(mccv_output,
                                   md_method_labels,
                                   md_type_labels,
                                   model_labels,
                                   outcome_labels,
                                   additional_missing_labels,
                                   rspec),

  tbl_recommendations = tabulate_recommendations(),

  fig_mccv_results = visualize_mccv_output(mccv_output,
                                           md_method_labels,
                                           md_type_labels,
                                           model_labels,
                                           outcome_labels,
                                           additional_missing_labels,
                                           times),

  fig_md_strat_infer = visualize_md_strat_inference(bayes_mccv_fit,
                                                    md_type_labels,
                                                    md_method_labels,
                                                    outcome_labels)



)
