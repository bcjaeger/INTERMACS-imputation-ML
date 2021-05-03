##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @param sim_output
##' @param md_method_labels
##' @param md_type_labels
##' @param model_labels
##' @param outcome_labels
##' @param additional_missing_labels
##' @param times
##'
##' @title
visualize_sim_output <- function(sim_output,
                                 md_method_labels,
                                 md_type_labels,
                                 model_labels,
                                 outcome_labels,
                                 additional_missing_labels,
                                 times) {

  rspec <- round_spec() %>%
    round_using_decimal(digits = 2) %>%
    round_half_even()

  ggdata <- sim_output %>%
    # remove any failed runs where result is a try error
    drop_na(md_strat) %>%
    mutate(cal_error = cal_error * 1000) %>%
    group_by(outcome, md_strat, model, additional_missing_pct) %>%
    summarize(across(c(auc, ipa, cal_error), mean), .groups = 'drop') %>%
    mutate(md_strat = if_else(md_strat == 'mia',
                              true = 'mia_si',
                              false = md_strat)) %>%
    separate(md_strat, into = c('md_method', 'md_type'), sep = '_') %>%
    group_by(outcome, md_method, model) %>%
    mutate(
      across(
        .cols = c(auc, ipa, cal_error),
        .fns  = list(pct_diff = ~ table_value(100*(max(.x)-min(.x))/min(.x),
                                              rspec = rspec))
      ),
      across(
        .cols = c(auc, ipa, cal_error),
        .fns = list(lbl = ~table_value(100 * .x, rspec = rspec))
      )
    ) %>%
    mutate(md_method = recode(md_method, !!!md_method_labels),
           md_type   = recode(md_type, !!!md_type_labels),
           model     = recode(model, !!!model_labels),
           outcome   = recode(outcome, !!!outcome_labels),
           additional_missing_pct = factor(additional_missing_pct),
           additional_missing_pct = fct_recode(additional_missing_pct,
                                               !!!additional_missing_labels),
           md_type   = fct_relevel(md_type, 'Single imputation'))

  md_methods_upper_only <- c(
    "Mean or mode",
    "Missingness as an attribute"
  )

  # auc plots ----

  lower_values <- ggdata %>%
    group_by(outcome, md_method, model, additional_missing_pct) %>%
    select(-ipa, -cal_error) %>%
    filter(auc == min(auc)) %>%
    ungroup() %>%
    filter(!(md_method %in% md_methods_upper_only)) %>%
    nest(lwr = -c(model, outcome))

  upper_values <- ggdata %>%
    group_by(outcome, md_method, model, additional_missing_pct) %>%
    select(-ipa, -cal_error) %>%
    filter(auc == max(auc)) %>%
    group_by(model) %>%
    nest(upr = -c(model, outcome))

  output_auc <- ggdata %>%
    group_by(model, outcome) %>%
    nest() %>%
    left_join(lower_values) %>%
    left_join(upper_values) %>%
    mutate(
      data = map(
        .x = data,
        .f = ~ .x %>%
          mutate(md_method = fct_reorder(md_method, .x = auc, .fun = max))
      ),
      plot = pmap(
        .l = list(data, lwr, upr),
        .f = function(..data, ..lwr, ..upr) {

          ggplot(..data) +
            aes(x = auc,
                y = md_method,
                fill = md_type) +
            geom_line(aes(group = md_method), color = 'grey') +
            geom_point(size = 3, shape = 21) +
            geom_text(
              data = ..lwr,
              aes(label = auc_lbl),
              nudge_x = -0.006
            ) +
            geom_text(
              data = ..upr,
              aes(label = auc_lbl),
              nudge_x = +0.006
            ) +
            labs(x = glue('Area underneath the ROC curve,',
                          '{times} months post transplant',
                          .sep = ' '),
                 y = '',
                 fill = '') +
            facet_wrap(~additional_missing_pct) +
            theme_bw() +
            scale_x_continuous(
              limits = c(
                min(..data$auc -0.01),
                max(..data$auc +0.01)
              )
            ) +
            scale_fill_manual(values = c("orange", "purple")) +
            theme(legend.position = 'top',
                  panel.grid.major.x = element_blank(),
                  panel.grid.minor.x = element_blank(),
                  panel.grid.major.y = element_line(linetype = 2))
        }
      )
    )

  # ipa plots ----

  lower_values <- ggdata %>%
    group_by(outcome, md_method, model, additional_missing_pct) %>%
    select(-auc, -cal_error) %>%
    filter(ipa == min(ipa)) %>%
    ungroup() %>%
    filter(!(md_method %in% md_methods_upper_only)) %>%
    nest(lwr = -c(model, outcome))

  upper_values <- ggdata %>%
    group_by(outcome, md_method, model, additional_missing_pct) %>%
    select(-auc, -cal_error) %>%
    filter(ipa == max(ipa)) %>%
    group_by(model) %>%
    nest(upr = -c(model, outcome))

  output_ipa <- ggdata %>%
    group_by(model, outcome) %>%
    nest() %>%
    left_join(lower_values) %>%
    left_join(upper_values) %>%
    mutate(
      data = map(
        .x = data,
        .f = ~ .x %>%
          mutate(md_method = fct_reorder(md_method, .x = ipa, .fun = max))
      ),
      plot = pmap(
        .l = list(data, lwr, upr),
        .f = function(..data, ..lwr, ..upr) {
          ggplot(..data) +
            aes(x = ipa,
                y = md_method,
                fill = md_type) +
            geom_line(aes(group = md_method), color = 'grey') +
            geom_point(size = 3, shape = 21) +
            geom_text(
              data = ..lwr,
              aes(label = ipa_lbl),
              nudge_x = -0.006
            ) +
            geom_text(
              data = ..upr,
              aes(label = ipa_lbl),
              nudge_x = +0.006
            ) +
            labs(x = glue('Index of prediction accuracy,',
                          '{times} months post transplant',
                          .sep = ' '),
                 y = '',
                 fill = '') +
            facet_wrap(~additional_missing_pct) +
            theme_bw() +
            scale_x_continuous(
              limits = c(
                min(..data$ipa -0.01),
                max(..data$ipa +0.01)
              )
            ) +
            scale_fill_manual(values = c("orange", "purple")) +
            theme(legend.position = 'top',
                  text = element_text(size = 15),
                  panel.grid.major.x = element_blank(),
                  panel.grid.minor.x = element_blank(),
                  panel.grid.major.y = element_line(linetype = 2))
        }
      )
    )

  # calibration error plots ----

  lower_values <- ggdata %>%
    group_by(outcome, md_method, model, additional_missing_pct) %>%
    select(-auc, -ipa) %>%
    filter(cal_error == min(cal_error)) %>%
    ungroup() %>%
    filter(!(md_method %in% md_methods_upper_only)) %>%
    nest(lwr = -c(model, outcome))

  upper_values <- ggdata %>%
    group_by(outcome, md_method, model, additional_missing_pct) %>%
    select(-auc, -ipa) %>%
    filter(cal_error == max(cal_error)) %>%
    group_by(model) %>%
    nest(upr = -c(model, outcome))

  output_cal_error <- ggdata %>%
    group_by(model, outcome) %>%
    nest() %>%
    left_join(lower_values) %>%
    left_join(upper_values) %>%
    mutate(
      data = map(
        .x = data,
        .f = ~ .x %>%
          mutate(md_method = fct_reorder(md_method, .x = cal_error, .fun = max))
      ),
      plot = pmap(
        .l = list(data, lwr, upr),
        .f = function(..data, ..lwr, ..upr) {
          ggplot(..data) +
            aes(x = cal_error,
                y = md_method,
                fill = md_type) +
            geom_line(aes(group = md_method), color = 'grey') +
            geom_point(size = 3, shape = 21) +
            geom_text(
              data = ..lwr,
              aes(label = cal_error_lbl),
              nudge_x = -0.006
            ) +
            geom_text(
              data = ..upr,
              aes(label = cal_error_lbl),
              nudge_x = +0.006
            ) +
            labs(x = glue('Calibration error,',
                          '{times} months post transplant',
                          .sep = ' '),
                 y = '',
                 fill = '') +
            facet_wrap(~additional_missing_pct) +
            theme_bw() +
            scale_x_continuous(
              limits = c(
                min(..data$cal_error -0.01),
                max(..data$cal_error +0.01)
              )
            ) +
            scale_fill_manual(values = c("orange", "purple")) +
            theme(legend.position = 'top',
                  text = element_text(size = 15),
                  panel.grid.major.x = element_blank(),
                  panel.grid.minor.x = element_blank(),
                  panel.grid.major.y = element_line(linetype = 2))
        }
      )
    )

  bind_rows(auc = output_auc,
            ipa = output_ipa,
            cal_error = output_cal_error,
            .id = 'metric')


}
