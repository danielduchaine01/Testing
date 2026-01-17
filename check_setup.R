# =============================================================================
# Setup Verification Script
# Project: Testing the Geopolitical Roche Limit
# Description: Check that all required packages are installed
# =============================================================================

cat("========================================\n")
cat("SETUP VERIFICATION\n")
cat("========================================\n\n")

# Check R version
cat("R version:", R.version.string, "\n\n")

# Required packages
required_packages <- c(
  "tidyverse",
  "WDI",
  "geosphere",
  "countrycode",
  "car",
  "ggrepel",
  "scales",
  "knitr",
  "kableExtra",
  "rmarkdown"
)

# Optional but recommended
optional_packages <- c("vdemdata")

cat("Checking required packages...\n")
cat("----------------------------------------\n")

all_installed <- TRUE

for (pkg in required_packages) {
  if (pkg %in% installed.packages()[,"Package"]) {
    cat("✓", pkg, "\n")
  } else {
    cat("✗", pkg, "- NOT INSTALLED\n")
    all_installed <- FALSE
  }
}

cat("\nChecking optional packages...\n")
cat("----------------------------------------\n")

for (pkg in optional_packages) {
  if (pkg %in% installed.packages()[,"Package"]) {
    cat("✓", pkg, "(recommended)\n")
  } else {
    cat("○", pkg, "- not installed (will use placeholder data)\n")
  }
}

cat("\n")

if (all_installed) {
  cat("========================================\n")
  cat("✓ ALL REQUIRED PACKAGES INSTALLED\n")
  cat("========================================\n")
  cat("\nYou're ready to run the analysis!\n")
  cat("\nRun the full analysis with:\n")
  cat("  source('run_analysis.R')\n\n")
  cat("Or run scripts individually:\n")
  cat("  source('scripts/01_collect_data.R')\n")
  cat("  source('scripts/02_clean_merge.R')\n")
  cat("  source('scripts/03_analysis.R')\n")
  cat("  source('scripts/04_visualize.R')\n")
  cat("  rmarkdown::render('roche_limit_report.Rmd')\n")
} else {
  cat("========================================\n")
  cat("✗ MISSING PACKAGES\n")
  cat("========================================\n")
  cat("\nInstall missing packages with:\n\n")

  missing <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

  cat('install.packages(c(\n')
  for (i in seq_along(missing)) {
    cat('  "', missing[i], '"', sep = "")
    if (i < length(missing)) cat(",\n") else cat("\n")
  }
  cat('))\n')
}

cat("\n")

# Check directory structure
cat("Checking directory structure...\n")
cat("----------------------------------------\n")

dirs <- c(
  "data/raw",
  "data/processed",
  "scripts",
  "output/figures",
  "output/tables"
)

for (dir in dirs) {
  if (dir.exists(dir)) {
    cat("✓", dir, "\n")
  } else {
    cat("✗", dir, "- MISSING\n")
  }
}

cat("\n")
cat("Setup check complete!\n")
