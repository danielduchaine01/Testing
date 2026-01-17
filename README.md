# Testing the Geopolitical Roche Limit

## Project Overview

This research project tests a novel theoretical framework for understanding state fragmentation in great power spheres of influence. Drawing an analogy from astrophysics, we propose that great powers exert "tidal forces" on nearby states that prevent full political consolidation—similar to how Saturn's gravity prevents its rings from coalescing into moons.

**Core Research Question:** Does proximity to the United States predict lower state capacity in Latin American countries, even after controlling for economic development?

**Hypothesis (H3):** States closer to the U.S. will have lower state capacity than states farther away, holding other factors constant.

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
  "vdemdata",     # V-Dem data (optional but recommended)
  "geosphere",    # Distance calculations
  "ggrepel",      # Label points on plots
  "countrycode",  # Standardize country codes
  "car",          # Regression diagnostics
  "knitr",        # R Markdown support
  "kableExtra",   # Enhanced tables
  "rmarkdown"     # Generate reports
))
```

**Note on vdemdata:** If you don't have the `vdemdata` package, the script will generate placeholder data. For real analysis, install it with:

```r
install.packages("vdemdata")
```

### Running the Analysis

Execute scripts in order:

```r
# 1. Collect data from V-Dem and World Bank
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
│   │   ├── vdem_data.csv
│   │   ├── wdi_data.csv
│   │   └── wgi_data.csv
│   └── processed/                 # Cleaned, merged data
│       ├── merged_data_all.csv
│       ├── analysis_data.csv
│       └── analysis_data_wgi.csv
├── scripts/
│   ├── 01_collect_data.R          # Download and prepare raw data
│   ├── 02_clean_merge.R           # Merge and clean datasets
│   ├── 03_analysis.R              # Statistical analysis
│   └── 04_visualize.R             # Create figures
└── output/
    ├── figures/                   # Generated plots
    │   ├── distance_state_capacity.png
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
| **State Capacity** (DV) | V-Dem Executive Capacity Index (`v2x_execap`) | V-Dem v13 |
| **Distance** (Key IV) | Great-circle distance from capital to Washington DC (km) | Calculated |
| **GDP per capita** (Control) | Log of constant 2015 USD | World Bank WDI |
| **Population** (Control) | Log of total population | World Bank WDI |
| **Years Independent** (Control) | Years since independence | Manual coding |

**Alternative outcome:** World Bank Government Effectiveness index (robustness check)

### Model Specification

```
State Capacity = β₀ + β₁(Distance) + β₂(log GDP pc) + β₃(log Pop) + β₄(Years Indep) + ε
```

**Test:** β₁ > 0 and statistically significant

---

## Key Findings

Run the analysis to discover:

1. Whether distance from the U.S. predicts state capacity
2. Whether this relationship holds after controlling for economic development
3. Robustness of the finding across alternative specifications

**Expected Results (if hypothesis is supported):**

- Positive and significant coefficient on distance
- Effect size: ~0.X increase in state capacity per 1,000 km
- Relationship visible in scatterplot and partial regression plot

---

## Data Sources

### V-Dem (Varieties of Democracy)

- **Variable:** `v2x_execap` (Executive Capacity Index)
- **Time period:** 2018-2022 (averaged)
- **Website:** https://v-dem.net
- **Citation:** Coppedge et al. (2023). "V-Dem Dataset v13"

### World Bank

**World Development Indicators (WDI):**
- GDP per capita: `NY.GDP.PCAP.KD`
- Population: `SP.POP.TOTL`
- **Website:** https://data.worldbank.org

**Worldwide Governance Indicators (WGI):**
- Government Effectiveness: `GE.EST`
- **Website:** https://info.worldbank.org/governance/wgi

### Geographic Data

- Capital coordinates: Standard geographic references
- Distance calculation: Haversine formula via `geosphere` package

---

## Methodology

### Data Collection (Script 01)

1. Defines Latin American sample (22 countries)
2. Codes capital coordinates and calculates distances to Washington DC
3. Downloads World Bank indicators (GDP, population, governance)
4. Loads V-Dem state capacity data
5. Codes independence years
6. Saves raw datasets

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
   - Alternative outcome (WGI Government Effectiveness)
   - Non-linear specification (distance squared)

### Visualization (Script 04)

1. Main scatterplot: Distance vs. state capacity with regression line
2. Partial regression plot: Relationship controlling for covariates
3. Geographic map: Spatial distribution
4. Coefficient plot: Regression results with confidence intervals
5. Distribution plots: Variable summaries

### Report (R Markdown)

Comprehensive HTML report including:
- Introduction and theory
- Research design
- Descriptive statistics
- Regression results
- Diagnostics and robustness checks
- Interpretation and conclusions

---

## Interpretation Guide

### If Distance Coefficient is Positive and Significant

✓ **Hypothesis SUPPORTED**

- Countries farther from the U.S. have higher state capacity
- Consistent with the "geopolitical Roche limit" framework
- Great power proximity may create fragmentation pressures

### If Distance Coefficient is Positive but Not Significant

~ **Hypothesis PARTIALLY SUPPORTED**

- Suggestive pattern but insufficient evidence
- May require larger sample or refined measures

### If Distance Coefficient is Negative or Null

✗ **Hypothesis NOT SUPPORTED**

- No evidence for the Roche limit mechanism
- State capacity patterns explained by development alone
- Framework needs revision

---

## Limitations

1. **Small N (≈20 observations)**
   - Limited statistical power
   - Cannot include many controls simultaneously
   - Individual cases have large influence

2. **Endogeneity**
   - Reverse causality: U.S. may target weak states for intervention
   - Omitted variables: Colonial history, geography, ethnic fractionalization
   - Correlational, not causal

3. **Measurement**
   - "State capacity" is contested; V-Dem is one operationalization
   - Distance is crude proxy for geopolitical influence
   - Cross-sectional design misses temporal dynamics

4. **Scope**
   - Limited to Latin America in contemporary era
   - May not generalize to other regions or periods

---

## Extensions (Future Work)

1. **Causal Identification:** Instrumental variables, natural experiments
2. **Mechanisms:** Test whether U.S. interventions mediate the relationship
3. **Panel Analysis:** Examine how relationship changes over time
4. **Comparative Analysis:** Test in other great power spheres (Soviet, Chinese)
5. **Interaction Effects:** Operationalize "density" of great power activity

---

## Citation

If you use this code or framework, please cite:

```
[Author Name]. (2025). Testing the Geopolitical Roche Limit:
Distance and State Capacity in Latin America.
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

- V-Dem Institute for state capacity data
- World Bank for development indicators
- R community for excellent open-source tools

---

**Last Updated:** January 2025
