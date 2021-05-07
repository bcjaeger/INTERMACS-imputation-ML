
#' @title Create table 2: variable missingness
#'
#' @description this function creates a target that contains
#'   - table 2 in `index.Rmd`, which summarizes the count and % of
#'     missing values for variables in `intermacs_fake`.
#'   - an inline summary of each table that is used to write results
#'     from the table into the text of the paper.
#'
#' @param descriptive_data a modified version of `intermacs_fake`
#'   that will be used to summarize patient data. This is created
#'   by the make_descriptive_data() functions.
#'
#' @param rspec a rounding specification to format numbers in the table
#'
#'

tabulate_missingness <- function(descriptive_data, rspec) {

  tbl_missingness_by_status <- descriptive_data %>%
    group_by(status) %>%
    miss_var_summary()

  tbl_missingness_overall <- miss_var_summary(descriptive_data) %>%
    mutate(status = 'Overall')

  tbl_missingness_data <- bind_rows(
    tbl_missingness_overall,
    tbl_missingness_by_status
  ) %>%
    transmute(
      status,
      variable,
      tbl_value = table_glue("{n_miss}\n({pct_miss}%)", rspec = rspec),
      label = recode(
        variable,
        demo_age = "Age, years",
        demo_gender = "Sex",
        demo_race = "Race",
        pi_bmi = "Body mass index",
        im_device_ty = "Device type",
        im_surgery_time = 'Surgery time, minutes',
        im_cpb_time = 'CPB time, minutes',
        pi_cv_pres = "CV pressure",
        pi_peripheral_edema = 'Periphal edema',
        pi_lvedd = 'LVEDD',
        pi_device_strategy = "Device strategy",
        pi_albumin_g_dl = 'Urinary albumin, g/dL',
        pi_creat_mg_dl = 'Urinary creatinine, mg/dL',
        pi_bun_mg_dl = 'BUN, mg/dL',
        pi_bili_total_mg_dl = 'Bilirubin levels, mg/dL'
      )
    )


  tbl_missingness_object <- tbl_missingness_data %>%
    select(-variable) %>%
    pivot_wider(values_from = tbl_value,
                names_from = status) %>%
    filter(label != 'status',
           label != 'months_post_implant') %>%
    mutate(across(everything(), str_replace, '\\n', '<br/>')) %>%
    gt() %>%
    cols_label(label = 'Variable') %>%
    cols_align(align = 'center') %>%
    cols_align(align = 'left', columns = 1) %>%
    fmt_markdown(columns = TRUE) %>%
    tab_footnote(
      footnote = 'Abbreviations: LVEDD = left ventricular end diastolic dimension; CV = central venous; BUN = blood urea nitrogen; CPB = cardiopulmonary bypass',
      locations = cells_column_labels(columns = 1)
    )

  tbl_missingness_inline <- tbl_missingness_data %>%
    mutate(tbl_value = str_replace(tbl_value, fixed("\n"), " ")) %>%
    as_inline(tbl_variables = c('status', 'variable'),
              tbl_values = 'tbl_value')

  list(table = tbl_missingness_object,
       inline = tbl_missingness_inline)

}
