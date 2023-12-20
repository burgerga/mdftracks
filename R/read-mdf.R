#' Read an MTrackJ Data File (`.mdf`)
#'
#' Reads an MTrackJ Data File (`.mdf`) file in a data.frame.
#'
#' @param file MTrackJ Data File (`.mdf`) file with tracking data.
#' @param drop.Z drop z-coordinate (for 2D data)
#' @param include.point.numbers include the point numbers in the mdf file
#' (**NB** these can be different from the time/frame points)
#' @param include.channel include channel information
#' @param generate.unique.ids combine cluster and id columns to get unique ids
#' @param text character string: if file is not supplied and this is, then data
#' are read from the value of text via a text connection. Notice that a literal
#' string can be used to include (small) data sets within R code.
#' @param fileEncoding character string: if non-empty declares the encoding to
#' be used on a file (not a connection) so the character data can be re-encoded
#' as they are written. See [base::file()].
#'
#' @family mdftracks functions
#'
#' @export
#'
#' @seealso [MTrackJ Data Format](https://imagescience.org/meijering/software/mtrackj/format/)
#'
#' @examples
#' read.mdf(system.file("extdata", "example.mdf", package = 'mdftracks'))
#'
read.mdf <- function(file, drop.Z = F, include.point.numbers = FALSE,
                     include.channel = F, generate.unique.ids = F, text,
                     fileEncoding = "") {
  if (missing(file) && !missing(text)) {
    file <- textConnection(text, encoding = "UTF-8")
    on.exit(close(file))
  }
  if (is.character(file)) {
    file <- if (nzchar(fileEncoding))
      file(file, "rt", encoding = fileEncoding)
    else file(file, "rt")
    on.exit(close(file))
  }
  if (!inherits(file, "connection"))
    stop("'file' must be a character string or connection")
  if (!isOpen(file, "rt")) {
    open(file, "rt")
    on.exit(close(file))
  }

  # Read first line
  mdf.lines <- readLines(file, n = 1)
  if(!grepl(sprintf(pkg.env$mtrackj.header, '[0-9]+(.[0-9]+)*'), mdf.lines)) {
    stop("does not appear to be an MTrackJ Data File")
  }
  # message(mdf.lines) # Print mdf version info from file
  mdf.lines <- c(mdf.lines, readLines(file))

  cluster.bounds <- getClusterBounds(mdf.lines)
  cluster.lines.list <- getClusterLines(mdf.lines, cluster.bounds)
  cluster.track.list <- lapply(cluster.lines.list, getClusterTracks)

  # Add cluster number
  cluster.track.list <- mapply(function(df, id) {
    df$cluster <- id
    df
  }, cluster.track.list, cluster.bounds$id, SIMPLIFY = F)
  # Merge to one data frame
  df <- do.call(rbind, cluster.track.list)

  # Select columns of interest
  cols <- c('cluster', 'id', 'time', 'x', 'y')
  if(!drop.Z) { cols <- c(cols, "z")}
  if(include.point.numbers) { cols <- c(cols, "point")}
  if(include.channel) { cols <- c(cols, "channel")}
  df <- df[, cols]

  # Generate unique ids
  if(generate.unique.ids) {
    if(length(unique(df$cluster)) == 1) {
      # Only one cluster, uid = id
      df$uid <- df$id
    } else {
      # Multiple clusters, create uid based on cl and id
      df$uid <- as.numeric(factor(paste(df$cluster, df$id, sep = ".")))
    }
  }

  attr(df, "doc") <- paste0("Read from ", mdf.lines[[1]])
  df
}

getTrackBounds <- function(mdf.lines) {
  track.lines <- grep("^Track", mdf.lines)
  track.nrs <- as.numeric(sapply(strsplit(mdf.lines[track.lines], " "), "[[", 2))
  data.frame(id = track.nrs, begin = track.lines + 1, end = c(track.lines[-1], length(mdf.lines)))
}


getClusterBounds <- function(mdf.lines) {
  cluster.lines <- grep("^Cluster", mdf.lines)
  cluster.nrs <- as.numeric(sapply(strsplit(mdf.lines[cluster.lines], " "), "[[", 2))
  # -1 for the last line in the file
  data.frame(id = cluster.nrs, begin = cluster.lines + 1, end = c(cluster.lines[-1], length(mdf.lines)) - 1)
}


getClusterLines <- function(mdf.lines, cluster.bounds) {
  cluster.bounds.l <- split(cluster.bounds, cluster.bounds$id)
  cluster.lines.l <- invisible(lapply(cluster.bounds.l, function(x) {
    mdf.lines[x$begin:x$end]
  }))
}


#' @importFrom utils read.delim
getClusterTracks <- function(cluster.lines) {
  track.bounds <- getTrackBounds(cluster.lines)
  track.bounds.l <- split(track.bounds, track.bounds$id)
  track.df.l <- invisible(lapply(track.bounds.l, function(x) {
    # Get correct rows from cluster.lines
    t <- cluster.lines[x$begin:x$end]
    # Filter out Point lines
    t <- t[grep("^Point", t)]
    # Read lines as data frame
    t.df <- read.delim(sep = " ", header = F, text = t)
    # Rename columns
    colnames(t.df) <- c('id', 'point', 'x', 'y', 'z', 'time', 'channel')
    # Put in the correct track id
    t.df$id <- x$id

    t.df
  }))
  # Bind list together to get the DF, then convert to data matrix (make numeric),
  # then back to DF
  as.data.frame(data.matrix(do.call(rbind, track.df.l)), stringsAsFactors = F)
}
