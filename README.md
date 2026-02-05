# Distance and National Capability in Latin America

## Project Overview

This research project tests a hypothesis about U.S. influence and national capability: Does distance from the United States correlate with the national capability (mass) of Latin American countries?

**Core Research Question:** Is there a correlation between distance from the United States and the CINC scores (Composite Index of National Capability) of Latin American countries?

**Hypothesis:** Countries closer to the U.S. may have higher national capabilities due to greater U.S. economic influence, investment, and strategic importance.

**Operationalization of Mass:** We use CINC (Composite Index of National Capability) from the Correlates of War National Material Capabilities (NMC) dataset as our measure of "mass." CINC captures a country's share of total world capabilities across six dimensions:
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
| **CINC Score** (DV) | Composite Index of National Capability (share of world total) | COW NMC 6.0 |
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

### Model Specification

```
Log(CINC) = beta_0 + beta_1(Distance) + beta_2(log GDP pc) + beta_3(log Pop) + beta_4(Years Indep) + epsilon
```

**Test:** Examine whether distance has a significant effect on national capability

---

## Key Findings

Run the analysis to discover:

1. Whether distance from the U.S. predicts national capability
2. Whether this relationship holds after controlling for economic development
3. Robustness of the finding across alternative specifications

**Possible Results:**

- **Negative coefficient on distance:** Countries closer to the US have higher CINC
- **Positive coefficient on distance:** Countries farther from the US have higher CINC
- **Non-significant coefficient:** No clear relationship

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
- **Website:** https://data.worldbank.org

### Geographic Data

- Capital coordinates: Standard geographic references
- Distance calculation: Haversine formula via `geosphere` package

---

## Methodology

### Data Collection (Script 01)

1. Defines Latin American sample (22 countries)
2. Codes capital coordinates and calculates distances to Washington DC
3. Downloads CINC scores from Correlates of War NMC dataset
4. Downloads World Bank indicators (GDP, population)
5. Codes independence years
6. Saves raw datasets

### Data Preparation (Script 02)

1. Merges all data sources by ISO3 country codes
2. Creates log-transformed variables (CINC, GDP, population)
3. Handles missing data
4. Produces analysis-ready datasets

### Statistical Analysis (Script 03)

1. **Descriptive statistics:** Summary stats and correlations
2. **Main model:** OLS regression with full controls
3. **Diagnostics:** VIF for multicollinearity, residual plots
4. **Robustness checks:**
   - Bivariate model (distance only)
   - Non-linear specification (distance squared)
   - Raw CINC (no log transformation)

### Visualization (Script 04)

1. Main scatterplot: Distance vs. CINC with regression line
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

### If Distance Coefficient is Negative and Significant

Countries closer to the U.S. have higher national capabilities, suggesting:
- U.S. economic influence boosts nearby economies
- Strategic importance leads to greater investment
- Geographic proximity facilitates trade and development

### If Distance Coefficient is Positive and Significant

Countries farther from the U.S. have higher national capabilities, suggesting:
- Resource-rich countries in South America drive the pattern
- Historical development patterns unrelated to U.S. proximity

### If Distance Coefficient is Not Significant

No clear relationship between distance and national capability, suggesting:
- Other factors (resources, institutions, history) dominate
- U.S. influence is not systematically related to distance

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
