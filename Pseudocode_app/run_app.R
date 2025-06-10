# Test script to run the Employee Activity Tracker

# Set working directory to the app location
setwd("/Users/josua.boeser/Library/CloudStorage/OneDrive-ChrestosGmbH/Daten/05_Uebungen/Cousera/getting_started_with_shiny/Test1/Github_rshiny/Pseudocode_app")

# Check if required packages are installed
required_packages <- c("shiny", "shinyjs", "DT", "dplyr", "plotly", "readr", "lubridate")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# Run the app
shiny::runApp("app.R", launch.browser = TRUE)
