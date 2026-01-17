build_package_index <- function(packages_list) {
  # packages_list: c("lubridate", "dplyr", "stringr")
  
  index <- list()
  
  for (pkg in packages_list) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      warning(paste("Package", pkg, "not installed locally. Skipping."))
      next
    }
    
    # Get all exported functions
    exports <- getNamespaceExports(pkg)
    
    # Create a dataframe: func_name | package
    index[[pkg]] <- data.frame(
      func_name = exports,
      package = pkg,
      stringsAsFactors = FALSE
    )
  }
  
  return(do.call(rbind, index))
}

# Example usage:
# ext_index <- build_package_index(c("lubridate", "data.table"))
# print(ext_index[ext_index$func_name == "date", ])
# Output: date | lubridate