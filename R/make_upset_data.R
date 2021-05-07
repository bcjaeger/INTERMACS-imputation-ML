
#' @title make data for upset plot
#'
#' @description this is just re-naming some variables so that they
#'   read clearly in the upset plot.
#'
#' @param descriptive_data a target created by `make_descriptive_data()`
#'

make_upset_data <- function(descriptive_data) {

  descriptive_data %>%
    select(demo_age,
           demo_gender,
           demo_race,
           pi_bmi,
           im_device_ty,
           `Surgery time` = im_surgery_time,
           im_cpb_time,
           `CV pressure` = pi_cv_pres,
           `Peripheral edema` = pi_peripheral_edema,
           pi_lvedd,
           pi_device_strategy,
           pi_albumin_g_dl,
           pi_creat_mg_dl,
           pi_bun_mg_dl,
           pi_bili_total_mg_dl)

}
