##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title
##' @param sim_output
tabulate_md_strat <- function(sim_output,
                              md_method_labels,
                              md_type_labels,
                              model_labels,
                              outcome_labels,
                              additional_missing_labels) {

  rspec <- round_spec() %>%
    round_using_decimal(digits = 2) %>%
    round_half_even()

  md_method_comparators <- sim_output %>%
    pull(md_strat) %>%
    unique() %>%
    setdiff("meanmode_si")

  tbl_data <- sim_output %>%
    group_by(md_strat, model, outcome, additional_missing_pct) %>%
    #mutate(iteration = seq(n())) %>%
    ungroup() %>%
    select(iteration,
           outcome,
           model,
           md_strat,
           additional_missing_pct,
           auc,
           ipa,
           cal_error) %>%
    pivot_longer(cols = c(auc, ipa, cal_error),
                 names_to = 'metric') %>%
    split(f = list(.$outcome, .$metric)) %>%
    map(
      ~ .x %>%
          select(-outcome, -metric) %>%
          pivot_wider(values_from = value, names_from = md_strat) %>%
          mutate(
            across(
              .cols = any_of(md_method_comparators),
              .fns = ~ .x - meanmode_si
            )
          ) %>%
          pivot_longer(cols = -c(iteration, model, additional_missing_pct),
                       names_to = 'md_strat') %>%
          group_by(model, md_strat, additional_missing_pct) %>%
          summarize(
            est = 100 * median(value, na.rm = TRUE),
            lwr = 100 * quantile(value, probs = 0.25, na.rm = TRUE),
            upr = 100 * quantile(value, probs = 0.75, na.rm = TRUE)
          ) %>%
          ungroup()
    )

  tbl_inline <- tbl_data %>%
    map(mutate,
        tbl_value = table_glue("{est} ({lwr}, {upr})"),
        additional_missing_pct = paste0('miss_', additional_missing_pct)
    ) %>%
    map(as_inline,
        tbl_variables = c('model', 'md_strat', 'additional_missing_pct'),
        tbl_values = 'tbl_value'
    )

  pm <- function(x) ifelse(x > 0, "+", "")

  tbl_objects <- tbl_data %>%
    map(
      ~ {
        gt_data <- .x %>%
        mutate(
          model = recode(model, !!!model_labels),
          additional_missing_pct = factor(
            additional_missing_pct,
            levels = additional_missing_labels,
            labels = names(additional_missing_labels)
          ),
          md_strat = str_replace(md_strat, 'mia', 'mia_si'),
          table_val = if_else(
            md_strat == 'meanmode_si',
            true = table_glue("{est} (reference)", rspec=rspec),
            false = table_glue("{pm(est)}{est}<br/>({lwr}, {upr})", rspec=rspec)
          )
        ) %>%
        select(-est, -lwr, -upr) %>%
        separate(md_strat, into = c('md_method', 'md_type')) %>%
        pivot_wider(names_from = md_type, values_from = table_val) %>%
        mutate(
          md_method = factor(md_method,
                             levels = names(md_method_labels),
                             labels = md_method_labels)
        ) %>%
        arrange(md_method) %>%
        filter(!(md_method == 'Missingness as an attribute' &
                   model == 'Proportional hazards')) %>%
        rename(MI = mi, SI = si) %>%
        pivot_wider(names_from = model, values_from = c(SI, MI)) %>%
        select(
          additional_missing_pct,
          md_method,
          `SI_Proportional hazards`,
          `MI_Proportional hazards`,
          `SI_Gradient boosted decision trees`,
          `MI_Gradient boosted decision trees`
        )

      cols <- str_detect(names(gt_data), pattern = 'MI$|SI$')
      cols <- names(gt_data)[cols]

      gt(gt_data,
         groupname_col = 'additional_missing_pct',
         rowname_col = 'md_method') %>%
        tab_stubhead(label = md('__Imputation method__')) %>%
        fmt_missing(columns = everything(),
                    missing_text = '--') %>%
        fmt_markdown(columns = TRUE) %>%
        tab_spanner(label = 'Proportional hazards',
                    columns = c("SI_Proportional hazards",
                                "MI_Proportional hazards")) %>%
        tab_spanner(label = "Gradient boosted decision trees",
                    columns = c("SI_Gradient boosted decision trees",
                                "MI_Gradient boosted decision trees")) %>%
        tab_style(
          style = list(cell_fill(color = 'grey'),
                       cell_text(style = "italic")),
          locations = cells_row_groups()
        ) %>%
        cols_label(
          "MI_Proportional hazards" = 'Multiple Imputation',
          "SI_Proportional hazards" = 'Single Imputation',
          "MI_Gradient boosted decision trees" = 'Multiple Imputation',
          "SI_Gradient boosted decision trees" = 'Single Imputation',
        ) %>%
        cols_align('center')
      }

    )

  list(inline = tbl_inline,
       objects = tbl_objects)

}
