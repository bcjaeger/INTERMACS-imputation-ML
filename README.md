
<!-- README.md is generated from README.Rmd. Please edit that file -->

# INTERMACS-imputation-ML

<!-- badges: start -->
<!-- badges: end -->

This project allows you to engage with an analysis of data from the
Interagency Registry for Mechanically Assisted Circulatory Support
(INTERMACS) without directly engaging with the INTERMACS data. The
analysis, which we anticipate publishing in *Circulation: Cardiovascular
Quality and Outcomes*, investigates how data should be imputed to
improve the prognostic accuracy of risk prediction models that leverage
the imputed values. In particular, our analysis applies twelve
imputation strategies in combination with two different modeling
strategies for mortality and transplant risk prediction following
surgery to receive mechanical circulatory support (MCS).

## Fake data

The real INTERMACS data are publicly available through
[BIOLINCC](https://biolincc.nhlbi.nih.gov/studies/intermacs/). This
project hosts a simulated INTERMACS dataset that contains **no
information** from the real INTERMACS data. Instead, the fake INTERMACS
data mimics the statistical properties of the real INTERMACS data. Once
you have opened this project, accessing the fake INTERMACS data will be
as easy as the code below makes it seem.

``` r
intermacs_fake <- readr::read_csv("data/intermacs_fake.csv", 
                                  col_types = readr::cols(),
                                  n_max = 10)

tibble::glimpse(intermacs_fake)
#> Rows: 10
#> Columns: 50
#> $ pt_outcome_dead             <dbl> 0, 0, 1, 1, 0, 1, 1, 0, 0, 1
#> $ pt_outcome_txpl             <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 1, 0
#> $ pt_outcome_cess             <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
#> $ months_post_implant         <dbl> 7.260929, 24.904002, 14.751843, 29.109427,~
#> $ demo_age                    <dbl> 41, 74, 72, 61, 75, 78, 72, 54, 61, 64
#> $ demo_gender                 <chr> "male", "male", "male", "male", "male", "m~
#> $ demo_race_af_amer           <chr> "no", "no", "no", "no", "no", "no", "no", ~
#> $ demo_race_white             <chr> "yes", "no", "yes", "yes", "yes", "yes", "~
#> $ pi_device_strategy          <chr> "bridge_to_transplant_patient_currently_li~
#> $ pi_hgt_cm                   <dbl> 167.64, 172.00, 177.80, 187.96, 182.90, 17~
#> $ pi_wgt_kg                   <dbl> 104.30, 89.58, 89.36, 91.82, 86.64, 76.02,~
#> $ pi_lvedd                    <dbl> 6.6, 7.1, 8.2, 6.8, 7.3, 5.7, 5.8, 8.5, 8.~
#> $ pi_albumin_g_dl             <dbl> 3.1, 4.2, 4.1, 3.6, 3.5, NA, 3.8, 3.2, 4.4~
#> $ pi_creat_mg_dl              <dbl> 0.70, 1.40, 1.30, 1.02, 2.00, 1.80, 2.67, ~
#> $ pi_cv_pres                  <dbl> NA, NA, NA, NA, NA, 5, NA, 2, 18, NA
#> $ pi_peripheral_edema         <chr> "no", NA, NA, NA, "yes", "no", NA, "no", "~
#> $ pi_bun_mg_dl                <dbl> 34, 48, 31, 16, 31, 11, 45, 53, 24, 92
#> $ pi_bili_total_mg_dl         <dbl> 3.4, 0.6, 1.1, 0.7, 1.0, 0.4, 0.7, 0.6, 0.~
#> $ im_device_ty                <chr> "lvad", "lvad", "lvad", "lvad", "lvad", "l~
#> $ im_surgery_time             <dbl> 157, 595, NA, 209, 473, NA, 280, 279, 180,~
#> $ im_cpb_time                 <dbl> 61, 104, 21, 93, 78, 55, 97, 149, 160, 112
#> $ pi_hemoglobin_g_l           <dbl> 113, 96, 134, 130, 114, 130, 101, 97, 108,~
#> $ pi_platelet_x10_3_ul        <dbl> 240, 130, 200, 157, 205, 165, 265, 234, 94~
#> $ im_concom_surg_rvad_implant <chr> "no", "no", "no", "no", "no", "no", "no", ~
#> $ pi_prev_cardiac_oper_none   <dbl> 1, 0, 1, 1, 0, 1, 0, 1, 1, 1
#> $ pi_ecg_rhythm               <chr> "paced_ventricular_pacing", "paced_ventric~
#> $ pi_event_hosp_dialysis      <chr> "no", "no", "no", "no", "no", "no", "no", ~
#> $ pi_prev_cardiac_oper_cabg   <chr> "no", "yes", "no", "no", "yes", "no", "yes~
#> $ pi_lymph_cnt_percent        <dbl> NA, 35.0, NA, 15.9, 11.0, NA, 20.1, 10.0, ~
#> $ im_rvad_can_outflow         <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
#> $ pi_sgot_ast                 <dbl> 28, 20, 15, 41, 26, 30, 22, 18, 19, 24
#> $ pi_wbc_x10_3_ul             <dbl> 7.9, 6.1, 9.3, 6.4, 10.0, 5.5, 10.6, 5.8, ~
#> $ pi_trail_making_time        <dbl> NA, NA, 94, NA, 131, 92, NA, NA, NA, NA
#> $ pi_hr_rate                  <dbl> 88, 89, 86, 99, 78, 88, 99, 68, 92, 103
#> $ pipulmonary_disease_m       <chr> "no", "no", NA, "no", "no", "no", "no", "n~
#> $ pifrailty_m                 <chr> "no", "no", NA, "no", "no", "no", "no", "n~
#> $ im_rvad_can_inflow          <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
#> $ piadvanced_age_m            <chr> "no", "yes", "yes", "no", "yes", "yes", "y~
#> $ pi_blood_type               <chr> "o", "a", "o", "a", "a", "o", "b", "o", "a~
#> $ pi_sys_bp                   <dbl> 92, 124, 115, 154, 106, 99, 137, 96, 101, ~
#> $ pi_lymph_cnt_x10_3_ul       <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
#> $ demo_work_yes_status        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA
#> $ pi_six_min_walk             <dbl> NA, NA, 668, NA, NA, 1200, NA, NA, NA, NA
#> $ pilarge_bmi_m               <chr> "no", "no", NA, "no", "no", "no", "no", "y~
#> $ pi_med_pre_imp_amiodarone   <chr> "known_previous_use_within_past_year", "no~
#> $ pi_cardiac_index            <dbl> 1.9, 2.0, NA, 1.7, 1.1, 2.1, 1.5, 2.1, 2.1~
#> $ pi_aortic_regurg            <chr> "x0_none", "x0_none", "x0_none", "x0_none"~
#> $ pi_cardiac_output           <dbl> 4.4, 3.6, 2.4, 4.0, 3.2, 4.3, 2.9, 5.5, 3.~
#> $ im_volume_2015              <chr> "x31_50_implants", "x31_50_implants", "x21~
#> $ pi_sgpt_alt                 <dbl> 29, 40, 48, 45, 46, 38, 54, 20, 66, 57
```

# Instructions for use

This project is supported by the `targets` package, a make-like pipeline
toolkit for statistics and data science. Users of this project will find
the online [targets manual](https://books.ropensci.org/targets/) to
provide all of the information needed to engage with this analysis.
However, we have also written a series of steps to help users who are
unfamiliar with the `targets` package engage with this analysis.

1.  Open the project in Rstudio (make sure you can see
    ‘INTERMACS-imputation-ML’ in the upper right hand corner of the
    Rstudio IDE). If you are accessing the project using the American
    Heart Association Precision Medicine Platform, you can skip the next
    three steps.

2.  Run `library(pacman)` in your console. If running this code leads to
    an error message “Error in library(pacman) : there is no package
    called ‘pacman’”, then run `install.packages("pacman")` in your
    console and make sure `pacman` is installed before proceeding.

3.  (optional) Open the `packages.R` script and read its contents.

4.  Source `packages.R` by pressing ctrl+shift+S while you are viewing
    the `packages.R` file in your editor or by running
    `source("packages.R")` in your console. This command will install
    packages that are needed to run the analyses in this project. Some
    packages take a few minutes to install, so this could take up to 15
    minutes depending on what needs to be installed.

5.  (optional) Open the `_targets.R` script and read its contents. This
    file contains a blueprint for the project’s analysis, and modifying
    it will alter how the analysis is run. Moreover, each function used
    in the call to `tar_plan()` has its own script in the R directory
    with accompanying documentation. See the File structure section
    below for more.

6.  Before modifying anything in `_targets.R`, run `targets::tar_make()`
    in your console. This command will initiate construction of the
    entire analysis pipeline, from data cleaning to the tabulation and
    visualization of our results. If this is the first time running
    `tar_make()`, it can take up to 3 hours. Sorry about the wait -
    believe it or not 3 hours to run the fake analysis is pretty quick
    relative to the time it takes to run the real analysis.

7.  Open `docs/index.Rmd`. This is the file that creates the manuscript.
    Now that your pipeline is constructed, you can knit this document
    and your results will populate the pages. To knit, just click the
    ‘knit’ button at the top of your editor window when you view this
    file in your editor. The results you get with default setting should
    match the results on this projects [GitHub pages
    website](https://bcjaeger.github.io/INTERMACS-imputation-ML/)

8.  Now you can begin to carefully modify the project and experiment.
    First, try modifying `_targets.R` so that the Monte-Carlo
    cross-validation experiment is created locally instead of using
    `data/mccv_output_fake.csv`. You will find instructions on how to do
    this in the comments written in `_targets.R`.

9.  Once you have set up your own target to create a Monte-Carlo
    cross-validation experiment, you can modify the function found in
    `make_mccv_output.R`. I recommend uncommenting the command
    `browser()` on line 50 of this file, saving the file, and then
    running `targets::tar_make(callr_function = NULL)` in your console.
    This will initiate a pipeline build in your local R session that
    will halt when it reaches line 50 of the `make_mccv_output.R` file
    and go into browser mode. From there, you can explore the function
    and run it interactively. You can learn more about browser mode
    [here](https://support.rstudio.com/hc/en-us/articles/205612627-Debugging-with-the-RStudio-IDE).
    You can also learn more about getting into browser mode with
    `targets` in Chapter 4 of the online [targets
    manual](https://books.ropensci.org/targets/).

If you have any trouble with these steps, please open an issue on this
repository and include details on the error message you are receiving.

# File structure:

Each directory in the project, and the files it contains, are described
here.

## R directory

The `R` directory contains R scripts used in this analysis:

-   Each script contains one function.

-   The name of the script is the name of the function it contains.

-   At the top of each script, a description of the function indicates
    what it does and where it is used in the analysis.

Generally, functions that create targets begin with the words `make`,
`visualize`, or `tabulate`. These functions are used to create targets
in the analysis workflow.

-   `make` functions create targets that contain datasets. These targets
    are often used in downstream targets, e.g. targets that contain
    figures or tables.

-   `visualize` functions create targets that contain figures.

-   `tabulate` functions create targets that contain tables.

Some functions do not begin with one of these pre-fixes, and the purpose
of these functions is written in the `@description` header at the top of
the file.

## data directory

The `data` directory holds three files:

-   `intermacs_fake.csv`: a simulated dataset that has similar
    statistical properties to data from INTERMACS.

-   `sim_output_fake.csv`: the results from the primary analysis when
    `intermacs_fake.csv` is used instead of the real INTERMACS data.

-   `sim_output_real.csv`: the results from the primary analysis when
    the real INTERMACS data is used. If this output is used to generate
    the distill article (see `docs/index.Rmd`), then the results
    generated will match results in the manuscript submitted to
    *Circulation: Cardiovascular Quality and Outcomes*.

## docs directory

The `docs` directory holds four files:

-   `ccqo.csl`: this file is used by `index.Rmd` to format references
    that follow guidelines from *Circulation: Cardiovascular Quality and
    Outcomes*.

-   `references.bib`: this file supplies references to `index.Rmd` in
    the [bibtex format](https://en.wikipedia.org/wiki/BibTeX).

-   `index.Rmd`: this is the file that knits together the manuscript. It
    is written using the [distill R
    package](https://rstudio.github.io/distill/), which is an extension
    of [R Markdown](https://bookdown.org/yihui/rmarkdown/) designed for
    scientific articles.

-   `index.html`: this is the file that `index.Rmd` produces. Also,
    `index.html` is used by GitHub pages to produce a website associated
    with this project.
