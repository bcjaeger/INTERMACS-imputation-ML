
#' @title Create table 1: patient characteristics
#'
#' @description this function creates a target that contains
#'   table 1 for `index.Rmd`.
#'
#' @param descriptive_data a modified version of `intermacs_fake`
#'   that will be used to summarize patient data. This is created
#'   by the make_descriptive_data() functions.
#'
#'
tabulate_characteristics <- function(descriptive_data) {

  descriptive_data %>%
    # this will trick tbl_summary into writing
    # the no. of patients in each column of the table.
    mutate(`No. of patients` = 1, .before = 1) %>%
    # these will be the column labels
    mutate(
      status = factor(
        status,
        levels = c('Dead',
                   'Transplant',
                   'Cessation of support',
                   'Alive on device',
                   'Censored')
      )
    ) %>%
    tbl_summary(
      by = status,
      label = list(
        demo_age ~ "Age, years",
        demo_gender ~ "Sex",
        demo_race ~ "Race",
        pi_bmi ~ "Body mass index",
        im_device_ty ~ "Device type",
        im_surgery_time ~ 'Surgery time, minutes',
        im_cpb_time ~ 'CPB time, minutes',
        pi_cv_pres ~ "CV pressure",
        pi_peripheral_edema ~ 'Periphal edema',
        pi_lvedd ~ 'LVEDD',
        pi_device_strategy ~ "Device strategy",
        pi_albumin_g_dl ~ 'Urinary albumin, g/dL',
        pi_creat_mg_dl ~ 'Urinary creatinine, mg/dL',
        pi_bun_mg_dl ~ 'BUN, mg/dL',
        pi_bili_total_mg_dl ~ 'Bilirubin levels, mg/dL'
      ),
      missing = 'no',
      type = list(`No. of patients` ~ 'continuous'),
      statistic = list(
        all_continuous() ~ "{mean} ({sd})",
        all_categorical() ~ "{p}",
        `No. of patients` ~ "{sum}"
      ),
      digits = list(`No. of patients` ~ 0)
    ) %>%
    modify_footnote(update = everything() ~ NA) %>%
    add_overall(last = FALSE, col_label = '**Overall**') %>%
    modify_header(stat_by="**{level}**")

}
