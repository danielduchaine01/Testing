# =============================================================================
# Script 02: Data Cleaning and Merging
# Project: Testing the Geopolitical Roche Limit
# Description: Merges all datasets and prepares analysis-ready data
# =============================================================================

library(tidyverse)
library(countrycode)

cat("Starting data cleaning and merging...\n")

# =============================================================================
# 1. Load raw data
# =============================================================================

capital_distances <- read_csv("data/raw/capital_distances.csv", show_col_types = FALSE)
independence_years <- read_csv("data/raw/independence_years.csv", show_col_types = FALSE)
wdi_data <- read_csv("data/raw/wdi_data.csv", show_col_types = FALSE)
vdem_data <- read_csv("data/raw/vdem_data.csv", show_col_types = FALSE)
wgi_data <- read_csv("data/raw/wgi_data.csv", show_col_types = FALSE)

cat("Loaded all raw data files\n")

# =============================================================================
# 2. Merge datasets
# =============================================================================

# Start with distance data and add other variables
analysis_data <- capital_distances %>%
  select(country, capital, lat, lon, distance_km) %>%
  # Add independence years
  left_join(independence_years, by = "country") %>%
  # Add World Bank data
  left_join(wdi_data, by = "country") %>%
  # Add V-Dem state capacity
  left_join(vdem_data, by = "country") %>%
  # Add WGI government effectiveness
  left_join(wgi_data, by = "country")

cat("Merged", nrow(analysis_data), "observations\n")

# =============================================================================
# 3. Create transformed variables
# =============================================================================

analysis_data <- analysis_data %>%
  mutate(
    # Log transformations for skewed variables
    log_gdp_pc = log(gdp_pc),
    log_population = log(population),

    # Distance in thousands of km for easier interpretation
    distance_1000km = distance_km / 1000,

    # Add country names for plotting
    country_name = countrycode(country, "iso3c", "country.name")
  )

# =============================================================================
# 4. Check for missing data
# =============================================================================

cat("\n=== Missing data summary ===\n")
missing_summary <- analysis_data %>%
  summarize(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
  filter(missing_count > 0)

if (nrow(missing_summary) > 0) {
  print(missing_summary)
} else {
  cat("No missing data detected!\n")
}

# =============================================================================
# 5. Create complete cases dataset for analysis
# =============================================================================

# Key variables for main analysis
key_vars <- c("country", "country_name", "capital", "distance_km", "distance_1000km",
              "state_capacity", "gdp_pc", "log_gdp_pc", "population", "log_population",
              "years_independent", "gov_effectiveness")

analysis_data_complete <- analysis_data %>%
  select(all_of(key_vars)) %>%
  drop_na(state_capacity, gdp_pc, population, years_independent)

cat("\nComplete cases for main analysis:", nrow(analysis_data_complete), "countries\n")

# Also create a version for robustness check with WGI
analysis_data_wgi <- analysis_data %>%
  select(all_of(key_vars)) %>%
  drop_na(gov_effectiveness, gdp_pc, population, years_independent)

cat("Complete cases for WGI robustness check:", nrow(analysis_data_wgi), "countries\n")

# =============================================================================
# 6. Save processed data
# =============================================================================

write_csv(analysis_data, "data/processed/merged_data_all.csv")
write_csv(analysis_data_complete, "data/processed/analysis_data.csv")
write_csv(analysis_data_wgi, "data/processed/analysis_data_wgi.csv")

cat("\n=== Data cleaning complete ===\n")
cat("Processed data saved to data/processed/\n")
cat("- merged_data_all.csv:", nrow(analysis_data), "observations\n")
cat("- analysis_data.csv:", nrow(analysis_data_complete), "observations\n")
cat("- analysis_data_wgi.csv:", nrow(analysis_data_wgi), "observations\n")

# =============================================================================
# 7. Preview the final dataset
# =============================================================================

cat("\n=== Preview of analysis dataset ===\n")
print(
  analysis_data_complete %>%
    select(country_name, distance_km, state_capacity, gdp_pc, years_independent) %>%
    arrange(distance_km) %>%
    head(10)
)
