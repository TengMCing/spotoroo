################################  STOP  ########################################

# STOP; use is._() to check type
check_type <- function(type, x, varname = deparse(substitute(x))) {
  bool_result <- do.call(paste0("is.", type), list(x))
  if (!bool_result) {
    stop("Formal argument `", varname, "` requires ", type, " input")
  }
}

# STOP; use is._() to check type for multiple variables
check_type_bundle <- function(type, ...) {
  vars <- list(...)
  var_names <- as.character(sys.call())[3:(length(vars) + 2)]

  for (i in 1:length(vars)) {
    check_type(type, vars[[i]], varname = var_names[i])
  }
}

# STOP; check if variable has length 1
is_length_one <- function(x, varname = deparse(substitute(x))) {
  if (length(x) != 1) stop("Formal argument `",
                           varname,
                           "` requires input with length equals to 1")
}

# STOP; check if multiple variables have length 1
is_length_one_bundle <- function(...) {
  vars <- list(...)
  var_names <- as.character(sys.call())[2:(length(vars) + 1)]

  for (i in 1:length(vars)) {
    is_length_one(vars[[i]], varname = var_names[i])
  }
}

# STOP; check if variable is non-negative
is_non_negative <- function(x, varname = deparse(substitute(x))) {
  if (x<0) stop("Formal argument `", varname, "` requires non-negative input")
}

# STOP; check if variable is positive
is_positive <- function(x, varname = deparse(substitute(x))) {
  if (x<=0) stop("Formal argument `", varname, "` requires positive input")
}

# STOP; check if variable is one of a vector of values
check_in <- function(values, x, varname = deparse(substitute(x))) {
  if (!x %in% values) {
    stop("Formal argument `",
         varname,
         '` only accepts one of these options: "',
         paste0(values, collapse = '", "'),
         '"')
  }
}

# STOP; check if variable is not null
is_not_null <- function(x, varname = deparse(substitute(x))) {
  if (is.null(x)) stop("Formal argument `", varname, "` requires valid column name")
}

# STOP; check if multiple variables are not null
is_not_null_bundle <- function(...) {
  vars <- list(...)
  var_names <- as.character(sys.call())[2:(length(vars) + 1)]

  for (i in 1:length(vars)) {
    is_not_null(vars[[i]], varname = var_names[i])
  }
}

# STOP; check multiple variables have equal lengths
equal_length <- function(...) {
  vars <- list(...)
  var_names <- as.character(sys.call())[2:(length(vars) + 1)]
  length_vec <- unlist(lapply(vars, length))
  if (length(unique(length_vec)) != 1) {
    stop("Formal arguments `",
         paste0(var_names, collapse = "`, `"),
         "` require names of columns with equal lengths")
  }

}


# STOP; check if variable is a numeric column
check_numeric_column <- function(x, varname = deparse(substitute(x))) {
  if (!(length(x)>0 & is.numeric(x))) {
    stop("Formal argument `",
         varname,
         "` requires a name of a numeric column with length greater than 0")
  }
}

# STOP; check if multiple variables are numeric columns
check_numeric_column_bundle <- function(...) {
  vars <- list(...)
  var_names <- as.character(sys.call())[2:(length(vars) + 1)]
  for (i in 1:length(vars)) {
    check_numeric_column(vars[[i]], varname = var_names[i])
  }
}

# STOP; check if timeID is integer
check_integer_timeID <- function(timeID) {
  if (!(length(timeID)>0 & is.integer(timeID))) {
    s1 <- "Internal variable timeID is not an integer vector. "
    s2 <- "A proper transformation for the time column is needed. "
    s3 <- "Consider to provide proper values to formal arguments "
    s4 <- "`timeUnit` and `timeStep` to perform the transformation"
    stop(paste0(s1, s2, s3, s4))
  }
}

################################  WARNING  #####################################

# WARNING; warn if any variable is null
any_null_warning <- function(...) {
  vars <- list(...)
  var_names <- as.character(sys.call())[2:(length(vars) + 1)]
  bool_vec <- unlist(lapply(vars, is.null))
  if (any(bool_vec)) {
    varname <- var_names[bool_vec][1]
    cli::cli_alert_warning("Formal argument `{varname}` is missing, formal argument `{paste0(var_names[!bool_vec], collapse = '` ')}` will be ignored")
  }
}
################################  BOOL  ########################################

# BOOL; check if any variable is null
any_null_bool <- function(...) {
  vars <- list(...)
  bool_vec <- unlist(lapply(vars, is.null))
  any(bool_vec)
}

# BOOL; check if all variables are null
all_null_bool <- function(...) {
  vars <- list(...)
  bool_vec <- unlist(lapply(vars, is.null))
  all(bool_vec)
}

# BOOL; check if all hotspots are noise
all_noise_bool <- function(global_membership) {
  all(global_membership == -1)
}



