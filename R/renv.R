
##----------------------------------------------------------------------------##
##                                RENVIRON FUNS                               ##
##----------------------------------------------------------------------------##


set_renv <- function(...) {
  dots <- list(...)
  stopifnot(are_named(dots))
  vars <- names(dots)
  x <- paste0(names(dots), "=", dots)
  x <- paste(x, collapse = "\n")
  for (var in vars) {
    check_renv(var)
  }
  append_lines(x, file = .Renviron())
  readRenviron(.Renviron())
}

check_renv <- function(var = NULL) {
  if (!file.exists(.Renviron())) return(invisible())
  if (is_incomplete(.Renviron())) {
    append_lines("", file = .Renviron())
  }
  if (!is.null(var)) {
    clean_renv(var)
  }
  invisible()
}

.Renviron <- function() {
  if (file.exists(".Renviron")) {
    ".Renviron"
  } else {
    file.path(home(), ".Renviron")
  }
}

is_incomplete <- function(x) {
  con <- file(x)
  x <- tryCatch(readLines(con, encoding = "UTF-8"), warning = function(w) return(TRUE))
  close(con)
  ifelse(isTRUE(x), TRUE, FALSE)
}

has_name_ <- function(x, name) isTRUE(name %in% names(x))

define_args <- function(args, ...) {
  dots <- list(...)
  nms <- names(dots)
  for (i in nms) {
    if (!has_name_(args, i)) {
      args[[i]] <- dots[[i]]
    }
  }
  args
}

home <- function() {
  if (!identical(Sys.getenv("HOME"), "")) {
    file.path(Sys.getenv("HOME"))
  } else {
    file.path(normalizePath("~"))
  }
}

append_lines <- function(x, ...) {
  args <- define_args(
    c(x, list(...)),
    append = TRUE,
    fill = TRUE
  )
  do.call("cat", args)
}

clean_renv <- function(var) {
  x <- readlines(.Renviron())
  x <- grep(sprintf("^%s=", var), x, invert = TRUE, value = TRUE)
  writeLines(x, .Renviron())
}

are_named <- function(x) is_named(x) && !"" %in% names(x)

is_named <- function(x) !is.null(names(x))
