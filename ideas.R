analyze_variable_usage <- function(file_path, target_var_name) {
  # 1. Read and parse the code
  code_lines <- readLines(file_path)
  parsed_data <- getParseData(parse(file_path, keep.source = TRUE))
  
  # 2. Filter for the target variable (SYMBOL)
  # We look for token "SYMBOL" that matches our target name
  occurrences <- parsed_data[parsed_data$text == target_var_name & 
                             parsed_data$token == "SYMBOL", ]
  
  if (nrow(occurrences) == 0) {
    return(NULL)
  }
  
  # 3. Determine Context (Assignment vs Usage)
  # We look at the sibling/parent tokens to see if it's near an assignment operator
  results <- list()
  
  for (i in 1:nrow(occurrences)) {
    id <- occurrences$id[i]
    parent_id <- occurrences$parent[i]
    
    # Get all siblings from the same parent expression
    siblings <- parsed_data[parsed_data$parent == parent_id, ]
    
    # Check for assignment operators (<- or =) in siblings
    # If the target is on the LHS of <-, it's an assignment.
    is_assignment <- FALSE
    
    # Check if standard assignment operator exists in siblings
    if (any(siblings$token %in% c("LEFT_ASSIGN", "EQ_ASSIGN"))) {
        # Find position of assignment op
        assign_pos <- siblings[siblings$token %in% c("LEFT_ASSIGN", "EQ_ASSIGN"), "col1"][1]
        # If our variable is to the left of the assignment, it's the target
        if (occurrences$col1[i] < assign_pos) {
            is_assignment <- TRUE
        }
    }
    
    # store in a structured list (row/col for exact replacement later)
    results[[i]] <- data.frame(
      file = basename(file_path),
      line = occurrences$line1[i],
      col_start = occurrences$col1[i],
      col_end = occurrences$col2[i],
      type = ifelse(is_assignment, "DEFINITION", "USAGE"),
      snippet = code_lines[occurrences$line1[i]]
    )
  }
  
  return(do.call(rbind, results))
}