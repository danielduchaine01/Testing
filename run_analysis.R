# =============================================================================
# Master Script: Run Complete Analysis Pipeline
# Project: Testing the Geopolitical Roche Limit
# Description: Executes all scripts in sequence
# =============================================================================

cat("========================================\n")
cat("GEOPOLITICAL ROCHE LIMIT ANALYSIS\n")
cat("========================================\n\n")

# Record start time
start_time <- Sys.time()

# =============================================================================
# Check and install required packages
# =============================================================================

cat("Checking required packages...\n")

required_packages <- c(
  "tidyverse", "WDI", "geosphere", "countrycode",
  "car", "ggrepel", "scales", "knitr", "kableExtra", "rmarkdown"
)

new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if (length(new_packages) > 0) {
  cat("Installing missing packages:", paste(new_packages, collapse = ", "), "\n")
  install.packages(new_packages, repos = "http://cran.us.r-project.org")
}

# Check for vdemdata (optional)
if (!("vdemdata" %in% installed.packages()[,"Package"])) {
  cat("\nNote: 'vdemdata' package not installed.\n")
  cat("The analysis will use placeholder data.\n")
  cat("For real V-Dem data, install with: install.packages('vdemdata')\n\n")
}

cat("All required packages available.\n\n")

# =============================================================================
# Execute analysis pipeline
# =============================================================================

tryCatch({

  # Step 1: Data Collection
  cat("========================================\n")
  cat("STEP 1/4: DATA COLLECTION\n")
  cat("========================================\n")
  source("scripts/01_collect_data.R")

  cat("\n")

  # Step 2: Data Cleaning and Merging
  cat("========================================\n")
  cat("STEP 2/4: DATA CLEANING AND MERGING\n")
  cat("========================================\n")
  source("scripts/02_clean_merge.R")

  cat("\n")

  # Step 3: Statistical Analysis
  cat("========================================\n")
  cat("STEP 3/4: STATISTICAL ANALYSIS\n")
  cat("========================================\n")
  source("scripts/03_analysis.R")

  cat("\n")

  # Step 4: Visualization
  cat("========================================\n")
  cat("STEP 4/4: VISUALIZATION\n")
  cat("========================================\n")
  source("scripts/04_visualize.R")

  cat("\n")

  # Generate Report
  cat("========================================\n")
  cat("GENERATING HTML REPORT\n")
  cat("========================================\n")
  cat("Knitting R Markdown report...\n")

  rmarkdown::render(
    "roche_limit_report.Rmd",
    output_file = "roche_limit_report.html",
    quiet = FALSE
  )

  cat("\nReport generated: roche_limit_report.html\n")

  # Success message
  end_time <- Sys.time()
  elapsed_time <- round(difftime(end_time, start_time, units = "secs"), 1)

  cat("\n")
  cat("========================================\n")
  cat("ANALYSIS COMPLETE!\n")
  cat("========================================\n")
  cat("Total execution time:", elapsed_time, "seconds\n\n")

  cat("Output files:\n")
  cat("- Report: roche_limit_report.html\n")
  cat("- Data: data/processed/\n")
  cat("- Figures: output/figures/\n")
  cat("- Tables: output/tables/\n\n")

  cat("Next steps:\n")
  cat("1. Open roche_limit_report.html in a web browser\n")
  cat("2. Review the figures in output/figures/\n")
  cat("3. Examine the regression tables in output/tables/\n")

}, error = function(e) {
  cat("\n\n")
  cat("========================================\n")
  cat("ERROR OCCURRED\n")
  cat("========================================\n")
  cat("Error message:", conditionMessage(e), "\n")
  cat("\nThe analysis pipeline was interrupted.\n")
  cat("Check the error message above for details.\n")
})
