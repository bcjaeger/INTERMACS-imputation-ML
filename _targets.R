

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

  # create descriptive summaries of the fake intermacs data
  descriptives = make_descriptives(intermacs_fake, times),

  md_method_labels = c(
    'meanmode' = 'Imputation to the mean',
    'mia' = 'Missingness as an attribute',
    'hotdeck' = 'Hot deck',
    'nbrs' = 'K-nearest-neighbors',
    'pmm' = 'Predictive mean matching',
    'ranger' = 'Random forest',
    'bayesreg' = 'Bayesian regression'
  ),

  md_type_labels = c(
    'si' = 'Single imputation',
    'mi' = 'Multiple imputation'
  ),

  model_labels = c(
    'rf' = 'Random forest',
    'xgb' = 'Gradient boosted decision trees',
    'cph' = 'Proportional hazards'
  ),

  outcome_labels = c(
    'dead' = 'Mortality',
    'txpl' = 'Transplant'
  ),

  additional_missing_labels = c(
    'No additional missing data'  = '0',
    '+15% additional missing data'= '15',
    '+30% additional missing data'= '30'
  ),

  # rounding specification for the project
  rspec = round_spec() %>%
    round_using_magnitude(
      digits = c(2, 2, 1),
      breaks = c(1, 10, 100)
    ) %>%
    round_half_even() %>%
    format_missing(replace_na_with = '---'),

  # create the test index, which is used to split
  # the fake INTERMACS data into train/test sets
  # throughout Monte-Carlo cross-validation.
  test_index = make_test_index(n_split = 2,
                               n_row = nrow(intermacs_fake)),


  # ------ running this simulation is optional ------
  # a pre-made result is available in data/sim_output_premade.csv.
  # You can make your own simulation using intermacs_fake,
  # but it will take ~2-3 hours per iteration, so plan accordingly!
  # Also, intermacs_fake may not give the same answer as the true
  # INTERMACS data, so don't be too surprised if you do your own sim
  # and find results are inconsistent with the results in the paper.

  # md_strat = c(
  #   'mia',
  #   'meanmode_si',
  #   'ranger_si',
  #   'ranger_mi',
  #   'pmm',
  #   'bayesreg',
  #   'hotdeck_si',
  #   'hotdeck_mi'
  #   'nbrs_mi',
  #   'nbrs_si'
  # ),
  # outcome = c('dead','txpl'),
  # additional_missing_pct = c(0, 15, 30),
  # tar_target(
  #   sim_output,
  #   make_sim_output(intermacs_fake = intermacs_fake,
  #                   times = times,
  #                   test_index = test_index,
  #                   md_strat = md_strat,
  #                   outcome = outcome,
  #                   additional_missing_pct = additional_missing_pct),
  #   # iterate over all combos inside of cross()
  #   pattern = cross(test_index,
  #                   md_strat,
  #                   outcome,
  #                   additional_missing_pct)
  # ),

  # add index to sim_output_no_index
  # sim_output = add_index(sim_output_no_index)


  # Leave this uncommented to use the pre-made simulation results
  # Note that the pre-made simulation results are the same results
  # that were used in the paper this project is based on, so using
  # the pre-made simulation will reproduce results in the paper.
  sim_output = read_csv("data/sim_output_premade.csv"),

  bayes_mccv_fit = make_bayes_mccv_fit(sim_output),

  tbl_impute_accuracy = tabulate_impute_accuracy(sim_output,
                                                 md_method_labels,
                                                 additional_missing_labels),

  tbl_md_strat = tabulate_md_strat(sim_output,
                                   md_method_labels,
                                   md_type_labels,
                                   model_labels,
                                   outcome_labels,
                                   additional_missing_labels,
                                   rspec),

  fig_sim_results = visualize_sim_output(sim_output,
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
