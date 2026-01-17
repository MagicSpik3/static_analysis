# Concept for your replacement tool
apply_rename <- function(file_path, change_log) {
  lines <- readLines(file_path)
  
  # Process in reverse order so column indices don't shift!
  change_log <- change_log[order(change_log$line, change_log$col_start, decreasing = TRUE), ]
  
  for (i in 1:nrow(change_log)) {
    r_idx <- change_log$line[i]
    c_start <- change_log$col_start[i]
    c_end <- change_log$col_end[i]
    new_name <- change_log$new_name[i] # Retrieved from your dictionary
    
    # Splice the string
    old_line <- lines[r_idx]
    
    # Safety check: verify the text at that location is still what we expect
    # (Implementation omitted for brevity, but highly recommended)
    
    lines[r_idx] <- paste0(
      substr(old_line, 1, c_start - 1),
      new_name,
      substr(old_line, c_end + 1, nchar(old_line))
    )
  }
  writeLines(lines, file_path)
}