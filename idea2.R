library(utils)

get_variable_scope <- function(file_path, target_var) {
  pdata <- getParseData(parse(file_path, keep.source = TRUE))
  
  # Filter for the target variable
  vars <- pdata[pdata$text == target_var & pdata$token == "SYMBOL", ]
  
  if (nrow(vars) == 0) return(NULL)
  
  results <- list()
  
  for (i in 1:nrow(vars)) {
    # 1. Traverse Parents to find Function Scope
    current_id <- vars$parent[i]
    scope_name <- "global" # Default
    
    while (current_id > 0) {
      parent_row <- pdata[pdata$id == current_id, ]
      
      # In R's parse data, a function definition usually looks like:
      # valid_name <- function(...) { ... }
      # We look for the 'FUNCTION' token.
      
      # If we hit a function definition, we need to find its name.
      # The name is usually a sibling of the 'function' keyword in an assignment.
      if (any(pdata$token == "FUNCTION" & pdata$parent == pdata$parent[pdata$id == current_id])) {
        
        # Find the assignment that created this function
        func_def_parent <- pdata$parent[pdata$id == current_id]
        grandparent_id <- pdata$parent[pdata$id == func_def_parent]
        
        # Look for the symbol assigned to this function definition
        siblings <- pdata[pdata$parent == grandparent_id, ]
        assign_tokens <- c("LEFT_ASSIGN", "EQ_ASSIGN")
        
        if (any(siblings$token %in% assign_tokens)) {
           assign_idx <- which(siblings$token %in% assign_tokens)[1]
           # The name is the symbol to the left of the assignment
           func_name_row <- siblings[1:(assign_idx-1), ]
           func_name_row <- func_name_row[func_name_row$token == "SYMBOL", ]
           
           if (nrow(func_name_row) > 0) {
             scope_name <- func_name_row$text[1]
             break # Found the scope, stop traversing
           }
        }
      }
      current_id <- parent_row$parent
    }
    
    # Record logic
    results[[i]] <- data.frame(
      line = vars$line1[i],
      var = target_var,
      scope = scope_name,
      file = basename(file_path)
    )
  }
  
  return(do.call(rbind, results))
}