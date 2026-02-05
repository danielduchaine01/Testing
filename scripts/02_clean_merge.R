# =============================================================================
# Script 02: Data Cleaning and Merging
# Project: Distance and National Capability in Latin America
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
cinc_data <- read_csv("data/raw/cinc_data.csv", show_col_types = FALSE)
wdi_data <- read_csv("data/raw/wdi_data.csv", show_col_types = FALSE)

cat("Loaded all raw data files\n")

# =============================================================================
# 2. Merge datasets
# =============================================================================

# Start with distance data and add other variables
analysis_data <- capital_distances %>%
  select(country, capital, lat, lon, distance_km) %>%
  # Add independence years
  left_join(independence_years, by = "country") %>%
  # Add CINC data (our main dependent variable)
  left_join(cinc_data, by = "country") %>%
  # Add World Bank data (controls)
  left_join(wdi_data, by = "country")

cat("Merged", nrow(analysis_data), "observations\n")

# =============================================================================
# 3. Create transformed variables
# =============================================================================

analysis_data <- analysis_data %>%
  mutate(
    # Log transformations for skewed variables
    log_gdp_pc = log(gdp_pc),
    log_population = log(population),
    # CINC is already a proportion (0-1), use log for analysis
    # Add small constant to avoid log(0) for very small CINC values
    log_cinc = log(cinc + 0.0001),
    # Also create CINC in percentage terms for easier interpretation
    cinc_pct = cinc * 100,

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
key_vars <- c("country", "country_name", "capital", "lat", "lon", "distance_km", "distance_1000km",
              "cinc", "cinc_pct", "log_cinc", "gdp_pc", "log_gdp_pc",
              "population", "log_population", "years_independent")

analysis_data_complete <- analysis_data %>%
  select(all_of(key_vars)) %>%
  drop_na(cinc, gdp_pc, population, years_independent)

cat("\nComplete cases for main analysis:", nrow(analysis_data_complete), "countries\n")

# =============================================================================
# 6. Save processed data
# =============================================================================

write_csv(analysis_data, "data/processed/merged_data_all.csv")
write_csv(analysis_data_complete, "data/processed/analysis_data.csv")

cat("\n=== Data cleaning complete ===\n")
cat("Processed data saved to data/processed/\n")
cat("- merged_data_all.csv:", nrow(analysis_data), "observations\n")
cat("- analysis_data.csv:", nrow(analysis_data_complete), "observations\n")

# =============================================================================
# 7. Preview the final dataset
# =============================================================================

cat("\n=== Preview of analysis dataset ===\n")
print(
  analysis_data_complete %>%
    select(country_name, distance_km, cinc_pct, gdp_pc, years_independent) %>%
    arrange(distance_km) %>%
    head(10)
)
