#' Build Function Inventory
#' 
#' Parses all .R files and extracts function definitions/locations.
#' 
#' @param pkg_root Path to the package root (from locate_package_root)
#' @export
inventory_functions <- function(pkg_root) {
  r_dir <- fs::path(pkg_root, "R")
  
  if (!fs::dir_exists(r_dir)) {
    stop("No R/ directory found at ", pkg_root)
  }
  
  r_files <- fs::dir_ls(r_dir, glob = "*.R")
  
  results <- lapply(r_files, function(f) {
    # Parse the code structure
    # 'keep.source = TRUE' is vital for line numbers
    tryCatch({
      pd <- xmlparsedata::xml_parse_data(parse(file = f, keep.source = TRUE))
      
      # Filter for function definitions
      # SYMBOL_FUNCTION_CALL is often the name in 'name <- function(...)'
      # But strictly, we look for 'FUNCTION' token, then look backwards for the assignment.
      
      # For the MVP, we use the `codetools` approach you listed as it's more robust
      # for getting names, but we combine it with xml for lines.
      
      # Quick & Dirty Robust Name Extractor:
      lines <- readLines(f)
      # Find "something <- function"
      func_lines <- grep("<- function", lines)
      
      if (length(func_lines) == 0) return(NULL)
      
      tibble::tibble(
        file = fs::path_file(f),
        func_name = trimws(sub("<- function.*", "", lines[func_lines])),
        line_start = func_lines,
        # Naive line_end (improvements needed later via AST)
        complexity_score = NA_integer_ # Placeholder for cyclocomp
      )
    }, error = function(e) {
      warning("Failed to parse ", f, ": ", e$message)
      return(NULL)
    })
  })
  
  dplyr::bind_rows(results)
}