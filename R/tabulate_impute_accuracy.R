##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title

tabulate_impute_accuracy <- function(sim_output,
                                     md_method_labels,
                                     additional_missing_labels) {

  tbl_data_inline <- sim_output %>%
    filter(additional_missing_pct > 0,
           md_strat != 'mia') %>%
    group_by(
      iteration,
      outcome,
      additional_missing_pct,
      model
    ) %>%
    mutate(
      pe = nominal[md_strat == 'meanmode_si'],
      nominal = (nominal - pe) / (1 - pe)
    ) %>%
    select(
      iteration,
      outcome,
      model,
      md_strat,
      additional_missing_pct,
      nominal,
      numeric
    ) %>%
    group_by(md_strat, additional_missing_pct) %>%
    summarize(
      across(
        .cols = c(nominal, numeric),
        .fns = list(
          est = median,
          lwr = ~quantile(.x, probs = 0.025),
          upr = ~quantile(.x, probs = 0.975)
        )
      ),
      .groups = 'drop'
    ) %>%
    mutate(
      nominal = table_glue(
        "{pm(nominal_est)}{nominal_est}<br/>({nominal_lwr}, {nominal_upr})"
      ),
      numeric = table_glue(
        "{pm(numeric_est)}{numeric_est}<br/>({numeric_lwr}, {numeric_upr})"
      ),
      across(
        .cols = c(nominal, numeric),
        .fns = ~str_replace(.x,
                            pattern = fixed('0.00<br/>(0.00, 0.00)'),
                            replacement = fixed('0 (reference)'))
      )
    )

  inline <- tbl_data_inline %>%
    ungroup() %>%
    mutate(
      across(
        .cols = c(nominal, numeric),
        .fns = ~str_replace(.x, pattern = fixed('<br/>'), replacement = ' ')
      ),
      additional_missing_pct = paste0('miss_', additional_missing_pct)
    ) %>%
    as_inline(tbl_variables = c('md_strat', 'additional_missing_pct'),
              tbl_values = c('nominal', 'numeric'))

  tbl_data_formatted <- tbl_data_inline  %>%
    separate(md_strat, into = c('md_method', 'md_type')) %>%
    pivot_wider(values_from = matches("^nominal|^numeric"),
                names_from = md_type) %>%
    select(md_method,
           additional_missing_pct,
           nominal_si,
           nominal_mi,
           numeric_si,
           numeric_mi,
           everything())

  tbl_object <- tbl_data_formatted %>%
    select(md_method:numeric_mi) %>%
    mutate(
      across(
        ends_with("_mi"),
        ~ if_else(is.na(.x), '---', .x)
      ),
      md_method = factor(
        md_method,
        levels = names(md_method_labels),
        labels = md_method_labels),
      additional_missing_pct = factor(
        additional_missing_pct,
        levels = additional_missing_labels[-1],
        labels = names(additional_missing_labels)[-1]
      )
    ) %>%
    arrange(additional_missing_pct, md_method) %>%
    gt(groupname_col = 'additional_missing_pct',
       rowname_col = 'md_method') %>%
    tab_stubhead(label = 'Imputation method') %>%
    tab_spanner(label = 'Nominal variables',
                columns = c('nominal_si', 'nominal_mi')) %>%
    tab_spanner(label = 'Numeric variables',
                columns = c('numeric_si', 'numeric_mi')) %>%
    fmt_markdown(columns = TRUE) %>%
    cols_label(
      nominal_si = 'Single imputation',
      nominal_mi = 'Multiple imputation',
      numeric_si = 'Single imputation',
      numeric_mi = 'Multiple imputation',
      md_method = 'Imputation method'
    ) %>%
    cols_align('center', columns = c('nominal_si', 'nominal_mi',
                                     'numeric_si', 'numeric_mi'))

  list(data = tbl_data_inline,
       inline = inline,
       table = tbl_object)

}

