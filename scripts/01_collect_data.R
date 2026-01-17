# =============================================================================
# Script 01: Data Collection
# Project: Distance and Geographic Size in Latin America
# Description: Collects World Bank data on land area and development indicators,
#              calculates distances, and codes independence years
# =============================================================================

# Load required packages
library(tidyverse)
library(WDI)
library(geosphere)
library(countrycode)

# Suppress messages
options(warn = -1)

cat("Starting data collection...\n")

# =============================================================================
# 1. Define Latin American countries
# =============================================================================

latin_america <- c(
  "Argentina", "Bolivia", "Brazil", "Chile", "Colombia",
  "Costa Rica", "Cuba", "Dominican Republic", "Ecuador",
  "El Salvador", "Guatemala", "Haiti", "Honduras",
  "Mexico", "Nicaragua", "Panama", "Paraguay", "Peru",
  "Uruguay", "Venezuela", "Jamaica", "Trinidad and Tobago"
)

# Convert to ISO3 codes for consistency
latin_america_iso3 <- countrycode(latin_america, "country.name", "iso3c")
cat("Sample includes", length(latin_america_iso3), "Latin American countries\n")

# =============================================================================
# 2. Capital coordinates and distance to Washington DC
# =============================================================================

# Capital city coordinates (latitude, longitude)
capital_coords <- tribble(
  ~country,              ~capital,           ~lat,      ~lon,
  "ARG",                "Buenos Aires",     -34.6037,  -58.3816,
  "BOL",                "La Paz",           -16.5000,  -68.1500,
  "BRA",                "Brasília",         -15.7939,  -47.8828,
  "CHL",                "Santiago",         -33.4489,  -70.6693,
  "COL",                "Bogotá",            4.7110,   -74.0721,
  "CRI",                "San José",          9.9281,   -84.0907,
  "CUB",                "Havana",           23.1136,   -82.3666,
  "DOM",                "Santo Domingo",    18.4861,   -69.9312,
  "ECU",                "Quito",            -0.1807,   -78.4678,
  "SLV",                "San Salvador",     13.6929,   -89.2182,
  "GTM",                "Guatemala City",   14.6349,   -90.5069,
  "HTI",                "Port-au-Prince",   18.5944,   -72.3074,
  "HND",                "Tegucigalpa",      14.0723,   -87.1921,
  "MEX",                "Mexico City",      19.4326,   -99.1332,
  "NIC",                "Managua",          12.1150,   -86.2362,
  "PAN",                "Panama City",       8.9824,   -79.5199,
  "PRY",                "Asunción",         -25.2637,  -57.5759,
  "PER",                "Lima",             -12.0464,  -77.0428,
  "URY",                "Montevideo",       -34.9011,  -56.1645,
  "VEN",                "Caracas",           10.4806,  -66.9036,
  "JAM",                "Kingston",          17.9714,  -76.7931,
  "TTO",                "Port of Spain",     10.6549,  -61.5019
)

# Washington DC coordinates
dc_coords <- c(lon = -77.0369, lat = 38.9072)

# Calculate great-circle distances (in kilometers)
capital_coords <- capital_coords %>%
  rowwise() %>%
  mutate(
    distance_km = distHaversine(
      c(lon, lat),
      dc_coords
    ) / 1000  # Convert meters to kilometers
  ) %>%
  ungroup()

cat("Calculated distances to Washington DC for", nrow(capital_coords), "countries\n")

# =============================================================================
# 3. Years since independence
# =============================================================================

independence_years <- tribble(
  ~country,  ~independence_year,
  "ARG",     1816,
  "BOL",     1825,
  "BRA",     1822,
  "CHL",     1818,
  "COL",     1810,
  "CRI",     1821,
  "CUB",     1902,  # From Spain 1898, from US occupation 1902
  "DOM",     1844,  # From Haiti
  "ECU",     1822,
  "SLV",     1821,
  "GTM",     1821,
  "HTI",     1804,
  "HND",     1821,
  "MEX",     1821,
  "NIC",     1821,
  "PAN",     1903,  # From Colombia
  "PRY",     1811,
  "PER",     1821,
  "URY",     1825,
  "VEN",     1811,
  "JAM",     1962,  # From UK
  "TTO",     1962   # From UK
)

# Calculate years independent (as of 2025)
current_year <- 2025
independence_years <- independence_years %>%
  mutate(years_independent = current_year - independence_year)

cat("Coded independence years for", nrow(independence_years), "countries\n")

# =============================================================================
# 4. World Bank Development Indicators
# =============================================================================

cat("Downloading World Bank data...\n")

# Get GDP per capita, population, and land area (most recent 5 years for averaging)
wdi_data <- WDI(
  country = latin_america_iso3,
  indicator = c(
    "NY.GDP.PCAP.KD",  # GDP per capita (constant 2015 USD)
    "SP.POP.TOTL",     # Population
    "AG.LND.TOTL.K2"   # Land area (sq. km) - Our dependent variable
  ),
  start = 2018,
  end = 2022,
  extra = TRUE
)

# Average over recent years to reduce year-to-year volatility
wdi_avg <- wdi_data %>%
  filter(!is.na(NY.GDP.PCAP.KD), !is.na(SP.POP.TOTL), !is.na(AG.LND.TOTL.K2)) %>%
  group_by(iso3c) %>%
  summarize(
    gdp_pc = mean(NY.GDP.PCAP.KD, na.rm = TRUE),
    population = mean(SP.POP.TOTL, na.rm = TRUE),
    land_area_km2 = mean(AG.LND.TOTL.K2, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  rename(country = iso3c)

cat("Downloaded World Bank data for", nrow(wdi_avg), "countries\n")

# =============================================================================
# 5. Save raw data files
# =============================================================================

# Save each dataset
write_csv(capital_coords, "data/raw/capital_distances.csv")
write_csv(independence_years, "data/raw/independence_years.csv")
write_csv(wdi_avg, "data/raw/wdi_data.csv")

cat("\n=== Data collection complete ===\n")
cat("Raw data files saved to data/raw/\n")
cat("- capital_distances.csv:", nrow(capital_coords), "countries\n")
cat("- independence_years.csv:", nrow(independence_years), "countries\n")
cat("- wdi_data.csv:", nrow(wdi_avg), "countries\n")
