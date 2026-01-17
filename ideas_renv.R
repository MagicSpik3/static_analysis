# run_me_first.R

# 1. Check if renv is installed; if not, install it
if (!requireNamespace("renv", quietly = TRUE)) {
  message("Installing renv ecosystem...")
  install.packages("renv")
}

# 2. Restore the environment (install all dependencies automatically)
message("Restoring project environment (this may take a few minutes)...")
renv::restore(prompt = FALSE) # prompt=FALSE stops it from asking "Are you sure?"

# 3. Launch the tool
message("Setup complete. Launching tool...")
source("main.R")