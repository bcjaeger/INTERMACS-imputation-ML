##' @title make descriptive data
##'
##' @description This code produces a dataset that is used to
##'   describe summary statistics for participants as well as
##'   missing counts and proportions for analysis variables and
##'   an upset plot summarizing the patterns of missingness.
##'
##' @param intermacs_fake the fake intermacs data
##'
##' @param times when to predict risk for outcomes, in months after surgery

make_descriptive_data <- function(intermacs_fake, times) {

  intermacs_fake %>%
    mutate(
      status = case_when(
        pt_outcome_dead == 1 & months_post_implant < times ~ "Dead",
        pt_outcome_txpl == 1 & months_post_implant < times ~ "Transplant",
        pt_outcome_cess == 1 & months_post_implant < times ~ "Cessation of support",
        pt_outcome_dead == 0 &
          pt_outcome_txpl == 0 &
          pt_outcome_cess == 0 &
          months_post_implant < times ~ "Censored",
          TRUE ~ "Alive on device"
      ),
      demo_race = case_when(
        demo_race_af_amer == 'yes' ~ "Black",
        demo_race_white == 'yes' ~ "White",
        TRUE ~ "Other"
      ),
      demo_gender = fct_recode(
        demo_gender,
        Male = 'male',
        Female = 'female',
      ),
      demo_race = fct_infreq(demo_race),
      pi_hgt_m = pi_hgt_cm / 100,
      pi_bmi = pi_wgt_kg / pi_hgt_m^2,
      pi_device_strategy = fct_recode(
        pi_device_strategy,
        'Destination therapy'  = "destination_therapy_patient_definitely_not_eligible_for_transplant",
        'Bridge to transplant' = "bridge_to_transplant_patient_currently_listed_for_transplant",
        'Bridge to transplant' = "possible_bridge_to_transplant_likely_to_be_eligible",
        'Bridge to transplant' = "possible_bridge_to_transplant_moderate_likelihood_of_becoming_eligible",
        'Bridge to transplant' = "possible_bridge_to_transplant_unlikely_to_become_eligible",
        'Other' = "bridge_to_recovery",
        'Other' = 'rescue_therapy',
        'Other' = 'other_specify'
      ),
      im_device_ty = fct_recode(
        im_device_ty,
        'Left-ventricular assistance device' = 'lvad',
        'Bi-ventricular assistance device'   = 'bivad'
      )
    ) %>%
    select(
      status,
      #months_post_implant,
      demo_age,
      demo_gender,
      demo_race,
      pi_bmi,
      pi_device_strategy,
      pi_lvedd,
      pi_albumin_g_dl,
      pi_creat_mg_dl,
      pi_cv_pres,
      pi_peripheral_edema,
      pi_bun_mg_dl,
      pi_bili_total_mg_dl,
      im_device_ty,
      im_surgery_time,
      im_cpb_time
    )



}
