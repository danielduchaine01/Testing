# =============================================================================
# Script 04: Visualization
# Project: Testing the Geopolitical Roche Limit
# Description: Creates figures for the analysis
# =============================================================================

library(tidyverse)
library(ggrepel)  # For better label placement
library(scales)   # For formatting axes

cat("Starting visualization creation...\n")

# =============================================================================
# 1. Load processed data
# =============================================================================

analysis_data <- read_csv("data/processed/analysis_data.csv", show_col_types = FALSE)

cat("Loaded data:", nrow(analysis_data), "observations\n")

# =============================================================================
# 2. Main Figure: Distance vs. State Capacity
# =============================================================================

cat("\nCreating main scatterplot: Distance vs. State Capacity...\n")

# Identify outliers (residuals from simple regression)
model_simple <- lm(state_capacity ~ distance_km, data = analysis_data)
analysis_data <- analysis_data %>%
  mutate(
    residual = residuals(model_simple),
    is_outlier = abs(residual) > 1.5 * sd(residual, na.rm = TRUE)
  )

# Create main plot
p_main <- ggplot(analysis_data, aes(x = distance_km, y = state_capacity)) +
  geom_point(aes(size = population / 1e6), alpha = 0.6, color = "#2E86AB") +
  geom_smooth(method = "lm", se = TRUE, color = "#A23B72", fill = "#A23B72", alpha = 0.2) +
  geom_text_repel(
    aes(label = ifelse(is_outlier, country_name, "")),
    size = 3,
    box.padding = 0.5,
    max.overlaps = 10
  ) +
  scale_size_continuous(
    name = "Population\n(millions)",
    range = c(2, 12),
    breaks = c(10, 50, 100, 200)
  ) +
  scale_x_continuous(labels = comma_format()) +
  labs(
    title = "The Geopolitical Roche Limit: Distance and State Capacity in Latin America",
    subtitle = "Countries farther from Washington DC show higher state consolidation",
    x = "Distance from Washington DC (km)",
    y = "State Capacity (V-Dem Index)",
    caption = "Note: Point size represents population. Outliers labeled.\nSource: V-Dem, World Bank"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )

ggsave("output/figures/distance_state_capacity.png",
       p_main, width = 10, height = 7, dpi = 300)

# =============================================================================
# 3. Supplementary Figure: Partial Regression Plot
# =============================================================================

cat("Creating partial regression plot (controlling for GDP)...\n")

# Run full model
model_full <- lm(
  state_capacity ~ distance_1000km + log_gdp_pc + log_population + years_independent,
  data = analysis_data
)

# Get partial residuals for distance
analysis_data <- analysis_data %>%
  mutate(
    state_capacity_resid = residuals(lm(state_capacity ~ log_gdp_pc + log_population + years_independent, data = analysis_data)),
    distance_resid = residuals(lm(distance_1000km ~ log_gdp_pc + log_population + years_independent, data = analysis_data))
  )

p_partial <- ggplot(analysis_data, aes(x = distance_resid, y = state_capacity_resid)) +
  geom_point(alpha = 0.6, size = 3, color = "#2E86AB") +
  geom_smooth(method = "lm", se = TRUE, color = "#A23B72", fill = "#A23B72", alpha = 0.2) +
  geom_text_repel(
    aes(label = country_name),
    size = 2.5,
    max.overlaps = 5
  ) +
  labs(
    title = "Partial Regression: Distance Effect After Controlling for Development",
    subtitle = "Residual plot showing distance effect net of GDP, population, and independence",
    x = "Distance (residual, in 1000s of km)",
    y = "State Capacity (residual)",
    caption = "Source: V-Dem, World Bank"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    panel.grid.minor = element_blank()
  )

ggsave("output/figures/partial_regression_plot.png",
       p_partial, width = 9, height = 6, dpi = 300)

# =============================================================================
# 4. Geographic Map Visualization
# =============================================================================

cat("Creating map visualization...\n")

p_map <- ggplot(analysis_data, aes(x = lon, y = lat)) +
  geom_point(aes(size = state_capacity, color = distance_km), alpha = 0.8) +
  scale_color_gradient2(
    low = "#A23B72",
    mid = "#F18F01",
    high = "#2E86AB",
    midpoint = median(analysis_data$distance_km),
    name = "Distance\nfrom DC (km)"
  ) +
  scale_size_continuous(
    name = "State\nCapacity",
    range = c(3, 12)
  ) +
  geom_text_repel(
    aes(label = country_name),
    size = 2.5,
    max.overlaps = 15,
    segment.size = 0.2
  ) +
  labs(
    title = "Geographic Distribution of State Capacity in Latin America",
    subtitle = "Color = distance from US; Size = state capacity level",
    x = "Longitude",
    y = "Latitude",
    caption = "Source: V-Dem"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    panel.grid.minor = element_blank()
  )

ggsave("output/figures/geographic_map.png",
       p_map, width = 9, height = 7, dpi = 300)

# =============================================================================
# 5. Variable Distributions
# =============================================================================

cat("Creating distribution plots...\n")

# Prepare data for faceted plot
dist_data <- analysis_data %>%
  select(
    `Distance (km)` = distance_km,
    `State Capacity` = state_capacity,
    `GDP per capita` = gdp_pc,
    `Population` = population,
    `Years Independent` = years_independent
  ) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value")

p_distributions <- ggplot(dist_data, aes(x = value)) +
  geom_histogram(fill = "#2E86AB", alpha = 0.7, bins = 15) +
  facet_wrap(~variable, scales = "free", ncol = 2) +
  labs(
    title = "Distribution of Key Variables",
    x = NULL,
    y = "Count"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold", size = 10)
  )

ggsave("output/figures/variable_distributions.png",
       p_distributions, width = 9, height = 7, dpi = 300)

# =============================================================================
# 6. Coefficient Plot (Model Comparison)
# =============================================================================

cat("Creating coefficient plot...\n")

# Extract coefficients from models
model_results <- tibble(
  variable = c("Distance (1000 km)", "Log GDP per capita", "Log Population", "Years Independent"),
  estimate = coef(model_full)[2:5],
  std_error = summary(model_full)$coefficients[2:5, "Std. Error"]
) %>%
  mutate(
    ci_lower = estimate - 1.96 * std_error,
    ci_upper = estimate + 1.96 * std_error,
    significant = !(ci_lower < 0 & ci_upper > 0)
  )

p_coef <- ggplot(model_results, aes(x = estimate, y = reorder(variable, estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbarh(
    aes(xmin = ci_lower, xmax = ci_upper, color = significant),
    height = 0.2,
    size = 1
  ) +
  geom_point(aes(color = significant), size = 4) +
  scale_color_manual(
    values = c("TRUE" = "#A23B72", "FALSE" = "gray60"),
    guide = "none"
  ) +
  labs(
    title = "Regression Coefficients with 95% Confidence Intervals",
    subtitle = "Predictors of state capacity in Latin America",
    x = "Coefficient Estimate",
    y = NULL,
    caption = "Note: Colored points indicate statistically significant effects (p < 0.05)"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    panel.grid.minor = element_blank(),
    panel.grid.major.y = element_blank()
  )

ggsave("output/figures/coefficient_plot.png",
       p_coef, width = 8, height = 5, dpi = 300)

# =============================================================================
# 7. Summary
# =============================================================================

cat("\n=== Visualization complete ===\n")
cat("Figures saved to output/figures/:\n")
cat("1. distance_state_capacity.png - Main scatterplot\n")
cat("2. partial_regression_plot.png - Controlled relationship\n")
cat("3. geographic_map.png - Spatial distribution\n")
cat("4. variable_distributions.png - Data distributions\n")
cat("5. coefficient_plot.png - Regression results visualization\n")
cat("6. regression_diagnostics.pdf - Model diagnostics (from 03_analysis.R)\n")
