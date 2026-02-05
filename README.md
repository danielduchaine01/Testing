# Distance and National Capability in Latin America

## Project Overview

This research project tests a geopolitical analogy inspired by the Roche limit in astrophysics. Using 22 Latin American countries, we examine how **distance from the United States** relates to three properties:

- **Mass** = CINC score (national capability from Correlates of War NMC 6.0)
- **Volume** = Land area (geographic size in km² from World Bank)
- **Density** = Mass / Volume = CINC / Land Area (capability per unit of geographic size)

**Core Research Question:** How does distance from the United States relate to a country's mass (CINC), volume (land area), and density (CINC per land area)?

**Operationalization of Mass:** We use CINC (Composite Index of National Capability) from the Correlates of War National Material Capabilities (NMC) dataset. CINC captures a country's share of total world capabilities across six dimensions:
- Military expenditure
- Military personnel
- Energy consumption
- Iron and steel production
- Urban population
- Total population

---

## Quick Start

### Prerequisites

Ensure you have R (>= 4.0) and RStudio installed.

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
# 1. Collect data from COW NMC and World Bank
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
│   │   ├── cinc_data.csv
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
    │   ├── distance_cinc.png
    │   ├── distance_density.png
    │   ├── roche_components_panel.png
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

- **Unit of Analysis:** Latin American countries (N = 20-22)
- **Included:** Mexico, Central America, Caribbean nations (pop > 500k), South America
- **Excluded:** U.S. territories, non-independent states

### Variables

| Variable | Measure | Source |
|----------|---------|--------|
| **CINC Score** (DV - Mass) | Composite Index of National Capability (share of world total) | COW NMC 6.0 |
| **Land Area** (DV - Volume) | Total land area in square kilometers | World Bank WDI |
| **Density** (DV - Derived) | CINC / Land Area (capability per unit of geographic size) | Computed |
| **Distance** (Key IV) | Great-circle distance from capital to Washington DC (km) | Calculated |
| **GDP per capita** (Control) | Log of constant 2015 USD | World Bank WDI |
| **Population** (Control) | Log of total population | World Bank WDI |
| **Years Independent** (Control) | Years since independence | Manual coding |

### What is CINC?

The **Composite Index of National Capability (CINC)** is a widely-used measure of national power developed by the Correlates of War project. It calculates each country's share of total world capabilities across six components:

1. **Military Expenditure** - Total military spending
2. **Military Personnel** - Active duty military personnel
3. **Energy Consumption** - Primary energy consumption
4. **Iron and Steel Production** - Industrial capacity proxy
5. **Urban Population** - Urbanization level
6. **Total Population** - Demographic weight

CINC = Average of the six component shares (ranges from 0 to 1)

### Model Specifications

```
Mass:    Log(CINC)      = beta_0 + beta_1(Distance) + beta_2(log GDP pc) + beta_3(log Pop) + beta_4(Years Indep) + epsilon
Volume:  Log(Land Area) = beta_0 + beta_1(Distance) + beta_2(log GDP pc) + beta_3(log Pop) + beta_4(Years Indep) + epsilon
Density: Log(CINC/Area) = beta_0 + beta_1(Distance) + beta_2(log GDP pc) + beta_3(log Pop) + beta_4(Years Indep) + epsilon
```

**Test:** Examine how distance relates to each Roche component independently

---

## Key Findings

Run the analysis to discover:

1. Whether distance from the U.S. predicts national capability (mass)
2. Whether distance predicts geographic size (volume)
3. Whether distance predicts geopolitical density (mass/volume)
4. Whether these relationships hold after controlling for economic development

---

## Data Sources

### Correlates of War

**National Material Capabilities (NMC) Version 6.0:**
- CINC scores for all countries (1816-2016)
- **Website:** https://correlatesofwar.org/data-sets/national-material-capabilities/

### World Bank

**World Development Indicators (WDI):**
- GDP per capita: `NY.GDP.PCAP.KD`
- Population: `SP.POP.TOTL`
- Land area: `AG.LND.TOTL.K2`
- **Website:** https://data.worldbank.org

### Geographic Data

- Capital coordinates: Standard geographic references
- Distance calculation: Haversine formula via `geosphere` package

---

## Methodology

### Data Collection (Script 01)

1. Defines Latin American sample (22 countries)
2. Codes capital coordinates and calculates distances to Washington DC
3. Loads CINC scores from Correlates of War NMC 6.0 dataset
4. Downloads World Bank indicators (GDP, population, land area)
5. Codes independence years
6. Saves raw datasets

### Data Preparation (Script 02)

1. Merges all data sources by ISO3 country codes
2. Creates log-transformed variables (CINC, land area, GDP, population)
3. Computes density = CINC / land area (raw, log, and scaled versions)
4. Handles missing data
5. Produces analysis-ready datasets

### Statistical Analysis (Script 03)

1. **Descriptive statistics:** Summary stats and correlations
2. **Main model:** OLS regression with full controls
3. **Diagnostics:** VIF for multicollinearity, residual plots
4. **Robustness checks:**
   - Bivariate model (distance only)
   - Non-linear specification (distance squared)
   - Raw CINC (no log transformation)
5. **Roche Equation models:**
   - Density models (distance -> log density, bivariate + full)
   - Land area model (distance -> log land area, full controls)
   - Comparison of mass, volume, and density coefficients

### Visualization (Script 04)

1. Main scatterplot: Distance vs. CINC with regression line
2. Partial regression plot: Relationship controlling for covariates
3. Geographic map: Spatial distribution
4. Coefficient plot: Regression results with confidence intervals
5. Distribution plots: Variable summaries
6. Distance vs. density scatterplot: Roche equation visualization
7. Roche components panel: Mass, volume, and density vs. distance side-by-side

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

### Roche Equation Analogy

In astrophysics, the Roche limit is the distance within which a satellite held together by its own gravity will be torn apart by tidal forces from a larger body. The formula depends on the densities of both bodies. In the geopolitical analogy:

- **Mass (CINC):** A country's overall national capability
- **Volume (Land Area):** A country's geographic size
- **Density (CINC/Area):** Capability concentrated per unit of territory

### Interpreting the Three Models

| Component | Negative distance coef | Positive distance coef |
|-----------|----------------------|----------------------|
| **Mass** | Closer countries have higher CINC | Farther countries have higher CINC |
| **Volume** | Closer countries are geographically larger | Farther countries are geographically larger |
| **Density** | Closer countries are more "dense" (concentrated capability) | Farther countries are more "dense" |

The density result is key for the Roche analogy: if density decreases with distance, countries closer to the U.S. are more "compact" in their capability, potentially making them harder to disrupt.

---

## Limitations

1. **Small N (~20 observations)**
   - Limited statistical power
   - Cannot include many controls simultaneously
   - Individual cases have large influence

2. **CINC Measurement**
   - Data availability ends around 2012-2016
   - May not capture modern capability dimensions (technology, soft power)
   - Aggregate measure may mask component differences

3. **Correlation vs. Causation**
   - Correlational, not causal
   - Cannot establish directional relationship
   - Omitted variables may drive the pattern

4. **Scope**
   - Limited to Latin America
   - May not generalize to other regions

---

## Extensions (Future Work)

1. **Regional Comparison:** Test in other world regions
2. **Historical Analysis:** Examine how relationships change over time
3. **Component Analysis:** Examine which CINC components drive the pattern
4. **Alternative Measures:** Include GDP, HDI, or other capability measures
5. **Network Effects:** Consider trade relationships, not just distance

---

## Citation

If you use this code or analysis, please cite:

```
[Author Name]. (2025). Distance and National Capability in Latin America.
GitHub repository: [URL]
```

Data citation:
```
Singer, J. David, Stuart Bremer, and John Stuckey. (1972). "Capability Distribution,
Uncertainty, and Major Power War, 1820-1965." in Bruce Russett (ed) Peace, War, and
Numbers, Beverly Hills: Sage, 19-48.
```

---

## License

This project is released under the MIT License. Data sources retain their original licenses.

---

## Contact

For questions or suggestions, please open an issue on GitHub or contact [your contact info].

---

## Acknowledgments

- Correlates of War project for National Material Capabilities data
- World Bank for development indicators
- R community for excellent open-source tools

---

**Last Updated:** February 2025
