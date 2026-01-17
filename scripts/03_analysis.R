# =============================================================================
# Script 03: Statistical Analysis
# Project: Distance and Geographic Size in Latin America
# Description: Descriptive statistics, correlations, and regression analysis
# =============================================================================

library(tidyverse)
library(car)  # For VIF diagnostics

cat("Starting statistical analysis...\n")

# =============================================================================
# 1. Load processed data
# =============================================================================

analysis_data <- read_csv("data/processed/analysis_data.csv", show_col_types = FALSE)

cat("Loaded data:", nrow(analysis_data), "observations\n")

# =============================================================================
# 2. Descriptive Statistics
# =============================================================================

cat("\n=== DESCRIPTIVE STATISTICS ===\n")

# Summary statistics for key variables
desc_stats <- analysis_data %>%
  select(
    distance_km,
    land_area_km2,
    gdp_pc,
    population,
    years_independent
  ) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value") %>%
  group_by(variable) %>%
  summarize(
    n = n(),
    mean = mean(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE),
    min = min(value, na.rm = TRUE),
    median = median(value, na.rm = TRUE),
    max = max(value, na.rm = TRUE),
    .groups = "drop"
  )

print(desc_stats)

# Save to file
write_csv(desc_stats, "output/tables/descriptive_statistics.csv")

# =============================================================================
# 3. Correlation Matrix
# =============================================================================

cat("\n=== CORRELATION MATRIX ===\n")

cor_vars <- analysis_data %>%
  select(
    `Distance (km)` = distance_km,
    `Land Area (km²)` = land_area_km2,
    `GDP per capita` = gdp_pc,
    `Population` = population,
    `Years Independent` = years_independent
  )

cor_matrix <- cor(cor_vars, use = "complete.obs")
print(round(cor_matrix, 3))

# Save correlation matrix
write.csv(cor_matrix, "output/tables/correlation_matrix.csv")

# =============================================================================
# 4. Main Regression Model
# =============================================================================

cat("\n=== MAIN REGRESSION MODEL ===\n")
cat("DV: Land Area (log-transformed)\n")
cat("Hypothesis: Distance should have a POSITIVE coefficient\n\n")

# Model specification:
# log(land_area) ~ distance + log(gdp_pc) + log(population) + years_independent

model_main <- lm(
  log_land_area ~ distance_1000km + log_gdp_pc + log_population + years_independent,
  data = analysis_data
)

# Display results
summary(model_main)

# =============================================================================
# 5. Model Diagnostics
# =============================================================================

cat("\n=== MODEL DIAGNOSTICS ===\n")

# Variance Inflation Factors (check for multicollinearity)
cat("\nVariance Inflation Factors (VIF):\n")
cat("(VIF > 10 indicates problematic multicollinearity)\n")
vif_values <- vif(model_main)
print(vif_values)

# Save VIF
write.csv(
  data.frame(variable = names(vif_values), VIF = vif_values),
  "output/tables/vif_diagnostics.csv",
  row.names = FALSE
)

# Residual diagnostics
cat("\nCreating diagnostic plots...\n")
pdf("output/figures/regression_diagnostics.pdf", width = 10, height = 8)
par(mfrow = c(2, 2))
plot(model_main)
dev.off()

# =============================================================================
# 6. Alternative Models for Robustness
# =============================================================================

cat("\n=== ROBUSTNESS CHECKS ===\n")

# Model 2: Bivariate (distance only)
cat("\n--- Model 2: Bivariate (Distance only) ---\n")
model_bivariate <- lm(log_land_area ~ distance_1000km, data = analysis_data)
summary(model_bivariate)

# Model 3: Squared distance term (non-linear relationship?)
cat("\n--- Model 3: Non-linear specification (distance squared) ---\n")
analysis_data <- analysis_data %>%
  mutate(distance_1000km_sq = distance_1000km^2)

model_nonlinear <- lm(
  log_land_area ~ distance_1000km + distance_1000km_sq +
    log_gdp_pc + log_population + years_independent,
  data = analysis_data
)
summary(model_nonlinear)

# Model 4: Without log transformation (raw land area)
cat("\n--- Model 4: Raw land area (no log transformation) ---\n")
model_raw <- lm(
  land_area_km2 ~ distance_1000km + log_gdp_pc + log_population + years_independent,
  data = analysis_data
)
summary(model_raw)

# =============================================================================
# 7. Extract and save regression tables
# =============================================================================

cat("\n=== Saving regression results ===\n")

# Function to extract model results
extract_model_results <- function(model, model_name) {
  coef_table <- summary(model)$coefficients
  tibble(
    model = model_name,
    variable = rownames(coef_table),
    estimate = coef_table[, "Estimate"],
    std_error = coef_table[, "Std. Error"],
    t_value = coef_table[, "t value"],
    p_value = coef_table[, "Pr(>|t|)"],
    significance = case_when(
      p_value < 0.001 ~ "***",
      p_value < 0.01 ~ "**",
      p_value < 0.05 ~ "*",
      p_value < 0.10 ~ ".",
      TRUE ~ ""
    )
  )
}

# Combine results from multiple models
model_results <- bind_rows(
  extract_model_results(model_bivariate, "Model 1: Bivariate"),
  extract_model_results(model_main, "Model 2: Full Model"),
  extract_model_results(model_nonlinear, "Model 3: Non-linear"),
  extract_model_results(model_raw, "Model 4: Raw Land Area")
)

# Add model fit statistics
model_fit <- tibble(
  model = c("Model 1: Bivariate", "Model 2: Full Model", "Model 3: Non-linear", "Model 4: Raw Land Area"),
  r_squared = c(
    summary(model_bivariate)$r.squared,
    summary(model_main)$r.squared,
    summary(model_nonlinear)$r.squared,
    summary(model_raw)$r.squared
  ),
  adj_r_squared = c(
    summary(model_bivariate)$adj.r.squared,
    summary(model_main)$adj.r.squared,
    summary(model_nonlinear)$adj.r.squared,
    summary(model_raw)$adj.r.squared
  ),
  n_obs = c(
    nobs(model_bivariate),
    nobs(model_main),
    nobs(model_nonlinear),
    nobs(model_raw)
  )
)

write_csv(model_results, "output/tables/regression_results.csv")
write_csv(model_fit, "output/tables/model_fit_statistics.csv")

# =============================================================================
# 8. Interpretation
# =============================================================================

cat("\n=== KEY FINDINGS ===\n")

main_coef <- coef(model_main)["distance_1000km"]
main_pval <- summary(model_main)$coefficients["distance_1000km", "Pr(>|t|)"]
main_rsq <- summary(model_main)$r.squared

cat("\nMain Model Results:\n")
cat("- Distance coefficient:", round(main_coef, 4), "\n")
cat("- P-value:", format.pval(main_pval, digits = 3), "\n")
cat("- R-squared:", round(main_rsq, 3), "\n")

if (main_coef > 0 & main_pval < 0.05) {
  cat("\n✓ HYPOTHESIS SUPPORTED:\n")
  cat("  Distance has a significant POSITIVE effect on land area.\n")
  cat("  Countries farther from the US have larger geographic sizes.\n")
  cat("  Interpretation: For every 1,000 km increase in distance from DC,\n")
  cat("  log(land area) increases by", round(main_coef, 3), "units.\n")
  cat("  This represents approximately a", round((exp(main_coef) - 1) * 100, 1), "% increase in land area.\n")
} else if (main_coef > 0) {
  cat("\n~ HYPOTHESIS PARTIALLY SUPPORTED:\n")
  cat("  Distance has a positive effect but is not statistically significant.\n")
} else {
  cat("\n✗ HYPOTHESIS NOT SUPPORTED:\n")
  cat("  Distance has a negative or null effect on geographic size.\n")
}

cat("\n=== Analysis complete ===\n")
cat("Results saved to output/tables/\n")
