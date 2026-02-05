# =============================================================================
# Script 04: Visualization
# Project: Distance and National Capability in Latin America
# Description: Creates figures for CINC, land area, and density (Roche) analysis
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
# 2. Main Figure: Distance vs. National Capability (CINC)
# =============================================================================

cat("\nCreating main scatterplot: Distance vs. CINC...\n")

# Identify outliers (residuals from simple regression)
model_simple <- lm(cinc_pct ~ distance_km, data = analysis_data)
analysis_data <- analysis_data %>%
  mutate(
    residual = residuals(model_simple),
    is_outlier = abs(residual) > 1.5 * sd(residual, na.rm = TRUE)
  )

# Create main plot
p_main <- ggplot(analysis_data, aes(x = distance_km, y = cinc_pct)) +
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
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Distance and National Capability in Latin America",
    subtitle = "Relationship between distance from Washington DC and CINC score",
    x = "Distance from Washington DC (km)",
    y = "CINC Score (% of world capability)",
    caption = "Note: Point size represents population. Outliers labeled.\nSource: Correlates of War NMC 6.0"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    legend.position = "right",
    panel.grid.minor = element_blank()
  )

ggsave("output/figures/distance_cinc.png",
       p_main, width = 10, height = 7, dpi = 300)

# =============================================================================
# 3. Supplementary Figure: Partial Regression Plot
# =============================================================================

cat("Creating partial regression plot (controlling for GDP and population)...\n")

# Run full model
model_full <- lm(
  log_cinc ~ distance_1000km + log_gdp_pc + log_population + years_independent,
  data = analysis_data
)

# Get partial residuals for distance
analysis_data <- analysis_data %>%
  mutate(
    cinc_resid = residuals(lm(log_cinc ~ log_gdp_pc + log_population + years_independent, data = analysis_data)),
    distance_resid = residuals(lm(distance_1000km ~ log_gdp_pc + log_population + years_independent, data = analysis_data))
  )

p_partial <- ggplot(analysis_data, aes(x = distance_resid, y = cinc_resid)) +
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
    y = "Log CINC (residual)",
    caption = "Source: Correlates of War NMC 6.0"
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
  geom_point(aes(size = cinc_pct, color = distance_km), alpha = 0.8) +
  scale_color_gradient2(
    low = "#A23B72",
    mid = "#F18F01",
    high = "#2E86AB",
    midpoint = median(analysis_data$distance_km),
    name = "Distance\nfrom DC (km)"
  ) +
  scale_size_continuous(
    name = "CINC Score\n(% of world)",
    range = c(3, 12)
  ) +
  geom_text_repel(
    aes(label = country_name),
    size = 2.5,
    max.overlaps = 20,
    segment.size = 0.2
  ) +
  labs(
    title = "Geographic Distribution of National Capability",
    subtitle = "Color = distance from US; Size = CINC score (US included as reference)",
    x = "Longitude",
    y = "Latitude",
    caption = "Source: Correlates of War NMC 6.0, World Bank"
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
    `CINC (% of world)` = cinc_pct,
    `Land Area (km2)` = land_area_km2,
    `Density (CINC/area)` = density_scaled,
    `GDP per capita` = gdp_pc,
    `Population` = population,
    `Years Independent` = years_independent
  ) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "value")

p_distributions <- ggplot(dist_data, aes(x = value)) +
  geom_histogram(fill = "#2E86AB", alpha = 0.7, bins = 15) +
  facet_wrap(~variable, scales = "free", ncol = 3) +
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
       p_distributions, width = 12, height = 9, dpi = 300)

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
    subtitle = "Predictors of log(CINC) in Latin America",
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
# 7. Distance vs. Density (Roche Equation Visualization)
# =============================================================================

cat("Creating Roche density scatterplot: Distance vs. Density...\n")

p_density <- ggplot(analysis_data, aes(x = distance_km, y = density_scaled)) +
  geom_point(aes(size = cinc_pct, color = land_area_km2 / 1e6), alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#A23B72", fill = "#A23B72", alpha = 0.2) +
  geom_text_repel(
    aes(label = country_name),
    size = 2.5,
    max.overlaps = 10
  ) +
  scale_size_continuous(
    name = "CINC Score\n(% of world)",
    range = c(2, 10)
  ) +
  scale_color_gradient(
    low = "#F18F01",
    high = "#2E86AB",
    name = "Land Area\n(million km2)"
  ) +
  scale_x_continuous(labels = comma_format()) +
  labs(
    title = "Geopolitical Density: National Capability per Unit of Geographic Size",
    subtitle = "Density = CINC / Land Area (Roche Equation: density = mass / volume)",
    x = "Distance from Washington DC (km)",
    y = "Density (CINC % per million km2)",
    caption = "Note: Point size = CINC (mass); Color = land area (volume)\nSource: COW NMC 6.0, World Bank"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray40"),
    panel.grid.minor = element_blank()
  )

ggsave("output/figures/distance_density.png",
       p_density, width = 10, height = 7, dpi = 300)

# =============================================================================
# 8. Roche Components Panel (Mass, Volume, Density vs Distance)
# =============================================================================

cat("Creating Roche components panel...\n")

# Prepare panel data in long format
roche_panel <- analysis_data %>%
  select(
    country_name, distance_km,
    `Mass (log CINC)` = log_cinc,
    `Volume (log Land Area)` = log_land_area,
    `Density (log CINC/Area)` = log_density
  ) %>%
  pivot_longer(
    cols = starts_with(c("Mass", "Volume", "Density")),
    names_to = "component",
    values_to = "value"
  )

p_roche_panel <- ggplot(roche_panel, aes(x = distance_km, y = value)) +
  geom_point(alpha = 0.6, size = 2.5, color = "#2E86AB") +
  geom_smooth(method = "lm", se = TRUE, color = "#A23B72", fill = "#A23B72", alpha = 0.2) +
  facet_wrap(~component, scales = "free_y", ncol = 3) +
  scale_x_continuous(labels = comma_format()) +
  labs(
    title = "Roche Equation Components vs. Distance from Washington DC",
    subtitle = "Mass = CINC; Volume = Land Area; Density = CINC / Land Area",
    x = "Distance from Washington DC (km)",
    y = "Value (log scale)",
    caption = "Source: COW NMC 6.0, World Bank"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    strip.text = element_text(face = "bold", size = 11),
    panel.grid.minor = element_blank()
  )

ggsave("output/figures/roche_components_panel.png",
       p_roche_panel, width = 14, height = 5, dpi = 300)

# =============================================================================
# 9. Summary
# =============================================================================

cat("\n=== Visualization complete ===\n")
cat("Figures saved to output/figures/:\n")
cat("1. distance_cinc.png - Main scatterplot (Distance vs CINC)\n")
cat("2. partial_regression_plot.png - Controlled relationship\n")
cat("3. geographic_map.png - Spatial distribution\n")
cat("4. variable_distributions.png - Data distributions\n")
cat("5. coefficient_plot.png - Regression results visualization\n")
cat("6. distance_density.png - Distance vs Density (Roche)\n")
cat("7. roche_components_panel.png - Mass/Volume/Density comparison\n")
cat("8. regression_diagnostics.pdf - Model diagnostics (from 03_analysis.R)\n")
