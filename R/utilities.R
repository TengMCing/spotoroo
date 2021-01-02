check_type <- function(type, x, varname = deparse(substitute(x))){
  bool_result <- do.call(paste0("is.", type), list(x))
  if (!bool_result){
    stop("Formal argument `", varname, "` requires ", type, " input")
  }
}

check_type_bundle <- function(type, ...){
  vars <- list(...)
  var_names <- as.character(sys.call())[3:(length(vars) + 2)]

  for (i in 1:length(vars)){
    check_type(type, vars[[i]], varname = var_names[i])
  }
}

is_non_negative <- function(x, varname = deparse(substitute(x))){
  if (x<0) stop("Formal argument `", varname, "` requires non-negative input")
}

is_positive <- function(x, varname = deparse(substitute(x))){
  if (x<=0) stop("Formal argument `", varname, "` requires positive input")
}

check_in <- function(values, x, varname = deparse(substitute(x))){
  if (!x %in% values){
    stop("Formal argument `",
         varname,
         "` only accepts one of these options: ",
         paste0(values, collapse = ", "))
  }
}

is_null <- function(x, varname = deparse(substitute(x))){
  if (is.null(x)) stop("Formal argument `", varname, "` requires valid column name")
}

is_null_bundle <- function(...){
  vars <- list(...)
  var_names <- as.character(sys.call())[2:(length(vars) + 1)]

  for (i in 1:length(vars)){
    is_null(vars[[i]], varname = var_names[i])
  }
}

any_null_warning <- function(...){
  vars <- list(...)
  var_names <- as.character(sys.call())[2:(length(vars) + 1)]
  bool_vec <- unlist(lapply(vars, is.null))
  if (any(bool_vec)){
    varname <- var_names[bool_vec][1]
    warning("Formal argument `",
            varname,
            "` is missing, formal argument `",
            paste0(var_names[!bool_vec], collapse = "``, `"),
            "` is ignored")
  }
}

all_null_bool <- function(...){
  vars <- list(...)
  bool_vec <- unlist(lapply(vars, is.null))
  all(bool_vec)
}

equal_length <- function(...){
  vars <- list(...)
  var_names <- as.character(sys.call())[2:(length(vars) + 1)]
  length_vec <- unlist(lapply(vars, length))
  if (length(unique(length_vec)) != 1){
    stop("Formal arguments `",
         paste0(var_names, collapse = "`, `"),
         "` require names of columns with equal lengths")
  }

}

check_numeric_column <- function(x, varname = deparse(substitute(x))){
  if (!(length(x)>0 & is.numeric(x))){
    stop("Formal argument `",
         varname,
         "` requires a name of a numeric column with length greater than 0")
  }
}

check_numeric_column_bundle <- function(...){
  vars <- list(...)
  var_names <- as.character(sys.call())[2:(length(vars) + 1)]
  for (i in 1:length(vars)){
    check_numeric_column(vars[[i]], varname = var_names[i])
  }
}

check_integer_time_id <- function(time_id){
  if (!(length(time_id)>0 & is.integer(time_id))) {
    s1 <- "Internal variable time_id is not an integer vector. "
    s2 <- "A proper transformation for the time column is needed. "
    s3 <- "Consider to provide proper values to formal arguments "
    s4 <- "`time_unit` and `timestep` to perform the transformation"
    stop(paste0(s1, s2, s3, s4))
  }
}




