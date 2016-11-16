#' mdftracks:  Read MTrackJ Tracks
#'
#' Reads the .mdf files generated by the MTrackJ and convert it to a data.frame.
#'
#' @docType package
#' @name mdftracks
NULL

#' Read an MTrackJ track file (.mdf)
#'
#' Reads the .mdf files generated by the MTrackJ and convert it to a data.frame.
#'
#' @param file The MTrackJ .mdf file with the tracks.
#'
#' @family icytracks functions
#'
#' @export
#'
#' @examples
#' \dontrun{
#' read.mdf('~/mdftracks.mdf')
#' }
read.mdf <- function(file, drop.Z = F, include.point.numbers = FALSE, include.channel = F) {
  mdf.lines <- readFileLines(file)
  track.bounds <- getTrackBoundsFromMDFLines(mdf.lines)
  df <- getTrackDF(mdf.lines, track.bounds)

   cols <- c('id', 't', 'x', 'y')
  if(!drop.Z) { cols <- c(cols, "z")}
  if(include.point.numbers) { cols <- c(cols, "point")}
  if(include.channel) { cols <- c(cols, "c")}
  df <- df[, cols]

  attr(df, "doc") <- paste0("Read from ", mdf.lines[[1]])
  df
}

getMTrackJVersion <- function(mdf.lines) {
  first.line.split <- strsplit(mdf.lines[[1]], " ")[[1]]
  stopifnot(first.line.split[1] == "MTrackJ")
  first.line.split[2]
}

readFileLines <- function(file) {
  con <- file(file, open="r")
  lines <- readLines(con)
  close(con)
  lines
}

getTrackBoundsFromMDFLines <- function(mdf.lines) {
  track.lines <- grep("^Track", mdf.lines)
  track.nrs <- sapply(strsplit(mdf.lines[track.lines], " "), "[[", 2)
  data.frame(id = track.nrs, begin = track.lines + 1, end = c(track.lines[-1], length(mdf.lines)) - 1)
}

getTrackDF <- function(mdf.lines, track_bounds) {
  track_bound_l <- split(track_bounds, track_bounds$id)
  track_df_l <- invisible(lapply(track_bound_l, function(x) {
    # Get correct rows from xls_data
    t <- mdf.lines[x$begin:x$end]
    t <- t[grep("^Point", t)]
    t.df <- read.delim(textConnection(t), sep = " ", header = F)
    # Put in the correct track id
    t.df$V1 <- x$id
    colnames(t.df) <- c('id', 'point', 'x', 'y', 'z', 't', 'c')
    t.df
  }))
  # Bind list together to get the DF, then convert to data matrix (make numeric),
  # then back to DF
  as.data.frame(data.matrix(do.call(rbind, track_df_l)))
}