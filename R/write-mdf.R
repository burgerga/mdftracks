#' Write an MTrackJ Data File (`.mdf`)
#'
#' Writes a data.frame with tracking information as an MTrackJ Data File (`.mdf`)
#' file. Allows flexible column specification, and to avoid errors the column
#' mapping used for writing is reported back to the user. Writing tracking data in
#' 'id time x y z' format, for example, from the celltrackR package, doesn't
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
#' @seealso [celltrackR](https://github.com/ingewortel/celltrackR)
#'
#' @examples
#' \dontrun{
#' # Output to file
#' write.mdf(mdftracks.example.data, '~/example.mdf', id.column = 'uid',
#'           time.column = 't', pos.columns = letters[24:26])
#' }
#'
#' # Output to stdout with cluster column
#' write.mdf(mdftracks.example.data, cluster.column = 'cl',
#'           id.column = 'id', time.column = 't', pos.columns = letters[24:26])
#'
#' # Output to stdout using data in (id, t, x, y, z) format
#' write.mdf(mdftracks.example.data[, c('uid', 't', letters[24:26])])
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
      track.data <- track.data[sort.list(track.data[[cn['t']]]), ]
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
