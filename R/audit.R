#' Run Full Package Audit
#' 
#' @param path Path to the local legacy repo
#' @param output_dir Where to save the reports
#' @export
audit_package <- function(path, output_dir = "audit_reports") {
  # 1. Point to the repo
  root <- locate_package_root(path)
  
  fs::dir_create(output_dir)
  
  message("🔍 Phase 1: Inventorying Functions...")
  inv <- inventory_functions(root)
  
  # Save the baseline
  readr::write_csv(inv, fs::path(output_dir, "function_inventory.csv"))
  
  message("📊 Phase 2: Calculating Complexity...")
  # If you have cyclocomp installed
  if (requireNamespace("cyclocomp", quietly = TRUE)) {
    cyc <- cyclocomp::cyclocomp_package(root)
    readr::write_csv(cyc, fs::path(output_dir, "complexity.csv"))
  }
  
  message("✅ Audit Complete. See ", output_dir)
  return(invisible(inv))
}