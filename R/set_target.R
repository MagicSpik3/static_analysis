#' Identify the Real Package Root
#'
#' Scans a directory to find the actual R package root, handling
#' the specific case of nested .Rproj folders.
#'
#' @param path String. Path to the cloned legacy repo.
#' @return String. The normalized path to the actual package root.
#' @export
locate_package_root <- function(path = ".") {
  path <- fs::path_abs(path)
  
  if (!fs::dir_exists(path)) {
    stop("Path does not exist: ", path)
  }
  
  # 1. Find all DESCRIPTION files (The marker of an R package)
  desc_files <- fs::dir_ls(path, recurse = TRUE, glob = "DESCRIPTION")
  
  if (length(desc_files) == 0) {
    stop("No DESCRIPTION file found. Is this an R package?")
  }
  
  # 2. Heuristic: The deepest DESCRIPTION file is usually the package 
  #    in these nested 'wrapper' projects.
  #    (Structure: Wrapper/Project/Package/DESCRIPTION)
  real_root <- fs::path_dir(desc_files[[1]])
  
  if (length(desc_files) > 1) {
    # Sort by depth (number of slashes)
    depths <- lengths(strsplit(as.character(desc_files), "/"))
    deepest_idx <- which.max(depths)
    real_root <- fs::path_dir(desc_files[[deepest_idx]])
    
    message(sprintf(
      "ℹ Note: Multiple DESCRIPTION files found.\n  Targeting nested package at: '%s'\n  (Outer wrapper ignored)",
      real_root
    ))
  } else {
    message(sprintf("✔ Targeted package at: '%s'", real_root))
  }
  
  return(real_root)
}