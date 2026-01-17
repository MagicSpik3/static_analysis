# install.packages(c("usethis", "fs", "desc", "xmlparsedata", "tibble", "dplyr"))
usethis::use_package("fs")
usethis::use_package("desc")
usethis::use_package("tibble")
usethis::use_package("dplyr")
usethis::use_package("xmlparsedata")

# This is how you start standardising cleanly
install.packages("usethis")
install.packages("devtools")
library(usethis)

# Analysis tool:
fs::dir_tree(".", depth = 3)

desc_files <- fs::dir_ls(".", recurse = TRUE, glob = "DESCRIPTION")
desc_files

library(xmlparsedata)
library(fs)

r_files <- dir_ls("R", glob = "*.R")

extract_functions <- function(file) {
  pd <- xmlparsedata::xml_parse_data(file)
  fun_nodes <- subset(pd, token == "FUNCTION")
  
  data.frame(
    file = file,
    line1 = fun_nodes$line1,
    col1 = fun_nodes$col1
  )
}

functions_df <- do.call(rbind, lapply(r_files, extract_functions))


get_function_names <- function(file) {
  exprs <- parse(file, keep.source = TRUE)
  Filter(is.function, as.list(exprs))
}


library(codetools)

get_assigned_functions <- function(file) {
  e <- new.env()
  sys.source(file, e)
  names(Filter(is.function, as.list(e)))
}


library(roxygen2)

parse_file("R/foo.R") |> str()


library(lintr)

bad_name_linter <- Linter(function(source_file) {
  ids <- source_file$parsed_content[source_file$parsed_content$token == "SYMBOL", ]
  bad <- ids[nchar(ids$text) <= 1 & ids$text != "i", ]
  
  lapply(seq_len(nrow(bad)), function(i) {
    Lint(
      filename = source_file$filename,
      line_number = bad$line1[i],
      message = paste("Single-character variable name:", bad$text[i]),
      type = "style"
    )
  })
})

lint_package(linters = bad_name_linter)


library(covr)

cov <- package_coverage(path = ".")
report(cov, file = "coverage.html")

covr::file_coverage("R", "tests")

zero_coverage(cov)

library(CodeDepends)

res <- getInputs("R/foo.R")

library(igraph)
library(flow)
flow::flow_view("R/foo.R")

library(cyclocomp)
cyclocomp::cyclocomp_package()


# Ideas yaml.
#metrics:
#  coverage_target: 80
#max_complexity: 10
#no_single_char_vars: true

library(pkgnet)
pkgnet::CreatePackageGraph(".")

library(fabricatr)

fake_data <- fabricate(
  N = 1000,
  id = draw_integer(1, 1e6),
  income = draw_normal(30000, 5000)
)


library(quickcheck)

grep("<<-|eval\\(|parse\\(", readLines(file))






