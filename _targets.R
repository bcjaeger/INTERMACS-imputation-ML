

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

  # number of iterations for Monte-Carlo cross-validation
  n_iter = 3,

  # create the test index, which is used to split
  # the fake INTERMACS data into train/test sets
  # throughout Monte-Carlo cross-validation.
  test_index = make_test_index(n_split = n_iter,
                               n_row = nrow(intermacs_fake)),

  # ------ running the simulation is optional ------
  # a pre-made result is available in data/sim_results.csv.
  # note that if you want to use the pre-made results, you should
  # NOT change any of the preceding code in the plan.
  # Making this target is no trouble but it will take ~2-3
  # hours per iteration, so plan accordingly!
  sim_results = run_sim(intermacs_fake = intermacs_fake,
                        test_index = test_index,
                        n_iter = n_iter,
                        force_run = TRUE),

  bayes_mccv_fit = make_bayes_mccv_fit(sim_results)



)
