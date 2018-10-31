#' Read input data from a given file
#'
#' This function reads data from a file specified in \code{filename} argument.
#' \code{fars_read} works when the appriopriate data files are in the working
#' directory, otherwise returns an error.
#'
#' @param filename A character string giving name of a file containing data.
#'
#' @return This function returns data formatted as data.frame.
#'
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#'
#' @examples
#' \dontrun{fars_read("accident_2001.csv.bz2")}
#'
#' @export
fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}

#' Creates filename associated with given year' data
#'
#' This function creates a name of a file containg accident data for a year
#' of interest specified in the \code{year} argument. \code{year} must be an integer
#' or be possible to be coerced to an integer, otherwise an error will be generated.
#'
#' @param year An integer specifing year of interest
#'
#' @return This function returns a character string specifying file name containing
#' data of interest.
#'
#' @examples
#' \dontrun{make_filename(2001)}
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}

#' Read data for a given set of years
#'
#' This function reads data for a set of years specified in the \code{years}
#' argument. \code{years} must be numeric or be possible to be coerced to numeric,
#' otherwise an error will occur.
#' \code{fars_read_years} is dependent on \code{dplyr} package.
#'
#' @param years An integer vector specifying years of interest
#'
#' @return This function returns a list of data.frames containing accident data.
#' Each element of a list contains data for one year.
#'
#' @importFrom dplyr mutate select
#'
#' @examples
#' \dontrun{fars_read_years(c(2013,2015))}
#'
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>%
                                dplyr::select(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#' Create summary of number of obserwations
#'
#' This function creates a summary of number of accidents in each monts and each
#' year specified in \code{years} argument.
#' \code{fars_summarize_years} is dependent on \code{dplyr} and \code{tidyr} packages.
#'
#' @inheritParams fars_read_years
#'
#' @return This function returns a table (tibble) with the number of observations
#' in each month and each given year
#'
#' @importFrom dplyr bind_rows group_by summarize
#' @importFrom tidyr spread
#'
#' @examples
#' \dontrun{fars_summarize_years(c(2013,2015))}
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by(year, MONTH) %>%
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}

#' Plot accidents location for a given state
#'
#' This is a function that, given a state number and a year, plots accidents locations
#' on a map. There are 51 states, entering \code{state.num} larger than 51 (or lower than 1)
#' will generate an error
#' \code{fars_map_state} is dependent on \code{dplyr} and \code{maps} packages.
#'
#' @param state.num An integer specifying state
#' @param year An integer specifying year
#'
#' @importFrom graphics points
#' @importFrom maps map
#'
#' @return This function doesn't return anything. The side effect is a plot of accidents location.
#'
#' @examples
#' \dontrun{fars_map_state(state.num = 2, year=2013)}
#'
#' @export
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
