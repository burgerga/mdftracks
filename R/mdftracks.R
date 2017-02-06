#' mdftracks:  Read and Write MTrackJ Data Files
#'
#' Reads and writes MTrackJ Data Files (`.mdf`).
#' Supports clusters, 2D data, and channel information. If desired, generates
#' unique track identifiers based on cluster and id data from the `.mdf` file.
#'
#' @docType package
#' @name mdftracks
#' @seealso [MTrackJ Data Format](https://imagescience.org/meijering/software/mtrackj/format/)
#' @import hellno
NULL


# Store package local variables
pkg.env <- new.env(parent = emptyenv())
pkg.env$mtrackj.version <- '1.5.1'
pkg.env$mtrackj.header <- "MTrackJ %s Data File"


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
#' \dontrun{
#' read.mdf('~/mdftracks.mdf')
#'
#' read.mdf('~/mdftracks.mdf', generate.unique.ids = T)
#' }
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
  message(mdf.lines)
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


#' Write an MTrackJ Data File (`.mdf`)
#'
#' Writes a data.frame with tracking information as an MTrackJ Data File (`.mdf`)
#' file. Allows flexible column specification, and to avoid errors the column
#' mapping used for writing is reported back to the user. Writing tracking data in
#' 'id time x y z' format, for example, from the MotilityLab package, doesn't
#' require additional arguments.
#'
#' @family mdftracks functions
#'
#' @export
#'
#' @param x the data.frame with track information.
#' @param file either a character string naming a file or a connection open for
#' writing. "" indicates output to the console.
#' @param cluster.column index or name of the column that contains the cluster
#' ID.
#' @param id.column index or name of the column that contains the track
#' ID (either the id in the cluster or a unique id).
#' @param time.column index or name of the column that contains elapsed time
#' @param scale.time a value by which to multiply each time point. Useful for
#' changing units, or specifying the time between positions if the time is given
#' in frames.
#' @param pos.columns vector containing indices or names of the columns that
#' contain the spatial coordinates. If this vector has two entries, the data is
#' assumed to be 2D and the z coordinate is set to 1.0.
#' @param channel.column index or name of the column that contains channel
#' information. If there is no channel column `default.channel` will be used.
#' @param default.channel channel to be used if `channel.column` is not
#' specified.
#' @param point.column index or name of the column that contains point ID. If
#' there is no point column, points will be numbered automatically (**NB** points
#' are not necessarily the same as frames).
#' @param fileEncoding character string: if non-empty declares the encoding to
#' be used on a file (not a connection) so the character data can be re-encoded
#' as they are written. See [base::file()].
#'
#' @seealso [MTrackJ Data Format](https://imagescience.org/meijering/software/mtrackj/format/)
#'
#' @examples
#' \dontrun{
#' write.mdf(x, '~/mdftracks.mdf')
#'
#' # 2D data with column name specification
#' write.mdf(x, '~/mdftracks.mdf', id.column = 'uid', time.column = 't',
#'           pos.columns = letters[24:25])
#' }
#'
#' @importFrom utils capture.output
write.mdf <- function(x, file = "", cluster.column = NA, id.column = 1,
                      time.column = 2, scale.time = 1, pos.columns = c(3,4,5),
                      channel.column = NA, point.column = NA,
                      default.channel = 1, fileEncoding = "") {
  cn <- getColumnNames(colnames(x), cluster.column, id.column,
                              time.column, pos.columns, channel.column,
                              point.column)
  message.cn <- cn
  names(message.cn) <- c("cluster", "id", "time", letters[24:26], "channel",
                         "point")
  message(paste(c("Using the following column mapping:",
                  capture.output(message.cn)), collapse = '\n'))

  # Get rid of factor columns
  factor.columns <- sapply(x[ , cn[!is.na(cn)]], is.factor)
  if(any(factor.columns)) {
    # Get factor.column names
    fcn <- names(factor.columns[factor.columns == T])
    message(paste("Converting factor to numeric in columns:",
                  paste(fcn, collapse = ", ")))
    x[fcn] <- lapply(x[fcn], function(x) as.numeric(as.character(x)))
  }

  if(is.na(cn['cl'])) {
    cn['cl'] <- "cl"
    x[cn['cl']] <- 1
  }
  if(is.na(cn['ch'])) {
    cn['ch'] <- "ch"
    x[cn['ch']] <- default.channel
  }
  if(is.na(cn['z'])) {
    cn['z'] <- "z"
    x[cn['z']] <- 1
  }
  generate.points <- F
  if(is.na(cn['p'])) {
    generate.points <- T
    cn['p'] <- 'p'
  }

  # Connection stuff, stolen from write.table
  if (file == "")
    file <- stdout()
  else if (is.character(file)) {
    file <- if (nzchar(fileEncoding))
      file(file, "w", encoding = fileEncoding)
    else file(file, "w")
    on.exit(close(file))
  }
  if (!inherits(file, "connection"))
    stop("'file' must be a character string or connection")
  if (!isOpen(file, "w")) {
    open(file, "w")
    on.exit(close(file))
  }

  writeLines(sprintf(pkg.env$mtrackj.header, pkg.env$mtrackj.version), file,
             sep = '\n')
  writeLines("Assembly 1", file, sep = '\n')
  cluster.l <- split(x, x[cn['cl']])
  for(cluster in names(cluster.l)) {
    writeLines(sprintf("Cluster %d", as.numeric(cluster)), file, sep = '\n')
    track.l <- split(cluster.l[[cluster]], cluster.l[[cluster]][cn['id']])
    for(track in names(track.l)) {
      writeLines(sprintf("Track %d", as.numeric(track)), file, sep = '\n')
      track.data <- track.l[[track]]
      track.data <- track.data[order(track.data[cn['t']]), ]
      if(generate.points) {
        track.data[cn['p']] <- 1:nrow(track.data)
      }
      point.l <- split(track.data, track.data[cn['p']])
      for(point in names(point.l)) {
        pd <- point.l[[point]]
        writeLines(paste("Point", as.integer(point), pd[cn['x']],  pd[cn['y']],
                         pd[cn['z']],  pd[cn['t']] * scale.time, pd[cn['ch']]),
                   file, sep = '\n')
      }
    }
  }
  writeLines("End of MTrackJ Data File", file, sep = '\n')
}


# getMTrackJVersion <- function(mdf.lines) {
#   first.line.split <- strsplit(mdf.lines[[1]], " ")[[1]]
#   stopifnot(first.line.split[1] == "MTrackJ")
#   first.line.split[2]
# }

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
  as.data.frame(data.matrix(do.call(rbind, track.df.l)))
}


getColumnNames <- function(col.names, cluster.column = NA, id.column = 1,
                           time.column = 2, pos.columns = c(3,4,5),
                           channel.column = NA, point.column = NA) {
  if(length(pos.columns) < 3) {
    pos.columns <- c(pos.columns, rep(NA, 3 - length(pos.columns)))
  }
  col.args <- as.character(c(cluster.column, id.column, time.column,
                             pos.columns, channel.column, point.column))
  # Try to match the provided column names to the column names
  matched.col.names <- col.names[match(col.args, col.names)]
  # Try to match the provided column indices to the column indices
  matched.col.indices <- match(col.args, seq_len(length(col.names)))
  # Merge the 2 results: get names for the columns specified as index
  non.matched.col.names <- is.na(matched.col.names)
  matched.col.names[non.matched.col.names] <-
    col.names[matched.col.indices[non.matched.col.names]]
  # We only care about the columns that are not NA by default, however, if a
  # column is specified (not NA in col.args) it should match an existing column
  col.specified.not.matched <- !is.na(col.args) & is.na(matched.col.names)
  if (any(col.specified.not.matched)) {
    stop("Column(s) not found: ", paste(col.args[col.specified.not.matched],
                                        collapse = ","))
  }

  colnames.names <- c("cl", "id", "t", "x", "y", "z", "ch", "p")
  names(matched.col.names) <- colnames.names
  matched.col.names
}
