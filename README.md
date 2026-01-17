# Distance and Geographic Size in Latin America

## Project Overview

This research project tests a simple geographic hypothesis: Does distance from the United States correlate with the geographic size of Latin American countries?

**Core Research Question:** Is there a positive correlation between distance from the United States and the land area of Latin American countries?

**Hypothesis:** Countries farther from the U.S. will have larger geographic sizes (land areas) than countries closer to the U.S.

---

## Quick Start

### Prerequisites

Ensure you have R (≥ 4.0) and RStudio installed.

### Installation

1. Clone this repository
2. Open R/RStudio in the project directory
3. Install required packages:

```r
install.packages(c(
  "tidyverse",    # Data manipulation and visualization
  "WDI",          # World Bank data
  "geosphere",    # Distance calculations
  "ggrepel",      # Label points on plots
  "countrycode",  # Standardize country codes
  "car",          # Regression diagnostics
  "knitr",        # R Markdown support
  "kableExtra",   # Enhanced tables
  "rmarkdown"     # Generate reports
))
```

### Running the Analysis

Execute scripts in order:

```r
# 1. Collect data from World Bank
source("scripts/01_collect_data.R")

# 2. Clean and merge datasets
source("scripts/02_clean_merge.R")

# 3. Run statistical analysis
source("scripts/03_analysis.R")

# 4. Create visualizations
source("scripts/04_visualize.R")

# 5. Generate HTML report
rmarkdown::render("roche_limit_report.Rmd")
```

**Or run all at once:**

```r
source("scripts/01_collect_data.R")
source("scripts/02_clean_merge.R")
source("scripts/03_analysis.R")
source("scripts/04_visualize.R")
rmarkdown::render("roche_limit_report.Rmd")
```

---

## Project Structure

```
.
├── README.md                      # This file
├── roche_limit_report.Rmd         # Main analysis report
├── data/
│   ├── raw/                       # Downloaded/source data
│   │   ├── capital_distances.csv
│   │   ├── independence_years.csv
│   │   └── wdi_data.csv
│   └── processed/                 # Cleaned, merged data
│       ├── merged_data_all.csv
│       └── analysis_data.csv
├── scripts/
│   ├── 01_collect_data.R          # Download and prepare raw data
│   ├── 02_clean_merge.R           # Merge and clean datasets
│   ├── 03_analysis.R              # Statistical analysis
│   └── 04_visualize.R             # Create figures
└── output/
    ├── figures/                   # Generated plots
    │   ├── distance_geographic_size.png
    │   ├── partial_regression_plot.png
    │   ├── geographic_map.png
    │   ├── variable_distributions.png
    │   ├── coefficient_plot.png
    │   └── regression_diagnostics.pdf
    └── tables/                    # Analysis output
        ├── descriptive_statistics.csv
        ├── correlation_matrix.csv
        ├── regression_results.csv
        ├── model_fit_statistics.csv
        └── vif_diagnostics.csv
```

---

## Research Design

### Sample

- **Unit of Analysis:** Latin American countries (N ≈ 20-22)
- **Included:** Mexico, Central America, Caribbean nations (pop > 500k), South America
- **Excluded:** U.S. territories, non-independent states

### Variables

| Variable | Measure | Source |
|----------|---------|--------|
| **Land Area** (DV) | Total land area in square kilometers | World Bank WDI |
| **Distance** (Key IV) | Great-circle distance from capital to Washington DC (km) | Calculated |
| **GDP per capita** (Control) | Log of constant 2015 USD | World Bank WDI |
| **Population** (Control) | Log of total population | World Bank WDI |
| **Years Independent** (Control) | Years since independence | Manual coding |

### Model Specification

```
Log(Land Area) = β₀ + β₁(Distance) + β₂(log GDP pc) + β₃(log Pop) + β₄(Years Indep) + ε
```

**Test:** β₁ > 0 and statistically significant

---

## Key Findings

Run the analysis to discover:

1. Whether distance from the U.S. predicts geographic size
2. Whether this relationship holds after controlling for economic development
3. Robustness of the finding across alternative specifications

**Expected Results (if hypothesis is supported):**

- Positive and significant coefficient on distance
- Effect size: increase in land area per 1,000 km of distance
- Relationship visible in scatterplot and partial regression plot

---

## Data Sources

### World Bank

**World Development Indicators (WDI):**
- Land area: `AG.LND.TOTL.K2`
- GDP per capita: `NY.GDP.PCAP.KD`
- Population: `SP.POP.TOTL`
- **Website:** https://data.worldbank.org

### Geographic Data

- Capital coordinates: Standard geographic references
- Distance calculation: Haversine formula via `geosphere` package

---

## Methodology

### Data Collection (Script 01)

1. Defines Latin American sample (22 countries)
2. Codes capital coordinates and calculates distances to Washington DC
3. Downloads World Bank indicators (land area, GDP, population)
4. Codes independence years
5. Saves raw datasets

### Data Preparation (Script 02)

1. Merges all data sources by ISO3 country codes
2. Creates log-transformed variables
3. Handles missing data
4. Produces analysis-ready datasets

### Statistical Analysis (Script 03)

1. **Descriptive statistics:** Summary stats and correlations
2. **Main model:** OLS regression with full controls
3. **Diagnostics:** VIF for multicollinearity, residual plots
4. **Robustness checks:**
   - Bivariate model (distance only)
   - Non-linear specification (distance squared)

### Visualization (Script 04)

1. Main scatterplot: Distance vs. geographic size with regression line
2. Partial regression plot: Relationship controlling for covariates
3. Geographic map: Spatial distribution
4. Coefficient plot: Regression results with confidence intervals
5. Distribution plots: Variable summaries

### Report (R Markdown)

Comprehensive HTML report including:
- Introduction and research question
- Research design
- Descriptive statistics
- Regression results
- Diagnostics and robustness checks
- Interpretation and conclusions

---

## Interpretation Guide

### If Distance Coefficient is Positive and Significant

✓ **Hypothesis SUPPORTED**

- Countries farther from the U.S. have larger land areas
- Geographic distance correlates with country size

### If Distance Coefficient is Positive but Not Significant

~ **Hypothesis PARTIALLY SUPPORTED**

- Suggestive pattern but insufficient evidence
- May require larger sample or refined measures

### If Distance Coefficient is Negative or Null

✗ **Hypothesis NOT SUPPORTED**

- No evidence for the distance-size relationship
- Geographic size patterns explained by other factors

---

## Limitations

1. **Small N (≈20 observations)**
   - Limited statistical power
   - Cannot include many controls simultaneously
   - Individual cases have large influence

2. **Correlation vs. Causation**
   - Correlational, not causal
   - Cannot establish directional relationship
   - Omitted variables may drive the pattern

3. **Measurement**
   - Distance is simple great-circle metric
   - Land area excludes territorial waters
   - Cross-sectional design misses temporal dynamics

4. **Scope**
   - Limited to Latin America
   - May not generalize to other regions

---

## Extensions (Future Work)

1. **Regional Comparison:** Test in other world regions
2. **Historical Analysis:** Examine how relationships change over time
3. **Additional Controls:** Colonial history, terrain, climate zones
4. **Alternative Measures:** Include territorial waters, EEZ boundaries

---

## Citation

If you use this code or analysis, please cite:

```
[Author Name]. (2025). Distance and Geographic Size in Latin America.
GitHub repository: [URL]
```

---

## License

This project is released under the MIT License. Data sources retain their original licenses.

---

## Contact

For questions or suggestions, please open an issue on GitHub or contact [your contact info].

---

## Acknowledgments

- World Bank for development indicators
- R community for excellent open-source tools

---

**Last Updated:** January 2025
